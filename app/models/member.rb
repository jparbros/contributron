class Member < ActiveRecord::Base

  belongs_to :organization
  has_many :repositories
  has_many :pull_requests

  scope :ranked, -> { select("members.id, members.name, members.profile, members.avatar, count(pull_requests.id) AS pr_count").
                      joins(:pull_requests).where("pull_requests.state like 'closed'").
                      group("members.id").
                      order("pr_count DESC") }


  def closed_pull_requests_count
    pull_requests.map{|pull| pull.state == 'closed'}.size
  end

end
