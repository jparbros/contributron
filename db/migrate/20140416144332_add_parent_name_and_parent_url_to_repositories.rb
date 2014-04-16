class AddParentNameAndParentUrlToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :parent_name, :string
    add_column :repositories, :parent_url, :string
  end
end
