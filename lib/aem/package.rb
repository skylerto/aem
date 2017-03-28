require 'net/http'
require 'net/https'
require 'uri'

module Aem

  DOWNLOAD_PATH = 'etc/packages'
  BUILD_PATH = 'crx/packmgr/service/.json/etc/packages'

  # Domain Model an AEM Package
  #
  # @author Skyler Layne
  class Package
    attr_accessor :name
    attr_accessor :group
    attr_accessor :version
    attr_accessor :downloadName
    attr_accessor :size
    attr_accessor :created
    attr_accessor :createdBy
    attr_accessor :lastModified
    attr_accessor :lastModifiedBy
    attr_accessor :lastUnpacked
    attr_accessor :lastUnpackedBy
    attr_accessor :info

    def initialize info=nil
      @info = info
    end


    # Download the package
    #
    # @param path [String] the path to the directory to download to.
    def download path='.'
      if @info.nil?
        raise "Info #{@info} cannot be null"
      end
      url = "http://#{@info.url}/#{DOWNLOAD_PATH}/#{@group}/#{@downloadName}"
      pack = "#{path}/#{@downloadName}"

      uri = URI(url)
      Net::HTTP.start(
        uri.host, uri.port,
        :use_ssl => uri.scheme == 'https',
        :verify_mode => OpenSSL::SSL::VERIFY_NONE
      ) do |http|
        request = Net::HTTP::Get.new uri.request_uri
        request.basic_auth @info.username, @info.password
        response = http.request request
        File.open(pack, 'wb') { |file| file.write(response.body) }
      end
      return pack
    end

    # Build the package
    #
    # @return [Net:HTTP] response object.
    def build
      pack = "#{BUILD_PATH}/#{@group}/#{@downloadName}"
      url = "http://#{@info.url}/#{pack}?cmd=build"
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth @info.username, @info.password
      request.content_type = 'application/x-www-form-urlencoded'
      res = http.request(request)
      raise "Failed to build package #{@downloadName}, server responded with code: #{res.code} and message #{res.body}" if res.code.to_i > 200
      return res
    end


    # A string representation of the current object
    #
    # @return [String] represent the package as a string.
    def to_s
      res = "name: #{@name}\n"
      res += "group: #{@group}\n"
      res += "version: #{@version}\n"
      res += "downloadName: #{@downloadName}\n"
      res += "size: #{@size}\n"
      res += "created: #{@created}\n"
      res += "createdBy: #{@createdBy}\n"
      res += "lastModified: #{@lastModified}\n"
      res += "lastModifiedBy: #{@lastModifiedBy}\n"
      res += "lastUnpacked: #{@lastUnpacked}\n"
      res += "lastUnpackedBy: #{@lastUnpackedBy}\n\n"
      return res
    end
  end
end
