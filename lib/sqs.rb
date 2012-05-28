require "faraday"

require "sqs/version"
require "sqs/signature_middleware"
require "sqs/response_xml"

module Sqs
  class Client
    attr_reader :access_key_id, :secret_access_key

    def initialize(options = {})
      config = options.fetch(:config, {})
      @access_key_id     = config[:access_key_id]
      @secret_access_key = config[:secret_access_key]
    end

    private

    [:get, :post, :put, :delete, :head].each do |method|
      define_method(method) do |*args, &block|
        connection.send(method, *args, &block)
      end
    end

    def connection
      @connection ||= begin
        Faraday.new(:url => 'https://sqs.us-east-1.amazonaws.com') do |builder|
          builder.use Faraday::Request::UrlEncoded
          builder.use Sqs::SignatureMiddleware, :access_key_id => access_key_id, :secret_access_key => secret_access_key
          builder.use Sqs::ResponseXML
          builder.use Faraday::Adapter::NetHttp
        end.tap do |connection|
          connection.headers["Content-Type"] = "application/xml; charset=utf-8"
          connection.headers["Accept"]       = "application/xml"
          connection.params = connection.params.merge({
            "AWSAccessKeyId"  => access_key_id,
            "Version"         => "2011-10-01"
          })
        end
      end
    end
  end
end
