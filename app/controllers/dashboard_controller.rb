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
    @repo = params['ext_repo']
    @org = params['ext_org']
    @organization.members.each do |member|
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

          pull_requests.each do |pull|
            member.pull_requests.where(url: pull['html_url'], title: pull['title'], state: pull['state']).first_or_create
          end

          unless pull_requests.empty?
            member.repositories.where(name: complete_repo['parent']['full_name'],
                                      homepage: complete_repo['parent']['html_url']).first_or_create
          end
        end
      end
    end

  end

  def load_closed
    @organization = Organization.find params[:org_id]
    @repo = params['ext_repo']
    @org = params['ext_org']
    @close_pull_requests = get_pull_requests @organization, @repo, @org, 'closed'
    #    pull_requests.select{|pull| organization.members.include? pull.try(:user).try(:login) }

    respond_to do |format|
      format.json { render json: @close_pull_requests }
    end
  end

  private

  def get_organization
    GithubService.new(session[:user_token], current_user).get_organizations
  end

  def get_pull_requests(repo, org, state)
    GithubService.new(session[:user_token], current_user).get_pull_requests(repo, org, state)
  end

  def get_members(org)
    GithubService.new(session[:user_token], current_user).get_members(org)
  end

  def get_repos(user)
    GithubService.new(session[:user_token], current_user).get_repos(user)
  end

  def get_complete_repo(user, repo)
    GithubService.new(session[:user_token], current_user).get_complete_repo(user, repo)
  end

end
