require 'java'

PROJECT_ROOT = File.expand_path('..', File.dirname(__FILE__))

require File.join(PROJECT_ROOT, 'vendor', 'jme3_2011-08-29.jar')

module Waves
  VERSION = "0.0.1"
  
  def self.start(file = "sample1")
    begin
      require file
      Object.const_get(file.capitalize).new.start
    rescue Exception => e
      warn "#{e}"
    end
  end
  
end