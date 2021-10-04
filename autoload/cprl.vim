function! cprl#copylink(host, ref) range
    call luaeval('require("cprl").copylink(_A[1], _A[2], _A[3], _A[4])', [a:host, a:ref, a:firstline, a:lastline])
endfunction
