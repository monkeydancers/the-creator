require 'test_helper'

class NumericPropertyTest < ActiveSupport::TestCase

	context 'When creating NumericProperties, the system' do 
		setup do 
			$redis = Redis.new
		end

		should 'return a new instance if passed nil' do 
			ps = NumericProperty.fetch(nil)
			assert ps.is_a?(NumericProperty)
			assert_equal ps.value, 0
			assert_equal ps.default_value,0
			assert_equal ps.stem, 'num'
		end
	end

	context 'NumericProperty' do 
		should 'only be able to contain strings' do 
			assert_equal NumericProperty.definition_class, Integer
		end

		should 'be able to set property_klazz' do 
			assert NumericProperty.can_set_property_klazz?
		end	

		should 'not auto-assign identifiers if required' do 
			instance = NumericProperty.new
			assert_nil instance.id
		end

		should 'assign property at save if required' do 
			instance = NumericProperty.new(:value => 5, :default_value => 6)
			assert_nil instance.id
			instance.save
			assert_not_nil instance.id
		end
	end

	context 'When retrieving instances of NumericProperty, the system' do 
		setup do 
			$redis.hmset "monkey-id", :value, 4, :default_value, 5
		end

		should 'return a loaded instance' do 
			property = NumericProperty.fetch("monkey-id")
			assert property.is_a?(NumericProperty)
			assert_equal property.value, 4
			assert_equal property.default_value, 5
		end

		should 'support forced reloading' do 
			property = NumericProperty.fetch("monkey-id")
			assert_equal property.value, 4			
			$redis.hset "monkey-id", :value, 3
			assert_equal property.value, 4			
			property.reload
			assert_equal property.value, 3
		end
	end

end