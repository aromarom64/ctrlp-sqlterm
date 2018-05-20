command! CtrlPsqlterm call ctrlp#init(ctrlp#sqlterm#id())
command! CtrlPsqlreset call ctrlp#sqlterm#resetuser()
call ctrlp#sqltermb#init_term_buffer()
