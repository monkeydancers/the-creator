require 'test_helper'

class SearchesControllerTest < ActionController::TestCase

	context 'When searching, the system' do 
		setup do 
			@game = Game.create(:name => "Test Game")

			@game_object_class 	= @game.game_object_classes.create(:name => "Ninja")
			@game_object 				= @game_object_class.game_objects.create(:name => "Hugo", :game_id => @game.id)

			@request.env['HTTP_ACCEPT'] = 'application/json'
		end

		should 'perform a correct search' do 
			ThinkingSphinx.expects(:search).with('*hug*', {:classes => [GameObject, GameObjectClass], :with => {:game_id => Game.first.id}}).returns([@game_object])

			post :create, {:query => {:query => "hug"}}
			assert_response 200

			data = JSON.parse(@response.body)
			assert_equal data['results'].length, 1
			assert_equal data['results'][0]['name'], 'Hugo'
		end

	end

end
