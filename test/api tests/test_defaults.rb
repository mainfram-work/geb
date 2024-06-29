# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the defaults for the Geb gem.
#
#  Licence MIT
# -----------------------------------------------------------------------------

require "test_helper"


class TestDefaults < Minitest::Test

  test "that all defaults have acceptable values" do

    # step through all the defaults and make sure they are not nil
    assert Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME
    assert Geb::Defaults::AVAILABLE_TEMPLATES
    assert Geb::Defaults::SITE_CONFIG_FILENAME
    assert Geb::Defaults::BUNDLED_TEMPLATES_DIR
    assert Geb::Defaults::DEFAULT_TEMPLATE_DIR
    assert Geb::Defaults::DEFAULT_TEMPLATE
    assert Geb::Defaults::LOCAL_OUTPUT_DIR
    assert Geb::Defaults::RELEASE_OUTPUT_DIR
    assert Geb::Defaults::ASSETS_DIR
    assert Geb::Defaults::PAGE_EXTENSIONS
    assert Geb::Defaults::TEMPLATE_AND_PARTIAL_IDENTIFIER
    assert Geb::Defaults::WEB_SERVER_PORT

    # make sure all the defaults are of correct type
    assert_instance_of String, Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME
    assert_instance_of Array, Geb::Defaults::AVAILABLE_TEMPLATES
    assert_instance_of String, Geb::Defaults::SITE_CONFIG_FILENAME
    assert_instance_of String, Geb::Defaults::BUNDLED_TEMPLATES_DIR
    assert_instance_of String, Geb::Defaults::DEFAULT_TEMPLATE_DIR
    assert_instance_of String, Geb::Defaults::DEFAULT_TEMPLATE
    assert_instance_of String, Geb::Defaults::LOCAL_OUTPUT_DIR
    assert_instance_of String, Geb::Defaults::RELEASE_OUTPUT_DIR
    assert_instance_of String, Geb::Defaults::ASSETS_DIR
    assert_instance_of Array, Geb::Defaults::PAGE_EXTENSIONS
    assert_instance_of Regexp, Geb::Defaults::TEMPLATE_AND_PARTIAL_IDENTIFIER
    assert_instance_of Integer, Geb::Defaults::WEB_SERVER_PORT

    # make sure the defaults are not empty
    refute_empty Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME
    refute_empty Geb::Defaults::AVAILABLE_TEMPLATES
    refute_empty Geb::Defaults::SITE_CONFIG_FILENAME
    refute_empty Geb::Defaults::BUNDLED_TEMPLATES_DIR
    refute_empty Geb::Defaults::DEFAULT_TEMPLATE_DIR
    refute_empty Geb::Defaults::DEFAULT_TEMPLATE
    refute_empty Geb::Defaults::LOCAL_OUTPUT_DIR
    refute_empty Geb::Defaults::RELEASE_OUTPUT_DIR
    refute_empty Geb::Defaults::ASSETS_DIR
    refute_empty Geb::Defaults::PAGE_EXTENSIONS
    refute_match Geb::Defaults::TEMPLATE_AND_PARTIAL_IDENTIFIER, ""
    refute_equal Geb::Defaults::WEB_SERVER_PORT, 0

  end # test "that all defaults have values"

end # class TestDefaults < Minitest::Test
