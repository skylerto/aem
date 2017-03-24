require 'curb'

module Aem
  class AemCmd
    def initialize(info)
      @info = info
      @help_path = 'crx/packmgr/service.jsp?cmd=help'
      @list_package_path = 'crx/packmgr/service.jsp?cmd=ls'
      @build_package_path = 'crx/packmgr/service/.json/etc/packages/my_packages'
      @download_package_path = 'etc/packages/my_packages'
    end

    # => curl -u admin:admin http://localhost:4502/crx/packmgr/service.jsp?cmd=help
    def help
      c = Curl::Easy.new("http://#{@info.url}/#{@help_path}")
      c.http_auth_types = :basic
      c.username = @info.username
      c.password = @info.password
      c.perform
      return c.body_str
    end

    # => curl -u admin:admin http://localhost:4502/crx/packmgr/service.jsp?cmd=ls
    def list_packages
      c = Curl::Easy.new("http://#{@info.url}/#{@list_package_path}")
      c.http_auth_types = :basic
      c.username = @info.username
      c.password = @info.password
      c.perform
      return c.body_str
    end

    # =>  curl -u admin:admin -X POST http://localhost:4502/crx/packmgr/service/.json/etc/packages/my_packages/samplepackage.zip?cmd=build
    def build_packages *packages
      res = Hash.new
      packages.each do |package|
        res[package] = self.build_package package
      end
      return res
    end

    def build_package package
      pack = "#{@build_package_path}/#{package}.zip"
      c = Curl::Easy.new("http://#{@info.url}/#{pack}?cmd=build")
      c.http_auth_types = :basic
      c.username = @info.username
      c.password = @info.password
      c.http_post
      return c.body_str
    end

    # => curl -u admin:admin http://localhost:4502/etc/packages/my_packages/samplepackage.zip > <local filepath>
    def download_package package, path
      c = Curl::Easy.new("http://#{@info.url}/#{@download_package_path}/#{package}.zip")
      c.http_auth_types = :basic
      c.username = @info.username
      c.password = @info.password
      c.perform
      pack = "#{path}/#{package}.zip"
      File.open(pack, 'w') do |file|
        file << c.body_str
      end
      return pack
    end



  end
end
