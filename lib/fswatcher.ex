defmodule Fswatcher do
  use GenServer

  alias Fswatcher.FileEvent, as: FileEvent
  alias Fswatcher.Helpers, as: Helpers

  # API
  def watch(dir) do
    GenServer.start_link __MODULE__, dir, name: __MODULE__
  end

  def stream do
    GenEvent.stream(event_manager)
  end

  def on_file_event(pattern, target_flags, callback) do
    spawn_link fn ->
      for file_event <- GenEvent.stream(event_manager) do
        filter(file_event, pattern, target_flags, callback)
      end
    end
  end

  def filter(file_event, pattern, target_flags, callback) do
    if Helpers.match_pattern?(file_event, pattern) && Helpers.match_flags?(file_event, target_flags) do
      callback.(file_event)
    end
  end

  def event_manager do
    GenServer.call(__MODULE__, :event_manager)
  end

  defmacro watch(dir, do: block) do
    quote do
      watch(unquote(dir))

      unquote(block)
    end
  end

  defmacro on(pattern, target_flags, do: block) do
    quote do
      on_file_event unquote(pattern), unquote(target_flags), fn e ->
        var!(file_event) = e

        unquote(block)
      end
    end
  end

  # GenServer Callbacks

  def init(dir) do
    {:ok, event_manager} = GenEvent.start_link

    # File.cd!(dir)
    Application.put_env(:fs, :path, dir)
    :fs_app.start([], [])
    :fs.subscribe()

    {:ok, event_manager}
  end

  def handle_call(:event_manager, _, event_manager) do
    {:reply, event_manager, event_manager}
  end

  def handle_info({_pid, {:fs, :file_event}, {path, flags}}, event_manager) do
    GenEvent.notify(event_manager, %FileEvent{path: to_string(path), flags: flags})

    {:noreply, event_manager}
  end
end
