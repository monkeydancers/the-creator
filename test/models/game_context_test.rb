require 'test_helper'

class GameContextTest < ActiveSupport::TestCase

	context 'When creating game objects, the system' do
		setup do
			@game = Game.create(:name => "Monkey Game")

			@item_class	 	= @game.game_object_classes.create(:name => "Item")
			@item1 				= @item_class.game_objects.create(:name => "Shaolin Spade", :game => @game)
			@item2 				= @item_class.game_objects.create(:name => "First Aid Kit", :game => @game)

			@parent_class = @game.game_object_classes.create(:name => "Ninja")
			@property1 = @parent_class.properties.create(:name => "Mana", :category => :string, :value => "monkey", :default_value => "laser", :game_id => @game.id)
			@property3 = @parent_class.properties.create(:name => "Weapon", :category => :object, :game_id => @game.id)
			@property4 = @parent_class.properties.create(:name => "Backpack", :category => :multi_object, :game_id => @game.id)

			@child_class = @game.game_object_classes.create(:name => "Death Ninja", :parent => @parent_class)
			@property2 = @child_class.properties.create(:name => "Ninja Stars", :category => :numeric, :value => 10, :default_value => 5, :game_id => @game.id)

			@game_object_1 = @parent_class.game_objects.create(:name => "Shinobin", :game => @game)
			@game_object_2 = @child_class.game_objects.create(:name => "Shinobin", :game => @game)

			@engine = Engine.new(@game)
		end

		should 'support fetching game objects by id' do 
			object_id = @engine.run(%{d = Ninja.find(#{@game_object_1.id}); d.identifier})
			assert_equal object_id, @game_object_1.identifier
		end

		should 'support loading names properly' do 
			object_name = @engine.run(%{d = Ninja.find(#{@game_object_1.id}); d.name})
			assert_equal object_name, @game_object_1.name
		end

		should 'support editing certain object-data' do 
			@engine.run(%{d = Ninja.find(#{@game_object_1.id}); d.name = 'Monkey Ninja'; d.save})
			@game_object_1.reload
			assert_equal @game_object_1.name, 'Monkey Ninja'
		end

		should 'support setting string properties' do 
			property = @game_object_1.properties.where(["parent_id = ?", @property1.id]).first
			assert_equal property.value, ''
			@engine.run(%{
				ninja = Ninja.find(#{@game_object_1.id}); 
				ninja.mana = "roligt"; 
			})
			property.reload
			assert_equal property.value, 'roligt'
		end

		should 'support setting single object properties' do 
			@engine.run(%{
				spade = Item.find(#{@item1.id}); 
				ninja = Ninja.find(#{@game_object_1.id}); 
				ninja.weapon.push(spade)
			})
			@game_object_1.reload
			property = @game_object_1.properties.where(["parent_id = ?", @property3.id]).first
			assert_equal property.value_description, @item1.name
		end

		should 'support deleting single object properties' do 
			property = @game_object_1.properties.where(["parent_id = ?", @property3.id]).first
			assert_equal property.value_description, 'No object'
			@engine.run(%{
				spade = Item.find(#{@item1.id}); 
				ninja = Ninja.find(#{@game_object_1.id}); 
				ninja.weapon.push(spade)
			})
			property.reload
			assert_equal property.value_description, @item1.name
			@engine.run(%{
				ninja = Ninja.find(#{@game_object_1.id}); 
				ninja.weapon.remove(); 
			})
			property.reload
			assert_equal property.value_description, 'No object'
		end

		should 'support setting multi object properties' do 
			property = @game_object_1.properties.where(["parent_id = ?", @property4.id]).first
			assert_equal property.value_description, '0 objects'
			@engine.run(%{
				ninja = Ninja.find(#{@game_object_1.id}); 
				ninja.backpack.push(Item.find(#{@item1.id})); 
				ninja.backpack.push(Item.find(#{@item2.id})); 
			})
			property.reload
			assert_equal property.value_description, "2 objects"
		end

		should 'support removing objects from multi-object properties' do 
			property = @game_object_1.properties.where(["parent_id = ?", @property4.id]).first
			assert_equal property.value_description, '0 objects'
			@engine.run(%{
				ninja = Ninja.find(#{@game_object_1.id}); 
				ninja.backpack.push(Item.find(#{@item1.id})); 
				ninja.backpack.push(Item.find(#{@item2.id})); 
			})
			property.reload
			assert_equal property.value_description, "2 objects"
			@engine.run(%{
				ninja = Ninja.find(#{@game_object_1.id}); 
				ninja.backpack.remove(Item.find(#{@item1.id}))
			})			
			property.reload
			assert_equal property.value_description, "1 objects"
		end

		should 'support removing objects from multi-object properties by keyword' do 
			property = @game_object_1.properties.where(["parent_id = ?", @property4.id]).first
			assert_equal property.value_description, '0 objects'
			@engine.run(%{
				ninja = Ninja.find(#{@game_object_1.id}); 
				ninja.backpack.push(Item.find(#{@item1.id})); 
				ninja.backpack.push(Item.find(#{@item2.id})); 
			})
			property.reload
			assert_equal property.value_description, "2 objects"
			@engine.run(%{
				ninja = Ninja.find(#{@game_object_1.id}); 
				ninja.backpack.remove('all'); 
			})
			property.reload
			assert_equal property.value_description, '0 objects'
		end

	end

end
