require 'test_helper'

class RuleTest < ActiveSupport::TestCase

	context 'When manipulating actor/target for rules, the system' do 
		setup do 
			@game = Game.create(:name => "Test Game")
			@game_object_class = @game.game_object_classes.create(:name => "Ninja")
			@game_object = @game_object_class.game_objects.create(:name => "Monkey Master", :game_id => @game.id)	

			@child_class = @game.game_object_classes.create(:name => "Death Ninja", :parent => @game_object_class)
		end

		should 'support setting actor' do 
			rule = @game.rules.create(:name => "Test Rule")
			assert rule.valid? 

			rule.actor_list = @game_object_class.identifier
			rule.save
			assert_equal rule.actor_list.length, 1
			assert_equal rule.actor, @game_object_class
		end

		should 'support setting target' do 
			rule = @game.rules.create(:name => "Test Rule")
			assert rule.valid? 

			rule.target_list = @game_object_class.identifier
			rule.save
			assert_equal rule.target_list.length, 1
			assert_equal rule.target, @game_object_class
		end

		should 'support changing actor / target' do 
			rule = @game.rules.create(:name => "Test Rule")
			assert rule.valid? 

			rule.actor_list = @game_object_class.identifier
			rule.save
			assert_equal rule.actor, @game_object_class
			
			rule.actor_list = @child_class.identifier
			rule.save
			assert_equal rule.actor, @child_class
		end

		should 'not support having more than one actor' do 
			rule = @game.rules.create(:name => "Test Rule")
			assert rule.valid? 

			rule.actor_list = [@game_object_class.identifier, @child_class.identifier]
			rule.save
			assert !rule.valid? 
			assert_not_empty rule.errors[:actor_list]
		end

		should 'not support having more than one target' do 
			rule = @game.rules.create(:name => "Test Rule")
			assert rule.valid? 

			rule.target_list = [@game_object_class.identifier, @child_class.identifier]
			rule.save
			assert !rule.valid? 
			assert_not_empty rule.errors[:target_list]
		end
	end

end
