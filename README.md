# dico-vim

What is it? A plugin to provide bindings to query via the dico client (i) a local DICT
server or (ii) GNU's [DICT server](dicoweb.gnu.org.ua).


## Dependencies

* ideally (there is a remote default), a local DICT server on the standard port
  2628 (see [dicod-docker](https://gitlab.com/metaporia/dicod-docker) for
  dockerized version of GNU's DICT server dicod v2.4); and
* GNU's DICT client `dico` version >= 2.4.
* fold from GNU coreutils


Note that at the moment the remote default DICT server (at [dicoweb.gnu.org.ua]())
is _not_ configurable.


## Installation

Add the following to your [neo]vim dotfile:

```vim
Plug "https://gitlab.com/metaporia/dico-vim"
```

I have not tested `dico-vim` with other plugin managers. Its directory structure
does, however, conform to pathogen's specification; and I see no reason why it
shouldn't work with vanilla vim's package management facility.


## Configuration

Set `g:dico_vim_map_keys = 1` to override the default and enable the below
key-mappings.

Set `g:dico_vim_prefix = <custom-prefix>` to override the default prefix
`<leader>`; naturally, this setting has no effect if `g:dico_vim_map_keys = 0`.



## Keymaps

By default `<prefix> = <leader>` in the following key-bindings, and all bindings
work in visual mode on the contents of the current visual selection.

* `<prefix>d`: define headword under cursor in horizontal split
* `<prefix>dv`: define headword in vertical split


* `<prefix>ls` : list synonyms in horizontal split

## Commands

* `Def <headword>`: define `<headword>` in horizontal split
* `Defv <headword>`: define `<headword>` in vertical split
* `Defp <prefix>`: list words with the specified prefix
* `Defs <suffix>`: list words with the specified suffix
* `LsSyn <headword>` : list synonyms (from moby-thesaurus by default) in horizontal split



