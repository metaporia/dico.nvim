# dico-vim

What is it? A plugin to provide bindings to query via the dico client either
(i) a local DICT server or (ii) GNU's [DICT server](dicoweb.gnu.org.ua).

For a vim compatible version see
[dico-vim](https://github.com/metaporia/dico-vim)


## Dependencies

* Ideally, a local DICT server on the standard port 2628. Either dicod or dictd
  will do. See below for pre-configured options.
* GNU's DICT client `dico` version >= 2.4.
* fold from GNU coreutils



> [!NOTE]
> There are two ready-made dicod servers pre-configured with good
> dictionaries:
> - [dicod-docker](https://github.com/metaporia/dot/tree/489cd70eae8eb4b48b4b02637578d216d76b759f/overlays/dico),
>   a dockerized DICT server; and
> - a nixpkgs [overlay](https://github.com/metaporia/dot/) and [nixos module](https://github.com/metaporia/dot/blob/489cd70eae8eb4b48b4b02637578d216d76b759f/home/modules/dicod.nix)

Note that at the moment the remote default DICT server (at [dicoweb.gnu.org.ua]())
is _not_ configurable.


## Installation

Add the following to your [neo]vim dotfile:

<details>
    <summary>With <a href="https://github.com/junegunn/vim-plug">junegunn/vim-plug</a>
    </summary>
    <code>Plug "metaporia/dico.nvim"</code>
</details>

<details>
    <summary>With <a href="https://github.com/folke/lazy.nvim">folke/lazy.nvim</a>
    </summary>
    <code>{ "metaporia/dico.nvim", config = true}</code>
</details>

## Configuration

See the [helpfile](doc/dico.nvim.txt) `:h dico.nvim` for more details.

### Default Configuration

```lua
{
    default_split = "h", -- window split orientation
    map_prefix = "<leader>", -- default prefix for keymappings
    enable_nofile = false, -- Expose user command `Nofile` used to open scratch buffer
    fallback_dict_server = "gnu.org.ua" -- remote fallback DICT server
}

```

## Keymaps

By default `<prefix> = <leader>` in the following key-bindings, and all bindings
work in visual mode on the contents of the current visual selection.

* `<prefix>d`: define headword under cursor in horizontal split
* `<prefix>da`: define headword in alternate split (if `opts.default_split` is
  `"h"`, then this would open a vertical split).


* `<prefix>ls` : list synonyms in default split

## Commands

* `Def <headword>`: define `<headword>` in default split
* `DefA <headword>`: define `<headword>` in alternate split
* `LsSyn <headword>` : list synonyms (from moby-thesaurus by default) in
  default split



