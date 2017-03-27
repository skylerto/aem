module Aem
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

    def initialize

    end

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
