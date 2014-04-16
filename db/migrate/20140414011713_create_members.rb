class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :name
      t.string :profile
      t.string :avatar
      t.integer :pull_requests_count

      t.timestamps
    end
  end
end
