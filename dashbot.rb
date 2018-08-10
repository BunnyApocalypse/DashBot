require 'slack-ruby-client'
require 'dogapi'
require 'faye/websocket'

token = ENV['SLACK_TOKEN']
api_key = ENV['DATADOG_API_KEY']
app_key = ENV['DATADOG_APP_KEY']
board_id = ENV['DATADOG_BOARD_ID']
widget_number = ENV['DATADOG_WIDGET_NUMBER'].to_i

Slack.configure do |config|
  config.token = token
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO
end

client = Slack::RealTime::Client.new
dog = Dogapi::Client.new(api_key, app_key)

client.on :hello do
  puts "Successfully connected."
end

client.on :message do |data|
  #using giphy
  puts data.attachments[0].image_url
  if data&.attachments&.at(0)&.image_url
      url = data.attachments[0].image_url
      result = dog.get_screenboard(board_id)
      board = result[1]
      board["widgets"][widget_number]["url"] = url
      dog.update_screenboard(board_id, board)
  end
  #Linking to an image directly/an imgur album
  if data&.message&.attachments&.at(0)&.image_url
      url = data.message.attachments[0].image_url
      result = dog.get_screenboard(board_id)
      board = result[1]
      board["widgets"][widget_number]["url"] = url
      dog.update_screenboard(board_id, board)
  end
end

client.on :close do |_data|
  puts "Client is about to disconnect"
end

client.on :closed do |_data|
  puts "Client has disconnected successfully!"
end

STDOUT.sync = true
client.start!
