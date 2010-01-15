$LOAD_PATH.unshift File.dirname(__FILE__)

# Testing
require "spec_helper"

# Project
require "rs/ui"


describe "UI creation" do

  it "yields the UI instance to the given block" do
    RS::UI.new {|ui| ui.should be_kind_of(RS::UI) }
  end

  it "provides some kind of a default prompt String" do
    Readline.should_receive(:readline).with(an_instance_of(String), true).once.and_return nil

    RS::UI.new {|ui| ui.run }
  end

  it "allows prompt to be assigned to" do
    lambda {
      RS::UI.new {|ui| ui.prompt = lambda { "hi>" } }
    }.should_not raise_error
  end

  it "accepts a ^C handler in #on_SIGINT" do
    lambda {
      RS::UI.new {|ui| ui.on_SIGINT { :hi } }
    }.should_not raise_error
  end

  it "accepts a linewise input handler in #on_input" do
    lambda {
      RS::UI.new {|ui| ui.on_input {|i| i.reverse } }
    }.should_not raise_error
  end

end


describe "UI loop/processing" do

  it "terminates when ^D, EOF, received." do
    Readline.should_receive(:readline).once.and_return nil

    RS::UI.new {|ui|
      ui.run
    }
  end

  it "calls the current prompt and uses its value going out for each loop" do
    str = "rs_ui_spec_prompt #{$$}> "

    prompt = Object.new
    prompt.should_receive(:call).exactly(2).times.and_return { str }

    inputs = ["hi\n", "ho\n", nil]
    prompts = [//, str, str]

    # TODO: Slightly iffy, improve.
    Readline.should_receive(:readline).exactly(3).times {|output_prompt, _|
      prompts.shift.should === output_prompt
      inputs.shift
    }

    RS::UI.new {|ui|
      ui.on_input {|input|
        ui.prompt = prompt
      }

      ui.run
    }
  end

end


describe "UI event handling" do

  it "calls block given to #on_SIGINT on ^C" do
    inputs = [lambda { raise Interrupt }, lambda { nil }]

    Readline.should_receive(:readline).exactly(2).times.and_return { inputs.shift.call }

    called = false

    RS::UI.new {|ui|
      ui.on_SIGINT { called = true }
      ui.run
    }

    called.should == true
  end

  it "continues processing after invoking #on_SIGINT" do
    continued = false

    inputs = [lambda { raise Interrupt }, lambda { continued = true; nil } ]

    Readline.should_receive(:readline).exactly(2).times.and_return { inputs.shift.call }

    RS::UI.new {|ui|
      ui.on_SIGINT { :yay }
      ui.run
    }

    continued.should == true
  end

  it "invokes #on_input block for each line of input until terminated by ^D" do
    inputs = ["hi\n", "ha\n", "hoo bee\n", nil, "blee\n"]
    expected = inputs.map {|i| i.chomp if i }

    Readline.should_receive(:readline).exactly(4).times.and_return { inputs.shift }

    RS::UI.new {|ui|
      ui.on_input {|input|
        input.should == expected.shift
      }

      ui.run
    }

    expected.should == [nil, "blee"]
  end

end


describe "UI output" do

  it "calls #to_s on its argument and writes it to output with a newline when using #puts" do
    lambda {
      RS::UI.new {|ui|
        ui.puts "Hiya"
        ui.puts "Really"
      }
    }.should output("Hiya\nReally\n")
  end

end

