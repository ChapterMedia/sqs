require "faraday"

require "sqs/version"
require "sqs/signature_middleware"
require "sqs/response_xml"
require "sqs/queue"
require "sqs/message"
require "sqs/responses"

module Sqs
  class RequestError < StandardError
    attr_reader :response
    def initialize(message, response)
      @response = response
      super(message)
    end
  end

  class Client
    attr_reader :access_key_id, :secret_access_key

    def initialize(options = {})
      config = options.fetch(:config, {})
      @access_key_id     = config[:access_key_id]
      @secret_access_key = config[:secret_access_key]
    end

    def create_queue(name, args = {})
      params = {
        :action     => "CreateQueue",
        :queue_name => name
      }.merge(args)

      response = get!("/", params)
      Queue.new(name, response.queue_url)
    end

    def get_queue(name)
      params = {
        :action    => "GetQueueUrl",
        :queue_name => name
      }
      response = get!("/", params)
      Queue.new(name, response.queue_url)
    end

    def send_message(queue, body)
      params = {
        :action => "SendMessage",
        :message_body => body
      }

      response = get!(queue.url, params)
      Message.new(queue, response.attributes)
    end

    def receive_message(queue)
      params = {
        :action => "ReceiveMessage"
      }

      response = get!(queue.url, params)

      unless response.empty_message?
        Message.new(queue, response.attributes)
      end
    end

    def delete_message(message)
      params = {
        :action => "DeleteMessage",
        :receipt_handle => message.receipt_handle
      }

      response = get!(message.queue_url, params)
      response.success?
    end

    private

    http_methods = [:get, :post, :put, :delete, :head]
    http_methods.each do |method|
      define_method(method) do |path, params = {}, headers = {}, &block|
        response = connection.send(method, path, camelize_params(params), headers, &block)
        wrap_response params[:action], response
      end
    end

    http_methods.each do |method|
      define_method("#{method}!") do |path, params = {}, headers = {}, &block|
        response = send(method, path, params, headers, &block)

        unless response.success?
          raise RequestError.new("Request failed", response)
        end

        response
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

    def camelize_params(args = {})
      args = args.map do |k, v|
        [camelize(k), v]
      end

      Hash[args]
    end

    # I don't want to require active support just for camelize, so I'll
    # just copy it for now
    def camelize(term)
      string = term.to_s
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
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
