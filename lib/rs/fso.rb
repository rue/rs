
#
# Yay, rs.
#
module RS


  #
  # Abstractions supposedly necessary over the filesystem.
  #
  module FileSystem

    #
    # Create an object of the appropriate type for the path.
    #
    # Nonexistent paths start their lives as plain FSOs.
    #
    # TODO: Allow creating e.g. a nonexisting Directory directly?
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
        if File.executable? absolute
          Executable.new given, absolute
        else
          RegularFile.new given, absolute
        end
      when "directory"
        Directory.new given, absolute
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


  # Nested classes for file system objects

    #
    # An object in the file system.
    #
    # FSO defines what little common behaviour there is between
    # the different types of files that may exist in a system.
    #
    # All nonexistent paths are also just plain FSOs since they
    # have no type yet.
    #
    class FileSystemObject                    # Sure, but rather than worry about ::Object everywhere

      #
      # New FSO to represent given path.
      #
      def initialize(path_given, path_absolute)
        @path_given, @path_absolute = path_given, path_absolute
      end

      # Given path is the one user gave, absolute computed.
      attr_reader :path_given, :path_absolute

      # For the lazy among us
      alias_method :path, :path_given

    end   # FileSystemObject


    #
    # Directory filesystem object.
    #
    class Directory < FileSystemObject

      #
      # New object representing (an existing) directory.
      #
      def initialize(path_given, path_absolute)
        super
      end

    end   # Directory


    #
    # Regular filesystem file object.
    #
    class RegularFile < FileSystemObject

      #
      # New object representing (an existing) plain file.
      #
      def initialize(path_given, path_absolute)
        super
      end

    end   # RegularFile


    #
    # Executables filesystem object.
    #
    class Executable < RegularFile

      #
      # New object representing (an existing) executable.
      #
      def initialize(path_given, path_absolute)
        super
      end

    end   # Executable


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
