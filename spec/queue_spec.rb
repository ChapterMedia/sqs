require 'spec_helper'

describe Sqs::Queue do
  it "raises an error if queue is not provided" do
    lambda {
      Sqs::Queue.new
    }.should raise_error(ArgumentError)
  end
end
