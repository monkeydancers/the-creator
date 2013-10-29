require 'test_helper'

class StringPropertyTest < ActiveSupport::TestCase

	context 'When creating StringProperties, the system' do 
		setup do 
			$redis = Redis.new
		end

		should 'return a new instance if passed nil' do 
			ps = StringProperty.fetch(nil)
			assert ps.is_a?(StringProperty)
			assert_nil ps.value
			assert_nil ps.default_value
			assert_equal ps.stem, 'str'
		end
	end

	context 'StringProperty' do 
		should 'only be able to contain strings' do 
			assert_equal StringProperty.definition_class, String
		end

		should 'not be able to set property_klazz' do 
			assert !StringProperty.can_set_property_klazz?
		end	

		should 'not auto-assign identifiers if required' do 
			instance = StringProperty.new
			assert_nil instance.id
		end

		should 'assign property at save if required' do 
			instance = StringProperty.new(:value => "monkey", :default_value => "troll")
			assert_nil instance.id
			instance.save
			assert_not_nil instance.id
		end
	end

	context 'When retrieving instances of StringProperty, the system' do 
		setup do 
			$redis.hmset "monkey-id", :value, "test", :default_value, "monkey"
		end

		should 'return a loaded instance' do 
			property = StringProperty.fetch("monkey-id")
			assert property.is_a?(StringProperty)
			assert_equal property.value, "test"
			assert_equal property.default_value, "monkey"			
		end

		should 'support forced reloading' do 
			property = StringProperty.fetch("monkey-id")
			assert_equal property.value, "test"			
			$redis.hset "monkey-id", :value, "hugo"
			assert_equal property.value, "test"			
			property.reload
			assert_equal property.value, "hugo"
		end
	end

end
