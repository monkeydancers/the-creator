json.list 						false
json.class_path 				""
json.name 						@object.name
json.identifier					@object.identifier
json.description	 			@object.description
json.properties(@object.properties) do |property|
	json.name 						property.name
	json.current_value		property.value_description
	json.default_value		property.value_description(false)
	json.identifier				property.identifier
	json.type							property.type
end