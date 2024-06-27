# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the template class
#
#  Licence MIT
# -----------------------------------------------------------------------------

require "test_helper"

class TemplateTest < Geb::ApiTest

  test "that template default initializes" do

    template_path = File.join(Dir.pwd, "test", "fixtures", "template.html")
    template_content = "This is a template file"

    Geb::Template.any_instance.stubs(:template_file_exists?).returns(true)
    File.stubs(:read).returns(template_content).once

    template = Geb::Template.new(template_path)

    assert_instance_of Geb::Template, template
    assert_equal template.path, template_path
    assert_equal template.content, template_content

  end # test "that site default initializes"

  test "that template constructor throws an error if the template file does not exist" do

    template_path = File.join(Dir.pwd, "test", "fixtures", "template.html")

    Geb::Template.any_instance.stubs(:template_file_exists?).returns(false)

    error = assert_raises Geb::Template::TemplateFileNotFound do
      Geb::Template.new(template_path)
    end

    assert_match(/#{template_path}/, error.message)

  end # test "that template constructor throws an error if the template file does not exist"

  test "that template constructor throws an error if the template file cannot be read" do

    template_path = File.join(Dir.pwd, "test", "fixtures", "template.html")

    Geb::Template.any_instance.stubs(:template_file_exists?).returns(true)
    File.stubs(:read).raises(Errno::ENOENT)

    assert_raises Geb::Template::TemplateFileReadFailure do
      Geb::Template.new(template_path)
    end

  end # test "that template constructor throws an error if the template file cannot be read"

  test "that self.load returns the template content when the template file exists" do

    template_path = File.join(Dir.pwd, "test", "fixtures", "template.html")
    template_content = "This is a template file"

    Geb::Template.any_instance.stubs(:template_file_exists?).returns(true)
    File.stubs(:read).returns(template_content)

    template = Geb::Template.load(template_path)

    assert_equal template_content, template.content

  end # test "that self.load returns the template content when the template file exists"

  test "that self.load returns a cached copy of the template if it was laoded previously" do

    assert_empty Geb::Template.class_variable_set(:@@loaded_templates, {})

    template_path = File.join(Dir.pwd, "test", "fixtures", "template.html")
    template_content = "This is a template file"

    Geb::Template.any_instance.stubs(:template_file_exists?).returns(true)
    File.stubs(:read).returns(template_content).once

    # assert the loaded_templates class variable is empty
    assert_empty Geb::Template.class_variable_get(:@@loaded_templates)
    template1 = Geb::Template.load(template_path)
    assert_equal 1, Geb::Template.class_variable_get(:@@loaded_templates).length
    template2 = Geb::Template.load(template_path)
    assert_equal 1, Geb::Template.class_variable_get(:@@loaded_templates).length

    assert_same template1, template2

  end # test "that self.load returns a cached copy of the template if it was laoded previously"

  test "that extract template path, finds the template path in the page content" do

    # initalize the template path
    original_template_path = "shared/templates/_site.html"

    # generate multiline page content
    page_content = <<-PAGE
      <p>foobar</p>
      <% template: #{original_template_path} %>
      <p>foobar</p>
    PAGE

    template_path = Geb::Template.extract_template_path(page_content)

    assert_equal original_template_path, template_path

  end # test "that extract template path, finds the template path in the page content"

  test "that extract template path, returns nil if no template path is found in the page content" do

    # generate multiline page content
    page_content = <<-PAGE
      <p>foobar</p>
      <p>foobar</p>
    PAGE

    template_path = Geb::Template.extract_template_path(page_content)

    assert_nil template_path

  end # test "that extract template path, returns nil if no template path is found in the page content"

  test "that extract template path, returns the first entry when multiple template definitions are present" do

    # initalize the template path
    original_template_path = "shared/templates/_site.html"

    # generate multiline page content
    page_content = <<-PAGE
      <p>foobar</p>
      <% template: #{original_template_path} %>
      <p>foobar</p>
      <% template: shared/templates/_site2.html %>
      <p>foobar</p>
    PAGE

    template_path = Geb::Template.extract_template_path(page_content)

    assert_equal original_template_path, template_path

  end # test "that extract template path, returns the first entry when multiple template definitions are present"

  test "that extract sections for template, finds the sections in the page content" do

    # initalize the sections
    original_sections = {
      "header" => "header content",
      "footer" => "footer content"
    }

    # generate multiline page content
    page_content = <<-PAGE
      <p>foobar</p>
      <% start: header %>
      #{original_sections["header"]}
      <% end: header %>
      <p>foobar</p>
      <% start: footer %>
      #{original_sections["footer"]}
      <% end: footer %>
      <p>foobar</p>
    PAGE

    sections = Geb::Template.extract_sections_for_template(page_content)

    assert_equal original_sections, sections

  end # test "that extract sections for template, finds the sections in the page content"

  test "that extract sections for template, returns an empty hash if no sections are found in the page content" do

    # generate multiline page content
    page_content = <<-PAGE
      <p>foobar</p>
      <p>foobar</p>
    PAGE

    sections = Geb::Template.extract_sections_for_template(page_content)

    assert_empty sections

  end # test "that extract sections for template, returns an empty hash if no sections are found in the page content"

  test "that parse template, returns the template content and sections" do

    original_template_path = "shared/templates/_site.html"

    # initalize the sections
    original_sections = {
      "header" => "header content",
      "footer" => "footer content"
    }

    # generate multiline template content
    template_content = <<-TEMPLATEPAGE
      <div class="header">
      <%= insert: header %>
      </div>
      <div class="footer">
      <%= insert: footer %>
      </div>
    TEMPLATEPAGE

    parsed_template_content = <<-PARSEDTEMPLATEPAGE
      <div class="header">
      header content
      </div>
      <div class="footer">
      footer content
      </div>
    PARSEDTEMPLATEPAGE

    Geb::Template.any_instance.stubs(:template_file_exists?).returns(true)
    File.stubs(:read).returns(template_content).once

    template = Geb::Template.new(original_template_path)
    output = template.parse(original_sections)

    assert_equal parsed_template_content, output
    refute_match(/<%= insert: header %>/, output)
    refute_match(/<%= insert: footer %>/, output)

  end # test "that parse template, returns the template content and sections"

  test "that that template file exists method finds files" do

    File.stubs(:read)

    Dir.mktmpdir do |dir|

      # generate a temporary file
      file_path = File.join(dir, "template.html")
      non_existent_file_path = File.join(dir, "non_existent_template.html")
      File.write(file_path, "This is a template file")

      Geb::Template.new(file_path)

      assert_raises Geb::Template::TemplateFileNotFound do
        Geb::Template.new(non_existent_file_path)
      end # assert_raises

    end # Dir.mktmpdir

  end # test "that that template file exists method finds files"

end # class TemplateTest < Geb::ApiTest
