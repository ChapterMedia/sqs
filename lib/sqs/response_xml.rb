require 'nokogiri'

module Sqs
  class ResponseXML < Faraday::Response::Middleware
    def on_complete(env)
      env[:body] = Nokogiri::XML env[:body]
    end
  end
end
