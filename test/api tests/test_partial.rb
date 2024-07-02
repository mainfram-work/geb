# frozen_string_literal: true
#
# Tests the partial class
#
# @title Geb - Test - Partial
# @author Edin Mustajbegovic <edin@actiontwelve.com>
# @copyright 2024 Edin Mustajbegovic
# @license MIT
#
# @see https://github.com/mainfram-work/geb for more information

require "test_helper"

class PartialTest < Geb::ApiTest

  test "that partial default initializes" do

    partial_path = File.join(Dir.pwd, "test", "partials", "template.html")
    partial_content = "This is a partial file"

    Geb::Partial.any_instance.stubs(:partial_file_exists?).returns(true)
    File.stubs(:read).returns(partial_content)

    partial = Geb::Partial.new(partial_path)

    assert_instance_of Geb::Partial, partial
    assert_equal partial.path, partial_path
    assert_equal partial.content, partial_content

  end # test "that partial default initializes"

  test "that partial constructor throws an error if the partial file does not exist" do

    partial_path = File.join(Dir.pwd, "test", "partials", "template.html")

    Geb::Partial.any_instance.stubs(:partial_file_exists?).returns(false)

    error = assert_raises Geb::Partial::PartialFileNotFound do
      Geb::Partial.new(partial_path)
    end

    assert_includes(error.message, partial_path)

  end # test "that partial constructor throws an error if the partial file does not exist"

  test "that partial constructor throws an error if the partial file cannot be read" do

    partial_path = File.join(Dir.pwd, "test", "partials", "template.html")

    Geb::Partial.any_instance.stubs(:partial_file_exists?).returns(true)
    File.stubs(:read).raises(Errno::ENOENT)

    assert_raises Geb::Partial::PartialFileReadFailure do
      Geb::Partial.new(partial_path)
    end # error = assert_raises Geb::Partial::PartialFileNotFound do

  end # test "that partial constructor throws an error if the page file cannot be read"

  test "that self.load returns the partial content when the partial file exists" do

    partial_path = File.join(Dir.pwd, "test", "partials", "template.html")
    partial_content = "This is a partial file"

    Geb::Partial.any_instance.stubs(:partial_file_exists?).returns(true)
    File.stubs(:read).returns(partial_content)

    partial = Geb::Partial.load(partial_path)

    assert_equal partial_content, partial.content

  end # test "that self.load returns the template content when the template file exists"

  test "that self.load returns a cached copy of the partial if it was laoded previously" do

    assert_empty Geb::Partial.class_variable_set(:@@loaded_partials, {})

    partial_path = File.join(Dir.pwd, "test", "partials", "template.html")
    partial_content = "This is a partial file"

    Geb::Partial.any_instance.stubs(:partial_file_exists?).returns(true)
    File.stubs(:read).returns(partial_content).once

    # assert the loaded_templates class variable is empty
    assert_empty Geb::Partial.class_variable_get(:@@loaded_partials)
    partial1 = Geb::Partial.load(partial_path)
    assert_equal 1, Geb::Partial.class_variable_get(:@@loaded_partials).length
    partial2 = Geb::Partial.load(partial_path)
    assert_equal 1, Geb::Partial.class_variable_get(:@@loaded_partials).length

    assert_same partial1, partial2

  end # test "that self.load returns a cached copy of the template if it was laoded previously"

  test "that self.process_partials returns the partial content when the partial file exists" do

      site_path = File.join(Dir.pwd, "test", "site")
      page_content = <<-PAGE
        <div class="partial1-container">
        <%= partial: partial1.html %>
        </div>
        <div class="partial1-container">
        <%= partial: partial2.html %>
        </div>
      PAGE
      parsed_page_content = <<-PARSEDPAGE
        <div class="partial1-container">
        partial 1 content
        </div>
        <div class="partial1-container">
        partial 2 content
        </div>
      PARSEDPAGE

      # mock the partial object
      partial = mock('partial')

      # setup a sequence
      partial_sequence = sequence('partial_sequence')
      partial.stubs(:content).returns("partial 1 content").once.in_sequence(partial_sequence)
      partial.stubs(:content).returns("partial 2 content").once.in_sequence(partial_sequence)
      Geb::Partial.stubs(:load).returns(partial)

      # call the method
      partial_count, content = Geb::Partial.process_partials(site_path, page_content)

      assert_equal 2, partial_count
      assert_equal parsed_page_content, content

  end # test "that self.extract_partial_paths returns the partial content when the partial file exists"

  test "that that partial file exists method finds files" do

    File.stubs(:read)

    Dir.mktmpdir do |dir|

      # generate a temporary file
      file_path = File.join(dir, "partial.html")
      non_existent_file_path = File.join(dir, "non_existent_partial.html")
      File.write(file_path, "This is a partial file")

      Geb::Partial.new(file_path)

      assert_raises Geb::Partial::PartialFileNotFound do
        Geb::Partial.new(non_existent_file_path)
      end # assert_raises

    end # Dir.mktmpdir

  end # test "that that template file exists method finds files"

end # class PartialTest < Geb::ApiTest
