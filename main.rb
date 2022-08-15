require 'watir'
require 'rest-client'
require 'json'
require 'sinatra'

require_relative 'playlist'
require_relative 'track'


set :port, 8888

$client_id = "6f120de7b20e4f67b84d422b50ac5836"
$client_secret = "3da3626c3862485f8d33905b72ff8e28"
$redirect_uri = "http://localhost:8888/callback"

def getAuthToken(code)
  body = {
    grant_type: "authorization_code",
    code: code,
    redirect_uri: $redirect_uri,
    client_id: $client_id,
    client_secret: $client_secret,
  }

  auth_response = RestClient.post('https://accounts.spotify.com/api/token', body) {|response, request, result| response }

  auth_params = JSON.parse(auth_response.body)

  return auth_params["access_token"]
end

def getUserId(access_token)
  response = RestClient.get('https://api.spotify.com/v1/me', Authorization: "Bearer #{access_token}")

  return JSON.parse(response.body)["id"]
end

def createPlaylist(access_token, user_id)
  response = RestClient.post('https://api.spotify.com/v1/users/%s/playlists' % [user_id], {name: "my_playlist"}.to_json, content_type: :json, accept: :json, Authorization: "Bearer #{access_token}") {|response, request, result| response }
  return JSON.parse(response.body)["id"]
end

def addTracks(access_token, playlist_id)
  body = {"uris": ["spotify:track:5n8Aro6j1bEGIy7Tpo7FV7","spotify:track:3nndHObJ5j5wpSKhTVODDG","spotify:track:6bhBAfmiMdvfFFtY0Rp8dA"]}
  response = RestClient.post('https://api.spotify.com/v1/playlists/%s/tracks' % [playlist_id], body.to_json, content_type: :json, accept: :json, Authorization: "Bearer #{access_token}") {|response, request, result| response }
end

def reorderPlaylist(access_token, playlist_id)
  body = {"range_start": 1, "insert_before": 3, "range_length": 1}
  response = RestClient.put('https://api.spotify.com/v1/playlists/%s/tracks' % [playlist_id], body.to_json, content_type: :json, accept: :json, Authorization: "Bearer #{access_token}") {|response, request, result| response }
end

def removeLastTrack(access_token, playlist_id)
  response = RestClient.get('https://api.spotify.com/v1/playlists/%s/tracks?limit=50' % [playlist_id], content_type: :json, accept: :json, Authorization: "Bearer #{access_token}}") {|response, request, result| response }
  track_uri = JSON.parse(response.body)["items"][-1]["track"]["uri"]

  body = {
    "tracks": [{ "uri": track_uri }]
  }
  headers = {
    Authorization: "Bearer #{access_token}",
    content_type: :json, 
    accept: :json
  }
  response = RestClient::Request.execute(:method => 'delete', :url => 'https://api.spotify.com/v1/playlists/%s/tracks' % [playlist_id], :payload => body.to_json, :headers => headers) {|response, request, result| response }
end

def initializePlaylistFromApi(access_token, playlist_id)
  response = RestClient.get('https://api.spotify.com/v1/playlists/%s?fields=%s' % [playlist_id, "description,external_urls,tracks,id,name,owner"], content_type: :json, accept: :json, Authorization: "Bearer #{access_token}") {|response, request, result| response }
  
  playlist_id = JSON.parse(response.body)["id"]
  playlist_name = JSON.parse(response.body)["name"]
  playlist_description = JSON.parse(response.body)["description"]
  playlist_owner = JSON.parse(response.body)["owner"]["display_name"]
  playlist_url = JSON.parse(response.body)["external_urls"]["spotify"]
  playlist_tracks = []

  # puts JSON.pretty_generate(JSON.parse(response.body)["tracks"])
  JSON.parse(response.body)["tracks"]["items"].each do |t|
    # puts JSON.pretty_generate(t)
    track_id = t["track"]["id"]
    track_name = t["track"]["name"]
    track_artist_name = t["track"]["album"]["artists"][0]["name"]
    track_album_name = t["track"]["album"]["name"]
    track_url = t["track"]["album"]["external_urls"]["spotify"]

    track = Track.new(track_id, track_name, track_artist_name, track_album_name, track_url)

    playlist_tracks.push(track)
  end

  return Playlist.new(playlist_id, playlist_name, playlist_description, playlist_owner, playlist_url, playlist_tracks)
end

get '/callback' do

  # Get Access Token
  access_token = getAuthToken(params[:code])

  # Get User Id
  user_id = getUserId(access_token)

  # Create Playlist
  playlist_id = createPlaylist(access_token, user_id)

  # Add Tracks
  addTracks(access_token, playlist_id)

  # Reorder Playlist
  reorderPlaylist(access_token, playlist_id)

  # Remove Last Track
  removeLastTrack(access_token, playlist_id)


  #------------------------------------------------------------

  playlist = initializePlaylistFromApi(access_token, playlist_id)

  File.open("output/playlist.json","w") do |f|
    f.write(JSON.pretty_generate(playlist))
  end

  'Hello world!'
end


Thread.new { 
  sleep(1) until Sinatra::Application.settings.running?

  browser = Watir::Browser.new

  browser.goto("https://accounts.spotify.com/authorize?client_id=%s&scope=%s&response_type=code&redirect_uri=%s" % [$client_id, ERB::Util.url_encode("playlist-modify-public playlist-modify-private"),ERB::Util.url_encode($redirect_uri)])
  browser.driver.manage.window.maximize

  browser.input(id: "login-username").set "kimonide@gmail.com"
  browser.input(id: "login-password").set "1223334444"
  browser.button(id: "login-button").click

  if browser.button(data_testid: "auth-accept").exists?
    browser.button(data_testid: "auth-accept").click
  end
  sleep(1)
  browser.close()
}



