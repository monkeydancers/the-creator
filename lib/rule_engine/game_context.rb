# @author buffpojken
# @api rules
# This class provides the global scope for the V8-context running rules for a particular game.
# 
# When a rule-run is initiated, this class is instantiated with a game, sets up accessors for the
# particular instance of rule-execution, and then executes the rules in order.
#
# More info to follow...
class GameContext

	def initialize(game=nil)
		@game = game	
		klazz = game.game_object_classes.to_a
		@klazz = Class.new do 
			def log
				puts "hugo"
			end
		end

		klazz.each do |gc|
			@klazz.define_singleton_method(gc.name) do ||
				return GameContext::GameObjectClassProxy.new(gc.identifier)
			end
		end

		self
	end

	def package
		return @klazz
	end

	class GameObjectClassProxy
		def initialize(name)
			puts name
		end

		def find(id)
			GameContext::GameObjectProxy.new(id)
		end
	end

	class GameObjectProxy
		def initialize(this)
			self
		end
		def hugo
			return "troll"
		end
		def name
			return "Sherlock"
		end

	end

	private 

	def setup(game)
		@game = game
	end

end