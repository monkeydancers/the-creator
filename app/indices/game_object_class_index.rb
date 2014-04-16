ThinkingSphinx::Index.define :game_object_class, :with => :active_record do

  indexes :name
  indexes :identifier

  has :game_id

end