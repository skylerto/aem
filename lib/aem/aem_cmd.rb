require 'curb'
require 'nokogiri'

module Aem
  class AemCmd
    def initialize(info)
      @info = info
      @help_path = 'crx/packmgr/service.jsp?cmd=help'
      @list_package_path = 'crx/packmgr/service.jsp?cmd=ls'
      @build_package_path = 'crx/packmgr/service/.json/etc/packages/my_packages'
      @download_package_path = 'etc/packages/my_packages'
      @upload_package_path = 'crx/packmgr/service.jsp'
    end

    # => curl -u admin:admin http://localhost:4502/crx/packmgr/service.jsp?cmd=help
    def help
      c = Curl::Easy.new("http://#{@info.url}/#{@help_path}")
      c.http_auth_types = :basic
      c.username = @info.username
      c.password = @info.password
      c.perform
      res = c.body_str
      xml = Nokogiri::XML(res)
      return xml.xpath('//data').text
    end

    def package_info name, property='name'
      packages = self.list_packages
      res = packages.select do |pkg|
        pkg[property].eql? name
      end
      return res
    end

    # => curl -u admin:admin http://localhost:4502/crx/packmgr/service.jsp?cmd=ls
    def list_packages value=''
      c = Curl::Easy.new("http://#{@info.url}/#{@list_package_path}")
      c.http_auth_types = :basic
      c.username = @info.username
      c.password = @info.password
      c.perform
      body = c.body_str
      xml = Nokogiri::XML(body)
      res = []
      xml.search("//package").each do |pkg|
        name = pkg.at('name').inner_text
        res << {
          'name' => pkg.at('name').inner_text,
          'group' => pkg.at('group').inner_text,
          'version' => pkg.at('version').inner_text,
          'downloadName' => pkg.at('downloadName').inner_text,
          'size' => pkg.at('size').inner_text,
          'created' => pkg.at('created').inner_text,
          'createdBy' => pkg.at('createdBy').inner_text,
          'lastModified' => pkg.at('lastModified').inner_text,
          'lastModifiedBy' => pkg.at('lastModifiedBy').inner_text,
          'lastUnpacked' => pkg.at('lastUnpacked').inner_text,
          'lastUnpackedBy' => pkg.at('lastUnpackedBy').inner_text
        }
      end
      if value.eql? ''
        return res
      else
        other = []
        res.each do |pkg|
          other << {
            value => pkg[value]
          }
        end
        return other
      end
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
      return c
    end

    # => curl -u admin:admin -X POST http://localhost:4502/crx/packmgr/service/.json/etc/packages/my_packages/samplepackage.zip?cmd=install
    def install_package package
      pack = "#{@build_package_path}/#{package}.zip"
      c = Curl::Easy.new("http://#{@info.url}/#{pack}?cmd=install")
      c.http_auth_types = :basic
      c.username = @info.username
      c.password = @info.password
      c.http_post
      return c
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

    # => curl -u admin:admin -F file=@"C:\sample\samplepackage.zip" -F name="samplepackage" -F force=true -F install=false http://localhost:4502/crx/packmgr/service.jsp
    def upload_package(file, name)
      c = Curl::Easy.new("http://#{@info.url}/#{@upload_package_path}")
      c.http_auth_types = :basic
      c.username = @info.username
      c.password = @info.password
      c.multipart_form_post = true
      c.http_post(
        Curl::PostField.file('file', file),
        Curl::PostField.content('name', name)
      )
      return c
    end
  end
end
