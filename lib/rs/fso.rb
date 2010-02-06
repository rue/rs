require "fileutils"


module RS

  #
  # An object in the file system. I.e. a file of some kind.
  #
  # Note: executable locations are "bound" at time of creation,
  #       not when running. These are objects.
  #
  class FileSystemObject

    #
    # New FSO to represent given path.
    #
    def initialize(given_path, absolute_path)
      @given_path, @absolute_path = given_path, absolute_path
    end

    # Given path is the one user gave, absolute computed.
    attr_reader :given_path, :absolute_path

  end   # FileSystemObject


  #
  # Normal file.
  #
  class RegularFile < FileSystemObject

    #
    # New object representing (an existing) plain file.
    #
    def initialize(given_path, absolute_path)
      super
    end

  end


  #
  # Abstractions supposedly necessary over the filesystem.
  #
  module FileSystem

    #
    # Create an object of the appropriate type for the path.
    #
    # Nonexistent paths start their lives as plain FSOs.
    #
    def self.object_for(given)
      absolute  = if qualified? given
                    File.expand_path given
                  else
                    find_in_PATH given
                  end

      # Does not exist (yet)
      return FileSystemObject.new given, absolute unless File.exist? absolute

      case File.stat(absolute).ftype
      when "file"
        RegularFile.new given, absolute
      else
        FileSystemObject.new given, absolute
      end
    end


  private

    #
    # Locate executable file name in one of the PATH directories.
    #
    def self.find_in_PATH(filename)
      # TODO: Own env
      ENV["PATH"].split(":").each {|path|
        candidate = File.join path, filename

        # TODO: Uses EUID, bad?
        return candidate if File.executable? candidate
      }

      raise ArgumentError, "'#{@original}' is not an executable file in PATH!"
    end

    #
    # A qualified path starts with a ., .., / or ~
    #
    def self.qualified?(path)
      path =~ /\A(\.{1,2}|\/|~)/
    end

  end   # FileSystem

end

# Need to patch String a little bit.

class ::String

  #
  # Create new FileSystemObject using self as argument.
  #
  def to_fso()
    RS::FileSystem.object_for self
  end

end
