class AddStateToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :state, :string
  end
end
