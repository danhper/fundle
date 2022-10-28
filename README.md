# fundle [![Build Status](https://travis-ci.org/danhper/fundle.svg?branch=master)](https://travis-ci.org/danhper/fundle)

A minimalist package manager for [fish](http://fishshell.com/) inspired by [Vundle](https://github.com/VundleVim/Vundle.vim).


All plugins are installed/updated using git, so the only requirement is to have
git installed and on the path (and well, fish, obviously).

This package manager is compatible with [oh-my-fish plugins](https://github.com/oh-my-fish).
If you need the core functions of [oh-my-fish](https://github.com/oh-my-fish),
you can use the [danhper/oh-my-fish-core](https://github.com/danhper/oh-my-fish-core) plugin.

## Installation

You can use the installer:

```sh
curl -sfL https://git.io/fundle-install | fish
```

Or if you don't like to pipe to a shell, just drop [fundle.fish](functions/fundle.fish)
in your `~/.config/fish/functions` directory and you are done.

```sh
mkdir -p ~/.config/fish/functions
wget https://git.io/fundle -O ~/.config/fish/functions/fundle.fish
```

### Automatic install

If you want to automatically install fundle when it is not present, you can add
the following at the top of your `~/.config/fish/config.fish`.

```fish
if not functions -q fundle; eval (curl -sfL https://git.io/fundle-install); end
```

### Global installation

If you want to install fundle globally, simply log in as a sudoer:

```fish
curl -sfL https://raw.githubusercontent.com/danhper/fundle/master/install-fundle-global.fish | fish
```

### Prevent user installations

If you want to install fundle globally and prevent non-sudoers from installing local plugins:

```fish
wget https://raw.githubusercontent.com/danhper/fundle/master/install-fundle-global.fish
fish -c "source ./install-fundle-global.fish --restrict-user-plugins"
rm -rf ./install-fundle-plugins.fish # don't forget to delete the downloaded script after the new shell loads
```

### ArchLinux

fundle is available on the AUR, so you can install it system wide with

```
yaourt -S fundle-git
```

### Updating

From fundle 0.2.0 and onwards, you can use `fundle self-update` to update fundle.

## Usage

### Sample `config.fish`


Add this to your `~/.config/fish/config.fish` or any file that you use to load fundle's plugins (in `/etc/fish` for example):

```
fundle plugin 'edc/bass'
fundle plugin 'oh-my-fish/plugin-php'
fundle plugin 'danhper/fish-fastdir'
fundle plugin 'danhper/fish-theme-afowler'

fundle init
```

This will source the four plugins listed and load all the functions and completions found.

*Note that the `fundle init` is required on each file loading a plugin, so if you load plugins in multiple .fish files, you have to add `fundle init` to each one of them.*

After editing `config.fish`:

1. Reload your shell (you can run `exec fish` for example)
2. Run `fundle install`
3. That's it! The plugins have been installed in `~/.config/fish/fundle`

### In depth

To add a plugin, you simply need to open `~/.config/fish/config.fish` and add:

```
fundle plugin 'repo_owner/repo_name'
```

For example:

```
fundle plugin 'danhper/fish-fastdir'
```

will install the repository at https://github.com/danhper/fish-fastdir.

To pick a specific version of the plugins, you can append @ followed by a tag from the repo:
```
fundle plugin 'joseluisq/gitnow@2.7.0'
```
will install Gitnow release 2.7.0 at https://github.com/joseluisq/gitnow/releases/tag/2.7.0.

If you need to change the repository, you can pass it with `--url` and
it will be passed directly to `git clone`:

```
fundle plugin 'danhper/fish-fastdir' --url 'git@github.com:danhper/fish-fastdir.git'
```
Keep in mind that this option overrides any tag set with '@'.

It also works with other repository hosts:

```
fundle plugin 'username/reponame' --url 'git@gitlab.com:username/reponame.git'
```

And it works with https remote as well (in case you have "the authenticity of host github can't be established"):

```
fundle plugin 'username/reponame' --url 'https://gitlab.com/username/reponame.git'
```

You can also use a branch, tag or any [commit-ish](https://www.kernel.org/pub/software/scm/git/docs/gitrevisions.html#_specifying_revisions) by appending `#commit-ish` to the URL. For example:

```
fundle plugin 'danhper/fish-fastdir' --url 'git@github.com:danhper/fish-fastdir.git#my-branch'
```

will use `my-branch`. If no commit-ish is passed, it will default to `master`.

If the fish functions or completions are in a subdirectory of the repository, you can use
`--path` to choose the path to load.

```
fundle plugin 'tmuxnator/tmuxinator' --path 'completion'
```

After having made all the calls to `fundle plugin`, you need to add

```
fundle init
```

in your configuration file for the plugins to be loaded.

IMPORTANT: When you add new plugins, you must restart your shell *before* running `fundle install`.
The simplest way to do this is probably to run `exec fish` in the running shell.

You can then run

```
fundle install
```

for fundle to download them.

You can also use

```
fundle update
```

to update the plugins.

### Global plugins
If you used the [global installation script](./install-fundle-global.fish) above, then your system is configured for all users to use fundle plugins!

This means you can `fundle global-plugin 'repo_owner/repo_name'` to load plugins to `/etc/fish`, where they are accessible to everyone.

`fundle global-plugin` simply invokes `fundle plugin` as `root`, so it has the same paramter functionality: `--url` and `--path`.

Unlike the `fundle plugin` command, there's no need to run this at startup in a `.fish` file, or to run `fundle init` afterwards. Users need only `source /etc/fish/config.fish` to load newly-installed plugins.

## Commands

* `fundle init`: Initialize fundle, loading all the available plugins
* `fundle install`: Install all plugins
* `fundle update`: Update all local plugins (deprecates: `fundle install -u`)
* `fundle global-update`: Update all global plugins
* `fundle global-plugin PLUGIN [--url PLUGIN_URL] [--path PATH]`: Globally dd a plugin to fundle.
  * `--url` set the URL to clone the plugin.
  * `--path` set the plugin path (relative to the repository root)
* `fundle plugin PLUGIN [--url PLUGIN_URL] [--path PATH]`: Locally add a plugin to fundle.
  * `--url` set the URL to clone the plugin.
  * `--path` set the plugin path (relative to the repository root)
* `fundle list [-s]`: List the currently installed plugins, globally or locally, including dependencies
* `fundle clean`: Cleans unused plugins
* `fundle self-update`: Updates fundle to the latest version
* `fundle version`: Displays the current version of fundle
* `fundle help`: Displays available commands

Completions are available in the [completions/fundle.fish](./completions/fundle.fish).
Note that you will need to install [fish-completion-helpers](https://github.com/danhper/fish-completion-helpers)
to use them.

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

NOTE: if no `init.fish` file is found, the root folder of the plugin is treated
as a functions directory. This is to make the plugins compatible with
[oh-my-fish plugins](https://github.com/oh-my-fish) themes.

## Managing dependencies

fundle can manage dependencies for you very easily.
You just have to add

```
fundle plugin 'my/dependency'
```

in your plugin `init.fish` and fundle will automatically fetch and install the
missing dependencies when installing the plugin.

I created a minimal example in [fish-nvm](https://github.com/danhper/fish-nvm),
which depends on [edc/bass](https://github.com/edc/bass).

## Profiling

Obviously, adding plugins makes the shell startup slower. It should usually be short enough,
but if you feel your shell is becoming to slow, fundle has a very basic profiling
mode to help you.

All you need to do is to change

```
fundle init
```

to

```
fundle init --profile
```

in your `config.fish` and fundle will print the time it took to load each plugin.

NOTE:
* You will need the `gdate` command on OSX. You can install it with `brew install coreutils`.
* This functionality simply uses the `date` command, so it prints the real time,
not the CPU time, but it should usually be enough to detect if something is wrong.
* When a plugin include dependencies, the load time for each dependency is added to the
parent plugin load time.

## Compatible plugins

Most [oh-my-fish plugins](https://github.com/oh-my-fish) should work out of the box
or with [danhper/oh-my-fish-core](https://github.com/danhper/oh-my-fish-core) installed.

Please feel free to edit the [wiki](https://github.com/danhper/fundle/wiki) and add
your plugins, or plugins you know work with fundle.

## Contributing

Contributions are very appreciated. Please open an issue or create a PR if you
want to contribute.

If you created a package compatible with fundle, feel free to [add it to the Wiki](https://github.com/danhper/fundle/wiki/Home/_edit).

## Motivations

I know that [oh-my-fish](https://github.com/oh-my-fish/oh-my-fish) has a utility to
install packages, but I wanted the simplest tool possible, not a whole framework.

## Changelog

* 2016-04-06 (v0.5.1): Fix `fundle help` to show `clean` command.
* 2016-04-06 (v0.5.0): Add `fundle clean`. Deprecate `fundle install -u` and add `fundle update` thanks to @enricobacis.
* 2015-12-22 (v0.4.0): Add `--path` option, thanks to @Perlence.
* 2015-12-16 (v0.3.2): Fix profiling in OSX.
* 2015-12-14 (v0.3.1): Fix incompatibility with oh-my-fish. Rename `plugins` to `list`.
* 2015-12-14 (v0.3.0): Fix dependency load order. Add profiling mode.
* 2015-12-14 (v0.2.2): Emit plugin initialization event
* 2015-12-07 (v0.2.1): Use `curl` instead of `wget` for `self-update`
* 2015-12-07 (v0.2.0): Add `self-update` command
* 2015-12-07 (v0.1.0): Fix bug with dependency loading in `fundle init`
* 2015-11-24: Allow the use of `#commit-ish` when using plugin repo. Checkout repository `commit-ish` instead of using master branch.
