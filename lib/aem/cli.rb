require 'thor'

module Aem
  class CLI < Thor
    def initialize(*args)
      super
      opts = Aem::FileParse.new.read
      @info = Aem::Info.new opts
      @c = Aem::AemCmd.new @info
      $thor_runner = false
    end

    desc "info", "gets the info used in the configuration"
    def info
      puts @info
    end

    desc "packages", "gets a list of all the packages available on AEM server"
    option :url
    def packages
      puts @c.list_packages
    end

    desc "package VALUE KEY", "searches for a package based on VALUE, KEY defaulting to name property"
    option :url
    def package name, property='name'
      puts @c.package_info name, property
    end

    desc "build NAME", "builds a NAME"
    option :url
    def build package
      puts @c.build_package package
    end

    desc "download NAME PATH", "downloads a specific NAME to a specific PATH defaulting to the current directory"
    option :url
    def download package, path='./'
      puts @c.download_package package, path
    end

    desc "upload PATH NAME", "uploads the PATH with the NAME"
    option :url
    def upload file, name
      puts @c.upload_package file, name
    end

    desc "install NAME", "installs a NAME"
    option :url
    def install package
      puts @c.install_package package
    end
  end
end
