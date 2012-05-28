module Sqs
  class Message
    attr_reader :queue, :id, :body, :receipt_handle

    def initialize(queue, attrs = {})
      @queue = queue || raise(ArgumentError, "Please provide a queue")
      @id    = attrs[:id]
      @body  = attrs[:body]
      @receipt_handle = attrs[:receipt_handle]
    end

    def queue_name
      queue.name
    end

    def queue_url
      queue.url
    end
  end
end
