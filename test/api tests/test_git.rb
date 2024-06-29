# frozen_string_literal: true
# -----------------------------------------------------------------------------
#  Ruby Gem: Geb
#  Author: Edin Mustajbegovic
#  Email: edin@actiontwelve.com
#
#  Tests the git class
#
#  Licence MIT
# -----------------------------------------------------------------------------

require "test_helper"

class GitTest < Geb::ApiTest

  test "that git validation raises an error if given fake folder" do

    assert_raises Geb::Git::FailedValidationError do
      Geb::Git.validate_git_repo("/some/fake/folder/path")
    end # assert_raises

  end # test "that git validation raises an error if given fake folder"

  test "that git validation raises an error if given a folder that already has a git repo" do

      assert_raises Geb::Git::InsideGitRepoError do
        Geb::Git.validate_git_repo(__dir__)
      end # assert_raises

  end # test "that git validation raises an error if given a folder that already has a git repo"

  test "that git validation raises an error if any other error other then not a git repo is raised" do

    capture3_status = mock()
    capture3_status.stubs(:success?).returns(false)

    Open3.expects(:capture3).returns(["", "", capture3_status]).once

    Dir.mktmpdir do |temp_dir|
      assert_raises Geb::Git::FailedValidationError do
        Geb::Git.validate_git_repo(File.join(temp_dir, "test_dir5"))
      end # assert_raises
    end # Dir.mktmpdir

  end # test "that git validation raises an error if any other error other then not a git repo is raised"

  test "that git validation passes if given a valid path without any git repos"  do

      Dir.mktmpdir do |temp_dir|
        Geb::Git.validate_git_repo(temp_dir)
      end # Dir.mktmpdir

  end # test "that git validation passes if given a valid path without any git repos"

  test "that git create repo raises an error if git command fails" do

    git_error_message = "Some very important git error"

    capture3_status = mock()
    capture3_status.stubs(:success?).returns(false)

    Open3.expects(:capture3).returns(["", git_error_message, capture3_status]).once

    error = assert_raises Geb::Git::GitError do
      Geb::Git.create_git_repo("/some/fake/folder/path")
    end # assert_raises

    assert_includes error.message, git_error_message

  end # test "that git create repo raises an error if git command fails"

  test "that git create repo passes if git command succeeds" do

      Dir.mktmpdir do |temp_dir|

        Geb::Git.create_git_repo(temp_dir)

        assert Dir.exist?(File.join(temp_dir, ".git"))
        assert File.exist?(File.join(temp_dir, ".gitignore"))

      end # Dir.mktmpdir

  end # test "that git create repo passes if git command succeeds"

  test "that git create repo raises an error if it fails to create .gitignore" do

    file_error_message = "Some very important file error"

    capture3_status = mock()
    capture3_status.stubs(:success?).returns(true)

    Open3.expects(:capture3).returns(["", "", capture3_status]).once

    File.expects(:open).raises(Errno::EACCES, file_error_message)

    error = assert_raises Geb::Git::GitError do
      Geb::Git.create_git_repo("/some/fake/folder/path")
    end # assert_raises

    assert_includes error.message, "Could not create .gitignore file"
    assert_includes error.message, file_error_message

  end # test "that git create repo raises an error if it fails to create .gitignore"

end # class SiteTest < Minitest::Test
