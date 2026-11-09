module SqlAccount
  class Configuration

    attr_accessor :host, :port, :database, :username, :password, :encoding, :pool, :checkout_timeout, :idle_timeout

    def initialize
      @port = 3050
      @encoding = 'UTF-8'
      @pool = 5
      @checkout_timeout = 5
      @idle_timeout = 300
    end

    def to_h 
      {
        adapter: 'firebird',
        host: host,
        port: port && port.to_i,
        database: database, 
        username: username, 
        password: password, 
        encoding: encoding,
        pool: pool,
        checkout_timeout: checkout_timeout,
        idle_timeout: idle_timeout
    }.compact
    end

  end
end