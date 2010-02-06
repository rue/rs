
module RS

  #
  # An object in the file system. I.e. a file of some kind.
  #
  class FileSystemObject

    #
    # New FSO for given path.
    #
    def initialize(path_string)
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
