require File.expand_path('../../../config/environment', __FILE__)
require './game_context'
require './engine'


ctx = Engine.new(Game.first)

puts ctx.run %{
	d = Detective.find(1)
	log(d)
}