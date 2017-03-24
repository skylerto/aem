require 'yaml'

module Aem
  def read file="#{ENV["HOME"]}/.aem.yaml"
    if File.exist?(file)
      return YAML.load_file(file)
    end
  end
  class FileParse
    include Aem
  end
end
