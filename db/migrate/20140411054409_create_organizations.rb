class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :avatar
      t.string :members
      t.integer :user_id

      t.timestamps
    end
  end
end
