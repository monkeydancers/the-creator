class Engine

	def initialize(game, opts = nil)
		@game = game
		@opts = opts
	end

	def run(code)
		@environment ||= setup_environment(@game)
		begin
			@environment.eval(code)
			res = {}
			@environment[:result].each do |key, value|
				res[key] = value
			end
			return res
		rescue V8::Error => e
		 	raise e
		end
	end

	private 

	def setup_environment(game)
		ctx = GameContext.new(game, @opts)
		return V8::Context.new(:with => ctx.package)		
	end	

end