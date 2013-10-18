require 'test_helper'

class PropertyTest < ActiveSupport::TestCase

	context 'When creating properties, the system' do 
		setup do 
			PropertyValue.destroy_all
		end

		should 'automatically create a value-keeper' do 
			assert_difference 'PropertyValue.count' do 
				@property = Property.create(:name => "Ninja Count", :property_klazz => "Integer", :default_value => 1)
			end
			assert_equal PropertyValue.last[:value], 1
			assert_equal @property.default_value, 1
			assert_equal @property.default_value_id, @property.default_value_object.id.to_s
			assert_equal @property.property_klazz, "Integer"
		end

		should 'not create value-keepers if not persisting' do 
			assert_no_difference 'PropertyValue.count' do 
				@property = Property.create(:property_klazz => "Integer", :default_value => 1)				
			end
			assert @property.errors[:name].length, 1
		end

		should 'transparently handle assigning default value after creation but before save' do 
			assert_no_difference 'PropertyValue.count' do 
				@property = Property.create(:name => "Ninja Count")
			end
			assert_nil @property.default_value
			@property.default_value = "Monkey"			
			assert_difference 'PropertyValue.count' do 
				@property.save
			end
			assert_equal @property.default_value, 'Monkey'
			assert_equal @property.default_value_id, @property.default_value_object.id.to_s
		end		
	end

	context 'When deleting properties, the system' do 
		setup do 
			PropertyValue.destroy_all
		end

		should 'automatically remove value-objects' do 
			@property = Property.create(:name => "Ninja Count", :property_klazz => "Integer", :default_value => 1)
			assert_not_nil @property.default_value_object
			assert_difference 'PropertyValue.count', -1 do 
				@property.destroy
			end
		end
	end

end
