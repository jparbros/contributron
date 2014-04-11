class Organization < ActiveRecord::Base
  serialize :members, Array

  belongs_to :user


end
