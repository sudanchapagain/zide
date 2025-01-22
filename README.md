# `zide`: A Zellij IDE-like Layout Environment

Zide is a combination of [Zellij](https://zellij.dev) layouts and convenience `bash` scripts that creates an IDE-like layout environment. It mainly consists of a file picker (such as `yazi`) in one pane, and your editor of choice in the main pane. You can browse the file tree in your picker pane, and then any files that are selected or opened do so in the editor's pane.

![zide screenshot](https://github.com/user-attachments/assets/6b26f0af-1a3e-486a-a395-e6f4cc6c355b)

The project was inspired by the [`yazelix`](https://github.com/luccahuguet/yazelix) project, but simplifies it down to work in most shells (instead of requiring `nushell`), more editors (vs just Helix), and essentailly any file picker, with less required configuration.

## Features

1. Start a `zellij` layout with a filepicker on the left and your editor on the right
1. Browse for files in any visual file picker of your choosing, and open any selected files or directories in your editor pane
1. Open multiple files at once in your editor if your picker supports a multiselect UI
1. When opening a directory, set that directory as the working directory in your editor automatically 

## Why?

I recently started using [Helix](https://helix-editor.com) as my editor of choice. I loved most everything about it, except that there was no tree-style file browser to open files. While the fuzzy finder is fantastic for quickly getting to files I know about, I often work in large monorepos where I don't know the directory or file naming structure in advance, and a visual filepicker is extremely useful. On top of that, [`yazi`](https://yazi-rs.github.io) is an incredibly powerful and useful tool for file management, and integrating it seemlessly with Helix was high on my list of priorities.

## Installation

Download the project files and place them somewhere convenient on your system (such as `$HOME/.config/zide`).

```sh
$ git clone git@github.com:josephschmitt/zide.git $HOME/.config/zide
```

Then add the `bin/` directory to your `PATH`.
```sh
# Add this to your shell profile
export PATH="$PATH:$HOME/.config/zide/bin"
```

### Dependencies

This project integrates [`zellij`](https://zellij.dev) with a file picker (assumes [`yazi`](https://yazi-rs.github.io) by default, but you can use any visual file picker you want), and so you'll need these installed for any of this to work. So far this project has been tested and works well with [`yazi`](https://yazi-rs.github.io/), [`nnn`](https://github.com/jarun/nnn), [`broot`](https://dystroy.org/broot/), and [`lf`](https://github.com/gokcehan/lf).

There are some additional layouts included that use a [`lazygit`](https://github.com/jesseduffield/lazygit) floating pane for easy git integration, so you'll need `lazygit` installed if you plan on using that. Otherwise, the rest is written in plain `bash` so it should work on a wide variety of systems without further dependencies.

## Usage

```sh
  $ zide <working_dir> <layout>
```

Run the `zide` command to start using Zellij with the zide-style IDE-like layout. It accepts two positional arguments, both of which are optional:

1. `<working_dir>` Defaults to `.`, aka your current working directory. Whatever directory you pass as this argument will be the directory that the file picker, your editor, and any future panes will start out in. If you want to open the IDE to a specific project, I suggest passing in that project's directory as this argument (as opposed to navigating after startup) so the working directory is correctly set.
1. `<layout>` Defaults to the `ZIDE_DEFAULT_LAYOUT` env var if set, otherwise to `compact`. You can see the list of available layouts in the [`layouts/`](./layouts) directory.

When executed, the `zide` command will do one of two things:

1. If you're not currently in a `zellij` session, it'll start one
1. If you're in an existing `zellij` session, it'll create a new tab

### Available Layouts

#### `compact` 
By default starting `zide` will use a layout consisting of 2 vertical split of panes with a filepicker on the left occupying a small slice of it, and your editor on the right occupying the rest, with your current working directory set as the directory in both your editor and the filepicker.
<p align="center"><img src="https://github.com/user-attachments/assets/62f09161-eb0a-4584-a174-8a2f3ad640c3" width=45% />&nbsp;<img src="https://github.com/user-attachments/assets/f8584284-99ca-407d-a808-54e82f6a948c" width=45% /></p>

#### `wide`
The `wide` layout is similar to the default one, but with a 3rd, 100-column wide pane to the right. The two layouts also differ slightly in how the swap layouts work.
<p align="center"><img src="https://github.com/user-attachments/assets/4c4c3881-6855-4b66-81c0-f5b18d8869a5" width=85% /></p>


#### `stacked`
The `stacked` layout uses Zellij's pane stacking feature to create 3 horizontal panes stacked on top of each other, but only 1 pane is visible at any one time. Switching panes will then make that pane visible, and collapse the rest.
<p align="center">
  <img src="https://github.com/user-attachments/assets/7fe1941a-12bd-4cf1-9bf8-86266784d55d" width=30% />
  <img src="https://github.com/user-attachments/assets/554cd950-55b4-49be-ba55-9fe99a181cc4" width=30% />
  <img src="https://github.com/user-attachments/assets/49dd43b1-5655-472e-b989-dd4a101bf81e" width=30% />
</p>
---

Each default layout also includes a `_lazygit` variant that includes a pane running `lazygit` for easier git access. Any additional layouts you add or configure in the zide `layouts/` directory will be available to use from the `zide` command, and will be git ignored.

## Configuration

```sh
$ zide --help
```

For basic help, you can use the `-h` or `--help` flags on any of the available commands to get details on how to configure them.

### Custom Layouts

If you want to make your own layouts, duplicate any of the built-in layouts in the `layouts/` directory and give them custom names. You'll be able to refer to those names when providing a custom layout to the `zide` command.

You can make any type of layout you like and use any and all of Zellij's awesome layout features. The one absolute requirement is that **your editor pane must be next to the picker pane**. There's no way to uniquely identify the different panes in `zellij` (outside of a plugin, anyway), therefore these scripts depend on calling `zellij action focus-next-pane` to focus your editor from your picker.

### Environment Variables

This project provides customization via the use of environment variables:

1. `ZIDE_DEFAULT_LAYOUT`: Default layout. Available layouts can be found in the zide `layouts/` directory. Feel free to add some layouts of your own here (they're gitignore'd).
1. `ZIDE_FILE_PICKER`: The file picker command to use, defaults to `yazi` if none is set.
1. `ZIDE_USE_YAZI_CONFIG`: When using `yazi` as a file picker, this will point it to the `yazi/yazi.toml` included with this project instead of using the default config. This config sets `yazi`'s ratio so that it operates in a single pane mode, which is more similar to how IDE's work. If you want to continue using your standard `yazi` config, set this env var to `false` (defaults to `true`). Alternatively, if you want to point to a different custom config directory, set this env var to that value.
1. `ZIDE_USE_LF_CONFIG`: Same idea as `ZIDE_USE_YAZI_CONFIG`, but for `lf` as the picker. This project includes a basic custom config to run `lf` in single pane mode, which you can turn off by setting this env var to `false`. Or, if you want to point it to your own config to use with zide, set the env var to that value.

You probably don't ever need to customize these env vars unless you use an editor that is _very_ different from the standard modal editors, but I've included the documentation here for completeness:

1. `ZIDE_EDITOR_CMD_MODE`: Character to open command mode in editor. In editors such as Helix and NeoVim, this is the `:`.
1. `ZIDE_EDITOR_CD_CMD`: Editor command to change the editor's current working directory. In Helix and NeoVim, this is `cd`.

### File Picker Configurations

#### [Yazi](https://yazi-rs.github.io/)

If you're using `yazi` and want to use a custom config other than your default and the one included in this project, you can point to a custom config directory in the `ZIDE_USE_YAZI_CONFIG` var.

```toml
# ~/.config/yazi-custom/yazi.toml

[manager]
ratio = [0, 1, 0]
show-hidden = true
# Some more config options here
```

```sh
export ZIDE_USE_YAZI_CONFIG="$HOME/.config/yazi-custom"
```

This will use that config when running in zide, but not when running `yazi` normally.

#### [nnn](https://github.com/jarun/nnn)

When using zide with `nnn` as your filepicker you'll have to make sure to set `NNN_OPENER` to point to `zide-edit`:

```sh
export ZIDE_FILE_PICKER="nnn -e"
export NNN_OPENER="zide-edit"
```

This makes sure that `nnn` will use zide to open your files when you select them.

#### [lf](https://github.com/gokcehan/lf)

When using zide with `lf`, you'll probably want to start it in single column mode. Similarly to Yazi above, zide comes with a simple config file it points to when using `lf` that turns this on by default called `ZIDE_USE_LF_CONFIG`. Similarly, set it to `false` to disable it, or give it a value to point it to a config outside of this project.

```env
# ~/.config/custom-configs/lf/lfrc
set preview false
set ratios 1
```

```sh
export ZIDE_USE_LF_CONFIG="~/.config/custom-configs"
```

## How it works

This project consists of 4 parts:

1. Pre-configured `zellij` layouts
1. The `zide` command to launch you into zide mode
1. A wrapper script around launching file pickers called `zide-pick`
1. A wrapper script that controls opening files in your editor called `zide-edit`

### `zide`

The main `zide` command controls opening new `zide` tabs, either in an existing session if inside one or starting a new one. It sets some environment variables, updates the working directory, and starts `zellij`.

### `zide-pick`

The `zide-pick` command is a small wrapper around the file pickers. It handles launching the correct picker based on either the `--picker` flag or the `ZIDE_FILE_PICKER` environment variable. This lets us avoid having to hard-code what picker to use in our layouts.

It also has one more very important job, which is changing the `EDITOR` env var to be `zide-edit` instead of your actual editor, so that the pickers open up our script instead of the real editor when picking files.

### `zide-edit`

The `zide-edit` command takes the place of your `EDITOR`. Instead of launching your `EDITOR`, it automates switching to your open editor pane, and sends it the correct `zellij` action commands so that it opens those files in the open editor pane.

---

Conceptually, this is the basic flow of the system.

We start up `zellij` with our layout (say two panes, left is `yazi` via our `zide-pick` wrapper script, and right is our editor, `hx`). When you choose files in `yazi`, `yazi` will attempt to open those files in `EDITOR`, which now points to `zide-edit`. The `zide-edit` script then switches the focused pane using `zellij action focus-next-pane` (which hopefully is the pane with your editor). It then writes the following commands to the pane to execute in the editor:

1. `zellij action write 27`: This sends the `<ESC>` key, to force us into Normal mode in your editor.
1. `zellij action write-chars :open file1.txt subdir/file2.txt`: This essentially just sends the `:open file1.txt subdir/file2.txt` command to your editor, which will tell it to open those files.
1. `zellij action write-chars :cd subdir/`: **If you chose a directory** in your filepicker it'll also send the `cd` command to set the working directory to that directory in your editor.
1. `zellij action write 13`: Send the `<ENTER>` key to submit the commands.
