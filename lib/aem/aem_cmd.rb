require 'curb'
require 'nokogiri'
require 'set'
require_relative './package'

module Aem

  # Commands that can be executed via AEM.
  #
  # @author Skyler Layne
  class AemCmd
    def initialize(info)
      @info = info
      @help_path = 'crx/packmgr/service.jsp?cmd=help'
      @list_package_path = 'crx/packmgr/service.jsp?cmd=ls'
      @install_package_path = 'crx/packmgr/service/.xml/etc/packages'
      @upload_package_path = 'crx/packmgr/service.jsp'
      @tree_activate_path = 'etc/replication/treeactivation.html'
    end

    # Grabs the help menu from AEM
    #
    # @example
    #   equivalent to curl -u admin:admin http://localhost:4502/crx/packmgr/service.jsp?cmd=help
    # @return [String] the help data.
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

    # Find package info using value, key
    #
    # @param name [String] the value to search for.
    # @param property [String] the key to search on.
    # @return [Hash] properties of the package.
    def package_info name, property='name'
      packages = self.list_packages
      res = packages.select do |pkg|
        pkg.instance_variable_get("@#{property}").eql? name
      end
      return res
    end

    # List Packages in AEM
    #
    # @example
    #   equivalent to curl -u admin:admin http://localhost:4502/crx/packmgr/service.jsp?cmd=ls
    # @return [Array] an array of package info as a Hash
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
        pack = Aem::Package.new
        pack.name = pkg.at('name').inner_text
        pack.group = pkg.at('group').inner_text
        pack.version = pkg.at('version').inner_text
        pack.downloadName = pkg.at('downloadName').inner_text
        pack.size = pkg.at('size').inner_text
        pack.created = pkg.at('created').inner_text
        pack.createdBy = pkg.at('createdBy').inner_text
        pack.lastModified = pkg.at('lastModified').inner_text
        pack.lastModifiedBy = pkg.at('lastModifiedBy').inner_text
        pack.lastUnpacked = pkg.at('lastUnpacked').inner_text
        pack.lastUnpackedBy = pkg.at('lastUnpackedBy').inner_text
        res << pack
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

    # Build a single package
    #
    # @param package [String] the name of the package to build.
    # @return [String] the response from the server
    def build_package package, group='my_packages'
      pack = get_package package
      pack.info = @info
      return pack.build
    end

    # Install a package
    #
    # @param package [String] the name of the package to install.
    # @return [Curl::Easy] the Curl object.
    def install_package package, group='my_packages'
      pack = "#{@install_package_path}/#{group}/#{package}.zip"
      c = Curl::Easy.new("http://#{@info.url}/#{pack}?cmd=install")
      c.http_auth_types = :basic
      c.username = @info.username
      c.password = @info.password
      c.http_post
      res = Set.new
      c.body_str.split('<br>').each do |br|
        content = Nokogiri::HTML(br)
        path = content.css('.\-').text.strip
        path = path.slice(2, path.size)
        res << path unless path.nil? || path.empty?
      end
      return res.to_a
    end

    # Download a package
    #
    # @param package [String] the name of the package to download.
    # @param path [String] the path to activate.
    # @return [String] the path to the downloaded zip.
    def download_package package, path='.'
      pack = get_package package
      pack.info = @info
      return pack.download(path)
    end

    # Upload a package with a name
    #
    # @param file [String] the zip file to upload
    # @param name [String] the name of the package in AEM
    # @return [Curl::Easy] the curl output.
    def upload_package(file, name, force='true', install='false')
      c = Curl::Easy.new("http://#{@info.url}/#{@upload_package_path}")
      c.http_auth_types = :basic
      c.username = @info.username
      c.password = @info.password
      c.multipart_form_post = true
      c.http_post(
        Curl::PostField.file('file', file),
        Curl::PostField.content('name', name),
        Curl::PostField.content('force', force),
        Curl::PostField.content('install', install)
      )
      return c
    end

    # Activate a path
    #
    # @param path [String] the path to activate
    # @param modified [Boolean] boolean to activitate only modified content,
    # defaulting to true.
    # @return [Hash] Hash of path, status
    def activate path, modified='true'
      c = Curl::Easy.new("http://#{@info.url}/#{@tree_activate_path}")
      c.http_auth_types = :basic
      c.username = @info.username
      c.password = @info.password
      c.http_post(
        Curl::PostField.content('cmd', 'activate'),
        Curl::PostField.content('ignoredeactivated', 'true'),
        Curl::PostField.content('onlymodified', modified),
        Curl::PostField.content('path', path)
      )
      content = Nokogiri::HTML(c.body_str)
      res = content

      err = content.css('.error')
      if err && !err.empty?
        res = err
      else
        res = []
        c.body_str.split('<br>').each do |br|
          content = Nokogiri::HTML(br)
          status = content.css('.action').text.strip.split(' ')[0] || nil
          path = content.css('.path')
          path = path.text.strip.split(' ')[0] || nil
          res << {
            'path' => path,
            'status' => status
          } unless path.nil?
        end
      end
      return res
    end

    # Activate a list of paths, see #activate
    #
    # @param paths [Array] the paths to activate
    # @param modified [Boolean] boolean to activitate only modified content,
    # defaulting to true.
    # @return [Array] array of Hashs path, status.
    def activate_paths paths, modified='true'
      res = []
      paths.each do |path|
        res << self.activate(path, modified)
      end
      return res
    end

    private

    def get_package package
      pack = self.package_info(package) if package.index('.zip').nil?
      pack = self.package_info(package, 'downloadName') unless package.index('.zip').nil?
      raise "Multiple packages found, Please use the downloadName \n #{pack}" if pack.size > 1
      raise "No packages found with name or downloadName #{package}" if pack.size <= 0
      return pack.first
    end
  end
end
