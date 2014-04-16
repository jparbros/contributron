class Organization < ActiveRecord::Base

  has_many :members
  belongs_to :user

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

  def start_bulk
    self.process!
    begin
      self.members.each do |member|
        reposotories = get_repos member.name
        reposotories.each do |repo|
          if repo['fork'] == true

            complete_repo = get_complete_repo member.name, repo['name']

            pull_requests = []
            open_pull_requests = get_pull_requests(complete_repo['parent']['name'], complete_repo['parent']['owner']['login'], 'open' )
            pull_requests = pull_requests + open_pull_requests.select{|pull| pull['user'] && pull['user']['login'] == member.name }

            closed_pull_requests = get_pull_requests(complete_repo['parent']['name'], complete_repo['parent']['owner']['login'], 'closed' )

            pull_requests = pull_requests + closed_pull_requests.select{|pull| pull['user'] && pull['user']['login'] == member.name }


            Rails.logger.info "#{member.name} fork: #{complete_repo['parent']['full_name']} - PRs: #{pull_requests.size}"

            unless pull_requests.empty?
              repository = member.repositories.where(name: complete_repo['parent']['full_name'],
                                        homepage: complete_repo['parent']['html_url']).first_or_create

              pull_requests.each do |pull|
                member.pull_requests.where(url: pull['html_url'], title: pull['title'], state: pull['state'], repository_id: repository.id).first_or_create
              end
            end
          end
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
    NotificationMailer.notify_user(self).deliver
  end

  private

    def get_pull_requests(repo, org, state)
      GithubService.new(session[:user_token], current_user).get_pull_requests(repo, org, state)
    end

    def get_repos(user)
      GithubService.new(session[:user_token], current_user).get_repos(user)
    end

    def get_complete_repo(user, repo)
      GithubService.new(session[:user_token], current_user).get_complete_repo(user, repo)
    end

end
