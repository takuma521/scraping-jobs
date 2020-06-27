require 'google_drive'
require 'config'

class GoogleSpreadsheet
  def self.authorize(client_id, client_secret, refresh_token)
    Google::Auth::UserRefreshCredentials.new(
      client_id: client_id,
      client_secret: client_secret,
      refresh_token:  refresh_token
    )
  end

  def self.output_to_spreadsheet(credentials, spreadsheet_id, worksheet_title, companies)
    session = GoogleDrive::Session.from_credentials(credentials)
    spreadsheet    = session.spreadsheet_by_key(spreadsheet_id)
    worksheet = spreadsheet.worksheet_by_title(worksheet_title)
    worksheet[1, 1] = '会社名'
    worksheet[1, 2] = '住所'
    worksheet[1, 3] = '説明'
    worksheet[1, 4] = 'url'
    companies.each_with_index do |company, index|
      worksheet[index + 2, 1] = company[:name]
      worksheet[index + 2, 2] = company[:location]
      worksheet[index + 2, 3] = company[:description]
      worksheet[index + 2, 4] = company[:url]
    end
    worksheet.save
  end
end









