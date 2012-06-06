require 'openssl'
require 'base64'
require 'time'

module Sqs
  class Signature
    attr_reader :url, :host, :method, :query, :path, :access_key

    def initialize(access_key, url, host, method, query, path)
      @access_key = access_key

      @url    = url
      @host   = host
      @method = method
      @query  = query
      @path   = path
    end

    def to_s
      generate
    end

    private

    def generate
      message = ""
      message << method
      message << "\n"
      message << host
      message << "\n"
      message << path
      message << "\n"
      message << canonical_query_string(query)

      digest = OpenSSL::Digest::Digest.new("sha256")
      hmac = OpenSSL::HMAC.digest(digest, access_key, message)
      base64 = Base64.encode64(hmac)
      base64.chomp
    end

    def canonical_query_string(query)
      query.split("&").sort.join("&")
    end
  end

  class SignatureMiddleware < Faraday::Response::Middleware
    attr_reader :secret_access_key
    def initialize(app = nil, options = {})
      super(app)
      @options = options

      @secret_access_key = options[:secret_access_key]
    end

    def call(env)
      headers = env[:request_headers]

      env[:url].query << "&Timestamp=#{CGI.escape(Time.now.utc.iso8601)}"
      env[:url].query << "&SignatureMethod=HmacSHA256&SignatureVersion=2"
      env[:url].query << "&Signature=#{CGI.escape(signature(env))}"

      @app.call(env)
    end

    private

    def signature(env)
      url    = env[:url]
      host   = url.host
      method = env[:method].to_s.upcase
      query  = url.query
      path   = url.path

      Signature.new(secret_access_key, url, host, method, query, path).to_s
    end
  end
end
