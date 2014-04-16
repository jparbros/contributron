class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :name
      t.string :homepage
      t.integer :member_id

      t.timestamps
    end
  end
end
