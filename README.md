# `zide`: A Zellij IDE-like Environment

![zide screenshot](https://github.com/user-attachments/assets/6b26f0af-1a3e-486a-a395-e6f4cc6c355b)

Zide is a group of configuration files and scripts that creates an IDE-like experience in `zellij` (think VS Code). It mainly consists of a file picker (using `yazi`) in one pane, and your editor of choice in the main pane. The project is heavily inspired by the [`yazelix`](https://github.com/luccahuguet/yazelix) project, but simplifies it down to work in most shells (instead of requiring `nushell`) and more editors (vs just Helix).

## Why?

I recently started using [Helix](https://helix-editor.com) as my editor of choice. I loved most everything about it, except that there was no tree-style file browser to open files. While the fuzzy finder is fantastic for quickly getting to files I know about, I often work in large monorepos where I don't know the directory or file naming structure in advance, and a visual filepicker is extremely useful. On top of that, [`yazi`](https://yazi-rs.github.io) is an incredibly powerful and useful tool for file management, and integrating it seemlessly with Helix was high on my list of priorities.

## Installation

Download the project files and place them somewhere convenient on your system (such as `$HOME/.config/zide`). Then add the `bin/` directory to your `PATH`.
```
export PATH="$PATH:$HOME/.config/zide/bin"
```

### Dependencies

This project cobbles together [`zellij`](https://zellij.dev) and [`yazi`](https://yazi-rs.github.io), and so you'll need both installed for any of this to work. Additionally, the pre-configured layouts have a [`lazygit`](https://github.com/jesseduffield/lazygit) floating pane for easy git integration, so you'll need `lazygit` installed if you plan on using that. Otherwise, the rest is written in plain `bash` so it should work on a wide variety of systems without further dependencies.

## Usage

Run the `zide` command to start using Zellij as an IDE. The command will do one of two things:
1. If you're not currently in a `zellij` session, it'll start one
2. If you're in an existing `zellij` session, it'll create a new tab

By default starting `zide` will use the compact layout, consisting of a vertical split of panes with yazi on the left occupying a small slice of it, and your `$EDITOR` on the right occupying the rest, with your current working directory set as the directory in both your `$EDITOR` and `yazi`. However, you can customize a few options using the `zide` startup command:

```sh
# Start zide layout in a different directory and use the non-compact layout
$ zide ~/development/zide ide
```

Passing in a working directory will ensure that `yazi`, your editor, and any future panes are all working in the same directory. By default, it'll use the current working directory from which you're calling the command.

The non-compact layout is similar to the compact one, but with a 3rd, 100-column wide pane to the right. The two layouts also differ slightly in how the swap layouts work. Any additional layouts you add or configure in the zide `layouts/` directory will be available to use from the `zide` command.

## Configuration

You can configure the existing layouts (or create new ones) by editing the `.kdl` files in the `layouts/` directory. Here you can tweak things such as how wide you want `yazi` to be vs the editor, and any other layout tweaks you want to make. The one absolute requirement is that **your editor pane must be next to the `yazi` pane**. There's no way to uniquely identify the different panes in `zellij`, therefore these scripts depend on calling `zellij action focus-next-pane` to focus your editor from `yazi`. If you want to lay your panes out in a different way, you can update focus command in the `yazide` script to make sure you focus the right pane.

Both the `zide` and `yazide` commands are somewhat configurable:

### `zide`
The main `zide` command controls opening new `zide` tabs, either in an existing session if inside one or starting a new one.

1. `ZIDE_DIR`: Controls the location of the zide project files (ie. where you installed zide to)
2. `ZIDE_DEFAULT_LAYOUT`: Default layout. Available layouts can be found in the zide layouts/ directory

### `yazide`
The `yazide` command is a wrapper around `yazi` which does most of the magic of communicating with your editor to open files and directories through `zellij` pane commands. Unless you're making custom layouts, you'll probably never need to run this yourself, but it is somewhat configurable.

1. `EDITOR_COMMAND_PREFIX`: Character to open command mode in editor. In editors such as Helix and NeoVim, this is the `:`.
2. `EDITOR_OPEN_COMMAND`: Editor open command, e.g. "open" or "vsplit" in Helix, "edit" in NeoVim, etc.
3. `EDITOR_CD_COMMAND`: Editor command to change the editor's current working directory. In Helix and NeoVim, this is `cd`.

The defaults will all work out of the box when using Helix as your editor, as that's my editor of choice, and Helix's lack of an IDE-like layout is the whole reason for this project. If you use NeoVim, be sure to update these to match NeoVim's expected commands.

Additionally, there's a custom `yazi/yazi.toml` file included which will allow you to customize `yazi` when using `zide`. I mainly use this to force `yazi` into a single column mode, but any other yazi config options you need that only apply when using zide can go here (including `keymap` and `theme` configs).
