class EngineContext

	def initialize(game)
		@game = game
	end

	def run(code)
		@environment ||= setup_environment
		@environment.eval(code)
	end

	private 

	def setup_environment

		s = Rufus::Lua::State.new
		s.eval(File.read(File.join(Rails.root, 'lib', 'lua_context', 'utils.lua')))
		s.eval(File.read(File.join(Rails.root, 'lib', 'lua_context', 'object_system.lua')))

		GameObjectClass.class_tree(@game).each do |parent_class|
			inject_class_in_context(parent_class, s)
		end

		s.function('game_object_with_class_and_id') do |klazz_id, id|
			game_object = @game.game_objects.where(["object_class_id = ? and id = ?", klazz_id, id]).first
			game_object
		end

		s.function('save_game_object') do |object|
			object = object.to_ruby
			game_object = @game.game_objects.where(["id = ?", object['id'].to_i]).first
			game_object.name = object['name']
			game_object.save
			true
		end

		

		s
	end	

	def inject_class_in_context(klazz, context)
		context.eval klazz[:klazz].generate_as_lua
		if klazz[:children].length > 0			
			klazz[:children].each{|a| inject_class_in_context(a, context)}
		end
	end

end