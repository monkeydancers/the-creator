json.list 						true
json.identifier				@object.identifier
json.num_game_objects	@object.objects(true).length
json.objects_per_page 10
json.game_objects_list(@object.objects(true)) do |go|
	json.identifier			go[:identifier]
	json.name 					go[:name]
end