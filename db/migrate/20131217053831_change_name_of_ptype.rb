class ChangeNameOfPtype < ActiveRecord::Migration
  def change
  	rename_column :properties, :property_type_definition, :category
  end
end
