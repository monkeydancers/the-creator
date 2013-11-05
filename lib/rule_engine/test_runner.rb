require File.expand_path('../../../config/environment', __FILE__)
require './engine_context'


ctx = EngineContext.new(Game.first)

puts ctx.run %{

	d = Detective:find(36)

	d.name = "Sherlock Holmes"

	print(d)

	d:save()

}