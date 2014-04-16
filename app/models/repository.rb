class Repository < ActiveRecord::Base

  belongs_to :member
  belongs_to :repository
  has_many :pull_requests


  scope :created, -> { where(state: 'created') }
  scope :errored, -> { where(state: 'created') }
  scope :done, -> { where(state: 'created') }

  state_machine :state, :initial => :created do
    event :process do
      transition [:created, :errored] => :processing
    end

    event :error do
      transition :processing => :errored
    end

    event :finish do
      transition :processing => :done
    end
  end

  def process_pull_requests(token)
    self.process!
    begin
      complete_repo = get_complete_repo self.member.name, self.name, token

      pull_requests = []
      open_pull_requests = get_pull_requests(complete_repo['parent']['name'], complete_repo['parent']['owner']['login'], 'open', token )
      pull_requests = pull_requests + open_pull_requests.select{|pull| pull['user'] && pull['user']['login'] == self.member.name }

      closed_pull_requests = get_pull_requests(complete_repo['parent']['name'], complete_repo['parent']['owner']['login'], 'closed', token )

      pull_requests = pull_requests + closed_pull_requests.select{|pull| pull['user'] && pull['user']['login'] == self.member.name }


      Rails.logger.info "#{member.name} fork: #{complete_repo['parent']['full_name']} - PRs: #{pull_requests.size}"

      unless pull_requests.empty?
        pull_requests.each do |pull|
          member.pull_requests.where(url: pull['html_url'], title: pull['title'], state: pull['state'], repository_id: self.id).first_or_create
        end
      end
    rescue => e
      self.error!
      message = ""
      message << e.message
      message << e.backtrace.join("\n")
      errors[:error] = message
      Rails.logger.info message
    end
    self.finish! if errors.empty?
    if self.member.organization.repositories.created.size == 0
      NotificationMailer.notify_user(self.member.organization).deliver
    end
  end


  private

    def get_pull_requests(repo, org, state, token)
      GithubService.new(token).get_pull_requests(repo, org, state)
    end

    def get_complete_repo(user, repo, token)
      GithubService.new(token).get_complete_repo(user, repo)
    end
end
