require 'thor'
require 'yaml'

module Aem

  # The CLI interface
  #
  # @author Skyler Layne
  class CLI < Thor
    def initialize(*args)
      super
      $thor_runner = false
      opts = Aem::FileParse.new.read
      if opts.nil?
        puts "must have a config file: run aem setup"
      else
        @info = Aem::Info.new opts
        @c = Aem::AemCmd.new @info
      end
    end

    # gets the info used in the configuration
    desc "info", "gets the info used in the configuration"
    def info
      puts @info
    end

    # starts the setup process
    desc "setup", "starts the setup process"
    def setup
      url = ask("AEM URL:")
      username = ask("AEM Username:")
      password = ask("AEM Password:")
      contents = {
        'url' => url,
        'username' => username,
        'password' => password
      }
      if File.exist?("#{ENV['HOME']}/.aem.yaml")
        yes = ask("#{ENV['HOME']}/.aem.yaml exists, would you like to overwrite it (Yn)?")
        if yes && yes.eql?('Y')
          puts "overwriting: #{contents.to_yaml} to #{ENV['HOME']}/.aem.yaml"
          opts = Aem::FileParse.new.write contents
        else
          puts "Ok, we'll keep your config"
        end
      else
        puts "writing: #{contents.to_yaml} to #{ENV['HOME']}/.aem.yaml"
        opts = Aem::FileParse.new.write contents
      end
    end

    # gets a list of all the packages available on AEM server
    desc "packages", "gets a list of all the packages available on AEM server"
    option :url
    def packages
      puts cmd(options).list_packages
    end

    # searches for a package based on VALUE, KEY defaulting to name property
    desc "package VALUE KEY", "searches for a package based on VALUE, KEY defaulting to name property"
    option :url
    def package name, property='name'
      puts cmd(options).package_info name, property
    end

    # builds a NAME
    desc "build NAME", "builds a NAME"
    option :url
    def build package
      puts cmd(options).build_package package
    end

    # downloads a specific NAME to a specific PATH defaulting to the current directory
    desc "download NAME PATH", "downloads a specific NAME to a specific PATH defaulting to the current directory"
    option :url
    def download package, path='./'
      puts cmd(options).download_package package, path
    end

    # uploads the PATH with the NAME
    desc "upload PATH NAME", "uploads the PATH with the NAME"
    option :url
    def upload file, name
      puts cmd(options).upload_package file, name
    end

    # installs a NAME
    desc "install NAME", "installs a NAME"
    option :url
    def install package
      puts cmd(options).install_package package
    end

    # tree activates a list of PATHS
    desc "activate PATHS", "tree activates a list of PATHS"
    option :url
    def activate *paths
      puts cmd(options).activate_paths(paths)
    end

    private

    def cmd options
      url = options[:url]
      res = @c
      if url
        info = @info
        info.url = url
        res = Aem::AemCmd.new info
      end
      return res
    end

  end
end
