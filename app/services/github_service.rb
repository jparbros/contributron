class GithubService
  attr_accessor :github, :token, :user

  def initialize(token, user)
    @user = user
    @token = token
    @github = Github.new oauth_token: token
  end

  def get_organizations
    orgs = []

    organizations = github.orgs.list

    organizations.each_page do |page|
      page.each do |org|
        members = github.orgs.members.list(org['login'], per_page: '100').map(&:login)
        user_org = user.organizations.where(name: org['login'], avatar: org['avatar']).first_or_initialize
        user_org.update_attribute(:members, members) if user_org.new_record?
        orgs << user_org
      end
    end

    orgs.sort_by { |org| org.name }
  end

  def get_pull_requests(organization,repo, org, state)
    pull_requests = github.pull_requests.list(user: org, repo: repo, auto_pagination: true, state: state)
    pull_requests.select{|pull| organization.members.include? pull.try(:user).try(:login) }
  end

end
