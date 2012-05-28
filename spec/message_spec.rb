require 'spec_helper'

describe Sqs::Message do
  it "raises an error if queue is not provided" do
    lambda {
      Sqs::Message.new
    }.should raise_error(ArgumentError)
  end

  it "allows to pass attributes hash" do
    message = Sqs::Message.new(double("queue"), {
      :id   => "id",
      :body => "body",
      :receipt_handle => "receipt_handle"
    })

    message.id.should   == "id"
    message.body.should == "body"
    message.receipt_handle.should == "receipt_handle"
  end

  context "#queue_name" do
    it "returns queue name" do
      queue = double("queue")
      queue.should_receive(:name).and_return("foo")
      Sqs::Message.new(queue).queue_name.should == "foo"
    end
  end
end
