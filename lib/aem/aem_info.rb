module Aem
  class Info
    attr_accessor :url, :username, :password
    def initialize(hash)
      @url = hash['url']
      @username = hash['username']
      @password = hash['password']
    end

    def to_s
      res = "URL: #{@url}\n"
      res += "Username: #{@username}\n"
      res += "password supressed"
      res
    end
  end
end
