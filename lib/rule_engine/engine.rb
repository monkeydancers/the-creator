class Engine

	def initialize(game)
		@game = game
	end

	def run(code)
		@environment ||= setup_environment(@game)
		begin
			@environment.eval(code)
		rescue V8::Error => e
			puts "Rule Engine Error: #{e.message}"
		end
	end

	private 

	def setup_environment(game)
		ctx = GameContext.new(game)
		return V8::Context.new(:with => ctx.package)		
	end	

end