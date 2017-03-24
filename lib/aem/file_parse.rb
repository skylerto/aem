require 'yaml'

module Aem

  # Reads the contents of a YAML file.
  # == Parameters:
  # file::
  #   A string path to a configuration file, default location is in user's HOME
  #   directory
  #
  # == Returns:
  #   A hash of the yaml file
  #
  def read file="#{ENV["HOME"]}/.aem.yaml"
    if File.exist?(file)
      return YAML.load_file(file)
    else
      return nil
    end
  end

  # Writes the configuration file to $HOME/.aem.yaml
  # == Parameters:
  # hash::
  #   A hash of contents to write to the confg file
  #
  def create hash
    File.open("#{ENV['HOME']}/.aem.yaml", 'w') {|f| f.write contents.to_yaml }
  end

  class FileParse
    include Aem
  end
end
