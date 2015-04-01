Fswatcher
=========

A simple watcher to monitor file system events. This is based on the excellent
https://github.com/synrc/fs FS Listener project.

## Examples

```elixir
# mix.exs

  defp deps do
    [
      ...
      {:fswatcher, git: "https://github.com/gniquil/fswatcher.git"},
      ...
    ]
  end

```

Then in your console

```
mix deps.get
iex -S mix
```

```elixir
import Fswatcher

watch "." do
  on "**/*.md", :modified do
    IO.inspect file_event
  end

  on "**/*.{exs,ex}", [:modified, :created, :renamed] do
    IO.inspect file_event
  end
end
```

`watch` specifies the root directory to watch. `on` injects the `file_event` variable
and executes the block IF both the given path pattern, and file event flags match.

The path pattern is the same glob used in `Path.wildcard`. The file event flags
can be an atom or a list of atoms. List implies `OR`.

Now update the files that match those glob pattern and observe what iex does.

## Three Ways of Access

### Stream

```elixir
Fswatcher.watch(".")

spawn_link fn ->
  for file_event <- Fswatcher.stream do
    Fswatcher.filter file_event, "**/*.md", :inodemetamod, fn (e) ->
      IO.inspect e # e is the same is file_event
    end

    Fswatcher.filter event, "**/*.{exs,ex}", [:modified, :created, :renamed], fn (event) ->
      IO.inspect e
    end
  end
end
```

Note the `spawn_link` above could be important as otherwise it elixir blocks.

### Streaming without spawn_link

```elixir
Fswatcher.watch(".")

Fswatcher.on_file_event "**/*.md", :inodemetamod, fn (file_event) ->
  IO.inspect file_event
end

Fswatcher.on_file_event "**/*.{exs,ex}", [:modified, :created, :renamed], fn (file_event) ->
  IO.inspect file_event
end
```

This form automatically handles the `spawn_link`

### Macro

```elixir
import Fswatcher

watch "." do
  on "**/*.md", :modified do
    IO.inspect file_event
  end

  on "**/*.{exs,ex}", [:modified, :created, :renamed] do
    IO.inspect file_event
  end
end
```

## Caveats

Becareful with the following:

- Not sure if this works when watching multiple directory. The FS Listener project
  seems to only support 1 root dir at a time
- `:removed` currently is not working as wildcard globbing actually walks the dir
  tree to test if the path pattern is matched. In the removed case, the file is
  no longer there. The tree walk is also slow. [TODO] consider reimplement globbing



