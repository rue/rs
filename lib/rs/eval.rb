# == Copyright
# Copyright (c) 2005-2010 Eero Saynatkari, all rights reserved.
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

# Libs
require "ostruct"


module RS

  # Creates and yields a new Evaluator.
  #
  # The block given should implement whatever logic is
  # desired. Will clean up as necessary.
  #
  # TODO: This needs much improvement, probably. --rue
  #
  def self.start(&block)
    rs = Evaluator.new

    begin
      rs.send :run, &block

    rescue SystemExit => e
      # No need to print errors etc., but set return code.
      exit! e.status
    end
  end


  #
  # Error raised trying to execute an incomplete expression.
  #
  class IncompleteExpression < SyntaxError; end


  # Runtime environment for executing user input as Ruby.
  #
  class Evaluator

    # Create a new execution environment.
    #
    # You should use RS.start instead.
    #
    # TODO: Generate unique bindings?
    #
    def initialize()
      @binding = eval "lambda { binding }.call", TOPLEVEL_BINDING

      stash = OpenStruct.new  :evaluator => self,
                              :config => OpenStruct.new

      @main = execute "self"
      @main.instance_variable_set "@rs", stash

      # Work around MRI changing description.
      def @main.inspect(); :rs_main; end

      execute "def rs(); @rs; end"
    end


    # Allow accessing main from the outside.
    #
    attr_reader :main


    # Execute a presumably valid String of Ruby code.
    #
    # Trying to execute an incomplete Ruby expression
    # raises IncompleteExpression.
    #
    # Errors are caught etc. (except top-level next and redo
    # LocalJumpErrors, those need to be caught outside this
    # scope), and returned as objects.
    #
    def execute(expression, file = "<no file>", line = "<no line>")
      eval expression, @binding

    rescue SyntaxError => e
      case e.message
      when /(parse|syntax) error.*?\$end/i, /unterminated/i  # Should catch most
        raise IncompleteExpression
      else
        raise
      end
    rescue SystemExit
      raise
    rescue Exception => e
      e
    end


    # Yields this instance to block.
    #
    # Use RS.start.
    #
    def run()
      yield self
    end
    private :run

  end

end

