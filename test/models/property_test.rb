require 'test_helper'

class PropertyTest < ActiveSupport::TestCase

	context 'When creating a property, the system' do 
		setup do 
			$redis = Redis.new
			$redis.flushall
		end

		should 'keep a local copy of value until explicitly saved' do 
			assert_equal $redis.keys("*").length, 0
			p = Property.new(:name => "Monkey", :category =>  :string, :default_value => "laser")
			assert_equal $redis.keys("*").length, 0
			assert_equal p.default_value, "laser"			
		end

		should 'persist a value to Redis when explicitly saved' do 
			p = Property.new(:name => "Monkey", :category => :string, :default_value => "laser")
			assert_nil p.value_id
			p.save
			assert_not_nil p.value_id
			assert_equal $redis.keys("*").length, 1
			p.reload
			assert_equal p.default_value, "laser"
		end

		should 'not persist to redis if saving of property fails' do 
			assert_equal $redis.keys("*").length, 0
			p = Property.new(:name => nil, :category => :string, :default_value => "laser")
			p.save
			assert !p.persisted? 
			assert_equal $redis.keys("*").length, 0
		end

		should 'properly handle stacked failed calls' do 
			p = Property.new(:name => nil, :category => :string, :default_value => "laser")
			p.save
			p.save
			assert_equal $redis.keys("*").length, 0			
			assert !p.persisted?
		end	

		should 'require a property name' do 
			p = Property.new(:name => nil, :category => :string, :default_value => "laser")
			p.save
			assert_not_empty p.errors[:name]
			assert !p.persisted?
			p.name = "Bongo"
			p.save
			assert p.persisted?
			assert_empty p.errors[:name]
		end
	end

	context 'When cloning properties, the system' do 
		setup do 
			@property = Property.create(:name => "Monkey", :category => :string, :default_value => "laser")
		end

		should 'support cloning the property' do 
			p2 = @property.clone
			assert_equal p2.name, @property.name
			assert_equal p2.property_klazz, @property.property_klazz
			assert_equal p2.category, @property.category
			assert_equal p2.parent_id, @property.id
			assert_equal p2.default_value, @property.value
		end

		should 'not allow cloning unpersisted properties' do 
			p1 = Property.new(:name => "Monkey")
			assert_raise ArgumentError do 
				p2 = p1.clone
			end
		end
	end

end
