class CreateGameObjectClasses < ActiveRecord::Migration
  def change
    create_table :game_object_classes do |t|
    	t.string 					:name
    	t.integer					:parent_id
    	t.integer 				:game_id
    	
      t.timestamps
    end
  end
end
