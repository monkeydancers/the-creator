require 'test_helper'

class SingleObjectPropertyTest < ActiveSupport::TestCase

	context 'When creating SingleObjectProperties, the system' do 
		setup do 
			game_object_class = GameObjectClass.create(:name => "Ninja")
			@game_object = game_object_class.game_objects.create(:name => "Monkey Master")			
		end

		should 'return a new instance if passed nil' do 
			sop = SingleObjectProperty.fetch(nil)
			assert sop.is_a?(SingleObjectProperty)
			assert_nil sop.value
			assert_nil sop.default_value
			assert_equal sop.stem, 'sio'
		end
	end

	context 'SingleObjectProperties' do 
		setup do 
			game_object_class = GameObjectClass.create(:name => "Ninja")
			@game_object = game_object_class.game_objects.create(:name => "Monkey Master")			
		end

		should 'only be able to contain instances of GameObject' do 
			assert_equal SingleObjectProperty.definition_class, GameObject
		end

		should 'not auto-assign identifiers if required' do 
			instance = SingleObjectProperty.new
			assert_nil instance.id
		end

		should 'assign property at save if required' do 
			instance = SingleObjectProperty.new(:value => @game_object, :default_value => @game_object)
			assert_nil instance.id
			instance.save
			assert_not_nil instance.id
		end
	end

	context 'When retrieving instances of SingleObjectProperty, the system' do 
		setup do 
			game_object_class = GameObjectClass.create(:name => "Ninja")
			@game_object = game_object_class.game_objects.create(:name => "Monkey Master")			
			@game_object2 = game_object_class.game_objects.create(:name => "Monkey Minion")
			$redis.hmset "monkey-id", :value, @game_object.identifier, :default_value, @game_object2.identifier
		end

		should 'return a loaded instance' do 
			property = SingleObjectProperty.fetch("monkey-id")
			assert property.is_a?(SingleObjectProperty)
			assert_equal property.value, @game_object
			assert_equal property.default_value, @game_object2
		end

		should 'support forced reloading' do 
			property = SingleObjectProperty.fetch("monkey-id")
			assert_equal property.value, @game_object			
			$redis.hset "monkey-id", :value, @game_object2.identifier
			assert_equal property.value, @game_object			
			property.reload
			assert_equal property.value, @game_object2
		end
	end
	
end