function! cprl#copylink(...) range
    if a:0 == 2
        call luaeval('require("cprl").copylink(_A[1], _A[2], _A[3], _A[4])', [a:1, a:2, a:firstline, a:lastline])
    else
        call luaeval('require("cprl").copylink(_A[1], _A[2], _A[3], _A[4])', ["github", "master", a:firstline, a:lastline])
    end
endfunction
