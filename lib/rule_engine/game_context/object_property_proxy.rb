class GameContext

	class ObjectPropertyProxy

		def initialize(property_object)
			@prop_object = property_object
			@multi = property_object.is_multi_object? 
			@list = Array(property_object.value).map{|game_object| GameContext::GameObjectProxy.new(game_object)}			
		end

		def [](idx)
			if idx.is_a?(Fixnum)
				return @list[idx]
			elsif !@multi
				@list[0].send(idx)
			else
				raise UnknownPropertyException.new("#{idx} is an unknown property in this context")
			end
		end

		# This needs to game-scoped!
		def push(obj)
			obj = GameObject.where(["identifier = ?", obj.identifier]).first	
			@prop_object.value = obj
			@prop_object.save
		end

		def remove(obj)
			if @multi
				@prop_object.handle_removal([obj.identifier])
#				@prop_object.value = @prop_object.value.delete_if{|object| object.identifier == obj.identifier }
			else
				@prop_object.value = nil
			end
			@prop_object.save
		end

		def first
			@list[0]
		end

		def last
			@list[-1]
		end

		def size
			@list.length
		end

	end

end