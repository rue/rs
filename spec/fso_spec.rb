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


describe "String#to_fso" do

  before :all do
    @sandbox, @here = setup_dummy_dir, Dir.pwd

    @existing, @nonexistent = File.join(@sandbox, "somefile"),
                              File.join(@sandbox, "nonesuch")

    @homefile = `ls ~ | tail -1`.strip
    @nohomefile = @homefile.succ! while File.exist? File.expand_path("~/#{@homefile}")

    Dir.chdir @sandbox
  end

  after :all do
    Dir.chdir @here
    FileUtils.rm_r @sandbox, :secure => true
  end

  it "returns an FSO given an absolute path to an existing file" do
    @existing.to_fso.should be_kind_of(RS::FileSystemObject)
  end

  it "returns an FSO given a . relative path to an existing file" do
    "./#{File.basename @existing}".to_fso.should be_kind_of(RS::FileSystemObject)  
  end

  it "returns an FSO given a .. relative path to an existing file" do
    Dir.chdir("subdirectory") {
      "../#{File.basename @existing}".to_fso.should be_kind_of(RS::FileSystemObject)  
    }
  end

  it "returns an FSO given a ~ relative path to an existing file" do
    @homefile.to_fso.should be_kind_of(RS::FileSystemObject)
  end

  it "returns an FSO given an absolute path to a nonexistent file" do
    @nonexistent.to_fso.should be_kind_of(RS::FileSystemObject)
  end

  it "returns an FSO given a . relative path to a nonexistent file" do
    "./#{File.basename @nonexistent}".to_fso.should be_kind_of(RS::FileSystemObject)  
  end

  it "returns an FSO given a .. relative path to a nonexistent file" do
    Dir.chdir("subdirectory") {
      "../#{File.basename @nonexistent}".to_fso.should be_kind_of(RS::FileSystemObject)  
    }
  end

  it "returns an FSO given a ~ relative path to a nonexistent file" do
    @nohomefile.to_fso.should be_kind_of(RS::FileSystemObject)
  end
end
