class Organization < ActiveRecord::Base

  has_many :members
  has_many :repositories, through: :members
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

  def start_bulk(token)
    self.process!
    begin
      self.members.each do |member|
        reposotories = get_repos member.name, token
        reposotories.each do |repo|
          if repo['fork'] == true
            repository = member.repositories.where(name: repo['name'],
                                               homepage: repo['html_url']).first_or_create

            PullRequestsWorker.perform_async(repository.id, token)

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
  end

  private

    def get_repos(user, token)
      GithubService.new(token).get_repos(user)
    end

end
