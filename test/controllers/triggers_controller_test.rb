require 'test_helper'

class TriggersControllerTest < ActionController::TestCase
 	
	context 'When triggering a rule-run, the system' do 
		setup do 

			@game 				= Game.create(:name => "Test Game")
			@class1 			= @game.game_object_classes.create(:name => "Klazz1")
			@class2 			= @game.game_object_classes.create(:name => "Klazz2")

			@object1			= @class1.game_objects.create(:name => "Object 1", :game => @game)
			@object2			= @class2.game_objects.create(:name => "Object 2", :game => @game)

			@rule 				= @game.rules.create(:name => "Test Rule", :rule_code => %{
				d = Klazz1.find(#{@object1.id})
				d.name = "Object A"
				d.save
			})
			@rule.actor_list = @class1.identifier
			@rule.target_list = @class2.identifier
			@rule.save
		end

		should 'run the correct rule-set' do 
			assert_equal @object1.name, "Object 1"
			assert_equal @rule.actor, @class1
			assert_equal @rule.target, @class2

			post :create, {:actor => @object1.identifier, :target => @object2.identifier, :apikey => @game.api_key}
			assert_response 200

			@object1.reload
			assert_equal @object1.name, "Object A"
		end

	end

end
