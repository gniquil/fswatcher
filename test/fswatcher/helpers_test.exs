defmodule FswatcherHelpersTest do
  use ExUnit.Case

  import Fswatcher.Helpers
  alias Fswatcher.FileEvent, as: FileEvent

  test "wildcard path match" do
    assert match_pattern?(%FileEvent{path: Path.absname("test/fixtures/subfolder/readme.md")}, "test/**") == true
    assert match_pattern?(%FileEvent{path: Path.absname("test/fixtures/subfolder/readme.md")}, "test/**/*.md") == true
  end

  test "file_event flag match" do
    assert match_flags?(%FileEvent{flags: [:modified, :inodemetamod]}, [:modified]) == true
    assert match_flags?(%FileEvent{flags: [:modified, :inodemetamod]}, [:inodemetamod]) == true

    assert match_flags?(%FileEvent{flags: [:modified, :inodemetamod]}, :modified) == true
    assert match_flags?(%FileEvent{flags: [:modified, :inodemetamod]}, :inodemetamod) == true

    # out of order
    assert match_flags?(%FileEvent{flags: [:modified, :inodemetamod]}, [:inodemetamod, :modified]) == true

    assert match_flags?(%FileEvent{flags: [:modified, :inodemetamod]}, [:inodemetamod, :modified, :created]) == true

    assert match_flags?(%FileEvent{flags: [:modified, :inodemetamod]}, [:created]) == false
  end
end
