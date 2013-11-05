GameObjectClass.destroy_all

@game = Game.first

investigator 	= GameObjectClass.create(:name => "Investigator", :game_id => @game.id)
detective 		= GameObjectClass.create(:name => "Detective", :parent => investigator, :game_id => @game.id)
priest				= GameObjectClass.create(:name => "Priest", :parent => investigator, :game_id => @game.id)
sorceress			= GameObjectClass.create(:name => "Sorceress", :parent => investigator, :game_id => @game.id)


monster				= GameObjectClass.create(:name => "Monster", :game_id => @game.id)
eldritch			= GameObjectClass.create(:name => "Eldritch", :parent => monster, :game_id => @game.id)
beastly				= GameObjectClass.create(:name => "Beast", :parent => monster, :game_id => @game.id)
cultist 			= GameObjectClass.create(:name => "Cultist", :parent => monster, :game_id => @game.id)

item 					= GameObjectClass.create(:name => "Item", :game_id => @game.id)


investigator.properties.create(:name => "Weapon", :property_type_definition => "SingleObjectProperty", :property_klazz => "Item")
investigator.properties.create(:name => "Backpack", :property_type_definition => "MultiObjectProperty", :property_klazz => "Item")
detective.properties.create(:name => "Investigation Skill", :property_type_definition => "NumericProperty", :value => 10)
priest.properties.create(:name => "Piety", :property_type_definition => "NumericProperty", :value => 100)
sorceress.properties.create(:name => "Mana", :property_type_definition => "NumericProperty", :value => 100)

monster.properties.create(:name => "Horror", :property_type_definition => "NumericProperty", :value => 10)
monster.properties.create(:name => "Weak Link", :property_type_definition => "SingleObjectProperty", :property_klazz => "Item")
