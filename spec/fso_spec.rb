# Testing
require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

# Ruby
require "fileutils"

# Project
require "rs/fso"


# Create a place for us to play in
def setup_dummy_dir()
  dir = File.join Dir.tmpdir, "rs_sandbox_#{$$}_#{Time.now.to_f}"

  FileUtils.mkdir_p File.join(dir, "subdirectory")
  FileUtils.touch File.join(dir, "somefile")

  dir
end


FSO = RS::FileSystemObject


describe "String#to_fso" do

  it "calls FileSystemObject.new with itself as the single argument" do
    RS::FileSystemObject.should_receive(:new).with __FILE__

    __FILE__.to_fso
  end

end

describe "Creating FSOs with a qualified path string (., .., /, ~)" do

  before :all do
    @sandbox, @here = setup_dummy_dir, Dir.pwd

    @existing, @nonexistent = File.join(@sandbox, "somefile"),
                              File.join(@sandbox, "nonesuch")

    @homefile = File.join "~", `ls ~ | tail -1`.strip

    @nohomefile = @homefile.succ
    @nohomefile = @nohomefile.succ! while File.exist? @nohomefile

    Dir.chdir @sandbox
  end

  after :all do
    Dir.chdir @here
    FileUtils.rm_r @sandbox, :secure => true
  end

  it "returns an FSO given an absolute path to an existing file" do
    FSO.new(@existing).should be_kind_of(RS::FileSystemObject)
  end

  it "returns an FSO given a . relative path to an existing file" do
    FSO.new("./#{File.basename @existing}").should be_kind_of(RS::FileSystemObject)  
  end

  it "returns an FSO given a .. relative path to an existing file" do
    Dir.chdir("subdirectory") {
      FSO.new("../#{File.basename @existing}").should be_kind_of(RS::FileSystemObject)  
    }
  end

  it "returns an FSO given a ~ relative path to an existing file" do
    FSO.new(@homefile).should be_kind_of(RS::FileSystemObject)
  end

  it "returns an FSO given an absolute path to a nonexistent file" do
    FSO.new(@nonexistent).should be_kind_of(RS::FileSystemObject)
  end

  it "returns an FSO given a . relative path to a nonexistent file" do
    FSO.new("./#{File.basename @nonexistent}").should be_kind_of(RS::FileSystemObject)  
  end

  it "returns an FSO given a .. relative path to a nonexistent file" do
    Dir.chdir("subdirectory") {
      FSO.new("../#{File.basename @nonexistent}").should be_kind_of(RS::FileSystemObject)  
    }
  end

  it "returns an FSO given a ~ relative path to a nonexistent file" do
    FSO.new(@nohomefile).should be_kind_of(RS::FileSystemObject)
  end

end


describe "Creating an FSO with a path string that is not qualified by ., .., / or ~" do

  before :each do
    @sandbox = setup_dummy_dir

    @nonesuch = "rs_no_such_file_in_PATH_#{$$}_#{Time.now.to_f}_aa"
    @nonesuch.succ! while system "which #{@nonesuch} >/dev/null"

    @oldpath, ENV["PATH"] = ENV["PATH"], "#{@sandbox}:#{ENV["PATH"]}"
  end

  after :each do
    ENV["PATH"] = @oldpath

    FileUtils.rm_r @sandbox, :secure => true
  end

  it "raises an error when path string does not correspond to a file name in one of the PATH directories" do
    lambda { FSO.new @nonesuch }.should raise_error
  end

  it "raises an error when path string corresponds to a nonexecutable file name in one of the PATH directories" do
    FileUtils.touch File.join(@sandbox, @nonesuch)

    lambda { FSO.new @nonesuch }.should raise_error
  end

  it "returns an FSO given a path string that is an executable file in one of the PATH directories" do
    FileUtils.touch File.join(@sandbox, @nonesuch)
    FileUtils.chmod 0755, File.join(@sandbox, @nonesuch)

    FSO.new(@nonesuch).should be_kind_of(RS::FileSystemObject)
  end

end

describe "An FSO created from a qualified file string (., .., /, ~)" do

end
