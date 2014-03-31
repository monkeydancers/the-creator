require 'test_helper'

class GameObjectClassTest < ActiveSupport::TestCase

	context 'When creating instances of GameObjectClass, the system' do 
		should 'support creating inheritance chains' do 
			@game 	= Game.create(:name => "Test Game")
			parent_class = @game.game_object_classes.create(:name => "Ninja")
			assert parent_class.valid? 
			assert_nil parent_class.parent

			child_class = @game.game_object_classes.create(:name => "Death Ninja", :parent => parent_class)
			assert child_class.valid? 
			assert_equal child_class.parent, parent_class
		end

		should 'generate an identifier for every instance' do 
			@game 	= Game.create(:name => "Test Game")
			parent_class = @game.game_object_classes.create(:name => "Ninja")
			assert_not_nil parent_class.identifier
			assert_equal parent_class.identifier.length, 7
		end
	end

	context 'When settings properties on GameObjectClasses, the system' do 
		setup do 
			@game = Game.create(:name => "Test Game")
		end

		should 'support basic property creation' do 
			object_class = @game.game_object_classes.create(:name => "Death Ninja")
			property = object_class.properties.create(:name => "Mana", :category => :string, :value => "monkey", :default_value => "laser", :game_id => @game.id)
			assert property.valid?
			assert_equal object_class.property_list, [property]
		end

		should 'support property inheritance' do 
			parent_class = @game.game_object_classes.create(:name => "Ninja")
			property1 = parent_class.properties.create(:name => "Mana", :category => :string, :value => "monkey", :default_value => "laser", :game_id => @game.id)

			child_class = @game.game_object_classes.create(:name => "Death Ninja", :parent => parent_class)
			property2 = child_class.properties.create(:name => "Ninja Stars", :category => :numeric, :value => 10, :default_value => 5, :game_id => @game.id)

			assert_equal child_class.property_list(:inherited => true).to_a, [property2, property1]
		end
	end

	context 'When rendering a GameObjectClass as a list, the system' do 
		setup do 
			@game = Game.create(:name => "Test Game")

			@parent_class = @game.game_object_classes.create(:name => "Ninja")
			assert @parent_class.valid? 
			assert_nil @parent_class.parent

			child_class = @game.game_object_classes.create(:name => "Death Ninja", :parent => @parent_class)
			assert child_class.valid? 
			assert_equal child_class.parent, @parent_class
		end
	end

	context "When creating game object classes, the nested set model" do 
		setup do 
			@game = Game.create(:name => "Test Game")			
		end

		should 'properly handle root classes' do 
			klazz = @game.game_object_classes.create(:name => "Hero")
			assert_nil klazz.lft
			assert_nil klazz.rgt
		end

		should 'properly handle class creation' do 
			klazz 		= GameObjectClass.create(:name => "Hero", :game => @game)
			subklazz 	= klazz.children.create(:name => "Knight", :game => @game)
			klazz.reload
			subklazz.reload
			assert_equal klazz.lft, 0
			assert_equal klazz.rgt, 3
			assert_equal subklazz.lft, 1
			assert_equal subklazz.rgt, 2
		end

		should 'handle N-level deep nesting of classes' do 
			root = @game.game_object_classes.create(:name => "Villain", :game => @game)
			subklazz1 = root.children.create(:name => "Ninja", :game => @game)
			subklazz2 = subklazz1.children.create(:name => "Foot Clan", :game => @game)
			[root, subklazz1, subklazz2].each{|gc| gc.reload }
			assert_equal root.lft, 0
			assert_equal root.rgt, 5
			assert_equal subklazz2.lft, 2
			assert_equal subklazz2.rgt, 3
			assert_equal subklazz1.lft, 1
			assert_equal subklazz1.rgt, 4
		end

		should 'provide efficient tree-based children-count' do 
			root = @game.game_object_classes.create(:name => "Villain", :game => @game)
			subklazz1 = root.children.create(:name => "Ninja", :game => @game)
			subklazz2 = subklazz1.children.create(:name => "Foot Clan", :game => @game)
			[root, subklazz1, subklazz2].each{|gc| gc.reload }

			root.game_objects.create(:name => "The Joker", :game => @game)
			subklazz1.game_objects.create(:name => "Shinobin", :game => @game)
			subklazz1.game_objects.create(:name => "Ninja #2", :game => @game)
			subklazz2.game_objects.create(:name => "Foot Clan 1", :game => @game)

			assert_equal root.full_stack_child_count, 4
			assert_equal subklazz1.full_stack_child_count, 3
			assert_equal subklazz2.full_stack_child_count, 1
		end

	end

end