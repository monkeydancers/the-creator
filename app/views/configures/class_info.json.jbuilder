json.name @gameobjectclass.name
json.identifier @gameobjectclass.identifier
json.properties(@gameobjectclass.property_list) do |property|
	json.name 				property.name
	json.default_value		property.value_description(false)
	json.identifier			property.identifier
	json.datatype			property.type
	json.inherited_from		""
end

json.subclasses(@gameobjectclass.children(true)) do |subclass|
	json.identifier			subclass[:identifier]
	json.name 				subclass[:name]
end