require 'test_helper'

class CreatesControllerTest < ActionController::TestCase

	context 'When loading tree structure, the system' do 
		setup do 
			Game.destroy_all
			@game = Game.create(:name => "Test Game")

			@game_object_class 	= @game.game_object_classes.create(:name => "Ninja")
			@game_object_class2 = @game.game_object_classes.create(:name => "Dark Ninja", :parent => @game_object_class)
			@game_object_class3 = @game.game_object_classes.create(:name => "Monster")

			@request.env['HTTP_ACCEPT'] = 'application/json'
		end

		should 'provide tree-data in defined format' do 
			get :structure
			assert_response 200
			data = JSON.parse(@response.body)
			assert data.length, 2
			assert_equal data[0]["name"], "Ninja"
			assert_equal data[0]["children"].length, 1
			assert_equal data[-1]["name"], "Monster"
		end

		should 'not respond to HTML-based requests' do 
			@request.env['HTTP_ACCEPT'] = "text/html"
			get :structure
			assert_response 406
		end
	end

	context 'When loading objects via identifier, the system' do 
		setup do 
			Game.destroy_all
			@game = Game.create(:name => "Test Game")

			@game_object_class 	= @game.game_object_classes.create(:name => "Ninja")
			@game_object 				= @game_object_class.game_objects.create(:name => "Hugo", :game_id => @game.id)

			@request.env['HTTP_ACCEPT'] = 'application/json'
		end

		should 'respond with a list-definition if the identifier is a game object class' do 
			get :identifier, {:identifier => @game_object_class.identifier}
			assert_response 200
			data = JSON.parse(@response.body)

			assert data['list']
			assert_equal data['identifier'], @game_object_class.identifier
			assert_equal data['num_game_objects'], @game_object_class.objects(true).length
			assert_equal data['game_objects_list'][0], {'identifier' => @game_object.identifier, 'name' => @game_object.name}
		end

		should 'respond with an object-definition if the identifier is a game object' do 
			get :identifier, {:identifier => @game_object.identifier}
			assert_response 200
			data = JSON.parse(@response.body)

			assert !data['list']
			assert_equal data['identifier'], @game_object.identifier
			assert_equal data['description'], @game_object.description
			assert_equal data['properties'], []

		end

	end

end
