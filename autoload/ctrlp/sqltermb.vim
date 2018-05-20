if ( exists('g:loaded_ctrlp_sqltermb') && g:loaded_ctrlp_sqltermb )
  \ || v:version < 700 || &cp
  finish
endif
let g:loaded_ctrlp_sqltermb = 1

if !exists("s:terms")
  let s:terms = {}
endif

augroup sqlterm_terminal1
  autocmd!
  autocmd TerminalOpen * if &buftype ==# 'terminal' |
        \ setl nowrap |
        \ call s:sqlterm_term(+expand('<abuf>')) |
        \ endif
augroup end

function! ctrlp#sqltermb#init_term_buffer()
"  let bf = filter(tabpagebuflist(tabpagenr()), "bufexists(v:val) && getbufvar(v:val, '&buftype') ==# 'terminal'")
"  for i in range(len(bf))
"    let s:terms[tabpagenr()] = bf[i]
"  endfor
endfunction

function! s:sqlterm_term(bufnr)
    let tabpagenr = tabpagenr()
    let s:terms[tabpagenr] = a:bufnr
endfunction

function! s:op(type, ...)
      let [sel, rv, rt] = [&selection, @@, getregtype('"')]
      let &selection = "inclusive"

      if a:0 
        silent exe "normal! `<" . a:type . "`>y"
      elseif a:type == 'line'
        silent exe "normal! '[V']y"
      elseif a:type == 'block'
        silent exe "normal! `[\<C-V>`]y"
      else
        silent exe "normal! `[v`]y"
      endif

    call s:send_to_term(@@)

      let &selection = sel
        call setreg('"', rv, rt)
endfunction

function! s:send_to_term(keys)
    let bufnr = get(s:terms, tabpagenr(), 0)
    if bufnr > 0 && bufexists(bufnr)
        "let keys = substitute(a:keys, '\n$', '', '')
        let keys = substitute(a:keys, '\n', '\r', 'g')
        call term_sendkeys(bufnr, keys . "\<cr>")
        echo "Sent " . len(keys) . " chars -> " . bufname(bufnr)
    else
        echom "Error: No terminal"
    endif
endfunction

command! -range -bar SendToTerm call s:send_to_term(join(getline(<line1>, <line2>), "\n"))
nmap <script> <Plug>(send-to-term-line) :<c-u>SendToTerm<cr>
nmap <script> <Plug>(send-to-term) :<c-u>set opfunc=<SID>op<cr>g@
xmap <script> <Plug>(send-to-term) :<c-u>call <SID>op(visualmode(), 1)<cr>

function! ctrlp#sqltermb#send_to_term(keys)
  call s:send_to_term(a:keys)
endfunction

