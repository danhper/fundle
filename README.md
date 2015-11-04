# fundle

A minimalist package manager for [fish](http://fishshell.com/) inspired by [Vundle](https://github.com/VundleVim/Vundle.vim).

All plugins are installed/updated using git, so the only requirement is to have
git installed and on the path (and well, fish, obviously).

## Installation

Just drop [fundle.fish](fundle.fish) in your `~/.config/fish/functions` directory and you are done.

```
wget https://raw.githubusercontent.com/tuvistavie/fundle/master/fundle.fish -O ~/.config/fish/functions/fundle.fish
```

## Usage

To add a plugin, you simply need to add

```
fundle plugin 'repo_owner/repo_name'
```

somewhere in your configuration.

For example:

```
fundle plugin 'tuvistavie/fastdir'
```

will install the repository at https://github.com/tuvistavie/fastdir.

If you need to change the repository, you can pass it as a second argument and
it will be passed directly to `git clone`:

```
fundle plugin 'tuvistavie/fastdir' 'git@github.com:tuvistavie/fastdir.git'
```

After having made all the calls to `fundle plugin`, you need to add

```
fundle init
```

in your configuration file for the plugins to be loaded.

When you add new plugins, you must restart your shell and run

```
fundle install
```

for fundle to download them.

You can also use

```
fundle install -u
```

to upgrade the plugins.

## Plugin structure

A plugin basically has the following structure.

```
.
├── completions
│   └── my_command.fish
├── functions
│   ├── __plugin_namespace_my_function.fish
│   └── my_public_function.fish
├── init.fish
└── README.md
```

* `init.fish` will be sourced directly, so it should not do anything that takes too long
  to avoid slowing down the shell startup. It is a good place to put aliases, for example.
* `functions` is the directory containing the plugin functions. This directory will
  be added to `fish_function_path`, and will therefore be auto loaded. I suggest you
  prefix your functions with `__plugin_name` if the user will not be using them explicitly.
* `completions` is the directory containing the plugin completions. This directory will
  be added to `fish_complete_path`.

## Contributing

Contributions are very appreciated. Please open an issue or create a PR if you
want to contribute.
If you created a package compatible with fundle, feel free to [add it to the Wiki](https://github.com/tuvistavie/fundle/wiki/Home/_edit).

## Motivations

I know that [oh-my-fish](https://github.com/oh-my-fish/oh-my-fish) has a utility to
install packages, but I wanted a simple tool, not a whole framework.
