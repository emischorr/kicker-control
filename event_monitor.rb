#!/usr/bin/env ruby

require 'uri'
require 'pi_piper'
require 'redis'

class EventMonitor
  include PiPiper

  PIN_GOAL_1 = 17
  PIN_GOAL_2 = 27
  TIMEOUT = 3 # time in seconds

  REDIS_URL = "redis://localhost:6379"

  def initialize
    @@last_goal = Time.now.to_i
    uri = URI.parse REDIS_URL
    @@redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end

  def start
    after :pin => PIN_GOAL_1, :goes => :high, :pull => :up do
      if Time.now.to_i >= @@last_goal + TIMEOUT
        puts "GOAL TEAM 1"
        @@redis.publish "event.goal", 1
        @@last_goal = Time.now.to_i
      end
    end
    after :pin => PIN_GOAL_2, :goes => :high, :pull => :up do
      if Time.now.to_i >= @@last_goal + TIMEOUT
        puts "GOAL TEAM 2"
        @@redis.publish "event.goal", 2
        @@last_goal = Time.now.to_i
      end
    end

    PiPiper.wait
  end
end

File.write "/tmp/event_monitor.pid", Process.pid
EventMonitor.new.start