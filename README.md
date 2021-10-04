cprl.nvim
---

# about
lua implementation of [knsh14/vim-github-link]( https://github.com/knsh14/vim-github-link )  
and more general.  
copy link to clipboard

# install

## [packer.nvim]( https://github.com/wbthomason/packer.nvim )
```
use {
  'knsh14/cprl.nvim',
  requires = {'rcarriga/nvim-notify'},
  cmd = {'CopyRemoteLink',},
  config = function()
      require'cprl'.setup {
          mode = {
              main = function()
                  return "main" -- always copy link of master branch's
              end
          },
          host = {
              example = function(host, repo, ref, path, startline, endline)
                local line = ""
                if startline == endline then
                    line = string.format("#L%d", startline)
                else
                    line = string.format("#L%d-%d", startline, endline)
                end
                return string.format("https://example.com/%s%s%s%s%s", host, repo, ref, path, line)
              end
          },
      }
  end
}
```

# depend libraries
[rcarriga/nvim-notify]( https://github.com/rcarriga/nvim-notify ) to show cool popup display
