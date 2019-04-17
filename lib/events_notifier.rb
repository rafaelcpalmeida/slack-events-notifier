#!/usr/bin/env ruby

require_relative 'slack_client'
require_relative 'calendar_parser'
require 'selene'
require 'time'
require 'mustache'

class EventSlackNotifier
	def initialize(slack_client:, calendar_file:, channels:, message:, days_before_alert:)
		@slack_client = slack_client

		@today = Date.today

		@ical = Selene.parse(calendar_file)

		@channels = channels
		@message = message
		@days_before_alert = days_before_alert
	end

	def analise_events
		@ical['vcalendar'][0]['vevent'].each do |event|
			date_time_format = (event['event-allday'] == 'true') ? '%Y%m%d' : '%Y%m%dT%H%M%S'

			event_details = Time.strptime([event['dtstart']].flatten.first, date_time_format)

			if event_details.to_date - @days_before_alert == @today
				replacements = {
					event_date: event_details.to_date.strftime('%d/%m'),
					event_title: event['summary'],
					starting_hour: event_details.hour.to_s,
					starting_minute: event_details.min.to_s,
					time_zone: event_details.zone,
					location: event['location']
				}

				rendered_message = Mustache.render(@message, replacements)

				@channels.split(',').each do |channel|
					notify_channel(channel: channel, message: rendered_message)
				end
			end
		end
	end

	def notify_channel(channel:, message:)
		@slack_client.send_message(channel: channel, as_user: true, message_options: {color: '#36a64f', text: message})
	end
end
