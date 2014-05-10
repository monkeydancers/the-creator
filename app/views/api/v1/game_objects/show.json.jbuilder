json.object do 
	json.id 		@object.id
	json.name 	@object.name
	json.identifier @object.identifier
	
	@object.properties.each do |prop|
		json.set! prop.name do 
			json.identifier		prop.identifier
			json.value 				prop.value
		end
	end
end