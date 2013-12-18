class AddDescriptionToGameObjects < ActiveRecord::Migration
  def change
  	add_column :game_objects, :description, :text
  end
end
