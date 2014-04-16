class PullRequestsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(repository_id, token)
    repository = Repository.find repository_id
    repository.process_pull_requests(token)
  end
end