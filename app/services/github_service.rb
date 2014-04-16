class GithubService
  attr_accessor :github, :token

  def initialize(token)
    @token = token
    @github = Github.new oauth_token: token
  end

  def get_organizations
    orgs = []
    organizations = github.orgs.list
    organizations.each_page do |page|
      page.each do |org|
        orgs << org
      end
    end

    orgs.sort_by { |org| org.name }
  end

  def get_pull_requests(repo, org, state)
    github.pull_requests.list(user: org, repo: repo, auto_pagination: true, state: state)
  end

  def get_members(organization)
    github.orgs.members.list(organization['login'], per_page: '100')
  end

  def get_repos(user)
    github.repos.list(user: user, per_page: '100')
  end

  def get_complete_repo(user, repo)
    github.repos.get(user, repo)
  end

end
