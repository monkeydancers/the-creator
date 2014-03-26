class AddParentKeyToClassTree < ActiveRecord::Migration
  def change
  	add_column :game_object_classes, :parent_key, :string
  end
end
