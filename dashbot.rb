require 'slack-ruby-client'
require 'dogapi'
require 'faye/websocket'
require '/etc/dashbot/environment'

token= ENV['slack-token']
api_key = ENV['datadog-api-key']
app_key = ENV['datadog-app-key']
board_id = ENV['datadog-board-id']
widget_number = ENV['datadog-widget-number'].to_i

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
  if defined? data.attachments[0].image_url
      url = data.attachments[0].image_url
      result = dog.get_screenboard(board_id)
      board = result[1]
      board["widgets"][widget_number]["url"] = url
      dog.update_screenboard(board_id, board)
  end
  #Linking to an image directly/an imgur album
  if defined? data.message.attachments[0].image_url
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

client.start!
