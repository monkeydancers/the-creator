class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
    	t.string		:name
    	t.text			:description
    	t.text			:rule_code
    	t.integer		:game_id    	
      t.timestamps
    end
  end
end
