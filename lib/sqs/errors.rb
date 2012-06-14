module Sqs
  class RequestError < StandardError
    attr_reader :response
    def initialize(message, response)
      @response = response
      super(message)
    end
  end

  class QueueNotFoundError < RequestError
  end
end
