require 'google_drive'
require 'config'

class GoogleMaps
  def self.get_distance(origin, destination, api_key)
    url = URI.escape("https://maps.googleapis.com/maps/api/directions/json?origin=#{origin}&destination=#{destination}&key=#{api_key}")
    uri = URI.parse(url)
    request = Net::HTTP::Get.new(uri, 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3860.0 Safari/537.36')
    request.content_type = 'application/json'
    req_options = { use_ssl: uri.scheme == 'https' }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    JSON.parse(response.body).dig('routes', 0, 'legs', 0, 'distance', 'text')
  end
end
