class Member < ActiveRecord::Base

  belongs_to :organization
  has_many :repositories
  has_many :pull_requests

end
