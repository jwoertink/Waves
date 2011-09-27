require 'java'

PROJECT_ROOT = File.expand_path('..', File.dirname(__FILE__))

require File.join(PROJECT_ROOT, 'vendor', 'jme3_2011-08-29.jar')

module Waves
  VERSION = "0.0.1"
  
  def self.start(file = "1")
    sample = "sample#{file}"
    begin
      require sample
      Object.const_get(sample.capitalize).new.start
    rescue Exception => e
      warn "#{e}"
    end
  end
  
  def self.samples
    @sample ||= Dir.glob(File.join(PROJECT_ROOT, 'lib', 'sample?.rb'))
  end
  
end