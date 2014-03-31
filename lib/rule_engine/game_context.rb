# @author buffpojken
# @api rules
# This class provides the global scope for the V8-context running rules for a particular game.
# 
# When a rule-run is initiated, this class is instantiated with a game, sets up accessors for the
# particular instance of rule-execution, and then executes the rules in order.
#
# In order to preserve proper scopes, and prevent any memory-related segfaults, this class internally
# creates a blank-slate implementation (in order to not pollute the memoryspace of the class passed
#	to V8), which gets all proper accessors added to it.
#
# Class-based methods on GameObjectClass are added as constructor-functions, keyed to class-name. These
# are then invoked on the fly when accessing a class. This means that no methods not explicitly added to the 
# available scope is accessible from within the rule-context.
class GameContext

	def initialize(game=nil)
		@game = game	
		class_list = game.game_object_classes.to_a
		slate_class = Class.new do 
			def log(*tmp)
#				$redis.set("monkey-log", tmp)
				puts tmp.inspect
				true
			end
		end

		@slate = slate_class.new

		class_list.each do |gc|
			@slate.define_singleton_method(gc.name) do ||
				return GameContext::GameObjectClassProxy.new(gc)
			end
		end

		# This way, we can define hidden accessor-methods, just like in Ruby, 
		# in order to provide dynamic invocations with keyword/macro-like style
		@slate.define_singleton_method('actor') do ||
			"I'm an actor object..."
		end

		self
	end

	def package
		return @slate
	end

	class GameObjectClassProxy
		def initialize(gc_class)
			@goc = gc_class
		end

		def find(id)
			goc = @goc.game_objects.where(["id = ?", id]).first
			if goc
				GameContext::GameObjectProxy.new(goc)
			else
				raise ElementNotFoundException.new("Could not find a #{@goc.name} with id: #{id.to_s}")
			end
		end
	end

	class GameObjectProxy
		def initialize(object)
			@object = object
			self
		end

		def name
			return @object.name
		end

		def name=(str)
			@object.name = str
		end

		def save
			@object.save
			@object.reload
		end

		def [](name)
			# Look through properties...
			property = @object.properties.where(["name = ?", name]).first
			if property
				return property.value_description
			else
				return nil
			end
		end

		def identifier
			return @object.identifier
		end
	end

	private 

	def setup(game)
		@game = game
	end

end