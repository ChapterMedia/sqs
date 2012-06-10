module Sqs
  class RetryMiddleware < Faraday::Middleware
    def initialize(app, retries = 2)
      @retries = retries
      super(app)
    end

    def call(env)
      retries = @retries
      begin
        @app.call(env)
      rescue Faraday::Error::TimeoutError, Errno::EPIPE, Errno::EINVAL, EOFError => e
        if retries > 0
          retries -= 1
          retry
        end
        raise
      end
    end
  end
end
