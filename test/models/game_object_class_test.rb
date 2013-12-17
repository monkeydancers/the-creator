require 'test_helper'

class GameObjectClassTest < ActiveSupport::TestCase

	context 'When creating instances of GameObjectClass, the system' do 
		should 'support creating inheritance chains' do 
			parent_class = GameObjectClass.create(:name => "Ninja")
			assert parent_class.valid? 
			assert_nil parent_class.parent

			child_class = GameObjectClass.create(:name => "Death Ninja", :parent => parent_class)
			assert child_class.valid? 
			assert_equal child_class.parent, parent_class
		end

		should 'generate an identifier for every instance' do 
			parent_class = GameObjectClass.create(:name => "Ninja")
			assert_not_nil parent_class.identifier
			assert_equal parent_class.identifier.length, 7
		end
	end

	context 'When settings properties on GameObjectClasses, the system' do 
		should 'support basic property creation' do 
			object_class = GameObjectClass.create(:name => "Death Ninja")
			property = object_class.properties.create(:name => "Mana", :category => :string, :value => "monkey", :default_value => "laser")
			assert property.valid?
			assert_equal object_class.property_list, [property]
		end

		should 'support property inheritance' do 
			parent_class = GameObjectClass.create(:name => "Ninja")
			property1 = parent_class.properties.create(:name => "Mana", :category => :string, :value => "monkey", :default_value => "laser")

			child_class = GameObjectClass.create(:name => "Death Ninja", :parent => parent_class)
			property2 = child_class.properties.create(:name => "Ninja Stars", :category => :numeric, :value => 10, :default_value => 5)

			assert_equal child_class.property_list(:inherited => true).to_a, [property2, property1]
		end
	end


end
