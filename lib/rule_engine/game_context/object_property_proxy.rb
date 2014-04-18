class GameContext

	class ObjectPropertyProxy

		def initialize(property_object)
			@prop_object = property_object
			@multi = property_object.is_multi_object? 
			@list = Array(property_object.value).map{|game_object| GameContext::GameObjectProxy.new(game_object)}			
			self
		end

		def game
			return OpenStruct.new(:api_key => @prop_object.game.api_key)
		end

		def identifier
			@prop_object.identifier
		end

		def value_description
			@prop_object.reload
			@prop_object.value_description
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
		# This needs to handle single-objects!
		def push(obj)
			
			obj = GameObject.where(["identifier = ?", obj.identifier]).first	
			if @multi
				@prop_object.add(obj.identifier)
			else
				@prop_object.value = obj
			end
		end

		def remove(obj)
			if @multi
				data = obj == 'all' ? obj : [obj.identifier]
				@prop_object.handle_removal(data)
			else
				@prop_object.value = nil
			end
		end

		def save
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

		alias_method :add, :push
	end

end