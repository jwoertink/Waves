require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Waves" do
  
  let :options do
    opts = ARGV.clear
  end
  
  it "should load sample 1 with no options passed" do
    file = "1"
    sample = "sample#{file}"
    require "samples/#{sample}"
    options.should be_empty
    Object.const_get(sample.capitalize).should == Sample1
  end
  
  it "should load sample 1 with 1 passed as an argument" do
    options[0] = "1"
    file = options[0]
    sample = "sample#{file}"
    require "samples/#{sample}"
    options.should_not be_empty
    Object.const_get(sample.capitalize).should == Sample1
  end
  
  
end