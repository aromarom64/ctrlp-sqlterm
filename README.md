# ctrlp-sqlterm

you must install ctrlp.vim  before start using this plugin. 
```bash
let g:ctrlp_extensions = ['sqlterm']
let g:sqlterm_tnsnames_ora = '/path_to/tnsnames.ora'
let g:sqlterm_default_username = 'defaultuser'
nmap <leader>ts :CtrlPsqlterm<cr>
```
