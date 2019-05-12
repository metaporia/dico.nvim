" dico client: assumes that dico is installed and that the host has a dicod
" instance running locally
"
" TODO
" □  lookup remotely (to ua.gnu.org or dict.org) when local dicod server is
"    not available
" □  add vertical split options wherever possible (LsSyn, Defp, Defv)


" FUNCTIONS

" defines word in split of the specified orientation; uses local dicod server
" if possible, else queries gnu.org.ua
function! Define(orientation, word, ...)
    if a:0 > 0 " a:1 contains search strategy, see ```man dico``` or ```dico --help```
        let query = "dico -s " . a:1 . " -d* " . "'" . a:word . "'"
    else
        let query = "dico " . '-- "' . a:word . '"' . ' | fmt' 
    endif
    echo query
    let definitions = system(query) 
    if definitions == "dict (client_read_status): Error reading from socket\nclient_read_status: Success\n"
        "echo "error"
        let remote_query = "dict --host gnu.org.ua " . '"' . a:word . '"' . ' | fmt'
        let definitions = system(remote_query)
    endif
    silent call DeadBuf(a:orientation) | call bufname("dico") | silent put =definitions | normal ggdd 
endfunction

function! LsSyn(word)
    let sedFilter = " | sed 's/,/\\n/g' | sed 's/\\s//g' "
    let query = "dico -dmoby\-thesaurus " . "'" . a:word . "'" . sedFilter
    let synList = system(query)
    silent call DeadBuf("h") | call bufname("LsSyn") | silent put =synList | normal gg4dj
endfunction

" opens unwritable buffer in horizontal or vertical split according to the
" orientation string:
"   * "v" sets vertical
"   * otherwise sets horizontal
function! DeadBuf(orientation)
    let cmd = "new"
    if a:orientation == "v"
        let cmd = "vnew"
    endif
    execute cmd . " | setlocal buftype=nofile | setlocal noswapfile"
endfunction

" returns contents of visual selection
func! GetSelectedText()
  " uses selection register
  " source: https://stackoverflow.com/questions/12805922/vim-vmap-send-selected-text-as-parameter-to-function
  normal gv"*y 
  let result = getreg("*")
  normal gv
  return result
endfunc


" COMMANDS

" define word in horizontal split
com! -nargs=1 Def :call Define("h", "<args>")
" define word in vertical split
com! -nargs=1 Defv :call Define("v", "<args>")

" list all words in GCIDE prefixed by the given argument
com! -nargs=* Defp :call Define("h", "<args>", "prefix")
" list all words in GCIDE suffixed by the given argument
com! -nargs=* Defs :call Define("h", "<args>", "suffix")

" TODO add option to list synonyms in vertical split
com! -nargs=1 LsSyn :call LsSyn("<args>")


" KEYMAPS

" set to enable keymaps
if !exists('g:dico_vim_map_keys')
    let g:dico_vim_map_keys = 1
endif

" when keymaps are enabled and no prefix is set, use <leader>
if !exists('g:dico_vim_prefix')
    let g:dico_vim_prefix = '<leader>'
endif

if g:dico_vim_map_keys
    execute "nnoremap <silent>" . g:dico_vim_prefix."d :call Define('h', expand('<cword>'))<CR>"
    execute "vnoremap <silent>".  g:dico_vim_prefix."d :call Define('h', GetSelectedText())<CR>"

    execute "nnoremap <silent>" . g:dico_vim_prefix."dv  :call Define('v', expand('<cword>'))<CR>"
    execute "vnoremap <silent>" . g:dico_vim_prefix."dv :call Define('v', GetSelectedText())<CR>"

    execute "nnoremap <silent>" . g:dico_vim_prefix."ls :call LsSyn(expand('<cword>'))<CR>"
    execute "vnoremap <silent>" . g:dico_vim_prefix."ls :call LsSyn(GetSelectedText())<CR>"

endif
