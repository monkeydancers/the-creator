require 'test_helper'

class MultiObjectPropertyTest < ActiveSupport::TestCase

	context 'When creating MultiObjectProperties, the system' do 
		setup do 
			@game = Game.create(:name => "Test Game")
			game_object_class = GameObjectClass.create(:name => "Ninja")
			@game_object = game_object_class.game_objects.create(:name => "Monkey Master", :game_id => @game.id)	
			@game_object2 = game_object_class.game_objects.create(:name => "Monkey Minion", :game_id => @game.id)			
		end

		should 'return a new instance if passed nil' do 
			sop = MultiObjectProperty.fetch(nil)
			assert sop.is_a?(MultiObjectProperty)
			assert_nil sop.value
			assert_nil sop.default_value
			assert_equal sop.stem, 'mio'
		end
	end

	context 'MultiObjectProperties' do 
		setup do 
			@game = Game.create(:name => "Test Game")
			game_object_class = GameObjectClass.create(:name => "Ninja")
			@game_object = game_object_class.game_objects.create(:name => "Monkey Master", :game_id => @game.id)		
			@game_object2 = game_object_class.game_objects.create(:name => "Monkey Minion", :game_id => @game.id)				
		end

		should 'only be able to contain instances of GameObject' do 
			assert_equal MultiObjectProperty.definition_class, GameObject
		end

		should 'not auto-assign identifiers if required' do 
			instance = MultiObjectProperty.new
			assert_nil instance.id
		end

		should 'assign property at save if required' do 
			instance = MultiObjectProperty.new(:value => @game_object, :default_value => @game_object)
			assert_nil instance.id
			instance.save
			assert_not_nil instance.id
		end
	end

	context 'When retrieving instances of MultiObjectProperty, the system' do 
		setup do 
			@game = Game.create(:name => "Test Game")
			game_object_class = GameObjectClass.create(:name => "Ninja")
			@game_object = game_object_class.game_objects.create(:name => "Monkey Master", :game_id => @game.id)			
			@game_object2 = game_object_class.game_objects.create(:name => "Monkey Minion", :game_id => @game.id)

			$redis.rpush('monkey-value', @game_object.identifier)
			$redis.rpush('monkey-default-value', @game_object2.identifier)
		end

		should 'return a loaded instance' do 
			property = MultiObjectProperty.fetch("monkey")
			assert property.is_a?(MultiObjectProperty)
			assert_equal property.value, [@game_object]
			assert_equal property.default_value, [@game_object2]
		end

		should 'support forced reloading' do 
			property = MultiObjectProperty.fetch("monkey")
			assert_equal property.value, [@game_object]
			$redis.del('monkey-value')
			$redis.rpush('monkey-value', @game_object2.identifier)
			assert_equal property.value, [@game_object]
			property.reload
			assert_equal property.value, [@game_object2]
		end		
	end

	context 'When setting values on MultiObjectProperty, the system' do 
		setup do 
			game = Game.create(:name => "Test Game")
			game_object_class = GameObjectClass.create(:name => "Ninja")
			@property = game_object_class.properties.create(:name => 'Backpack', :category => :multi_object, :game_id => game.id)
			@game_object = game_object_class.game_objects.create(:name => "Monkey Master", :game_id => game.id)			
			@game_object2 = game_object_class.game_objects.create(:name => "Monkey Minion", :game_id => game.id)
		end

		should 'add new objects instead of overwriting' do 
			assert_equal @property.value, nil
			@property.value = @game_object
			@property.save
			@property.reload
			assert_equal @property.value, [@game_object]
			assert_equal @property.value.length, 1
			@property.value = @game_object2
			@property.save
			@property.reload
			assert_equal @property.value.length, 2
			assert_equal @property.value, [@game_object, @game_object2]
		end
	end

end