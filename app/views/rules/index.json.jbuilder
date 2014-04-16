json.rules(@rules) do |rule|
	json.id 						rule.id
	json.name 					rule.name
	json.path 					rule_path(rule)
end