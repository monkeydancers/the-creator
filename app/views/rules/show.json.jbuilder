json.rule do 
	json.id 					@rule.id
	json.name 				@rule.name
	json.path 				rule_path(@rule)
	json.code 				@rule.rule_code
	json.actor_list 	@rule.actor.nil? ? "Click to set" : @rule.actor.name
	json.target_list	@rule.target.nil? ? "Click to set" : @rule.target.name
end