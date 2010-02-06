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
    # New FSO for given path.
    #
    def initialize(path_string)
      @original = path_string

      @absolute = if qualified?
                    File.expand_path path_string
                  else
                    find_in_PATH
                  end
    end


  private

    def find_in_PATH()
      dir = ENV["PATH"].split(":").find {|path|
              # TODO: Uses EUID, bad?
              File.executable? File.join(path, @original)
            }

      raise ArgumentError, "'#{@original}' is not an executable file in PATH!" unless dir

      File.join dir, @original
    end

    #
    # A qualified path starts with a ., .., / or ~
    #
    def qualified?()
      @original =~ %r[\A(\.{1,2}|/|~)]
    end

  end

end

# Need to patch String a little bit.

class ::String

  #
  # Create new FileSystemObject using self as argument.
  #
  def to_fso()
    RS::FileSystemObject.new self
  end

end
