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

		# Fetch all root-instances of GameObjectClasses
		s = Rufus::Lua::State.new
		s.eval(File.read(File.join(Rails.root, 'lib', 'lua_context', 'utils.lua')))
		s.eval(File.read(File.join(Rails.root, 'lib', 'lua_context', 'object_system.lua')))

		s.function('load_game_object_by_id') do |id|
			game_object = GameObject.find(id)
			game_object
		end

		s
	end	

end