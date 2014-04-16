class Repository < ActiveRecord::Base

  belongs_to :member
  has_many :pull_requests
end
