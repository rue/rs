$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")

require "tempfile"

require "rubygems"
  require "micronaut"

Micronaut.configure {|config| config.mock_with :rr }


class OutputMatcher
  def initialize(expected, stream)
    @expected = expected
    @stream = stream
  end

# TODO: cleanup unnecessary error stuffs
  def matches?(block)
    old_to = @stream.dup

    # Obtain a filehandle to replace (works with Readline)
    @stream.reopen File.open(File.join(Dir.tmpdir, "should_output_#{$$}"), "w+")

    # Execute
    block.call

    # Restore
    out = @stream.dup
    @stream.reopen old_to

    # Grab the data
    out.rewind
    @data = out.read

    # Match up
    case @expected
      when Regexp
        @data.should =~ @expected
      else
        @data.should == @expected
    end

  # Clean up
  ensure
    out.close if out and !out.closed?

    # STDIO redirection will break else
    begin
      @stream.seek 0, IO::SEEK_END
    rescue Errno::ESPIPE, Errno::EPIPE
      # Ignore
    end

    FileUtils.rm out.path if out
  end

  def failure_message()
    fail
#    "Output to #{@stream.to_i} was:\n#{@data.inspect}\nshould have been:\n#{@expected.inspect}"
  end

  def negative_failure_message()
    fail
  end
end

# Top-level matching
#
def output(expected, into_stream = $stdout)
  OutputMatcher.new expected, into_stream
end

