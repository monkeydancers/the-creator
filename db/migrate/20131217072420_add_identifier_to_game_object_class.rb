class AddIdentifierToGameObjectClass < ActiveRecord::Migration
  def change
  	add_column :game_object_classes, :identifier, :string
  end
end
