require 'yaml'

module Aem

  # Reads the contents of a YAML file. Prefers the copy local to where the
  # execution path is, falls back to $HOME otherwise.
  #
  # @param file [String] A string path to a configuration file, default
  # location is in user's HOME directory
  # @return [Hash] the yaml translated into a hash.
  def read file="#{ENV["HOME"]}/.aem.yaml"
    if File.exist?(file)
      return YAML.load_file(file)
    elsif File.exist?("#{ENV["HOME"]}/#{file}")
      return YAML.load_file("#{ENV["HOME"]}/#{file}")
    else
      return nil
    end
  end

  # Writes the configuration file to $HOME/.aem.yaml
  #
  # @param hash [Hash] A hash of contents to write to the confg file
  def create hash
    File.open("#{ENV['HOME']}/.aem.yaml", 'w') {|f| f.write contents.to_yaml }
  end

  # File Parser if a class for file operations.
  #
  # @author Skyler Layne
  class FileParse
    include Aem
  end
end
