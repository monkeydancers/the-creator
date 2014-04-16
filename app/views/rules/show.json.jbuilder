json.rule do 
	json.id 				@rule.id
	json.name 			@rule.name
	json.path 			rule_path(@rule)
	json.code 			@rule.rule_code
end