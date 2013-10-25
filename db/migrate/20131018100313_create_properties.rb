class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
    	t.string 		:name
    	t.integer		:game_object_class_id
    	t.string 		:property_type_definition
    	t.string		:property_klazz 	
    	t.string		:value_id
      t.timestamps
    end
  end
end