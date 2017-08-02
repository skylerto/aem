module Aem

  # Class representation of the info needed to interact with the AEM server.
  #
  # @author Skyler Layne
  class Info
    attr_accessor :url, :username, :password
    def initialize(hash)
      @url = hash['url']
      @username = hash['username']
      @password = hash['password']
    end

    # A string.
    #
    # @return [String] string representation of the class.
    def to_s
      res = "URL: #{@url}\n"
      res += "Username: #{@username}\n"
      res += "password supressed"
      res
    end
  end
end
