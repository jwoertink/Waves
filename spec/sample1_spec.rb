require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'sample1'

describe "Sample1" do
  
  before(:all) do
    @app = Sample1.new
  end
  
  it "should respond to start" do
    @app.should respond_to :start
  end
  
end