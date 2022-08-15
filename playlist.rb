class Playlist
  def initialize(id, name, description, owner_name, spotify_url, tracks)
    @id = id
    @name = name
    @description = description
    @owner_name = owner_name
    @spotify_url = spotify_url
    @tracks = tracks
  end

  def to_json(options = {})
    JSON.pretty_generate({:id => @id, :description => @description, :name => @name, :owner_name => @owner_name, :spotify_url => @spotify_url, :tracks => @tracks}, options)
  end
end