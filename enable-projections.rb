#!/usr/bin/env ruby --disable-gems

require 'net/http'

port = ENV['EVENT_STORE_PORT'] || '2113'
host = ENV['EVENT_STORE_HOST'] ||= 'localhost'

if ENV.key? 'PROJECTIONS'
  projections = ENV['PROJECTIONS'].split ','
else
  projections = %w(
    by_category
    by_event_type
    streams
    stream_by_category
  )
end

puts <<~TEXT

Enabling Projections (Host: #{host}, Port: #{port})
= = =

TEXT

Net::HTTP.start host, port.to_i do |http|
  projections.each do |projection|
    path = "/projection/%24#{projection}/command/enable"

    puts <<~TEXT
    Enabling #{projection}
    - - -
    TEXT

    request = Net::HTTP::Post.new path
    request.basic_auth 'admin', 'changeit'

    puts "Request: POST #{path}"

    response = http.request request

    puts <<~TEXT
    Response: #{response.code} #{response.message}

    TEXT
  end
end

puts <<~TEXT
= = =
done
TEXT
