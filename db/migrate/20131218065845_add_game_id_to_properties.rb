class AddGameIdToProperties < ActiveRecord::Migration
  def change
  	add_column :properties, :game_id, :integer
  end
end
