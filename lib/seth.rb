# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Module with some pretty crazy things.
#  Seth is an egyption god of chaos and mischief.  This code is a tribute to him.
#  Some of the thigns here run at the very bassis of the Ruby language and change
#  how standard things work.  This is not for the faint of heart.
#
#  Licence MIT
# -----------------------------------------------------------------------------

module Seth

  # Suppress warnings within the block being executed. This is useful for testing.
  # @example
  # #
  #   suppress_warnings do
  #     # code that generates warnings
  #   end
  #   # no warnings will be printed
  #
  # @yield []
  # @return [void]
  def suppress_warnings

    # save the original verbose setting
    original_verbose = $VERBOSE

    # suppress warnings
    $VERBOSE = nil

    # execute the block
    yield

  ensure

    # restore the original verbose setting
    $VERBOSE = original_verbose

  end # def suppress_warnings

  # can you imagine what this does? ;)
  module_function :suppress_warnings

end # module Seth

puts "Seth has been loaded.  Hang on to your hats!. Seth is here: #{__FILE__}"
