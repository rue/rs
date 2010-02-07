# Testing
require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

# Ruby
require "fileutils"

# Project
require "rs/fso"


# Create a place for us to play in
#
# dir/
#     somefile
#     some_executable
#     <nonexistent>
#     not_in_PATH
#     subdirectory/
#
def setup_dummy_dir()
  dir             = File.join Dir.tmpdir, "rs_sandbox_#{$$}_#{Time.now.to_f}"
  subdir          = File.join dir, "subdirectory"
  somefile        = File.join dir, "somefile"
  some_executable = File.join dir, "some_executable"
  nonexistent     = File.join dir, "nonesuch"

  FileUtils.mkdir_p subdir
  FileUtils.touch somefile

  FileUtils.touch some_executable
  FileUtils.chmod 0755, some_executable

  not_in_PATH = "rs_no_such_file_in_PATH_aaa"
  not_in_PATH.succ! while system "which #{not_in_PATH} >/dev/null"

  FileUtils.touch File.join(dir, not_in_PATH)
  FileUtils.chmod 0755, File.join(dir, not_in_PATH)


  [dir, somefile, some_executable, nonexistent, not_in_PATH, subdir]
end


FS = RS::FileSystem


describe "String#to_fso" do

  it "calls FileSystem.object_for with itself as the single argument" do
    FS.should_receive(:object_for).with __FILE__

    __FILE__.to_fso
  end

end

describe "Creating FSOs with a qualified path string (., .., /, ~)" do

  before :each do
    @dir, @existing, @executable, @nonexistent, @not_in_PATH, @subdir = setup_dummy_dir

    @homefile = File.join "~", `ls ~ | tail -1`.strip

    @nohomefile = @homefile + "_rs_aaa"
    @nohomefile = @nohomefile.succ! while File.exist? @nohomefile

    @here = Dir.pwd
    Dir.chdir @dir
  end

  after :each do
    Dir.chdir @here
    FileUtils.rm_r @dir, :secure => true
  end

  it "returns an FSO given an absolute path to an existing file" do
    FS.object_for(@existing).should be_kind_of(FS::FileSystemObject)
  end

  it "returns an FSO given a . relative path to an existing file" do
    FS.object_for("./#{File.basename @existing}").should be_kind_of(FS::FileSystemObject)
  end

  it "returns an FSO given a .. relative path to an existing file" do
    Dir.chdir("subdirectory") {
      FS.object_for("../#{File.basename @existing}").should be_kind_of(FS::FileSystemObject)
    }
  end

  it "returns an FSO given a ~ relative path to an existing file" do
    FS.object_for(@homefile).should be_kind_of(FS::FileSystemObject)
  end

  it "returns an FSO given an absolute path to a nonexistent file" do
    FS.object_for(@nonexistent).should be_kind_of(FS::FileSystemObject)
  end

  it "returns an FSO given a . relative path to a nonexistent file" do
    FS.object_for("./#{File.basename @nonexistent}").should be_kind_of(FS::FileSystemObject)
  end

  it "returns an FSO given a .. relative path to a nonexistent file" do
    Dir.chdir("subdirectory") {
      FS.object_for("../#{File.basename @nonexistent}").should be_kind_of(FS::FileSystemObject)
    }
  end

  it "returns an FSO given a ~ relative path to a nonexistent file" do
    FS.object_for(@nohomefile).should be_kind_of(FS::FileSystemObject)
  end

  it "returns an Executable for an existing file that is executable." do
    FileUtils.chmod 0755, @existing

    FS.object_for(@existing).should be_instance_of(FS::Executable)
  end

  it "returns a RegularFile for existing plain nonexecutable files." do
    FS.object_for(@existing).should be_instance_of(FS::RegularFile)
  end

  it "returns a Directory for existing directories." do
    FS.object_for(@dir).should be_instance_of(FS::Directory)
  end

  it "returns a Socket/FIFO/Blockdevice/etc. for corresponding existing files"

  it "returns an actual FSO instance for all nonexisting paths" do
    FS.object_for(@nonexistent).should be_instance_of(FS::FileSystemObject)
  end

end


describe "Creating an FSO with a path string that is not qualified by ., .., / or ~" do

  before :each do
    @dir, @existing, @executable, @nonexistent, @not_in_PATH, @subdir = setup_dummy_dir

    @real_PATH, @substitute_PATH = ENV["PATH"], "#{@dir}:#{ENV["PATH"]}"

    # All but one at this point need adjusted PATH, be mindful when working with them.
    ENV["PATH"] = @substitute_PATH
  end

  after :each do
    ENV["PATH"] = @real_PATH

    FileUtils.rm_r @dir, :secure => true
  end

  it "raises an error when path string does not correspond to a file name in one of the PATH directories" do
    ENV["PATH"] = @real_PATH        # Revert our modification

    lambda { FS.object_for @not_in_PATH }.should raise_error
  end

  it "raises an error when path string corresponds to a nonexecutable file name in one of the PATH directories" do
    FileUtils.chmod 0644, File.join(@dir, @not_in_PATH) # Present but not executable

    lambda { FS.object_for @not_in_PATH }.should raise_error
  end

  it "returns an FSO given a path string that is an executable file in one of the PATH directories" do
    FS.object_for(@not_in_PATH).should be_kind_of(FS::FileSystemObject)
  end

  it "returns an Executable rather than a plain FSO in fact." do
    FS.object_for(@not_in_PATH).should be_instance_of(FS::Executable)
  end

end


describe "An FSO created with a particular path string" do

  before :each do
    @relative = File.join ".", File.basename(__FILE__)
    @absolute = File.expand_path __FILE__
    @unqualified = %w[wc grep ls cd echo].find {|cmd| system "which #{cmd} >/dev/null" }
  end

  after :each do
  end

  # TODO: Add sanity check for other file types
  it "stores the string given at creation as #path_given whether relative, absolute or unqualified" do
    FS.object_for(@relative).path_given.should == @relative
    FS.object_for(@absolute).path_given.should == @absolute
    FS.object_for(@unqualified).path_given.should == @unqualified
  end

  it "stores the absolute path resolved from given at creation as #path_absolute" do
    FS.object_for(@relative).path_absolute.should == File.expand_path(@relative)
    FS.object_for(@absolute).path_absolute.should == @absolute
    FS.object_for(@unqualified).path_absolute.should == `which #{@unqualified}`.strip
  end

end


describe "An FSO with a nonexistent path" do
  it "Says no to exists? or whatever"
end
