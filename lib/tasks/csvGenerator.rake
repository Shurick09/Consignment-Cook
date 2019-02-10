require 'csv'
require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'mail'
require 'mime'

task :data_dump => :environment do
  CSV.open("results.csv","w") do |csv|
    Shoe.all.each_with_index do |sneaker,index|
      puts "done #{index}"
      csv << [sneaker.sku, sneaker.size, sneaker.price]
    end
  end

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Gmail API Ruby Quickstart'.freeze
  CREDENTIALS_PATH = 'credentials.json'.freeze
  # The file token.yaml stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  TOKEN_PATH = 'token.yaml'.freeze
  SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_MODIFY



  service = Google::Apis::GmailV1::GmailService.new
  service.client_options.application_name = APPLICATION_NAME
  service.authorization = authorize

  m = Mail.new(
  to: "alexroz0909@gmail.com",
  from: "cookszn121@gmail.com",
  subject: "Test Subject",
  body:"Test Body")
  #msg = m.encoded

  m.attachments['shoes.csv'] = { mime_type: 'text/csv', content: File.read("/Users/Shurick/Documents/Documents\ -\ Alex’s\ MacBook\ Air/Web\ Development/Learning\ Ruby/Consignment\ V2/consignment/results.csv") }

  message_object = Google::Apis::GmailV1::Message.new(raw:m.to_s)
  service.send_user_message("me", message_object)



end

def authorize
  client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end
