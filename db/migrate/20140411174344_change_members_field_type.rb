class ChangeMembersFieldType < ActiveRecord::Migration
  def change
    change_column :organizations, :members, :text
  end
end
