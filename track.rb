class Track
  def initialize(id, name, artist_name, album_name, spotify_url)
    @id = id
    @name = name
    @artist_name = artist_name
    @album_name = album_name
    @spotify_url = spotify_url
  end

  def to_json(options = {})
    JSON.pretty_generate({:id => @id, :artist_name => @artist_name, :name => @name, :album_name => @album_name, :spotify_url => @spotify_url}, options)
  end
end