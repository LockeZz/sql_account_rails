module SqlAccount
  class Configuration

    attr_accessor :host, :port, :database, :username, :password, :encoding

    def initialize
      @port = 3050
      @encoding = "UTF-8"
    end

    class << self
      
      def configure
        yield(configuration)
      end

      def configuration
        @configuration ||= Configuration.new
      end

      def establish_connection!
        ActiveRecord::Base.establish_connection(
          adapter: "firebird",
          host: configuration.host,
          port: configuration.port,
          database: configuration.database,
          username: configuration.username,
          password: configuration.password,
          encoding: configuration.encoding
        )
      end

  end
end