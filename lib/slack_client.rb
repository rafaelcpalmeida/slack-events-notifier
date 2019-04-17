#!/usr/bin/env ruby

require 'slack-ruby-client'

class SlackClient
  def initialize(client_token)
    Slack.configure do |config|
      config.token = client_token
    end

    @client = Slack::Web::Client.new
  end

  def send_message(channel:, message_options:, as_user: false)
    @client.chat_postMessage(channel: channel, as_user: as_user, attachments: [message_options])
  end
end