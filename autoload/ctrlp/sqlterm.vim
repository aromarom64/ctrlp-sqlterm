" =============================================================================
" File:          autoload/ctrlp/sqlterm.vim
" Description:   Example extension for ctrlp.vim
" =============================================================================

" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['sqlterm']
"
" Where 'sqlterm' is the name of the file 'sqlterm.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]

" Load guard
if ( exists('g:loaded_ctrlp_sqlterm') && g:loaded_ctrlp_sqlterm )
  \ || v:version < 700 || &cp
  finish
endif
let g:loaded_ctrlp_sqlterm = 1


" Add this extension's settings to g:ctrlp_ext_vars
"
" Required:
"
" + init: the name of the input function including the brackets and any
"         arguments
"
" + accept: the name of the action function (only the name)
"
" + lname & sname: the long and short names to use for the statusline
"
" + type: the matching type
"   - line : match full line
"   - path : match full line like a file or a directory path
"   - tabs : match until first tab character
"   - tabe : match until last tab character
"
" Optional:
"
" + enter: the name of the function to be called before starting ctrlp
"
" + exit: the name of the function to be called after closing ctrlp
"
" + opts: the name of the option handling function called when initialize
"
" + sort: disable sorting (enabled by default when omitted)
"
" + specinput: enable special inputs '..' and '@cd' (disabled by default)
"
call add(g:ctrlp_ext_vars, {
  \ 'init': 'ctrlp#sqlterm#init()',
  \ 'accept': 'ctrlp#sqlterm#accept',
  \ 'lname': 'long statusline name',
  \ 'sname': 'shortname',
  \ 'type': 'line',
  \ 'enter': 'ctrlp#sqlterm#enter()',
  \ 'exit': 'ctrlp#sqlterm#exit()',
  \ 'opts': 'ctrlp#sqlterm#opts()',
  \ 'sort': 0,
  \ 'specinput': 0,
  \ })


function! ctrlp#sqlterm#resetuser()
  unlet s:sqlterm_username
  unlet s:sqlterm_userpassword
endfunction

" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#sqlterm#init()
  "call s:init_term_buffer()

  if !exists("s:sqlterm_default_username")
    let g:sqlterm_default_username = 'aromashchenko'
  endif

  if !exists("s:sqlterm_username")
    call inputsave()
    let s:sqlterm_username = input('Username: ', g:sqlterm_default_username)
    call inputrestore()
  endif

  if !exists("s:sqlterm_userpassword")
    call inputsave()
    let s:sqlterm_userpassword = inputsecret('Password: ')
    call inputrestore()
  endif

  let fname = g:sqlterm_tnsnames_ora
  let mx0 = '^\s*\([a-zA-Z0-9_]\+\)'
  let mx = 'HOST\s*=\s*\([a-zA-Z0-9_.\-]\+\)'
  let services = []
  for line in readfile(fname)
    let ser = matchstr(line, mx0)
    if ser != ''
      let l = matchstr(line, mx)
      call add(services, ser . ':' . substitute(l, mx, '\1',""))
    endif
  endfor
  return services
endfunction

function! s:parseline(line)
  let info = split(a:line, ':')
  return get(info, 0)
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#sqlterm#accept(mode, str)
  call ctrlp#exit()
  if a:mode == 'e'
    call ctrlp#sqltermb#send_to_term('discon')
    let service = 'conn '.s:sqlterm_username.'@'.s:parseline(a:str)
    call ctrlp#sqltermb#send_to_term(service)
    sleep 200m
    call ctrlp#sqltermb#send_to_term(s:sqlterm_userpassword)
    call feedkeys("\<cr>")
  endif
endfunction

" (optional) Do something before enterting ctrlp
function! ctrlp#sqlterm#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#sqlterm#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#sqlterm#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#sqlterm#id()
  return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/sqlterm.vim
" command! CtrlPsqlterm call ctrlp#init(ctrlp#sqlterm#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2
