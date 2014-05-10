json.array!(@objects) do |go|
	json.id 				go.id
	json.name 			go.name
	json.identifier	go.identifier
	go.properties.each do |prop|
		json.set! prop.name do 
			json.identifier		prop.identifier
			json.value 				prop.value
		end
	end
end