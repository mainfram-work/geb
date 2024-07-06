# frozen_string_literal: true
#
# Tests the site class
#
# @title Geb - Test - Site
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @todo Probably should break these tests into multiple classes, in line with class having modules.
#
# @see https://github.com/mainfram-work/geb for more information

require "test_helper"

class SiteTest < Geb::ApiTest

  test "that site default initializes" do

    site = Geb::Site.new

    assert_instance_of Geb::Site, site
    assert_nil site.site_path
    assert_nil site.template_path

  end # test "that site default initializes"

  test "that site validate method sets site path and template path" do

    site = Geb::Site.new
    test_site_path = "test/site"

    site.stubs(:site_directory_exists?).returns(false)
    site.validate(test_site_path, nil, true)
    assert test_site_path, site.site_path
    assert_nil site.template_path
    assert site.validated

  end # test "that site validate method sets site path and template path"

  test "that site validate method throws an exception if called on validated site" do

    site = Geb::Site.new
    test_site_path = "test/site"

    site.stubs(:site_directory_exists?).returns(false)

    site.validate(test_site_path, nil, true)

    assert test_site_path, site.site_path
    assert_nil site.template_path
    assert site.validated

    assert_raises Geb::Site::SiteAlreadyValidated do
      site.validate(test_site_path, nil, true)
    end # assert_raises

  end # test "that site validates method throws an exception if called on validated site"

  test "that site validates method throws an exception if site directory exists and force flag is false" do

    site = Geb::Site.new
    test_site_path = "test/site"

    site.stubs(:site_directory_exists?).returns(true)
    assert_raises Geb::Site::DirectoryExistsError do
      site.validate(test_site_path, nil, true)
    end # assert_raises
    assert_nil site.site_path
    assert_nil site.template_path
    refute site.validated

  end # test "that site validates method throws an exception if site directory exists and force flag is false"

  test "test site validates and uses default template if the template is not specified" do

    site = Geb::Site.new
    test_site_path = "tmp/test_site"

    Geb::Config.stubs(:site_directory_exists?).returns(false)

    site.validate(test_site_path)

    assert_equal site.site_path,      test_site_path
    assert site.template_path.end_with?(Geb::Defaults::DEFAULT_TEMPLATE)

  end # test "test site validates and uses default template if the template is not specified"

  test "test site validates and uses specified template if the template is specified" do

    site = Geb::Site.new
    test_site_path = "tmp/test_site"
    test_template = "/not/real/template"

    site.stubs(:site_directory_exists?).returns(false)
    site.stubs(:template_directory_exists?).returns(true)
    site.stubs(:is_bundled_template?).returns(false)
    Geb::Config.stubs(:site_directory_has_config?).returns(true)

    site.validate(test_site_path, test_template)

    assert_equal site.site_path,      test_site_path
    assert_equal site.template_path,  test_template
    assert site.validated

  end # test "test site validates and uses specified template if the template is specified"

  test "test site validates and uses the URL template specified" do

    site = Geb::Site.new
    test_site_path = "tmp/test_site"
    test_template_url = "http://www.example.com/template.tar.gz"
    test_template_dir = "/var/tmp/downloaded/template"

    site.stubs(:validate_template_url).returns(test_template_url)
    site.stubs(:download_template_from_url).returns(test_template_dir)
    site.stubs(:template_directory_exists?).returns(true)
    Geb::Config.stubs(:site_directory_has_config?).returns(true)

    site.validate(test_site_path, test_template_url)

    assert_equal site.site_path,      test_site_path
    assert_equal site.template_path,  test_template_dir
    assert site.validated

  end # test "test site validates and uses the URL template specified"

  test "test site validates and uses the bundle template identifier specified" do

    site = Geb::Site.new
    test_site_path = "tmp/test_site"
    test_template = "bootstrap_jquery"

    site.validate(test_site_path, test_template)

    assert_equal site.site_path,      test_site_path
    assert site.template_path.end_with?(test_template)
    assert site.validated

  end # test "test site validates and uses the bundle template identifier specified"

  test "that template url validation doesn't through any exceptions when it has a working URL" do

    site = Geb::Site.new
    test_template_url = "http://www.example.com/"+ Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME

    stub_request(:get, test_template_url).to_return(body: "<html></html>", headers: { 'Content-Type' => 'application/x-gzip' })

    validated_test_template_url = site.send(:validate_template_url, test_template_url)

    assert_equal  test_template_url, validated_test_template_url

  end # test "that template url validation doesn't through any exceptions when it has a working URL"

  test "that template url validation retries with archive filename after first URL query fails" do

    site = Geb::Site.new
    test_template_url = "http://www.example.com/"

    stub_request(:get, test_template_url).to_return(body: "<html></html>", headers: { 'Content-Type' => 'text/html' })
    stub_request(:get, test_template_url + Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME).to_return(body: "<html></html>", headers: { 'Content-Type' => 'application/x-gzip' })

    validated_test_template_url = site.send(:validate_template_url, test_template_url)

    assert_equal  test_template_url + Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME, validated_test_template_url

  end # test "that template url validation retries with archive filename after first URL query fails"

  test "that the template url validation throws an exception if the http request fails" do

      site = Geb::Site.new
      test_template_url = "http://www.example.com/"

      site.stubs(:fetch_http_response).raises(Geb::Site::InvalidTemplateURL)

      assert_raises Geb::Site::InvalidTemplateURL do
        site.send(:validate_template_url, test_template_url)
      end # assert_raises

  end # test "that the template url validation throws an exception if the http request fails"

  test "that the template url validation correctly detects the template URL access was not successful" do

    site = Geb::Site.new
    test_template_url = "http://www.example.com/"

    response_mock = mock()
    response_mock.stubs(:body).returns("<html></html>")
    response_mock.stubs(:headers).returns({ 'Content-Type' => 'application/x-gzip' })
    response_mock.stubs(:[]).with('Content-Type').returns('application/x-gzip') # Stubbing hash-like access to 'Content-Type'
    response_mock.stubs(:is_a?).with(Net::HTTPSuccess).returns(false)
    response_mock.stubs(:code).returns("404")
    site.expects(:fetch_http_response).returns(response_mock).times(2) # expecting a retry

    error = assert_raises Geb::Site::InvalidTemplateURL do
      site.send(:validate_template_url, test_template_url)
    end # assert_raises

    assert_includes error.message, "Web server returned 404"

  end # test "that the template url validation correctly detects the template URL access was not successful"

  test "that the template url validation correctly detects the template URL is not an archive" do

    site = Geb::Site.new
    test_template_url = "http://www.example.com/"

    response_mock = mock()
    response_mock.stubs(:body).returns("<html></html>")
    response_mock.stubs(:headers).returns({ 'Content-Type' => 'text/html' })
    response_mock.stubs(:[]).with('Content-Type').returns('text/html') # Stubbing hash-like access to 'Content-Type'
    response_mock.stubs(:is_a?).with(Net::HTTPSuccess).returns(true)
    site.expects(:fetch_http_response).returns(response_mock).times(2) # expecting a retry

    error = assert_raises Geb::Site::InvalidTemplateURL do
      site.send(:validate_template_url, test_template_url)
    end # assert_raises

    assert_includes error.message, "Specified template is not a gzip archive"


  end # test "that the template url validation correctly detects the template URL is not an archive"

  test "that the template url validation correctly retries and doesn't retry depending on the archive url" do

    site = Geb::Site.new
    test_template_url_should_retry = "http://www.examples.com/"
    test_template_url_should_not_retry = "http://www.examples.com/"+ Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME

    http_success_sequence = sequence('http_success_sequence')
    response_mock_first_fail = mock()
    response_mock_first_fail.stubs(:body).returns("<html></html>")
    response_mock_first_fail.stubs(:headers).returns({ 'Content-Type' => 'application/x-gzip' })
    response_mock_first_fail.stubs(:[]).with('Content-Type').returns('application/x-gzip') # Stubbing hash-like access to 'Content-Type'
    response_mock_first_fail.stubs(:is_a?).with(Net::HTTPSuccess).returns(false)
    response_mock_first_fail.stubs(:code).returns("200")
    response_mock_second_ok = mock()
    response_mock_second_ok.stubs(:body).returns("<html></html>")
    response_mock_second_ok.stubs(:headers).returns({ 'Content-Type' => 'application/x-gzip' })
    response_mock_second_ok.stubs(:[]).with('Content-Type').returns('application/x-gzip') # Stubbing hash-like access to 'Content-Type'
    response_mock_second_ok.stubs(:is_a?).with(Net::HTTPSuccess).returns(true)
    response_mock_second_ok.stubs(:code).returns("200")

    site.expects(:fetch_http_response).returns(response_mock_first_fail).once.in_sequence(http_success_sequence) # expecting a retry
    site.expects(:fetch_http_response).returns(response_mock_second_ok).once.in_sequence(http_success_sequence) # expecting a retry

    validated_template_url = site.send(:validate_template_url, test_template_url_should_retry)
    assert_equal validated_template_url, test_template_url_should_retry + Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME

    site.expects(:fetch_http_response).returns(response_mock_second_ok).once # expecting no retry

    validated_template_url = site.send(:validate_template_url, test_template_url_should_not_retry)

    assert_equal test_template_url_should_not_retry, validated_template_url

  end # test "that the template url validation correctly retries and doesn't retry depending on the archive url"

  test "that the fetch http response method returns a response object" do

      site = Geb::Site.new
      test_template_url = "http://www.example.com/"

      # mock the http response
      stub_request(:get, test_template_url).to_return(body: "<html></html>", headers: { 'Content-Type' => 'text/html' })

      response = site.send(:fetch_http_response, test_template_url)

      assert_instance_of Net::HTTPOK, response

  end # test "that the fetch http response method returns a response object"

  test "that the fetch http response method throws an exception if the http request fails" do

    site = Geb::Site.new
    test_template_url = "http://www.example.com/"

    # stub the Net::HTTP.get_response to raise an exception
    Net::HTTP.stubs(:get_response).raises(StandardError.new("HTTP request failed"))

    error = assert_raises Geb::Site::InvalidTemplateURL do
      site.send(:fetch_http_response, test_template_url)
    end # assert_raises

    assert_includes error.message, "HTTP request failed"

  end # test "that the fetch http response method throws an exception if the http request fails"

  test "that the download template actually downloads and extracts the template" do

    site = Geb::Site.new
    test_template_url = "http://www.example.com/"

    # stub the http request to return a gzip archive from test files folder
    stub_request(:get, test_template_url)
      .to_return(body: File.open(File.expand_path("../../files/geb-template.tar.gz", __FILE__)).read,
      headers: { 'Content-Type' => 'application/x-gzip' })

    template_directory = site.send(:download_template_from_url, test_template_url)

    refute_empty Dir.glob("#{template_directory}/*")

  end # test "that the download template actually downloads and extracts the template"

  test "that the download template throws an exception if the download fails" do

    site = Geb::Site.new
    test_template_url = "http://www.example.com/"

    # stub the http request to return a gzip archive from test files folder
    stub_request(:get, test_template_url)
      .to_return(body: "Not Found", status: 404, headers: { 'Content-Type' => 'application/x-gzip' })

    error = assert_raises Geb::Site::InvalidTemplateURL do
      site.send(:download_template_from_url, test_template_url)
    end # assert_raises

    assert_includes error.message, "Failed to extract template archive: tar: Error opening archive"

  end # test "that the download template throws an exception if the download fails"

  test "that the download template throws an exception if the archive is not a gzip archive" do

    site = Geb::Site.new
    test_template_url = "http://www.example.com/"

    # stub the http request to return a gzip archive from test files folder
    stub_request(:get, test_template_url)
      .to_return(body: "Actially a gip file",
      headers: { 'Content-Type' => 'text/plain' })

    error = assert_raises Geb::Site::InvalidTemplateURL do
      site.send(:download_template_from_url, test_template_url)
    end # assert_raises

    assert_includes error.message, "Failed to extract template archive: tar: Error opening archive"

  end # test "that the download template throws an exception if the archive is not a gzip archive"

  test "that the create site method raises an exception if the site is not validated" do

    site = Geb::Site.new

    assert_raises Geb::Site::UnvalidatedSiteAndTemplate do
      site.create
    end # assert_raises

  end # test "that the create site method raises an exception if the site is not validated"

  test "that the create site method creates a site folder without a template" do

    site = Geb::Site.new
    test_site_path = "test_site"

    Dir.mktmpdir do |temp_dir|

      site.instance_variable_set(:@validated, true)
      site.instance_variable_set(:@site_path, File.join(temp_dir, test_site_path))
      site.instance_variable_set(:@template_path, nil)
      Geb::stubs(:site_directory_has_config?).returns(true)

      site.create

      assert Dir.exist?(site.site_path)
      assert Dir.exist?(File.join(site.site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::LOCAL_OUTPUT_DIR))
      assert Dir.exist?(File.join(site.site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::RELEASE_OUTPUT_DIR))

    end # Dir.mktmpdir

  end # test "that the create site method creates a site folder without a template"

  test "that the create site method creates a site folder with a template" do

    site = Geb::Site.new
    test_site_path = "test_site"

    Dir.mktmpdir do |temp_dir|

      test_template_path = File.join(temp_dir, "test_template")
      Dir.mkdir(test_template_path)

      template_paths = []
      template_paths << File.join("assets")
      template_paths << File.join("shared")
      template_paths << File.join("index.html")
      template_paths << File.join("site.webmanifest")
      template_paths << File.join("shared/_header.html")
      template_paths << File.join("shared/_footer.html")
      template_paths.each do |path|
        if path !~ /\./
          FileUtils.mkdir_p(File.join(test_template_path, path))
        else
          FileUtils.mkdir_p(File.dirname(File.join(test_template_path, path)))
          File.open(File.join(test_template_path, path), "w") do |file|
            file.write("This is a dumny file path: #{path}")
          end
        end
      end
      File.open(File.join(test_template_path, Geb::Defaults::SITE_CONFIG_FILENAME), "w") do |file|
        file.write("\n")
        file.write('template_paths: ["assets", "shared", "*.html", "site.webmanifest", "geb.config.yml"]')
        file.write("\n")
      end

      Geb::stubs(:site_directory_has_config?).returns(true)
      site.instance_variable_set(:@validated, true)
      site.instance_variable_set(:@site_path, File.join(temp_dir, test_site_path))
      site.instance_variable_set(:@template_path, test_template_path)

      template_paths.each do |path|
        if path !~ /\./
          refute Dir.exist?(File.join(site.site_path, path))
        else
          refute File.exist?(File.join(site.site_path, path))
        end
      end

      site.create

      assert Dir.exist?(site.site_path)
      template_paths.each do |path|
        if path !~ /\./
          assert Dir.exist?(File.join(site.site_path, path))
        else
          assert File.exist?(File.join(site.site_path, path))
          File.open(File.join(site.site_path, path), "r") do |file|
            assert_equal file.read, "This is a dumny file path: #{path}"
          end
        end
      end

      assert Dir.exist?(File.join(site.site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::LOCAL_OUTPUT_DIR))
      assert Dir.exist?(File.join(site.site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::RELEASE_OUTPUT_DIR))

    end # Dir.mktmpdir

  end # test "that the create site method creates a site folder with a template"

  test "that the create site method skips the site directory folder creation if folder already exists" do

    site = Geb::Site.new
    test_site_path = "test_site"

    site.expects(:site_directory_exists?).returns(true)

    Dir.mktmpdir do |temp_dir|

      site.instance_variable_set(:@validated, true)
      site.instance_variable_set(:@site_path, File.join(temp_dir, test_site_path))
      site.instance_variable_set(:@template_path, nil)
      Geb::stubs(:site_directory_has_config?).returns(true)

      FileUtils.mkdir_p(site.site_path)

      site.create

      assert Dir.exist?(site.site_path)
      assert Dir.exist?(File.join(site.site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::LOCAL_OUTPUT_DIR))
      assert Dir.exist?(File.join(site.site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::RELEASE_OUTPUT_DIR))

    end # Dir.mktmpdir

  end # test "that the create site method skips the site directory folder creation if folder already exists"

  test "that the load site method loads the site successfully from the current working directory" do

    site = Geb::Site.new
    test_site_path = "test/site"

    config = mock('config')
    config.stubs(:site_name).returns("site")
    Geb::Config.stubs(:site_directory_has_config?).returns(true)
    Geb::Config.stubs(:new).returns(config)

    site.load(test_site_path)

    assert_equal site.site_path, test_site_path
    assert site.loaded

  end # test "that the load site method works as expected"

  test "that the load site method looks up the chain to find the site directory" do

    site = Geb::Site.new
    test_site_path = "find/site/here/nothere"

    template_dir_sequence = sequence('template_directory_has_config_sequence')

    config = mock('config')
    config.stubs(:site_name).returns("nothere")
    Geb::Config.stubs(:site_directory_has_config?).returns(false).once.in_sequence(template_dir_sequence)
    Geb::Config.stubs(:site_directory_has_config?).returns(true).once.in_sequence(template_dir_sequence)
    Geb::Config.stubs(:new).returns(config).once

    site.load(test_site_path)

    full_site_path = File.join(Dir.pwd, test_site_path)

    assert_equal site.site_path, full_site_path.gsub('/nothere', '')
    assert site.loaded

  end # test "that the load site method looks up the chain to find the site directory"

  test "that the load site throws an exception if the site directory is not found" do

    site = Geb::Site.new
    test_site_path = "test/site"

    site.stubs(:site_directory_exists?).returns(false)

    error = assert_raises Geb::Site::SiteNotFoundError do
      site.load(test_site_path)
    end # assert_raises

    assert_includes error.message, "is not and is not in a geb site"

  end # test "that the load site throws an exception if the site directory is not found"

  test "that the build pages method builds the pages successfully" do

    site = Geb::Site.new
    test_site_path = "test/site"

    site_pages = ["index.html", "about.html", "contact.html"]

    config = mock('config')
    config.stubs(:site_name).returns("site")
    config.stubs(:output_dir).returns("output")
    config.stubs(:page_extensions).returns(Geb::Defaults::PAGE_EXTENSIONS)
    config.stubs(:template_and_partial_identifier).returns(Geb::Defaults::TEMPLATE_AND_PARTIAL_IDENTIFIER)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    site.expects(:get_page_files).returns(site_pages)
    site.expects(:clear_site_output_directory).once
    site.expects(:output_site).once

    page_build_sequence = sequence('page_build_sequence')
    mock_page = mock('page')

    site_pages.each { |page| Geb::Page.expects(:new).with(site, page).returns(mock_page).once.in_sequence(page_build_sequence) }
    mock_page.expects(:build).times(site_pages.length)

    site.build_pages

  end # test "that the build pages method builds the pages successfully"

  test "that the build pages method throws an exception if site is not loaded" do

    site = Geb::Site.new

    site_pages = ["index.html", "about.html", "contact.html"]

    mock_pages = {}
    site_pages.each { |page| mock_pages[page] = mock('page') }

    site.instance_variable_set(:@pages, mock_pages)
    site.instance_variable_set(:@loaded, false)

    assert_equal site_pages.length, site.pages.length

    error = assert_raises Geb::Site::SiteNotLoadedError do
      site.build_pages
    end # assert_raises

    assert_includes error.message, "Could not build pages"

  end # test "that the build pages method throws an exception if site is not loaded"

  test "that the build pages method throws an exception clear site output throws an exception" do

    site = Geb::Site.new
    test_site_path = "test/site"

    site_pages = ["index.html", "about.html", "contact.html"]

    config = mock('config')
    config.stubs(:site_name).returns("site")
    config.stubs(:output_dir).returns("output")
    config.stubs(:page_extensions).returns(Geb::Defaults::PAGE_EXTENSIONS)
    config.stubs(:template_and_partial_identifier).returns(Geb::Defaults::TEMPLATE_AND_PARTIAL_IDENTIFIER)
    page_mock = mock('page')
    page_mock.expects(:build).times(site_pages.length)
    Geb::Page.expects(:new).returns(page_mock).times(site_pages.length)

    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    site.expects(:get_page_files).returns(site_pages)
    site.expects(:clear_site_output_directory).raises(StandardError.new("Failed to clear site output directory"))
    site.expects(:output_site).never

    error = assert_raises Geb::Site::FailedToOutputSite do
      site.build_pages
    end # assert_raises

    assert_includes error.message, "Failed to clear site output directory"

  end # test "that the build pages method throws an exception clear site output throws an exception"

  test "that the build pages method throws an exception if the page output throws an exception" do

    site = Geb::Site.new
    test_site_path = "test/site"

    site_pages = ["index.html", "about.html", "contact.html"]

    config = mock('config')
    config.stubs(:site_name).returns("site")
    config.stubs(:output_dir).returns("output")
    config.stubs(:page_extensions).returns(Geb::Defaults::PAGE_EXTENSIONS)
    config.stubs(:template_and_partial_identifier).returns(Geb::Defaults::TEMPLATE_AND_PARTIAL_IDENTIFIER)

    page_mock = mock('page')
    page_mock.expects(:build).times(site_pages.length)
    Geb::Page.expects(:new).returns(page_mock).times(site_pages.length)

    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    site.expects(:get_page_files).returns(site_pages)
    site.expects(:clear_site_output_directory).once
    site.expects(:output_site).raises(StandardError.new("Failed to output site."))

    error = assert_raises Geb::Site::FailedToOutputSite do
      site.build_pages
    end # assert_raises

    assert_includes error.message, "Failed to output site"

  end # test "that the build pages method throws an exception if the page output throws an exception"

  test "that the build pages methods builds pages with custom page extensions" do

      site = Geb::Site.new
      test_site_path = "test/site"

      Dir.mktmpdir do |temp_dir|

        site_path = File.join(temp_dir, test_site_path)

        site_pages = []
        site_pages << File.join(site_path, "index.html")
        site_pages << File.join(site_path, "about.htm")
        site_pages << File.join(site_path, "contact.html")
        site_pages << File.join(site_path, "sub/page.html")
        site_pages << File.join(site_path, "sub/sub/page.htm")
        site_pages << File.join(site_path, "assets/styles/foo.css")
        site_pages.sort!

        FileUtils.mkdir_p(site_path)

        site_pages.each do |page|
          FileUtils.mkdir_p(File.dirname(page))
          FileUtils.touch(page)
        end

        config = mock('config')
        config.stubs(:site_name).returns("site")
        config.stubs(:output_dir).returns("output")
        config.stubs(:page_extensions).returns([".htm", ".css"])
        config.stubs(:template_and_partial_identifier).returns(Geb::Defaults::TEMPLATE_AND_PARTIAL_IDENTIFIER)

        page_mock = mock('page')
        page_mock.expects(:build).times(3)
        Geb::Page.expects(:new).returns(page_mock).with(site, File.join(site_path, "about.htm")).once
        Geb::Page.expects(:new).returns(page_mock).with(site, File.join(site_path, "sub/sub/page.htm")).once
        Geb::Page.expects(:new).returns(page_mock).with(site, File.join(site_path, "assets/styles/foo.css")).once

        site.instance_variable_set(:@loaded, true)
        site.instance_variable_set(:@site_path, site_path)
        site.instance_variable_set(:@site_config, config)
        site.expects(:clear_site_output_directory).once
        site.expects(:output_site).once

        site.build_pages

      end # Dir.mktmpdir

  end # test "that the build pages methods builds pages with custom page extensions"

  test "that get page files method returns a list of page files using defaults" do

    site = Geb::Site.new
    test_site_path = "test/site"

    Dir.mktmpdir do |temp_dir|

      site_path = File.join(temp_dir, test_site_path)

      site_pages = []
      site_pages << File.join(site_path, "index.html")
      site_pages << File.join(site_path, "about.html")
      site_pages << File.join(site_path, "contact.html")
      site_pages << File.join(site_path, "sub/page.html")
      site_pages << File.join(site_path, "sub/sub/page.html")
      site_pages.sort!

      FileUtils.mkdir_p(site_path)

      site_pages.each do |page|
        FileUtils.mkdir_p(File.dirname(page))
        FileUtils.touch(page)
      end

      pages = site.send(:get_page_files, site_path)

      assert_equal site_pages, pages

    end # Dir.mktmpdir

  end # test "that get page files method returns a list of page files using defaults"

  test "that get page files method returns a list of page files using custom page extensions" do

    site = Geb::Site.new
    test_site_path = "test/site"

    Dir.mktmpdir do |temp_dir|

      site_path = File.join(temp_dir, test_site_path)

      site_pages = []
      site_pages << File.join(site_path, "index.htm")
      site_pages << File.join(site_path, "about.html")
      site_pages << File.join(site_path, "contact.htm")
      site_pages << File.join(site_path, "styles/test.css")
      site_pages << File.join(site_path, "sub/page.htm")
      site_pages << File.join(site_path, "sub/sub/page.html")
      site_pages.sort!

      FileUtils.mkdir_p(site_path)

      site_pages.each do |page|
        FileUtils.mkdir_p(File.dirname(page))
        FileUtils.touch(page)
      end

      pages = site.get_page_files(site_path, [".htm"])

      assert_equal 3, pages.length
      assert_includes pages, File.join(site_path, "index.htm")
      refute_includes pages, File.join(site_path, "about.html")
      assert_includes pages, File.join(site_path, "contact.htm")
      refute_includes pages, File.join(site_path, "styles/test.css")
      assert_includes pages, File.join(site_path, "sub/page.htm")
      refute_includes pages, File.join(site_path, "sub/sub/page.html")

      pages = site.get_page_files(site_path, [".htm", ".css"])

      assert_equal 4, pages.length
      assert_includes pages, File.join(site_path, "index.htm")
      refute_includes pages, File.join(site_path, "about.html")
      assert_includes pages, File.join(site_path, "contact.htm")
      assert_includes pages, File.join(site_path, "styles/test.css")
      assert_includes pages, File.join(site_path, "sub/page.htm")
      refute_includes pages, File.join(site_path, "sub/sub/page.html")

      pages = site.get_page_files(site_path, [".htm", "css"])

      assert_equal 4, pages.length
      assert_includes pages, File.join(site_path, "index.htm")
      refute_includes pages, File.join(site_path, "about.html")
      assert_includes pages, File.join(site_path, "contact.htm")
      assert_includes pages, File.join(site_path, "styles/test.css")
      assert_includes pages, File.join(site_path, "sub/page.htm")
      refute_includes pages, File.join(site_path, "sub/sub/page.html")

    end # Dir.mktmpdir

  end # test "that get page files method returns a list of page files using custom page extensions"

  test "that the get page files method returns a list of page files while ignoring files with ignore pattern" do

    site = Geb::Site.new
    test_site_path = "test/site"
    test_page_extension = [".htm"]
    ignore_pattern = /^ignore_/

    Dir.mktmpdir do |temp_dir|

      site_path = File.join(temp_dir, test_site_path)

      site_pages = []
      site_pages << File.join(site_path, "index.htm") # not ignored
      site_pages << File.join(site_path, "about.html") # not matched
      site_pages << File.join(site_path, "ignore_contact.htm") # ignored
      site_pages << File.join(site_path, "sub/page.htm") # not ignored
      site_pages << File.join(site_path, "sub/sub/ignore_page.html") # ignored
      site_pages.sort!

      FileUtils.mkdir_p(site_path)

      site_pages.each do |page|
        FileUtils.mkdir_p(File.dirname(page))
        FileUtils.touch(page)
      end

      pages = site.send(:get_page_files, site_path, test_page_extension, ignore_pattern)

      assert_equal site_pages.length - 3, pages.length

    end # Dir.mktmpdir

  end # test "that the get page files method returns a list of page files while ignoring files with ignore pattern"

  test "that the get page files method returns a list of page files while ignoring directories specified" do

    site = Geb::Site.new
    test_site_path = "test/site"
    test_page_extension = [".htm"]
    ignore_pattern = /^ignore_/

    Dir.mktmpdir do |temp_dir|

      site_path = File.join(temp_dir, test_site_path)

      site_pages = []
      site_pages << File.join(site_path, "index.htm") # not ignored
      site_pages << File.join(site_path, "about.html") # not matched
      site_pages << File.join(site_path, "ignore_contact.htm") # ignored
      site_pages << File.join(site_path, "sub/page.htm") # ignored (sub directory)
      site_pages << File.join(site_path, "sub/sub/ignore_page.html") # ignored
      site_pages.sort!

      ignore_directories = []
      ignore_directories << File.join(site_path, "sub")

      FileUtils.mkdir_p(site_path)

      site_pages.each do |page|
        FileUtils.mkdir_p(File.dirname(page))
        FileUtils.touch(page)
      end

      pages = site.send(:get_page_files, site_path, test_page_extension, ignore_pattern, ignore_directories)

      assert_equal site_pages.length - 4, pages.length

    end # Dir.mktmpdir

  end # test "that the get page files method returns a list of page files while ignoring directories specified"

  test "that the clear site output directory method clears the output directory" do

    site = Geb::Site.new
    test_site_path = "test/site"

    Dir.mktmpdir do |temp_dir|

      site_path = File.join(temp_dir, test_site_path)

      FileUtils.mkdir_p(site_path)
      FileUtils.mkdir_p(File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::LOCAL_OUTPUT_DIR))

      # generate some sub-directories and files in the output directory
      FileUtils.mkdir_p(File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::LOCAL_OUTPUT_DIR, "sub"))
      FileUtils.touch(File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::LOCAL_OUTPUT_DIR, "sub", "file1.html"))
      FileUtils.touch(File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::LOCAL_OUTPUT_DIR, "sub", "file2.html"))
      FileUtils.touch(File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::LOCAL_OUTPUT_DIR, "file3.html"))

      config = mock('config')
      config.stubs(:output_dir).returns("output")
      site.instance_variable_set(:@site_path, site_path)
      site.instance_variable_set(:@site_config, config)

      site.clear_site_output_directory(site.get_site_local_output_directory())

      # check to make sure all the files and directories are gone
      refute Dir.exist?(File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::LOCAL_OUTPUT_DIR, "sub"))
      refute File.exist?(File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::LOCAL_OUTPUT_DIR, "file3.html"))

    end # Dir.mktmpdir

  end # test "that the clear site output directory method clears the output directory"

  test "that the output site method files from one directory to another" do

    site = Geb::Site.new
    test_site_path = "test/site"

    Dir.mktmpdir do |temp_dir|

      site_path = File.join(temp_dir, test_site_path)
      very_temp_dir = File.join(temp_dir, "very_temp_dir")

      FileUtils.mkdir_p(site_path)
      FileUtils.mkdir_p(File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::LOCAL_OUTPUT_DIR))

      # generate some sub-directories and files in the output directory
      FileUtils.mkdir_p(File.join(very_temp_dir, "sub"))
      FileUtils.touch(File.join(very_temp_dir, "sub", "file1.html"))
      FileUtils.touch(File.join(very_temp_dir, "sub", "file2.html"))
      FileUtils.touch(File.join(very_temp_dir, "file3.html"))

      config = mock('config')
      config.stubs(:output_dir).returns("output")
      site.instance_variable_set(:@site_path, site_path)
      site.instance_variable_set(:@site_config, config)

      site.output_site(very_temp_dir, site.get_site_local_output_directory())

      # check to make sure all the files and directories are gone
      assert Dir.exist?(File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::LOCAL_OUTPUT_DIR, "sub"))
      assert File.exist?(File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::LOCAL_OUTPUT_DIR, "file3.html"))

    end # Dir.mktmpdir

  end # test "that the output site method files from one directory to another"

  test "that the release method executes the site build first" do

    site = Geb::Site.new
    test_site_path = "test/site"

    site.expects(:build).once

    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@loaded, true)

    site.release

    # TODO: More...

  end # test "that the release method executes the site build first"

  test "that the site release directory is correctly generated" do

    site = Geb::Site.new
    test_site_path = "test/site"

    config = mock('config')
    config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)

    site_release_directory = site.get_site_release_output_directory()

    assert_equal File.join(test_site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::RELEASE_OUTPUT_DIR), site_release_directory

  end # test "that the site release directory is correctly generated"

  test "that the site release sets and resets the releasing flag correctly" do

    site = Geb::Site.new
    test_site_path = "test/site"

    site.expects(:build).once
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@releasing, false)

    site.release

    refute site.releasing

  end # test "that the site release sets and resets the releasing flag correctly"

  test "that the site release handles site not being loaded" do

    site = Geb::Site.new
    test_site_path = "test/site"

    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@loaded, false)
    site.instance_variable_set(:@releasing, false)

    error = assert_raises Geb::Site::SiteNotLoadedError do
      site.release
    end

    assert_includes error.message, "Could not release the site"

  end # test "that the site release handles site not being loaded"

  test "that the site release handles release flag already set" do

    site = Geb::Site.new
    test_site_path = "test/site"

    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@releasing, true)

    assert_raises Geb::Site::SiteReleasingError do
      site.release
    end

  end # test "that the site release handles release flag already set"

  test "that site bundle template method executes as expected" do

    site = Geb::Site.new
    test_site_path = "test/site"

    template_paths_config = ["assets", "shared", "*.html", "site.webmanifest", "geb.config.yml"]
    template_file_paths = template_paths_config.map { |path| File.join(test_site_path, path) }

    config = mock('config')
    config.stubs(:template_paths).returns(template_paths_config)
    config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
    config.stubs(:generate_config_file)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_config, config)
    Dir.stubs(:glob).returns(template_file_paths)
    Geb.expects(:copy_paths_to_directory)
    Open3.expects(:capture3)

    site.bundle_template()

  end # test "that site bundle template method executes as expected"

  test "that the site bundle template method throws an exception if the site is not loaded" do

    site = Geb::Site.new
    test_site_path = "test/site"

    template_paths_config = ["assets", "shared", "*.html", "site.webmanifest", "geb.config.yml"]

    config = mock('config')
    config.stubs(:template_paths).returns(template_paths_config)
    config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@loaded, false)

    error = assert_raises Geb::Site::SiteNotFoundError do
      site.bundle_template()
    end

    assert_includes error.message, "Site not loaded"

  end # test "that the site bundle template method throws an exception if the site is not loaded"

  test "that the site bundle template method throws an exception if the template paths are empty" do

    site = Geb::Site.new
    test_site_path = "test/site"

    template_paths_config = ["assets", "shared", "*.html", "site.webmanifest", "geb.config.yml"]

    config = mock('config')
    config.stubs(:template_paths).returns(template_paths_config)
    config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    site.instance_variable_set(:@loaded, true)

    error = assert_raises Geb::Site::InvalidTemplateSpecification do
      site.bundle_template()
    end

    assert_includes error.message, "Config template_paths not specified."

  end # test "that the site bundle template method throws an exception if the template paths are empty"

  test "that the template archive release path is constructed correctly" do

    site = Geb::Site.new
    site_path = "test/site"

    config = mock('config')
    config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)

    site.instance_variable_set(:@site_path, site_path)
    site.instance_variable_set(:@site_config, config)

    release_path = site.get_template_archive_release_path()

    assert_equal release_path, File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::RELEASE_OUTPUT_DIR, Geb::Defaults::TEMPLATE_ARCHIVE_FILENAME)

  end # test "that the template archive release path is constructed correctly"

  test "that launch remot method executes as expected" do

    site = Geb::Site.new
    test_site_path = "test/site"
    remote_uri = "user@server.com"

    config = mock('config')
    config.stubs(:remote_uri).returns(remote_uri)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    Open3.expects(:capture3).with("ssh", remote_uri).once

    site.launch_remote

  end # test "that launch remote method executes as expected"

  test "that launch remote method handles site not loaded exception" do

    site = Geb::Site.new
    test_site_path = "test/site"
    remote_uri = "user@server.com"

    config = mock('config')
    config.stubs(:remote_uri).returns(remote_uri)
    site.instance_variable_set(:@loaded, false)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    Open3.expects(:capture3).with("ssh", remote_uri).never

    error = assert_raises Geb::Site::SiteNotFoundError do
      site.launch_remote
    end

    assert_includes error.message, "Site not loaded"

  end # test "that launch remote method handles site not loaded exception"

  test "that launch remote method handles remote uri not specified exception" do

    site = Geb::Site.new
    test_site_path = "test/site"
    remote_uri = nil

    config = mock('config')
    config.stubs(:remote_uri).returns(remote_uri)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    Open3.expects(:capture3).with("ssh", remote_uri).never

    error = assert_raises Geb::Site::RemoteURINotConfigured do
      site.launch_remote
    end

    assert_includes error.message, "Remote URI not configured in geb.config.yml"

  end # test "that launch remote method handles remote uri not specified exception"

  test "that launch remote method handles Interrupt and IOError exceptions" do

    site = Geb::Site.new
    test_site_path = "test/site"
    remote_uri = "user@server.com"

    config = mock('config')
    config.stubs(:remote_uri).returns(remote_uri)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    Open3.expects(:capture3).with("ssh", remote_uri).raises(Interrupt).once
    Geb.expects(:log).with("Remote session interrupted.").once

    site.launch_remote

  end # test "that launch remote method handles Interrupt and IOError exceptions"

  test "that launch remote method handles general exception while executing external command" do

    site = Geb::Site.new
    test_site_path = "test/site"
    remote_uri = "user@server.com"

    config = mock('config')
    config.stubs(:remote_uri).returns(remote_uri)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    Open3.expects(:capture3).with("ssh", remote_uri).raises(StandardError).once
    Geb.expects(:log).with("Remote session interrupted.").once

    site.launch_remote

  end # test "that launch remote method handles general exception while executing external command"

  test "that upload release to remote method executes as expected" do

    site = Geb::Site.new
    test_site_path = "test/site"
    remote_uri = "user@server.com"
    remote_path = '/var/www/site'

    config = mock('config')
    config.stubs(:remote_uri).returns(remote_uri)
    config.stubs(:remote_path).returns(remote_path)
    config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
    site.expects(:released?).returns(true)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    Open3.expects(:popen3).once

    site.upload_release_to_remote

  end # test "that upload release to remote method executes as expected"

  test "that upload release to remote method handles if site has not been released" do

    site = Geb::Site.new
    test_site_path = "test/site"
    remote_uri = "user@server.com"
    remote_path = '/var/www/site'

    config = mock('config')
    config.stubs(:remote_uri).returns(remote_uri)
    config.stubs(:remote_path).returns(remote_path)
    config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
    site.expects(:released?).returns(false)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    Open3.expects(:popen3).never

    error = assert_raises Geb::Site::SiteNotReleasedError do
      site.upload_release_to_remote
    end

    assert_includes error.message, "Site not released."

  end # test "that upload release to remote method handles if site has not been released"

  test "that upload release to remote method handles if remote uri is not specified" do

    site = Geb::Site.new
    test_site_path = "test/site"
    remote_uri = nil
    remote_path = '/var/www/site'

    config = mock('config')
    config.stubs(:remote_uri).returns(remote_uri)
    config.stubs(:remote_path).returns(remote_path)
    config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
    site.expects(:released?).returns(true)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    Open3.expects(:popen3).never

    error = assert_raises Geb::Site::RemoteURINotConfigured do
      site.upload_release_to_remote
    end

    assert_includes error.message, "Remote URI not configured in geb.config.yml"

  end # test "that upload release to remote method handles if remote uri is not specified"

  test "that upload release to remote method handles if remote path is not specified" do

    site = Geb::Site.new
    test_site_path = "test/site"
    remote_uri = "user@server.com"
    remote_path = nil

    config = mock('config')
    config.stubs(:remote_uri).returns(remote_uri)
    config.stubs(:remote_path).returns(remote_path)
    config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
    site.expects(:released?).returns(true)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    Open3.expects(:popen3).never

    error = assert_raises Geb::Site::RemotePathNotConfigured do
      site.upload_release_to_remote
    end

    assert_includes error.message, "Remote Path is not configured in geb.config.yml"

  end # test "that upload release to remote method handles if remote path is not specified"


  test "that upload release to remote method handles Interrupt and IOError exceptions" do

    site = Geb::Site.new
    test_site_path = "test/site"
    remote_uri = "user@server.com"
    remote_path = '/var/www/site'

    config = mock('config')
    config.stubs(:remote_uri).returns(remote_uri)
    config.stubs(:remote_path).returns(remote_path)
    config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
    site.expects(:released?).returns(true)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    Open3.expects(:popen3).raises(Interrupt).once
    Geb.expects(:log).with("Upload interrupted.").once

    site.upload_release_to_remote

  end # test "that upload release to remote method handles Interrupt and IOError exceptions"

  test "that upload release to remote method handles general exception while executing external command" do

    site = Geb::Site.new
    test_site_path = "test/site"
    remote_uri = "user@server.com"
    remote_path = '/var/www/site'

    config = mock('config')
    config.stubs(:remote_uri).returns(remote_uri)
    config.stubs(:remote_path).returns(remote_path)
    config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
    site.expects(:released?).returns(true)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)
    Open3.expects(:popen3).raises(Geb::Error).once
    Geb.expects(:log).with("Upload interrupted.").once

    site.upload_release_to_remote

  end # test "that lupload release to remote method handles general exception while executing external command"

  test "that upload release to remote method handles output from external command"  do

    site = Geb::Site.new
    test_site_path = "test/site"
    remote_uri = "user@server.com"
    remote_path = '/var/www/site'

    config = mock('config')
    config.stubs(:remote_uri).returns(remote_uri)
    config.stubs(:remote_path).returns(remote_path)
    config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
    site.expects(:released?).returns(true)
    site.instance_variable_set(:@loaded, true)
    site.instance_variable_set(:@site_path, test_site_path)
    site.instance_variable_set(:@site_config, config)

    mock_stdout = StringIO.new("mocked stdout line 1\nmocked stdout line 2\n")
    mock_stderr = StringIO.new("mocked stderr line 1\nmocked stderr line 2\n")
    mock_wait_thr = mock('wait_thr')
    mock_wait_thr.stubs(:value) #.returns(mock('status', exitstatus: 0))

    Open3.stubs(:popen3).yields(nil, mock_stdout, mock_stderr, mock_wait_thr)

    site.upload_release_to_remote

  end # test "that upload release to remote method handles output from external command"

  test "that the released method returns true if the release directory exists and is not empty" do

    site = Geb::Site.new
    test_site_path = "site"

    Dir.mktmpdir do |temp_dir|

      site_path = File.join(temp_dir, test_site_path)
      site_release_path = File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::RELEASE_OUTPUT_DIR)

      config = mock('config')
      config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
      site.instance_variable_set(:@site_path, site_path)
      site.instance_variable_set(:@site_config, config)

      FileUtils.mkdir_p(site_path)
      FileUtils.mkdir_p(site_release_path)

      FileUtils.touch(File.join(site_release_path, "dummy_file.html"))

      assert_equal site_release_path, site.get_site_release_output_directory()

      assert site.released?

    end # Dir.mktmpdir

  end # test "that the released method returns true if the release directory exists and is not empty"

  test "that the released method returns false if the release directory does not exist" do

    site = Geb::Site.new
    test_site_path = "site"

    Dir.mktmpdir do |temp_dir|

      site_path = File.join(temp_dir, test_site_path)
      site_release_path = File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::RELEASE_OUTPUT_DIR)

      config = mock('config')
      config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
      site.instance_variable_set(:@site_path, site_path)
      site.instance_variable_set(:@site_config, config)

      FileUtils.mkdir_p(site_path)

      assert_equal site_release_path, site.get_site_release_output_directory()

      refute site.released?

    end # Dir.mktmpdir

  end # test "that the released method returns false if the release directory does not exist"

  test "that the released method returns false if the release directory is empty" do

    site = Geb::Site.new
    test_site_path = "site"

    Dir.mktmpdir do |temp_dir|

      site_path = File.join(temp_dir, test_site_path)
      site_release_path = File.join(site_path, Geb::Defaults::OUTPUT_DIR, Geb::Defaults::RELEASE_OUTPUT_DIR)

      config = mock('config')
      config.stubs(:output_dir).returns(Geb::Defaults::OUTPUT_DIR)
      site.instance_variable_set(:@site_path, site_path)
      site.instance_variable_set(:@site_config, config)

      FileUtils.mkdir_p(site_path)
      FileUtils.mkdir_p(site_release_path)

      assert_equal site_release_path, site.get_site_release_output_directory()

      refute site.released?

    end # Dir.mktmpdir

  end # test "that the released method returns false if the release directory is empty"

end # class SiteTest < Minitest::Test
