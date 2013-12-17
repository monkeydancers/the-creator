class AddIdentifierToGameobject < ActiveRecord::Migration
  def change
  	add_column :game_objects, :identifier, :string
  end
end
