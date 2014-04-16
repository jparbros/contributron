class ProcessWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(organization_id)
    organization = Organization.find params[:org_id]
    organization.start_bulk
  end
end