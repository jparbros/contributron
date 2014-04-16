class PullRequest < ActiveRecord::Base

  belongs_to :repository
  belongs_to :member

end
