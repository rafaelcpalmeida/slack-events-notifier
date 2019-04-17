#!/usr/bin/env ruby

require 'net/https'
require 'uri'

class CalendarParser
  def self.ics_file(calendar_url:)
    uri = URI.parse(calendar_url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    raise Net::HTTPError.new("Error. Couldn't access given URL. Error code: #{response.code}", response) unless response.code == '200'

    response.body
  end
end