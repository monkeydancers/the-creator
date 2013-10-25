class CreateGameObjects < ActiveRecord::Migration
  def change
    create_table :game_objects do |t|
    	t.string			:name
    	t.integer			:object_class_id
    	t.integer			:game_id
      t.timestamps
    end
  end
end
