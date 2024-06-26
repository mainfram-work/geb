# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the page class
#
#  Licence MIT
# -----------------------------------------------------------------------------

require "test_helper"

class PageTest < Geb::ApiTest

  test "that page default initializes" do

    page_path = File.join(Dir.pwd, "test", "fixtures", "template.html")
    page_content = "This is a template file"

    site = mock('site')
    site.stubs(:site_path).returns(Dir.pwd)

    Geb::Page.any_instance.stubs(:page_file_exists?).returns(true)
    Geb::Page.any_instance.stubs(:parse)
    File.stubs(:read).returns(page_content)

    page = Geb::Page.new(site, page_path)

    assert_instance_of Geb::Page, page
    assert_equal page.path, page_path
    assert_equal page.content, page_content

  end # test "that site default initializes"

  test "that page constructor throws an error if the page file does not exist" do

    page_path = File.join(Dir.pwd, "test", "fixtures", "template.html")

    site = mock('site')
    site.stubs(:site_path).returns(Dir.pwd)

    Geb::Page.any_instance.stubs(:page_file_exists?).returns(false)

    error = assert_raises Geb::Page::PageFileNotFound do
      Geb::Page.new(site, page_path)
    end

    assert_includes(error.message, page_path)

  end # test "that page constructor throws an error if the page file does not exist"

  test "that page constructor throws an error if the page file cannot be read" do

    page_path = File.join(Dir.pwd, "test", "fixtures", "template.html")

    site = mock('site')
    site.stubs(:site_path).returns(Dir.pwd)

    Geb::Page.any_instance.stubs(:page_file_exists?).returns(true)
    File.stubs(:read).raises(Errno::ENOENT)

    assert_raises Geb::Page::PageFileReadFailure do
      Geb::Page.new(site, page_path)
    end # assert_raises

  end # test "that page constructor throws an error if the page file cannot be read"

  test "that page parse method works" do

    page_path = File.join(Dir.pwd, "test", "fixtures", "template.html")
    page_content = "This is a template file"

    parsed_page_content = "This is a parsed template file"

    site = mock('site')
    site.stubs(:site_path).returns(Dir.pwd)

    Geb::Page.any_instance.stubs(:page_file_exists?).returns(true)
    Geb::Page.any_instance.stubs(:parse_for_templates).returns(parsed_page_content)
    Geb::Page.any_instance.stubs(:parse_for_partials).returns(parsed_page_content)
    File.stubs(:read).returns(page_content)

    page = Geb::Page.new(site, page_path)

    assert_respond_to page, :parse

    page.parse

    assert_respond_to page, :parsed_content
    assert_equal page.parsed_content, parsed_page_content
    refute_equal page.parsed_content, page.content

  end # test "that page parse method works"

  test "that page parse_for_templates method works" do

    page_path = File.join(Dir.pwd, "test", "fixtures", "template.html")

    page_content = <<-PAGE
      <% template: test_template.html %>
      <p>foobar</p>
      <% start: header %>
        header content
      <% end: header %>
      <p>foobar</p>
      <% start: footer %>
        footer content
      <% end: footer %>
      <p>foobar</p>
    PAGE

    original_sections = {
      "header" => "header content",
      "footer" => "footer content"
    }

    template_parsed_content = <<-TEMPLATE
      <p>foobar</p>
    TEMPLATE

    site = mock('site')
    site.stubs(:site_path).returns(Dir.pwd)

    template = mock('template')
    template.stubs(:parse).returns(template_parsed_content)

    Geb::Page.any_instance.stubs(:page_file_exists?).returns(true)
    Geb::Page.any_instance.stubs(:parse)
    File.stubs(:read).returns(page_content)

    extract_template_path_sequence = sequence('extract_template_path_sequence')
    Geb::Template.stubs(:extract_template_path).returns("test_template.html").once.in_sequence(extract_template_path_sequence)
    Geb::Template.stubs(:extract_template_path).returns(nil).in_sequence(extract_template_path_sequence)
    Geb::Template.stubs(:extract_sections_for_template).returns(original_sections).once.in_sequence(extract_template_path_sequence)
    Geb::Template.stubs(:extract_sections_for_template).returns({}).in_sequence(extract_template_path_sequence)
    Geb::Template.stubs(:load).returns(template)
    Geb::Template.stubs(:parse).returns(template_parsed_content)

    page = Geb::Page.new(site, page_path)

    output_content = page.parse_for_templates(page_content)

    assert_equal output_content, template_parsed_content

  end # test "that page parse_for_templates method works"

  test "that page parse_for_templates method raises an exception if page content has sections but no template defintion" do

    page_path = File.join(Dir.pwd, "test", "fixtures", "template.html")
    page_content = <<-PAGE
      <p>foobar</p>
      <% start: header %>
        header content
      <% end: header %>
      <p>foobar</p>
      <% start: footer %>
        footer content
      <% end: footer %>
      <p>foobar</p>
    PAGE

    site = mock('site')
    site.stubs(:site_path).returns(Dir.pwd)

    Geb::Page.any_instance.stubs(:page_file_exists?).returns(true)
    Geb::Page.any_instance.stubs(:parse)
    File.stubs(:read).returns(page_content)

    page = Geb::Page.new(site, page_path)

    assert_raises Geb::Page::PageMissingTemplateDefition do
      page.parse_for_templates(page_content)
    end # assert_raises

  end # test "that page parse_for_templates method raises an exception if page content has sections but no template defintion"

  test "that page parse_for_partials method works" do

    page_path = File.join(Dir.pwd, "test", "fixtures", "template.html")
    page_content = <<-PAGE
      <% partial: test_partial.html %>
      <% partial: test_partial2.html %>
    PAGE

    partial_content = "This is a partial file"

    site = mock('site')
    site.stubs(:site_path).returns(Dir.pwd)

    Geb::Page.any_instance.stubs(:page_file_exists?).returns(true)
    Geb::Page.any_instance.stubs(:parse)
    File.stubs(:read).returns(page_content)

    extract_partial_path_sequence = sequence('extract_partial_path_sequence')
    Geb::Partial.stubs(:process_partials).with(Dir.pwd, page_content).returns([2, partial_content]).once.in_sequence(extract_partial_path_sequence)
    Geb::Partial.stubs(:process_partials).with(Dir.pwd, partial_content).returns([0, partial_content]).in_sequence(extract_partial_path_sequence)

    page = Geb::Page.new(site, page_path)

    output_content = page.parse_for_partials(page_content)

    assert_equal output_content, partial_content

  end # test "that page parse_for_partials method works"

  test "that page build method works" do

    site_path = Dir.pwd
    page_path = File.join(Dir.pwd, "test", "fixtures", "template.html")
    output_path = File.join(Dir.pwd, "output")
    page_output_path = page_path.gsub(site_path, output_path)
    page_content = "This is a template file"

    site = mock('site')
    site.stubs(:site_path).returns(site_path)
    site.stubs(:output_path).returns(File.join(Dir.pwd, "output"))

    Geb::Page.any_instance.stubs(:page_file_exists?).returns(true)
    Geb::Page.any_instance.stubs(:parse)
    Geb::Page.any_instance.stubs(:parse_for_templates)
    Geb::Page.any_instance.stubs(:parse_for_partials)
    File.stubs(:read).returns(page_content)
    FileUtils.stubs(:mkdir_p).with(File.dirname(page_output_path)).returns(true)
    File.stubs(:write).with(page_output_path, page_content).returns(true)

    page = Geb::Page.new(site, page_path)
    page.instance_variable_set(:@parsed_content, page_content)

    page.build(output_path)

  end # test "that page build method works"

  test "that page build method raises an exception if the output directory cannot be created" do

    site_path = Dir.pwd
    page_path = File.join(Dir.pwd, "test", "fixtures", "template.html")
    output_path = File.join(Dir.pwd, "output")
    page_output_path = page_path.gsub(site_path, output_path)
    page_content = "This is a template file"

    site = mock('site')
    site.stubs(:site_path).returns(site_path)
    site.stubs(:output_path).returns(File.join(Dir.pwd, "output"))

    Geb::Page.any_instance.stubs(:page_file_exists?).returns(true)
    Geb::Page.any_instance.stubs(:parse)
    Geb::Page.any_instance.stubs(:parse_for_templates)
    Geb::Page.any_instance.stubs(:parse_for_partials)
    File.stubs(:read).returns(page_content)
    FileUtils.stubs(:mkdir_p).raises(Errno::EACCES)
    File.stubs(:write).with(page_output_path, page_content).returns(true)

    page = Geb::Page.new(site, page_path)
    page.instance_variable_set(:@parsed_content, page_content)

    assert_raises Geb::Page::FailedToOutputPage do
      page.build(output_path)
    end # assert_raises

  end # test "that page build method raises an exception if the output directory cannot be created"

  test "that page build method raises an exception if the output file cannot be written" do

    site_path = Dir.pwd
    page_path = File.join(Dir.pwd, "test", "fixtures", "template.html")
    output_path = File.join(Dir.pwd, "output")
    page_output_path = page_path.gsub(site_path, output_path)
    page_content = "This is a template file"

    site = mock('site')
    site.stubs(:site_path).returns(site_path)
    site.stubs(:output_path).returns(File.join(Dir.pwd, "output"))

    Geb::Page.any_instance.stubs(:page_file_exists?).returns(true)
    Geb::Page.any_instance.stubs(:parse)
    Geb::Page.any_instance.stubs(:parse_for_templates)
    Geb::Page.any_instance.stubs(:parse_for_partials)
    File.stubs(:read).returns(page_content)
    FileUtils.stubs(:mkdir_p).with(File.dirname(page_output_path)).returns(true)
    File.stubs(:write).raises(Errno::EACCES)

    page = Geb::Page.new(site, page_path)
    page.instance_variable_set(:@parsed_content, page_content)

    assert_raises Geb::Page::FailedToOutputPage do
      page.build(output_path)
    end # assert_raises

  end # test "that page build method raises an exception if the output file cannot be written"

  test "that that template file exists method finds files" do

    site_path = Dir.pwd
    page_content = "This is a template file"

    site = mock('site')
    site.stubs(:site_path).returns(site_path)

    Geb::Page.any_instance.stubs(:parse)
    File.stubs(:read).returns(page_content)

    Dir.mktmpdir do |dir|

      # generate a temporary file
      file_path = File.join(dir, "template.html")
      non_existent_file_path = File.join(dir, "non_existent_template.html")
      File.write(file_path, "This is a template file")

      Geb::Page.new(site, file_path)

      assert_raises Geb::Page::PageFileNotFound do
        Geb::Page.new(site, non_existent_file_path)
      end # assert_raises

    end # Dir.mktmpdir

  end # test "that that template file exists method finds files"

end # class PageTest < Geb::ApiTest
