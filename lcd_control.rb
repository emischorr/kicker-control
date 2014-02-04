#!/usr/bin/env ruby

require 'socket'
require 'uri'
require 'pi_lcd'
require 'redis'

class LcdControl
  REDIS_URL = "redis://localhost:6379"
  SUPPORTED_CMDS = ["text", "screen", "centered", "on", "off", "cls", "return_line", "return_home", "set_line", "next_line"]

  def initialize
    uri = URI.parse REDIS_URL
    @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end

  def start
    lcd = PiLcd::Lcd.new

    lcd.return_home
    Socket.ip_address_list.each do |addr|
      lcd.centered "IP: #{addr.ip_address}" unless addr.ipv4_loopback?
      lcd.next_line
    end

    @redis.psubscribe('lcd.*') do |on|
      on.pmessage do |match, channel, message|
        puts "match: #{match}, channel: #{channel}, message: #{message}"
        cmd = channel[/lcd.([a-z]*)/, 1]
        if SUPPORTED_CMDS.include? cmd
          message.empty? ? lcd.send(cmd) : lcd.send(cmd, message)
        else
          puts "Method '#{cmd}' not supported!"
        end
      end
    end
  end
end

File.write "/tmp/lcd_control.pid", Process.pid
LcdControl.new.start
