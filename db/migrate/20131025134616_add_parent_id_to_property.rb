class AddParentIdToProperty < ActiveRecord::Migration
  def change
  	add_column :properties, :parent_id, :integer
  end
end
