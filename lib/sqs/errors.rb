module Sqs
  class RequestError < StandardError
    attr_reader :response
    def initialize(message, response)
      @response = response
      super(message)
    end

    def self.from_response(response)
      code = code(response)

      # TODO: refactor if there is need for more cases
      if code == "AWS.SimpleQueueService.NonExistentQueue"
        QueueNotFoundError.new("Queue could not be found", response)
      else
        RequestError.new("Request failed: #{code}", response)
      end
    end

    def self.code(response)
      element = response.xml.css("Code").first
      element && element.text
    end
  end

  class QueueNotFoundError < RequestError
  end
end
