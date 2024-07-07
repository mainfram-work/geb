# frozen_string_literal: true
#
# Tests the site config class for the Geb gem.
#
# @title Geb - Test - Config
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

require "test_helper"

class TestConfig < Minitest::Test

  test "that the site directory find test site config file" do

    site_path = File.join(File.dirname(__FILE__), "..", "files", "test-site")

    assert Geb::Config.site_directory_has_config?(site_path)

  end # test "that the site directory has a config file uses the correct defaults"

  test "that the site directory find test site config file uses correct defaults" do

    site_path = File.join(File.dirname(__FILE__), "..", "files", "test-site")
    File.expects(:join).with(site_path, Geb::Defaults::SITE_CONFIG_FILENAME)
    File.expects(:exist?).returns(true)

    Geb::Config.site_directory_has_config?(site_path)

  end # test "that the site directory has a config file uses the correct defaults"

  test "that configuration object is initialized correctly" do

    site = Geb::Site.new
    site_path = File.join(File.dirname(__FILE__), "..", "files", "test-site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.expects(:load_file).with(File.join(site_path, Geb::Defaults::SITE_CONFIG_FILENAME)).returns({})

    config = Geb::Config.new(site)

    refute_nil config
    assert_instance_of Geb::Config, config

  end # test "that configuration object is initialized correctly"

  test "that the configuration object raises an error if the site directory has no config file" do

    site = Geb::Site.new
    site_path = "fake_file_path"

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(false)

    error = assert_raises(Geb::Config::ConfigFileNotFound) do
      Geb::Config.new(site)
    end

    assert_includes error.message, "Site path [#{site_path}] has no geb configuration."

  end # test "that the configuration object raises an error if the site directory has no config file"

  test "that the site name is returned as folder name if no site name config" do

      site = Geb::Site.new
      site_name = "test-site22"
      site_path = File.join(File.dirname(__FILE__), "..", "files", site_name)

      site.instance_variable_set :@site_path, site_path
      Geb::Config.expects(:site_directory_has_config?).returns(true)
      YAML.expects(:load_file).returns(nil)

      config = Geb::Config.new(site)

      assert_equal site_name, config.site_name

  end # test "that the site name is returned as folder name if no site name config"

  test "that the site name is returned as config value if set" do

    site = Geb::Site.new
    site_name = "test-site22"
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({'site_name' => site_name})

    config = Geb::Config.new(site)

    assert_equal site_name, config.site_name

  end # test "that the site name is returned as config value if set"

  test "that the remote uri is returned as nil if not set" do

    site = Geb::Site.new
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({})

    config = Geb::Config.new(site)

    assert_nil config.remote_uri

  end # test "that the remote uri is returned as nil if not set"

  test "that the remote uri is returned as config value if set" do

    site = Geb::Site.new
    remote_uri = "https://example.com"
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({'remote_uri' => remote_uri})

    config = Geb::Config.new(site)

    assert_equal remote_uri, config.remote_uri

  end # test "that the remote uri is returned as config value if set"

  test "that the remote path is returned as nil if not set" do

    site = Geb::Site.new
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({})

    config = Geb::Config.new(site)

    assert_nil config.remote_path

  end # test "that the remote path is returned as nil if not set"

  test "that the remote path is returned as config value if set" do

    site = Geb::Site.new
    remote_path = "/var/www/html"
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({'remote_path' => remote_path})

    config = Geb::Config.new(site)

    assert_equal remote_path, config.remote_path

  end # test "that the remote path is returned

  test "that the local port is returned as nil if not set" do

    site = Geb::Site.new
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({})

    config = Geb::Config.new(site)

    assert_nil config.local_port

  end # test "that the local port is returned as nil if not set"

  test "that the local port is returned as config value if set" do

    site = Geb::Site.new
    local_port = 8080
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({'local_port' => local_port})

    config = Geb::Config.new(site)

    assert_equal local_port, config.local_port

  end # test "that the local port is returned as config value if set"

  test "that the output directory is returned as default if not set" do

    site = Geb::Site.new
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({})

    config = Geb::Config.new(site)

    assert_equal Geb::Defaults::OUTPUT_DIR, config.output_dir

  end # test "that the output directory is returned as default if not set"

  test "that the output directory is returned as config value if set" do

    site = Geb::Site.new
    output_dir = "public"
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({'output_dir' => output_dir})

    config = Geb::Config.new(site)

    assert_equal output_dir, config.output_dir

  end # test "that the output directory is returned as config value if set"

  test "that the assets directory is returned as default if not set" do

    site = Geb::Site.new
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({})

    config = Geb::Config.new(site)

    assert_equal Geb::Defaults::ASSETS_DIR, config.assets_dir

  end # test "that the assets directory is returned as default if not set"

  test "that the assets directory is returned as config value if set" do

    site = Geb::Site.new
    assets_dir = "assets"
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({'assets_dir' => assets_dir})

    config = Geb::Config.new(site)

    assert_equal assets_dir, config.assets_dir

  end # test "that the assets directory is returned as config value if set"

  test "that page extensions are returned as default if not set" do

    site = Geb::Site.new
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({})

    config = Geb::Config.new(site)

    assert_equal Geb::Defaults::PAGE_EXTENSIONS, config.page_extensions

  end # test "that page extensions are returned as default if not set"

  test "that page extensions are returned as config value if set" do

    site = Geb::Site.new
    page_extensions = [".html", ".htm"]
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({'page_extensions' => page_extensions})

    config = Geb::Config.new(site)

    assert_equal page_extensions, config.page_extensions

  end # test "that page extensions are returned as config value if set"

  test "that the template and partial identifier is returned as default if not set" do

    site = Geb::Site.new
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({})

    config = Geb::Config.new(site)

    assert_equal Geb::Defaults::TEMPLATE_AND_PARTIAL_IDENTIFIER, config.template_and_partial_identifier

  end # test "that the template and partial identifier is returned as default if not set"

  test "that the template paths are returned as empty array if not set" do

    site = Geb::Site.new
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({})

    config = Geb::Config.new(site)

    assert_empty config.template_paths

  end # test "that the template paths are returned as empty array if not set"

  test "that the template paths are returned as config value if set" do

    site = Geb::Site.new
    template_paths = ["templates", "partials"]
    site_path = File.join(File.dirname(__FILE__), "..", "files", "fake_site")

    site.instance_variable_set :@site_path, site_path
    Geb::Config.expects(:site_directory_has_config?).returns(true)
    YAML.stubs(:load_file).returns({'template_paths' => template_paths})

    config = Geb::Config.new(site)

    assert_equal template_paths, config.template_paths

  end # test "that the template paths are returned as config value if set"

  test "that generate config file creates a new config file" do

    site = Geb::Site.new
    site_path = File.join(File.dirname(__FILE__), "..", "files", "test-site")

    site.instance_variable_set :@site_path, site_path

    config = Geb::Config.new(site)

    refute_empty config.instance_variable_get(:@config)

    Dir.mktmpdir do |tmp_dir|

      config.generate_config_file(tmp_dir)

      assert File.exist?(File.join(tmp_dir, Geb::Defaults::SITE_CONFIG_FILENAME))

      new_generated_config = YAML.load_file(File.join(tmp_dir, Geb::Defaults::SITE_CONFIG_FILENAME))

      refute_empty new_generated_config

      assert_nil new_generated_config['site_name']
      assert_nil new_generated_config['remote_uri']
      assert_nil new_generated_config['remote_path']

    end # Dir.mktmpdir

  end # test "that generate config file creates a new config file"

  test "that generate config file raises an error if the destination directory doesn't exist" do

    site = Geb::Site.new
    site_path = File.join(File.dirname(__FILE__), "..", "files", "test-site")

    site.instance_variable_set :@site_path, site_path

    config = Geb::Config.new(site)

    refute_empty config.instance_variable_get(:@config)

    error = assert_raises(Geb::Config::DestinationDirMissing) do
      config.generate_config_file("fake_dir")
    end

    assert_includes error.message, "Specified directory [fake_dir] missing."

  end # test "that generate config file raises an error if the destination directory doesn't exist"

  test "that generate config file raises an error if the config file already exists" do

    site = Geb::Site.new
    site_path = File.join(File.dirname(__FILE__), "..", "files", "test-site")

    site.instance_variable_set :@site_path, site_path

    config = Geb::Config.new(site)

    refute_empty config.instance_variable_get(:@config)

    Dir.mktmpdir do |tmp_dir|

      File.open(File.join(tmp_dir, Geb::Defaults::SITE_CONFIG_FILENAME), 'w') { |f| f.write("test") }

      error = assert_raises(Geb::Config::ConfigAlreadyExists) do
        config.generate_config_file(tmp_dir)
      end

      assert_includes error.message, "Specified directory [#{tmp_dir}] already has geb config."

    end # Dir.mktmpdir

  end # test "that generate config file raises an error if the config file already exists"

  test "that generate config successfully generates all configuration fields" do

    site = Geb::Site.new
    site_path = File.join(File.dirname(__FILE__), "..", "files", "test-site")

    site.instance_variable_set :@site_path, site_path

    config = Geb::Config.new(site)

    refute_empty config.instance_variable_get(:@config)

    test_config = {}
    test_config['site_name']                        = "test-site"
    test_config['remote_uri']                       = "https://primjer.hr"
    test_config['remote_path']                      = "/var/www/html"
    test_config['local_port']                       = 737373
    test_config['output_dir']                       = "publicni"
    test_config['assets_dir']                       = "assetsni"
    test_config['page_extensions']                  = [".erb", ".htm", ".php"]
    test_config['template_paths']                   = ["templates", "partials"]
    test_config['template_and_partial_identifier']  = "erb"
    test_config['site_variables']                   = {
      'local'   => {'site_name' => 'test-site', 'site_url' => 'http://localhost:737373',  'site_path' => '/var/www/html' },
      'release' => {'site_name' => 'test-site', 'site_url' => 'https://primjer.hr',       'site_path' => '/var/www/html' }
    }

    config.instance_variable_set :@config, test_config

    Dir.mktmpdir do |tmp_dir|

      config.generate_config_file(tmp_dir)

      assert File.exist?(File.join(tmp_dir, Geb::Defaults::SITE_CONFIG_FILENAME))

      new_generated_config = YAML.load_file(File.join(tmp_dir, Geb::Defaults::SITE_CONFIG_FILENAME))

      refute_empty new_generated_config

      assert_nil new_generated_config['site_name']
      assert_nil new_generated_config['remote_uri']
      assert_nil new_generated_config['remote_path']

      assert_equal test_config['local_port'],                       new_generated_config['local_port']
      assert_equal test_config['output_dir'],                       new_generated_config['output_dir']
      assert_equal test_config['assets_dir'],                       new_generated_config['assets_dir']
      assert_equal test_config['page_extensions'],                  new_generated_config['page_extensions']
      assert_equal test_config['template_paths'],                   new_generated_config['template_paths']
      assert_equal test_config['template_and_partial_identifier'],  new_generated_config['template_and_partial_identifier']
      assert_equal test_config['site_variables']['local'],          new_generated_config['site_variables']['local']
      refute_equal test_config['site_variables']['release'],        new_generated_config['site_variables']['release']

      assert_empty new_generated_config['site_variables']['release']['site_name']
      assert_empty new_generated_config['site_variables']['release']['site_url']
      assert_empty new_generated_config['site_variables']['release']['site_path']

    end # Dir.mktmpdir

  end # test "that generate config successfully generates all configuration fields"

end # class TestConfig < Minitest::Test
