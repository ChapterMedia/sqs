require "faraday"

require "sqs/version"
require "sqs/signature_middleware"
require "sqs/response_xml"
require "sqs/queue"
require "sqs/message"
require "sqs/responses"

module Sqs
  class Client
    attr_reader :access_key_id, :secret_access_key

    def initialize(options = {})
      config = options.fetch(:config, {})
      @access_key_id     = config[:access_key_id]
      @secret_access_key = config[:secret_access_key]
    end

    def create_queue(name)
      params = {
        :Action    => "CreateQueue",
        :QueueName => name
      }
      response = get("/", params)

      if response.success?
        Queue.new(name, response.queue_url)
      end
    end

    def get_queue(name)
      params = {
        :Action    => "GetQueueUrl",
        :QueueName => name
      }
      response = get("/", params)

      if response.success?
        Queue.new(name, response.queue_url)
      end
    end

    def send_message(queue, body)
      params = {
        :Action => "SendMessage",
        :MessageBody => body
      }

      response = get(queue.url, params)

      if response.success?
        Message.new(queue, response.attributes)
      end
    end

    def receive_message(queue)
      params = {
        :Action => "ReceiveMessage"
      }

      response = get(queue.url, params)

      if response.success?
        Message.new(queue, response.attributes)
      end
    end

    def delete_message(message)
      params = {
        :Action => "DeleteMessage",
        :ReceiptHandle => message.receipt_handle
      }

      response = get(message.queue_url, params)

      response.success?
    end

    private

    [:get, :post, :put, :delete, :head].each do |method|
      define_method(method) do |path, params = {}, headers = {}, &block|
        response = connection.send(method, path, params, headers, &block)
        wrap_response params[:Action], response
      end
    end

    def wrap_response(action, response)
      class_name = "#{action}Response"
      klass = if (200..299).include?(response.status) && Sqs.const_defined?(class_name)
        Sqs.const_get(class_name)
      else
        Sqs::Response
      end

      klass.new(response)
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
