#!/usr/bin/env ruby

require 'uri'
require 'pi_piper'
require 'redis'

class EventMonitor
  include PiPiper

  PIN_GOAL_1 = 11
  PIN_GOAL_2 = 13

  REDIS_URL = "redis://localhost:6379"

  def initialize
    uri = URI.parse REDIS_URL
    @@redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end

  def start
    after :pin => PIN_GOAL_1, :goes => :low do
      puts "GOAL TEAM 1"
      @@redis.publish "event.goal", 1
    end
    after :pin => PIN_GOAL_2, :goes => :low do
      puts "GOAL TEAM 2"
      @@redis.publish "event.goal", 2
    end

    PiPiper.wait
  end
end

File.write "/tmp/event_monitor.pid", Process.pid
EventMonitor.new.start
