json.results(@results) do |res|
	json.id 			res.id
	json.name 		res.name
	json.type 		res.class.name
end