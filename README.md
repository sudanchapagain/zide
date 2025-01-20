# `zide`: A Zellij IDE-like Environment

![zide screenshot](https://github.com/user-attachments/assets/6b26f0af-1a3e-486a-a395-e6f4cc6c355b)

Zide is a combination of Zellij layouts and convenience `bash` scripts that creates an IDE-like experience in `zellij` (think VS Code). It mainly consists of a file picker (using `yazi`) in one pane, and your editor of choice in the main pane. The project is heavily inspired by the [`yazelix`](https://github.com/luccahuguet/yazelix) project, but simplifies it down to work in most shells (instead of requiring `nushell`) and more editors (vs just Helix) with less requied configuration.

## Features

1. Start a `zellij` layout with `yazi` on the left and your `$EDITOR` on the right
2. Browse for files in `yazi`, and open any selected files or directories in your `$EDITOR` pane
3. Open multiple files at once in your `$EDITOR` using `yazi`'s multiselect UI
4. When opening a directory in `yazi`, set that directory as the working directory in your `$EDITOR` automatically 

## Why?

I recently started using [Helix](https://helix-editor.com) as my editor of choice. I loved most everything about it, except that there was no tree-style file browser to open files. While the fuzzy finder is fantastic for quickly getting to files I know about, I often work in large monorepos where I don't know the directory or file naming structure in advance, and a visual filepicker is extremely useful. On top of that, [`yazi`](https://yazi-rs.github.io) is an incredibly powerful and useful tool for file management, and integrating it seemlessly with Helix was high on my list of priorities.

## Installation

Download the project files and place them somewhere convenient on your system (such as `$HOME/.config/zide`). Then add the `bin/` directory to your `PATH`.

```sh
export PATH="$PATH:$HOME/.config/zide/bin"
```

### Dependencies

This project cobbles together [`zellij`](https://zellij.dev) and [`yazi`](https://yazi-rs.github.io), and so you'll need both installed for any of this to work. Additionally, the pre-configured layouts have a [`lazygit`](https://github.com/jesseduffield/lazygit) floating pane for easy git integration, so you'll need `lazygit` installed if you plan on using that. Otherwise, the rest is written in plain `bash` so it should work on a wide variety of systems without further dependencies.

## Usage

Run the `zide` command to start using Zellij as an IDE. The command will do one of two things:
1. If you're not currently in a `zellij` session, it'll start one
2. If you're in an existing `zellij` session, it'll create a new tab

By default starting `zide` will use the compact layout, consisting of a vertical split of panes with yazi on the left occupying a small slice of it, and your `$EDITOR` on the right occupying the rest, with your current working directory set as the directory in both your `$EDITOR` and `yazi`.

However, you can customize a few options using the `zide` startup command:

```sh
# Start zide layout in a different directory and use the non-compact layout
$ zide ~/development/zide ide
```

Passing in a working directory will ensure that `yazi`, your editor, and any future panes are all working in the same directory. By default, it'll use the current working directory from which you're calling the command.

The non-compact layout is similar to the compact one, but with a 3rd, 100-column wide pane to the right. The two layouts also differ slightly in how the swap layouts work. Any additional layouts you add or configure in the zide `layouts/` directory will be available to use from the `zide`.

## Configuration

You can configure the existing layouts (or create new ones) by editing the `.kdl` files in the `layouts/` directory. Here you can tweak things such as how wide you want your picker pane to be vs the editor, and any other layout tweaks you want to make. The one absolute requirement is that **your editor pane must be next to the picker pane**. There's no way to uniquely identify the different panes in `zellij`, therefore these scripts depend on calling `zellij action focus-next-pane` to focus your editor from your picker. If you want to lay your panes out in a different way, you can update focus command in the `zide-pick` script to make sure you focus the right pane.

Both the `zide` and `zide-pick` commands are somewhat configurable via some environment variables which you can override in your shell or session:

### `zide`
The main `zide` command controls opening new `zide` tabs, either in an existing session if inside one or starting a new one.

1. `ZIDE_DEFAULT_LAYOUT`: Default layout. Available layouts can be found in the zide `layouts/` directory

### `zide-edit`
The `zide-edit` command is responsible for sending the correct Zellij commands to the `$EDITOR` pane to open them. This command is used by the file picker wrapper scripts, and you'll probably never need to run it yourself.

The defaults will all work out of the box when using Helix as your editor, as that's my editor of choice, and Helix's lack of an IDE-like layout is the whole reason for this project. They should also work with other modal editors such as Vim and NeoVim. If you need to make changes, you can update the following environment variables:

1. `ZIDE_EDITOR_CMD_MODE`: Character to open command mode in editor. In editors such as Helix and NeoVim, this is the `:`.
2. `ZIDE_EDITOR_CD_CMD`: Editor command to change the editor's current working directory. In Helix and NeoVim, this is `cd`.

### `zide-pick`
The `zide-pick` command is a wrapper around support picker command (current `yazi` and `nnn`) which does most of the magic of communicating with your editor to open files and directories through `zellij` pane commands. Unless you're making custom layouts, you'll probably never need to run this yourself.

If you're using `yazi`, there's a custom `yazi/yazi.toml` file included which will allow you to customize `yazi` when using `zide`. I mainly use this to force `yazi` into a single column mode, but any other yazi config options you need that only apply when using `zide `can go here (including `keymap` and `theme` configs). You can point to different config directories using the `ZIDE_YAZI_CONFIG` env var.

## How it works

This project consists of 3 parts:
1. Pre-configured `zellij` layouts
2. A wrapper script around file pickers called `zide-pick`
3. The `zide` command to launch you into zide mode

Conceptually, this is the basic flow of the system. First, we start up `zellij` with our layout (say two panes, left is `yazi` via our `zide-pick` wrapper script, and right is our `$EDITOR`). When you choose files in `yazi`, the `zide-pick` script grabs those paths and turns them into a space-separated list. So if you chose `file1.txt` and `subdir/file2.txt`, it would turn it into `file1.txt subdir/file2.txtl`.

Once we have our files, the `zide-pick` script then switches the focused pane using `zellij action focus-next-pane` (which hopefully is the pane with your `$EDITOR`). It then sends that pane the following commands:
1. `zellij action write 27`: This sends the `<ESC>` key, to force us into Normal mode in the `$EDITOR`.
2. `zellij action write-chars :open file1.txt subdir/file2.txt`: This essentially just sends the `:open file1.txt subdir/file2.txt` command to your `$EDITOR`, which will tell it to open those files.
3. `zellij action write-chars :cd subdir/`: **If you chose a directory** in `yazi` it'll also send the `cd` command to set the working directory to that directory in your `$EDITOR`.
4. `zellij action write 13`: Send the `<ENTER>` key to submit the commands.

Lastly, `yazi` closes itself once you choose files, so `zide-pick` will re-run itself so that `yazi` re-opens. If you chose a `directory`, it'll also re-open itself to that directory as its working dir.
