require 'spec_helper'

describe Sqs::Client do
  let(:client) do
    Sqs::Client.new(:config => { :access_key_id => "abc", :secret_access_key => "def" })
  end

  context "#create_queue" do
    it "makes a request to create and returns a queue" do
      body = sample_response("create_queue")

      stub_request(:get, /.*/).with do |request|
        request.uri.to_s =~ /Action=CreateQueue/ &&
          request.uri.to_s =~ /QueueName=foo/
      end.to_return(:status => 200, :body => body)

      queue = client.create_queue("foo")
      queue.name.should == "foo"
      queue.url.should  == "http://sqs.us-east-1.amazonaws.com/123456789012/foo"
    end

    it "passes the options for creation (camel cased)" do
      body = sample_response("create_queue")

      stub_request(:get, /.*/).with do |request|
        request.uri.to_s =~ /Action=CreateQueue/ &&
          request.uri.to_s =~ /QueueName=foo/ &&
          request.uri.to_s =~ /MaximumMessageSize=1/
      end.to_return(:status => 200, :body => body)

      queue = client.create_queue("foo", :maximum_message_size => 1)
      queue.name.should == "foo"
    end
  end

  context "#get_queue" do
    it "returns a queue" do
      body = sample_response("get_queue_url")

      stub_request(:get, /.*/).with do |request|
        request.uri.to_s =~ /Action=GetQueueUrl/ &&
          request.uri.to_s =~ /QueueName=foo/
      end.to_return(:status => 200, :body => body)

      queue = client.get_queue("foo")
      queue.name.should == "foo"
      queue.url.should  == "http://sqs.us-east-1.amazonaws.com/123456789012/foo"
    end
  end

  context "#receive_message" do
    it "returns a message" do
      body = sample_response("receive_message")
      queue = Sqs::Queue.new("foo", "https://queue.url/queue/foo")

      stub_request(:get, /.*/).with do |request|
        request.uri.to_s =~ /Action=ReceiveMessage/ &&
          request.uri.to_s =~ /https:\/\/queue.url:443\/queue\/foo/
      end.to_return(:status => 200, :body => body)

      message = client.receive_message(queue)
      message.receipt_handle.should == "MbZj6wDWli"
      message.id.should == "5fea7756-0ea4-451a-a703-a558b933e274"
      message.body.should == "This is a test message"
    end
  end

  context "#send_message" do
    it "sends and returns mesage" do
      body = sample_response("send_message")
      queue = Sqs::Queue.new("foo", "https://queue.url/queue/foo")

      stub_request(:get, /.*/).with do |request|
        request.uri.to_s =~ /Action=SendMessage/ &&
          request.uri.to_s =~ /MessageBody=message-body/ &&
          request.uri.to_s =~ /https:\/\/queue.url:443\/queue\/foo/
      end.to_return(:status => 200, :body => body)

      message = client.send_message(queue, "message-body")
      message.id.should == "5fea7756-0ea4-451a-a703-a558b933e274"
    end
  end

  context "#delete_message" do
    it "deletes a message" do
      body = sample_response("delete_message")
      queue = Sqs::Queue.new("foo", "https://queue.url/queue/foo")
      message = Sqs::Message.new(queue, { :receipt_handle => "abc123" })

      stub_request(:get, /.*/).with do |request|
        request.uri.to_s =~ /Action=DeleteMessage/ &&
          request.uri.to_s =~ /https:\/\/queue.url:443\/queue\/foo/ &&
          request.uri.to_s =~ /ReceiptHandle=abc123/
      end.to_return(:status => 200, :body => body)

      client.delete_message(message).should be_true
    end
  end
end
