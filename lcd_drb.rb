#!/usr/bin/env ruby

require 'drb'
require 'pi_lcd'

$lcd = PiLcd::Lcd.new

DRb.start_service 'druby://:9000', $lcd
puts "Server running at #{DRb.uri}"
 
trap("INT") { DRb.stop_service }
DRb.thread.join
