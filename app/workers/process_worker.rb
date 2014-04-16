class ProcessWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(organization_id, token)
    organization = Organization.find organization_id
    organization.start_bulk(token)
  end
end