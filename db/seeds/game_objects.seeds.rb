GameObject.destroy_all

@game = Game.first

detective = GameObjectClass.where(["name = ?", 'Detective']).first.game_objects.create(:name => "Sherlock Holmes", :game_id => @game.id)
priest = GameObjectClass.where(["name = ?", 'Priest']).first.game_objects.create(:name => "Father Malacchi", :game_id => @game.id)
priest = GameObjectClass.where(["name = ?", 'Sorceress']).first.game_objects.create(:name => "Vordai", :game_id => @game.id)


dark_young = GameObjectClass.where(["name = ?", 'Eldritch']).first.game_objects.create(:name => "Dark Young", :game_id => @game.id)
werewolf = GameObjectClass.where(["name = ?", 'Beast']).first.game_objects.create(:name => "Lupin", :game_id => @game.id)
werewolf = GameObjectClass.where(["name = ?", 'Cultist']).first.game_objects.create(:name => "Emelie", :game_id => @game.id)

weapon = GameObjectClass.where(["name = ?", 'Item']).first.game_objects.create(:name => "Spear of Destiny", :game_id => @game.id)
shield = GameObjectClass.where(["name = ?", 'Item']).first.game_objects.create(:name => "Shield of Light", :game_id => @game.id)