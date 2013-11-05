-- Game Object Hierarchy --

-- Base Class
GameObjectClass = {
	
}


GameObject = {}
-- Setup class inheritance using GameObject_mt as metatable
GameObject_mt = { 
	__index = GameObject, 
	__tostring = function(table)
		return table.name .. " - Monkey"
	end
}

-- Allow for creation of game-objects. This should probably be renamed to something
-- which doesn't carry connotations for Ruby-developers.
function GameObject:create(data)
	local inst = {}
	setmetatable(inst, GameObject_mt)
	for key, value in pairs(data) do 
		if key == "properties" then
			for name, property in pairs(data.properties) do 
				data[property.name] = ObjectPropertyWrapper.create(property.id, property.name)
			end
		else
			inst[key] = value
		end
	end
	return inst
end

-- Fetch and instantiate a GameObject with the provided id
function GameObject.find(id)
	data = load_game_object_by_id(id)
	if data then
		return GameObject:create(data)
	else
		return "There's no GameObject with id:" .. id
	end
end

-- Persist the GameObject to the database
function GameObject:save()
	print("Persisting game object with name: " .. self.name)
	return true
end

-- Return which GameObjectClass this object belongs to
function GameObject:className(x)
	print("GameObject")
end


-- Property System --

ObjectPropertyWrapper = {}

PM = {
	__index = ObjectPropertyWrapper, 
	__call = function(table)
		print(table.id)
	end
}

ObjectPropertyWrapper.default_value = function()
	print("This should return default_value")
end

setmetatable(ObjectPropertyWrapper, {
	__index = function(table, idx)
		return function(...)
			print("Initiate property loading...")
			print(rawget(table, 'id'))
		end
	end
})

function ObjectPropertyWrapper.create(_id, _name)
	local inst = {
		id = _id, 
		name = _name
	}
	setmetatable(inst, PM)
	return inst
end