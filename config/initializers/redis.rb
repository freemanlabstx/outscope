module JumpstartApp
  class Application < Rails::Application
    def self.redis
      @redis ||= ConnectionPool::Wrapper.new do
        Redis.new(
          url: Rails.application.credentials[:redis_url] || ENV["REDIS_URL"]
        )
      end
    end
  end
end
