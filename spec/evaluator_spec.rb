$LOAD_PATH.unshift File.dirname(__FILE__)

# Testing
require "spec_helper"

# Project
require "rs/eval"


# TODO: Dunno how much point there is to add stuff to spec
#       here, but I suppose some coverage is useful. --rue

describe "Executing Ruby code with the evaluator" do
  before :each do
    @rs = RS::Evaluator.new
    @topmeth = "rs_eval_toplevel_def_#{$$}"
  end

  after :each do
    @rs.execute "Object.send :remove_method, :#{@topmeth} if Object.instance_methods.include?(:#{@topmeth})"
    @rs.execute "Object.send :remove_const, :RSEvalSpecsClass if defined? RSEvalSpecsClass"
    @rs.execute "Object.send :remove_const, :RSEvalSpecsModule if defined? RSEvalSpecsModule"
    @rs.execute "Object.send :remove_const, :RSEvalSpecsExtModule if defined? RSEvalSpecsExtModule"
  end

  it "has a top-level self object" do
    @rs.execute("self").should be_kind_of(Object)
  end

  it "provides #rs which gives access to an OpenStruct" do
    @rs.execute("rs").should be_kind_of(OpenStruct)
  end

  it "allows access to a #config OpenStruct through #rs" do
    @rs.execute("rs.config").should be_kind_of(OpenStruct)
  end

  it "allows top-level method definitions" do
    @rs.execute("def #{@topmeth}; :gots; end").should == nil
    @rs.execute(@topmeth).should == :gots
  end

  it "allows top-level class and module definitions" do
    @rs.execute "class RSEvalSpecsClass; end"
    @rs.execute "module RSEvalSpecsModule; end"

    @rs.execute("RSEvalSpecsClass").should be_kind_of(Class)
    @rs.execute("RSEvalSpecsModule").should be_kind_of(Module)
  end

  it "has no wrapping nesting in top-level modules" do
    @rs.execute("Module.nesting").should == []
    @rs.execute("module RSEvalSpecsModule; Module.nesting; end").should == [RSEvalSpecsModule]
  end

  it "supports extending and including into self" do
    @rs.execute "module RSEvalSpecsModule; def rsesm; end; end"
    @rs.execute "module RSEvalSpecsExtModule; def rsesem; end; end"

    @rs.execute "include RSEvalSpecsModule"
    @rs.execute("Object.ancestors").include?(RSEvalSpecsModule).should == true

    @rs.execute "extend RSEvalSpecsExtModule"
    @rs.execute("class << self; ancestors; end").include?(RSEvalSpecsExtModule).should == true
  end

  it "gracefully returns error object if an error bubbles to top level" do
    @rs.execute("raise SyntaxError").should be_kind_of(SyntaxError)
  end

  it "supports normal error handling" do
    @rs.execute("begin; raise SyntaxError; rescue SyntaxError; :yay; end").should == :yay
  end

  it "lets SystemExit bubble up" do
    lambda { @rs.execute "exit 1" }.should raise_error(SystemExit)
  end

  it "returns error object given top-level return" do
    @rs.execute("return").should be_kind_of(LocalJumpError)
  end

  it "returns error object given top-level break" do
    @rs.execute("break").should be_kind_of(LocalJumpError)
  end

  # TODO: Known to fail, same as redo. Fix? --rue
  it "returns error object given top-level next" do
    @rs.execute("next").should be_kind_of(LocalJumpError)
  end

  # TODO: Known to fail, same as next. Fix? --rue
  it "returns error object given top-level redo" do
    @rs.execute("redo").should be_kind_of(LocalJumpError)
  end

end


describe "Evaluator creation using RS.start" do

  it "yields an Evaluator to the block given" do
    RS.start {|rs| rs.should be_kind_of(RS::Evaluator) }
  end

  it "does not rescue errors raised in the block" do
    lambda { RS.start {|rs| raise "hi" } }.should raise_error("hi")
  end

end
