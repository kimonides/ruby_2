require 'watir'
require 'rest-client'
require 'json'
require 'sinatra'


set :port, 8888

client_id = "6f120de7b20e4f67b84d422b50ac5836"
client_secret = "3da3626c3862485f8d33905b72ff8e28"
redirect_uri = "http://localhost:8888/callback"

get '/callback' do
  body = {
    grant_type: "authorization_code",
    code: params[:code],
    redirect_uri: redirect_uri,
    client_id: client_id,
    client_secret: client_secret,
  }

  auth_response = RestClient.post('https://accounts.spotify.com/api/token', body) {|response, request, result| response }

  auth_params = JSON.parse(auth_response.body)

  # ACCESS TOKEN
  access_token = auth_params["access_token"]

  response = RestClient.get('https://api.spotify.com/v1/me', Authorization: "Bearer #{auth_params["access_token"]}")

  # USER ID
  user_id = JSON.parse(response.body)["id"]

  puts user_id

  # params = {name: "my_playlist"}

  RestClient.log = 'stdout'
  response = RestClient.post('https://api.spotify.com/v1/users/%s/playlists' % [user_id], {name: "my_playlist"}.to_json, content_type: :json, accept: :json, Authorization: "Bearer #{auth_params["access_token"]}") {|response, request, result| response }

  puts response

  playlist_id = JSON.parse(response.body)["id"]

  # https://api.spotify.com/v1/playlists/{playlist_id}/tracks
  body = {"uris": ["spotify:track:5n8Aro6j1bEGIy7Tpo7FV7","spotify:track:3nndHObJ5j5wpSKhTVODDG","spotify:track:6bhBAfmiMdvfFFtY0Rp8dA"]}
  response = RestClient.post('https://api.spotify.com/v1/playlists/%s/tracks' % [playlist_id], body.to_json, content_type: :json, accept: :json, Authorization: "Bearer #{auth_params["access_token"]}") {|response, request, result| response }

  snapshot_id = JSON.parse(response.body)["snapshot_id"]
  puts snapshot_id

  body = {"range_start": 1, "insert_before": 3, "range_length": 1}

  response = RestClient.put('https://api.spotify.com/v1/playlists/%s/tracks' % [playlist_id], body.to_json, content_type: :json, accept: :json, Authorization: "Bearer #{auth_params["access_token"]}") {|response, request, result| response }


  response = RestClient.get('https://api.spotify.com/v1/playlists/%s/tracks?limit=50' % [playlist_id], content_type: :json, accept: :json, Authorization: "Bearer #{auth_params["access_token"]}") {|response, request, result| response }

  track_uri = JSON.parse(response.body)["items"][-1]["track"]["uri"]


  body = {
    "tracks": [{ "uri": track_uri }]
  }
  # response = RestClient.delete('https://api.spotify.com/v1/playlists/%s/tracks' % [playlist_id], body.to_json, content_type: :json, accept: :json, Authorization: "Bearer #{auth_params["access_token"]}") {|response, request, result| response }
  headers = {
    Authorization: "Bearer #{auth_params["access_token"]}",
    content_type: :json, 
    accept: :json
  }
  response = RestClient::Request.execute(:method => 'delete', :url => 'https://api.spotify.com/v1/playlists/%s/tracks' % [playlist_id], :payload => body.to_json, :headers => headers) {|response, request, result| response }

  puts response
  # puts JSON.pretty_generate(JSON.parse(response.body)["items"])

  'Hello world!'
end


Thread.new { 
  sleep(1) until Sinatra::Application.settings.running?

  browser = Watir::Browser.new


  # browser.goto("https://accounts.spotify.com/authorize?client_id="+ client_id + "&scope=code" +"&response_type=code&redirect_uri="+ ERB::Util.url_encode(redirect_uri))

  browser.goto("https://accounts.spotify.com/authorize?client_id=%s&scope=%s&response_type=code&redirect_uri=%s" % [client_id, ERB::Util.url_encode("playlist-modify-public playlist-modify-private"),ERB::Util.url_encode(redirect_uri)])
  browser.driver.manage.window.maximize

  browser.input(id: "login-username").set "kimonide@gmail.com"
  browser.input(id: "login-password").set "1223334444"
  browser.button(id: "login-button").click
  browser.button(data_testid: "auth-accept").click
  sleep(1)
  browser.close()
}



