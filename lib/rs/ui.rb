# == Authors
# Please see doc/AUTHORS.
#
# == Copyright
# Copyright (c) 2005-2009 the Authors, all rights reserved.
#
# == Licence
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# - Redistributions of source code must retain the above copyright
#   notice, this list of conditions, the following disclaimer and
#   attribution to the original authors.
#
# - Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions, the following disclaimer and
#   attribution to the original authors in the documentation and/or
#   other materials provided with the distribution.
#
# - The names of the authors may not be used to endorse or promote
#   products derived from this software without specific prior
#   written permission.
#
# == Disclaimer
# This software is provided "as is" and without any express or
# implied warranties, including, without limitation, the implied
# warranties of merchantability and fitness for a particular purpose.
# Authors are not responsible for any damages, direct or indirect.

module RS

  # Readline-based console UI.
  #
  class UI

    # Lib
    require "readline"


    # Default prompt is unexciting.
    #
    DefaultPrompt = lambda { "#{Dir.pwd} rs> " }


    # UI is set up and prepared to be read/written.
    #
    # Initial prompt may be given as an argument, and can
    # later be changed using #prompt=.
    #
    def initialize(initial_prompt = DefaultPrompt)
      $stdin.sync   = true
      $stdout.sync  = true
      $stderr.sync  = true

      # Work around Readline binding to get full line of input
      Readline.completer_word_break_characters  = 0.chr   # NUL byte unlikely?
      Readline.completion_append_character      = nil

      self.prompt = initial_prompt

      yield self
    end

    # Prompt used for next input read.
    #
    attr_accessor :prompt


    # Signal handlers
    #
    # TODO: Perhaps autogenerate these? --rue


    # ^C, keyboard interrupt.
    #
    def on_SIGINT(&block); @sigint = block; end


    # Other event handlers

    # Block to call with each line of input.
    #
    def on_input(&block); @input = block; end


    # Write #to_s to output.
    #
    # TODO: Probably need a .print version, huh? --rue
    #
    def puts(data)
      $stdout.puts data.to_s
    end

    # Input loop.
    #
    # Calls the block given in #on_input for each line of
    # input, as well as any other #on_* handlers as needed.
    #
    def run()
      loop {
        begin
          if input = Readline.readline(@prompt.call, true)
            @input.call input.chomp
          else
            return
          end
        rescue Interrupt
          @sigint.call
        end
      }
    end

  end

end
