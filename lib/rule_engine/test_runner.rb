require File.expand_path('../../../config/environment', __FILE__)
require './engine_context'


ctx = EngineContext.new(Game.first)



puts ctx.run %{


}