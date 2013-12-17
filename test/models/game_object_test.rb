require 'test_helper'

class GameObjectTest < ActiveSupport::TestCase

	context 'When creating game objects, the system' do
		setup do
			@parent_class = GameObjectClass.create(:name => "Ninja")
			@property1 = @parent_class.properties.create(:name => "Mana", :category => :string, :value => "monkey", :default_value => "laser")

			@child_class = GameObjectClass.create(:name => "Death Ninja", :parent => @parent_class)
			@property2 = @child_class.properties.create(:name => "Ninja Stars", :category => :numeric, :value => 10, :default_value => 5)
		end

		should 'create the correct set of properties' do 
			ninja = @parent_class.game_objects.create(:name => "Ninja")
			assert_equal ninja.properties.length, 1
			assert_equal ninja.properties.first.name, @property1.name

			death_ninja = @child_class.game_objects.create(:name => "Svart Ninja")
			assert_equal death_ninja.properties.length, 2
			assert_equal death_ninja.properties.first.name, @property2.name
			assert_equal death_ninja.properties.last.name, @property1.name
		end

	end

end
