# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Site release functionality, releasing the site, packaging site templates
#  and assets
#
#  Licence MIT
# -----------------------------------------------------------------------------

module Geb
  class Site
    module Release

      # release the site
      def release

        # build the site first
        build();

      end # def release

      # get the site release directory
      # @return [String] the site release directory
      def get_site_release_directory
        return File.join(@site_path, Geb::Defaults::RELEASE_OUTPUT_DIR)
      end # def get_site_release_directory

    end # module Build
  end # class Site
end # module Geb
