require 'spec_helper'

describe Jemmy do
  it "should have a version number" do
    Jemmy::VERSION.should_not be_nil 
  end

  it 'should allow me to new a CLI' do
    # Jemmy::CLI.new.should_not be_nil
  end
end