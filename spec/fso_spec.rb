# Testing
require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

# Project
require "rs/fso"


describe "String#to_fso" do

  it "returns an FSO given an absolute path to an existing file" do
    File.expand_path(__FILE__).to_fso.should be_kind_of(RS::FileSystemObject)
  end

end
