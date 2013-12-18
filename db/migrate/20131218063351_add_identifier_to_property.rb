class AddIdentifierToProperty < ActiveRecord::Migration
  def change
  	add_column :properties, :identifier, :string
  end
end
