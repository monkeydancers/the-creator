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

		s.function('load_game_object_by_id') do |id|
			game_object = @game.game_objects.find_by_id(id)
			game_object
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