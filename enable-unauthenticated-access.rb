#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'securerandom'

port = ENV['EVENT_STORE_PORT'] || '2113'
host = ENV['EVENT_STORE_HOST'] ||= 'localhost'

puts <<~TEXT

Enabling System Stream Reads (Host: #{host}, Port: #{port})
= = =

TEXT

Net::HTTP.start(host, port.to_i) do |http|
  path = "/streams/$settings"

  puts <<~TEXT
  Updating default ACL
  - - -
  TEXT

  body = JSON.pretty_generate({
    '$userStreamAcl' => {
      '$r' => '$all',
      '$w' => '$all',
      '$d' => '$all',
      '$mr' => '$all',
      '$mw' => '$all'
    },

    '$systemStreamAcl' => {
      '$r' => '$all',
      '$w' => '$all',
      '$d' => '$all',
      '$mr' => '$all',
      '$mw' => '$all'
    }
  })


  post = Net::HTTP::Post.new(path)
  post.basic_auth('admin', 'changeit')
  post['Content-Type'] = 'application/json'
  post['ES-EventType'] = 'settings'
  post['ES-EventId'] = SecureRandom.uuid
  post.body = body

  response = http.request(post)

  puts <<~TEXT
  Response: #{response.code} #{response.message}

  TEXT
end

puts <<~TEXT
= = =
done
TEXT
