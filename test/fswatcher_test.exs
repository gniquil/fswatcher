defmodule FswatcherTest do
  use ExUnit.Case

  import Fswatcher

  test "functional form with stream and filter" do
    test_pid = self()

    watch(".")

    spawn_link fn ->
      for x <- stream do
        filter x, "**/*.md", :inodemetamod, fn (event) ->
          send test_pid, {:md, event.path}
        end

        filter x, "**/readme", :inodemetamod, fn (event) ->
          send test_pid, {:readme, event.path}
        end
      end
    end

    path = Path.absname("test/fixtures/subfolder/readme.md")

    File.touch! path

    assert_receive {:md, ^path}, 1_000
    refute_receive {:readme, ^path}, 1_000

    path = Path.absname("test/fixtures/subfolder/readme")

    File.touch! path

    assert_receive {:readme, ^path}, 1_000
    refute_receive {:md, ^path}, 1_000
  end

  test "functional form with on_file_event" do
    test_pid = self()

    watch(".")

    on_file_event "**/*.md", :inodemetamod, fn (event) ->
      send test_pid, {:md, event.path}
    end

    on_file_event "**/readme", :inodemetamod, fn (event) ->
      send test_pid, {:readme, event.path}
    end

    path = Path.absname("test/fixtures/subfolder/readme.md")

    File.touch! path

    assert_receive {:md, ^path}, 1_000
    refute_receive {:readme, ^path}, 1_000

    path = Path.absname("test/fixtures/subfolder/readme")

    File.touch! path

    assert_receive {:readme, ^path}, 1_000
    refute_receive {:md, ^path}, 1_000
  end

  test "macro form" do
    test_pid = self()

    watch "test/fixtures/subfolder" do
      on "**/*.md", :inodemetamod do
        send test_pid, {:md, file_event.path}
      end

      on "**/readme", :inodemetamod do
        send test_pid, {:readme, file_event.path}
      end
    end

    path = Path.absname("test/fixtures/subfolder/readme.md")

    File.touch! path

    assert_receive {:md, ^path}, 1_000
    refute_receive {:readme, ^path}, 1_000

    path = Path.absname("test/fixtures/subfolder/readme")

    File.touch! path

    assert_receive {:readme, ^path}, 1_000
    refute_receive {:md, ^path}, 1_000

    path = Path.absname("test/fixtures/readme")

    File.touch! path

    refute_receive {:readme, ^path}, 1_000
  end
end
