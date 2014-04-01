require 'java'
require 'jruby/core_ext'

PROJECT_ROOT = File.expand_path('..', File.dirname(__FILE__))
$CLASSPATH << File.join(PROJECT_ROOT, "package", "classes", "java")

$: << File.join(PROJECT_ROOT, "lib")

require File.join(PROJECT_ROOT, 'vendor', 'jme3-2014-3-31.jar')

module Waves
  VERSION = "0.4.0"

  COLORS = {
    :black  => "\e[30m",
    :red    => "\e[31m",
    :green  => "\e[32m",
    :yellow => "\e[33m",
    :blue   => "\e[34m",
    :magenta=> "\e[35m",
    :cyan   => "\e[36m",
    :white  => "\e[37m",
    :reset  => "\e[0m"
  }

  def self.start(file = "1")
    sample = "sample#{file}"
    begin
      require "samples/#{sample}"
      echo("Starting Sample #{file}", :green)
      Object.const_get(sample.capitalize).new.start
    rescue Exception => e
      warn "#{e}"
    end
  end

  def self.samples
    @samples ||= Dir.glob(File.join(PROJECT_ROOT, 'lib', 'samples', "*.rb"))
  end

  def self.echo(words, color = :white)
    puts "#{COLORS[color]}#{words}#{COLORS[:reset]}"
  end

end