class RemoveMembersFromOrganizations < ActiveRecord::Migration
  def change
    remove_column :organizations, :members
  end
end
