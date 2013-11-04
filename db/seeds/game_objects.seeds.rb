detective = GameObjectClass.where(["name = ?", 'Detective']).first.game_objects.create(:name => "Sherlock Holmes")
priest = GameObjectClass.where(["name = ?", 'Priest']).first.game_objects.create(:name => "Father Malacchi")
priest = GameObjectClass.where(["name = ?", 'Sorceress']).first.game_objects.create(:name => "Vordai")


dark_young = GameObjectClass.where(["name = ?", 'Eldritch']).first.game_objects.create(:name => "Dark Young")
werewolf = GameObjectClass.where(["name = ?", 'Beast']).first.game_objects.create(:name => "Lupin")
werewolf = GameObjectClass.where(["name = ?", 'Cultist']).first.game_objects.create(:name => "Emelie")

weapon = GameObjectClass.where(["name = ?", 'Item']).first.game_objects.create(:name => "Spear of Destiny")
shield = GameObjectClass.where(["name = ?", 'Item']).first.game_objects.create(:name => "Shield of Light")