# == Authors
# Please see doc/AUTHORS.
#
# == Copyright
# Copyright (c) 2005-2010 the Authors, all rights reserved.
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


# Externals
require "rubygems"
  require "ruby_parser"


# Extensions to String needed for rs.
#
class String

  # Treat String as Ruby code, and attempt to parse it.
  #
  # Importantly, only errors that look to be due to an unterminated
  # expression, be it class body, String literal or an Array, are
  # combed for among all possible errors. Even though a syntax (or
  # other) error occurs, the expression may be considered to be
  # "complete" for purposes of attempting to execute it.
  #
  # TODO: Untested, since it is a bit hard to do reasonably. --rue
  # TODO: This probably deserves a fix in RubyParser/Racc. --rue
  #
  def complete_expression?()
    RubyParser.new.parse self
  rescue Racc::ParseError, SyntaxError => e
    case e.message
    when /parse error.*?\$end/i, /unterminated string/i
      false
    else
      true
    end
  end

end
