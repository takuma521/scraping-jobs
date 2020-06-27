namespace :scrape_jobs do
  desc '求人情報を取得し出力する'
  task :scrape => :environment do
    require './lib/google_spreadsheet'
    require 'nokogiri'
    require 'open-uri'
    require 'pry'
    client_id = Rails.application.credentials.google_drive[:client_id]
    client_secret = Rails.application.credentials.google_drive[:client_secret]
    refresh_token = Rails.application.credentials.google_drive[:refresh_token]
    spreadsheet_id = Rails.application.credentials.google_drive[:spreadsheet_id]
    credentials = GoogleSpreadsheet.authorize(client_id, client_secret, refresh_token)
    worksheet_title = '応募会社'
    url = Rails.application.credentials.recruitment[:api_url]
    page_numbers = 1..19
    companies = page_numbers.map do |page_number|
      uri = "#{url}#{page_number}"
      uri = URI.parse(uri)
      request = Net::HTTP::Get.new(uri, 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3860.0 Safari/537.36')
      request.content_type = 'application/json'
      req_options = { use_ssl: uri.scheme == 'https' }
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      next if JSON.parse(response.body).first.second.empty?
      JSON.parse(response.body).first.second.map do |company|
        {
          name: company['name'],
          location: company['location'],
          description: company['description'],
          url: "#{Rails.application.credentials.recruitment[:companies_url]}#{company['id']}"
        }
      end
    end.compact
    companies.flatten!
    GoogleSpreadsheet.output_to_spreadsheet(credentials, spreadsheet_id, worksheet_title, companies)
  end
end
