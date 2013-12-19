json.error false
json.identifier @property.identifier
json.num_game_objects Array(@property.value).length
json.game_objects_list(Array(@property.value)) do |go|
	json.name 				go.name
	json.identifier		go.identifier
end