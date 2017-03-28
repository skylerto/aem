require 'json'
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
    option :profile
    def info
      profile = options[:profile]
      res = @info
      if profile
        opts = Aem::FileParse.new.read profile
        if opts.nil?
          puts 'must have a config file: run aem setup'
        else
          res = Aem::Info.new opts
        end
      end
      puts res
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
          opts = Aem::FileParse.new.create contents
        else
          puts "Ok, we'll keep your config"
        end
      else
        puts "writing: #{contents.to_yaml} to #{ENV['HOME']}/.aem.yaml"
        opts = Aem::FileParse.new.create contents
      end
    end

    # gets a list of all the packages available on AEM server
    desc "packages", "gets a list of all the packages available on AEM server"
    option :profile
    def packages
      puts cmd(options).list_packages
    end

    # searches for a package based on VALUE, KEY defaulting to name property
    desc "package VALUE KEY", "searches for a package based on VALUE, KEY defaulting to name property"
    option :profile
    def package name, property='name'
      puts cmd(options).package_info name, property
    end

    # builds a NAME
    desc "build NAME GROUP", "builds a NAME package from a GROUP"
    option :profile
    def build package, group=''
      puts JSON.parse cmd(options).build_package(package, group).body
    end

    # downloads a specific NAME to a specific PATH defaulting to the current directory
    desc "download NAME GROUP PATH", "downloads a specific NAME package from a group, to a specific PATH defaulting to the current directory"
    option :profile
    def download package, path='.'
      puts cmd(options).download_package(package, path)
    end

    # uploads the PATH with the NAME
    desc "upload PATH NAME", "uploads the PATH with the NAME"
    option :profile
    def upload file, name
      puts cmd(options).upload_package(file, name).body_str
    end

    # installs a NAME
    desc "install NAME GROUP", "installs a NAME package from a GROUP"
    option :profile
    def install package
      # puts cmd(options).install_package(package, group).body_str
      puts cmd(options).install_package(package)
    end

    # tree activates a list of PATHS
    desc "activate PATHS", "tree activates a list of PATHS"
    option :profile
    option :paths
    option :all
    def activate *paths
      modified = options[:all] ? 'false' : 'true'
      res = cmd(options).activate_paths(paths, modified)
      res = res.flatten unless res.nil?
      if options[:paths]
        out = []
        res.each do |path|
          if path['status'].eql? 'Activate'
            out << path['path']
          end
        end
        res = out
      end
      puts res
    end

    private

    def cmd options
      profile = options[:profile]
      res = @c
      if profile
        opts = Aem::FileParse.new.read profile
        if opts.nil?
          puts 'must have a config file: run aem setup'
        else
          info = Aem::Info.new opts
          res = Aem::AemCmd.new info
        end
      end
      return res
    end

  end
end
