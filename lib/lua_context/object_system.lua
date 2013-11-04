
-- Game Object Hierarchy --
GameObject = {}
GameObject_mt = { __index = GameObject }

function GameObject:create()
	local inst = {}
	setmetatable(inst, GameObject_mt)
	return inst
end

function GameObject.find(id)
	data = load_game_object_by_id(id)
	for key, value in pairs(data.properties) do 
		print(value.id)
		print(value.name)
		data[value.name] = ObjectPropertyWrapper.create(value.id, value.name)
	end
	return data
end

function GameObject:className(x)
	print("GameObject")
end




-- Property System --

-- OPW = { __index = function(table, idx)
-- 	return function(...)
-- 		print("Initiate property loading...")
-- 		print(rawget(table, 'id'))
-- 	end
-- end}

ObjectPropertyWrapper = {

}

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