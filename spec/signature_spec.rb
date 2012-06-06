require 'spec_helper'

describe 'signature' do
  it "calculates proper signature" do
    access_key = "abc"
    url    = "http://example.org"
    host   = "example.org"
    method = "GET"
    query  = "b=foo&a=bar"
    path   = "/path"

    sig = Sqs::Signature.new(access_key, url, host, method, query, path)
    sig.to_s.should == "ra7PUroL5vhGzqQARC52B7iDUCxcc0dhA2SQS+mAj20="
  end

  it "does not escape query string values, faraday already does it" do
    config = { :access_key_id => "abc", :secret_access_key => "efg" }
    time   = Time.new(2012, 1, 1, 1, 1)
    sqs    = Sqs::Client.new :config => config

    url = "https://sqs.us-east-1.amazonaws.com:443/?AWSAccessKeyId=abc&Action=::&Signature=aptVnZbtBBOeCET7jUFhttjM8hClhiSN1fL9Nf7o+U8=&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2012-01-01T00:01:00Z&Version=2011-10-01"
    stub_request(:any, /.*/).with do |request|
      request.uri.to_s == url
    end.to_return(:status => 200, :body => "<xml></xml>")

    Timecop.freeze(time) do
      sqs.get("/", :Action => "::")
    end
  end

  it "attaches signature data to request" do
    config = { :access_key_id => "abc", :secret_access_key => "efg" }
    time   = Time.new(2012, 1, 1, 1, 1)
    sqs    = Sqs::Client.new :config => config

    url = "https://sqs.us-east-1.amazonaws.com:443/?AWSAccessKeyId=abc&Action=Create&Signature=9PpxZlqjhn37pukmH0I9PoGa+eM0BTTmERPmruW54Kg=&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2012-01-01T00:01:00Z&Version=2011-10-01"
    stub_request(:any, /.*/).with do |request|
      request.uri.to_s == url
    end.to_return(:status => 200, :body => "<xml></xml>")

    Timecop.freeze(time) do
      sqs.get("/", :Action => "Create")
    end
  end
end

