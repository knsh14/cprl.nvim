if exists('g:cprl')
  finish
endif
let g:cprl = 1

command! -range -nargs=* CopyRemoteLink <line1>,<line2>call cprl#copylink(<f-args>)
