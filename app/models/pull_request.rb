class PullRequest < ActiveRecord::Base

  belongs_to :repository
  belongs_to :member

  scope :closed, -> { where(state: 'closed') }
  scope :open, -> { where(state: 'open') }

end
