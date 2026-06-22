module SqlAccount
  class Configuration

    attr_accessor :host, :port, :database, :username, :password, :encoding

    def initialize
      @port = 3050
      @encoding = 'UTF-8'
    end

    def to_h 
      {
        adapter: 'firebird',
        host: host,
        database: database, 
        username: username, 
        password: password, 
        encoding: encoding
      }
    end

  end
end