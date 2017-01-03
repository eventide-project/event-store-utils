#!/usr/bin/env ruby --disable-gems

at_exit do
  StartEventStore.(ARGV)
end

require 'optparse'
require 'resolv'

module StartEventStore
  def self.call(argv)
    parser = Options::Parser.new

    options = parser.(argv)

    command = Command.new options

    puts <<~TEXT

    Starting EventStore
    = = =

    Command: #{command}
    - - -

    TEXT

    if options.dry_run
      puts "Dry-run was specified; exiting"
      puts

      exit 0
    end

    Dir.chdir 'event-store' do
      exec *command.to_a
    end
  end

  class Command
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def bind_address
      index = options.cluster_member - 1

      ip_addresses.fetch index
    end

    def cluster?
      cluster_size > 1
    end

    def cluster_size
      ip_addresses.count
    end

    def ip_addresses
      @ip_addresses ||=
        begin
          if options.host == 'localhost'
            ['127.0.0.1']
          else
            Resolv.getaddresses(options.host).map &:to_s
          end
        end
    end

    def to_a
      ary = %W(
        ./run-node.sh
        --mem-db
        --run-projections=System
        --start-standard-projections
        --int-ip=#{bind_address}
        --ext-ip=#{bind_address}
        --int-tcp-port=#{options.int_tcp_port}
        --ext-tcp-port=#{options.ext_tcp_port}
        --int-http-port=#{options.int_http_port}
        --ext-http-port=#{options.ext_http_port}
      )

      if cluster?
        ary.concat %W(
          --cluster-dns=#{options.host}
          --cluster-gossip-port=#{options.int_http_port}
          --cluster-size=#{cluster_size}
          --discover-via-dns=true
        )
      end

      ary
    end

    def to_s
      to_a * ' '
    end
  end

  Options = Struct.new :cluster_member, :dry_run, :host, :ext_http_port

  class Options
    attr_accessor :clustering_enabled

    def self.build
      new(
        Defaults.cluster_member,
        Defaults.dry_run,
        Defaults.host,
        Defaults.ext_http_port
      )
    end

    def int_tcp_port
      int_http_port - 1000
    end

    def ext_tcp_port
      ext_http_port - 1000
    end

    def int_http_port
      ext_http_port - 1
    end

    module Defaults
      def self.cluster_member
        1
      end

      def self.dry_run
        false
      end

      def self.host
        'localhost'
      end

      def self.ext_http_port
        2113
      end
    end

    class Parser
      def call(argv)
        OptionParser.new do |option_parser|
          option_parser.banner = "Usage: #{File.basename $PROGRAM_NAME} [options]"

          option_parser.on '-d', '--dry-run', "Does not start EventStore; instead, prints the command that would be run (default is #{Defaults.dry_run})" do
            options.dry_run = true
          end

          option_parser.on '--host HOST', "Binds EventStore to IP-ADDRESS (default is #{Defaults.host})" do |host|
            options.host = host
          end

          option_parser.on '-m INDEX', '--member INDEX', Integer, "If multiple IP addresses are resolved from host, reference INDEX to identify specific bind address (default is #{Defaults.cluster_member})" do |index|
            options.cluster_member = index
          end

          option_parser.on '-p PORT', '--port PORT', '--ext-http-port PORT', Integer, "Specifies PORT as the external HTTP port (default is #{Defaults.ext_http_port})" do |port|
            options.ext_http_port = port.to_i
          end

          option_parser.on '-h', '--help', "Prints this help message and exits" do
            puts option_parser
            exit 0
          end
        end.parse! argv

        options
      end

      def options
        @options ||= Options.build
      end
    end
  end
end
