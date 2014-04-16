ThinkingSphinx::Index.define :game_object, :with => :active_record do

  indexes :name
  indexes :identifier
  indexes :description

  has :game_id

end