# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the site class
#
#  Licence MIT
# -----------------------------------------------------------------------------

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

    site.stubs(:site_directory_exists?).returns(false)

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
      site.stubs(:template_directory_has_config?).returns(true)
      site.stubs(:is_bundled_template?).returns(false)

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
    site.stubs(:template_directory_has_config?).returns(true)

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

    assert_match(/Web server returned 404/, error.message)

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

    assert_match(/Specified template is not a gzip archive/, error.message)

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

    assert_match(/HTTP request failed/, error.message)

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

    assert_match(/Failed to extract template archive: tar: Error opening archive/, error.message)

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

    assert_match(/Failed to extract template archive: tar: Error opening archive/, error.message)

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

      site.create

      assert Dir.exist?(site.site_path)
      assert Dir.exist?(File.join(site.site_path, Geb::Defaults::LOCAL_OUTPUT_DIR))
      assert Dir.exist?(File.join(site.site_path, Geb::Defaults::RELEASE_OUTPUT_DIR))

    end # Dir.mktmpdir

  end # test "that the create site method creates a site folder without a template"

  test "that the create site method creates a site folder with a template" do

    site = Geb::Site.new
    test_site_path = "test_site"
    test_template_path = "template_folder"

    # stub the FileUtils.cp_r method
    FileUtils.expects(:cp_r).returns(true)

    Dir.mktmpdir do |temp_dir|

      site.instance_variable_set(:@validated, true)
      site.instance_variable_set(:@site_path, File.join(temp_dir, test_site_path))
      site.instance_variable_set(:@template_path, test_template_path)

      site.create

      assert Dir.exist?(site.site_path)
      assert Dir.exist?(File.join(site.site_path, Geb::Defaults::LOCAL_OUTPUT_DIR))
      assert Dir.exist?(File.join(site.site_path, Geb::Defaults::RELEASE_OUTPUT_DIR))

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

      FileUtils.mkdir_p(site.site_path)

      site.create

      assert Dir.exist?(site.site_path)
      assert Dir.exist?(File.join(site.site_path, Geb::Defaults::LOCAL_OUTPUT_DIR))
      assert Dir.exist?(File.join(site.site_path, Geb::Defaults::RELEASE_OUTPUT_DIR))

    end # Dir.mktmpdir

  end # test "that the create site method skips the site directory folder creation if folder already exists"

end # class SiteTest < Minitest::Test
