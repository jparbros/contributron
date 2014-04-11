class DashboardController < ApplicationController

  before_filter :authenticate!

  def index
    @organizations = get_organization
  end

  def show
    @organization = Organization.find params[:org_id]
    @repo = params['ext_repo']
    @org = params['ext_org']
    @open_pull_requests = get_pull_requests @organization, @repo, @org, 'open'
  end

  def load_closed
    @organization = Organization.find params[:org_id]
    @repo = params['ext_repo']
    @org = params['ext_org']
    @close_pull_requests = get_pull_requests @organization, @repo, @org, 'closed'
    respond_to do |format|
      format.json { render json: @close_pull_requests }
    end
  end

  private

  def get_organization
    GithubService.new(session[:user_token], current_user).get_organizations
  end

  def get_pull_requests(organization, repo, org, state)
    GithubService.new(session[:user_token], current_user).get_pull_requests(organization, repo, org, state)
  end

end
