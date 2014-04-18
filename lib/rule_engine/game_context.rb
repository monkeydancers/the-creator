#coding:utf-8
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
#
# This class should not be used for anything outside the context provided by the Engine-class, since it performs
# some scope-related magic to present a proper Slate for V8 to use.
class GameContext

	def initialize(game, opts = nil)
		@game = game	
		@opts = opts
		class_list = game.game_object_classes.to_a
		slate_class = Class.new do 
			def log(*args)
				puts args.inspect
				true
			end
		end

		@slate = slate_class.new

		class_list.each do |gc|
			@slate.define_singleton_method(gc.name) do ||
				return GameContext::GameObjectClassProxy.new(gc)
			end
		end

		if @opts
			@slate.instance_variable_set(:@actor, @opts[:actor])
			@slate.instance_variable_set(:@target, @opts[:target])
		end

		# This way, we can define hidden accessor-methods, just like in Ruby, 
		# in order to provide dynamic invocations with keyword/macro-like style
		@slate.define_singleton_method('actor') do ||
			return @actor
		end

		@slate.define_singleton_method('target') do ||
			return @target
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
			@dirty 	= {}			
			self
		end

		def name
			return @object.name
		end

		def name=(str)
			@object.name = str
		end
		# Add support for using transactions here...
		def save
			@dirty.each_pair do |k,p|
				p.save
			end
			@object.save
			# Empty the dirty-cache after successful saves
			@dirty.clear
			@object.reload
		end

		def []=(name, value)
			property = @object.properties.where(["LOWER(name) = ?", name.downcase]).first
			if property
				if property.is_object_property?
					raise IncompatiblePropertyOperationException.new("Object-properties can't be directly assigned, use push, set or +.")
				else
					property.value = value
					@dirty[property.name] = property
	#				property.save
				end
			else
				return nil
			end
		end

		def [](name)
			property = @object.properties.where(["LOWER(name) = ?", name.downcase]).first
			if property
				if property.is_single_object?
					if @dirty.key?(property.name)
						return @dirty[property.name]
					else
						prop = GameContext::ObjectPropertyProxy.new(property)
						@dirty[property.name] = prop
						prop
					end
				elsif property.is_multi_object?
					if @dirty.key?(property.name)
						return @dirty[property.name]
					else
						prop = GameContext::ObjectPropertyProxy.new(property)
						@dirty[property.name] = prop
						prop
					end
				else
					return property.value
				end
			else
				return nil
			end
		end

		def identifier
			return @object.identifier
		end
	end

	private 

end