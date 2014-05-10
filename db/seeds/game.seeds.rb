Game.destroy_all
User.destroy_all

user = User.create(:email => "test@test.com", :password => "ninjamagick")

game = Game.create(:name => "Mörkret i Vassen")
user.game = game
user.save

