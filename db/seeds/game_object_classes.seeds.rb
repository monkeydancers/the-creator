investigator 	= GameObjectClass.create(:name => "Investigator")
detective 		= GameObjectClass.create(:name => "Detective", :parent => investigator)
priest				= GameObjectClass.create(:name => "Priest", :parent => investigator)
sorceress			= GameObjectClass.create(:name => "Sorceress", :parent => investigator)


monster				= GameObjectClass.create(:name => "Monster")
eldritch			= GameObjectClass.create(:name => "Eldritch", :parent => monster)
beastly				= GameObjectClass.create(:name => "Beast", :parent => monster)
cultist 			= GameObjectClass.create(:name => "Cultist", :parent => monster)

item 					= GameObjectClass.create(:name => "Item")


investigator.properties.create(:name => "Weapon", :property_type_definition => "SingleObjectProperty", :property_klazz => "Item")
investigator.properties.create(:name => "Backpack", :property_type_definition => "MultiObjectProperty", :property_klazz => "Item")
detective.properties.create(:name => "Investigation Skill", :property_type_definition => "NumericProperty", :value => 10)
priest.properties.create(:name => "Piety", :property_type_definition => "NumericProperty", :value => 100)
sorceress.properties.create(:name => "Mana", :property_type_definition => "NumericProperty", :value => 100)

monster.properties.create(:name => "Horror", :property_type_definition => "NumericProperty", :value => 10)
monster.properties.create(:name => "Weak Link", :property_type_definition => "SingleObjectProperty", :property_klazz => "Item")
