# fundle [![Build Status](https://travis-ci.org/tuvistavie/fundle.svg?branch=master)](https://travis-ci.org/tuvistavie/fundle)

A minimalist package manager for [fish](http://fishshell.com/) inspired by [Vundle](https://github.com/VundleVim/Vundle.vim).


All plugins are installed/updated using git, so the only requirement is to have
git installed and on the path (and well, fish, obviously).

This package manager is compatible with [oh-my-fish plugins](https://github.com/oh-my-fish).
If you need the core functions of [oh-my-fish](https://github.com/oh-my-fish),
you can use the [tuvistavie/oh-my-fish-core](https://github.com/tuvistavie/oh-my-fish-core) plugin.

## Installation

Just drop [fundle.fish](fundle.fish) in your `~/.config/fish/functions` directory and you are done.

```
wget https://raw.githubusercontent.com/tuvistavie/fundle/master/fundle.fish -O ~/.config/fish/functions/fundle.fish
```

### ArchLinux

fundle is available on the AUR, so you can install it system wide with

```
yaourt -S fundle-git
```

## Usage

### Sample `config.fish`

```
fundle plugin 'edc/bass'
fundle plugin 'oh-my-fish/plugin-php'
fundle plugin 'tuvistavie/fish-fastdir'
fundle plugin 'tuvistavie/fish-theme-afowler'

fundle init
```

This will source the four plugins listed and load all the functions and completions found.
All you need to do is to run `fundle install` once after reloading your shell and you are set.

### In depth

To add a plugin, you simply need to add

```
fundle plugin 'repo_owner/repo_name'
```

somewhere in your configuration.

For example:

```
fundle plugin 'tuvistavie/fish-fastdir'
```

will install the repository at https://github.com/tuvistavie/fish-fastdir.

If you need to change the repository, you can pass it as a second argument and
it will be passed directly to `git clone`:

```
fundle plugin 'tuvistavie/fish-fastdir' 'git@github.com:tuvistavie/fish-fastdir.git'
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

## Commands

* `fundle init`: Initialize fundle, loading all the available plugins
* `fundle install [-u]`: Install (or update) all plugins
* `fundle plugin PLUGIN [PLUGIN_URL]`: Add a plugin to fundle
* `fundle plugins [-s]`: List the currently installed plugins, including dependencies (-s gives a shorter version)
* `fundle help`: Displays available commands

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

NOTE: if no `init.fish` file is found, all the files with a `.fish` extensions in the
top directory of the plugin will be loaded. This is to make the plugins compatible with
[oh-my-fish plugins](https://github.com/oh-my-fish).

## Managing dependencies

fundle can manage dependencies for you very easily.
You just have to add

```
fundle plugin 'my/dependency'
```

in your plugin `init.fish` and fundle will automatically fetch and install the
missing dependencies when installing the plugin.

I created a minimal example in [fish-nvm](https://github.com/tuvistavie/fish-nvm),
which depends on [edc/bass](https://github.com/edc/bass).

## Compatible plugins

Most [oh-my-fish plugins](https://github.com/oh-my-fish) should work out of the box
or with [tuvistavie/oh-my-fish-core](https://github.com/tuvistavie/oh-my-fish-core) installed.

Please feel free to edit the [wiki](https://github.com/tuvistavie/fundle/wiki) and add
your plugins, or plugins you know work with fundle.

## Contributing

Contributions are very appreciated. Please open an issue or create a PR if you
want to contribute.

If you created a package compatible with fundle, feel free to [add it to the Wiki](https://github.com/tuvistavie/fundle/wiki/Home/_edit).

## Motivations

I know that [oh-my-fish](https://github.com/oh-my-fish/oh-my-fish) has a utility to
install packages, but I wanted the simplest tool possible, not a whole framework.
