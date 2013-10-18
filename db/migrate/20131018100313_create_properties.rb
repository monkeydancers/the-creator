class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
    	t.string 		:name
    	t.integer		:game_object_class_id
    	t.string		:default_value_id
    	t.string		:property_klazz    	    	
      t.timestamps
    end
  end
end
