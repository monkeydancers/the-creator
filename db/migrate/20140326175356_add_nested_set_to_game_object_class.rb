class AddNestedSetToGameObjectClass < ActiveRecord::Migration
  def change
  	add_column :game_object_classes, :lft, :integer
  	add_column :game_object_classes, :rgt, :integer
  end
end
