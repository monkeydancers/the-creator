class Engine

	def initialize(game)
		@game = game
	end

	def run(code)
		@environment ||= setup_environment(@game)
		@environment.eval(code)
	end

	private 

	def setup_environment(game)
		ctx = GameContext.new(game)
		return V8::Context.new(:with => ctx.package)		
	end	

end