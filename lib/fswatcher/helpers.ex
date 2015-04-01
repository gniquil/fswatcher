defmodule Fswatcher.Helpers do
  alias Fswatcher.FileEvent, as: FileEvent

  def match_pattern?(%FileEvent{path: path}, pattern) do
    path in (Path.wildcard(pattern) |> Enum.map &Path.absname(&1))
  end

  def match_flags?(%FileEvent{flags: flags}, target_flags) when is_list(target_flags) do
     !HashSet.disjoint?(Enum.into(target_flags, HashSet.new), Enum.into(flags, HashSet.new))
  end

  def match_flags?(file_event, target_flags) do
     match_flags? file_event, [target_flags]
  end
end
