class DashboardController < ApplicationController

  before_filter :authenticate!

  def index
    organizations = get_organization
    organizations.each do |org|
      organization  = current_user.organizations.where(name: org['login'], avatar: org['avatar']).first_or_create
      members = get_members org

      members.each do |member|
        organization.members.where(name: member['login'],
                                   avatar: member['avatar_url'],
                                   profile: member['received_events_url'] ).first_or_create
      end
    end
    @organizations = current_user.organizations
  end

  def show
    @organization = Organization.find params[:org_id]

    if current_user.organizations.where("state like 'done' OR state like 'processing'").size > 0
      flash[:alert] = "You can only process one organization"
    elsif @organization.state == 'created'
      ProcessWorker.perform_async params[:org_id], session[:user_token]
      message = "Give us some time we're processing your organization"
    end

    flash[:notice] = message

  end


  private

    def get_organization
      GithubService.new(session[:user_token], current_user).get_organizations
    end

    def get_members(org)
      GithubService.new(session[:user_token], current_user).get_members(org)
    end
end
