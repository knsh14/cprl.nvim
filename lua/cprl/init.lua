function display(message, level)
    local n = require("notify")
    if n == nil then
        return
    end
    n.setup({
        stages = "slide",
    })
    n(message, level, {
        title = "cprl.nvim",
        timeout = 2000,
    })
end

local modes = {}
modes["branch"] = function()
  return shellexec("git rev-parse --abbrev-ref HEAD")
end
modes["head"] = function()
  return shellexec("git rev-parse HEAD")
end
modes["file"] = function()
  return shellexec(string.format("git rev-list -1 HEAD -- %s", vim.fn.expand('%')))
end

local hosts = {}
hosts["github"] = function(host, repo, ref, path, firstline, lastline)
    -- https://HOST/REPO/blob/BRANCH/PATH#LN-LM
    local line = ""
    if firstline == lastline then
        line = string.format("#L%d", firstline)
    else
        line = string.format("#L%d-L%d", firstline, lastline)
    end
    return string.format("https://%s/%s/blob/%s/%s%s", host, repo, ref, path, line)
end

hosts["srg"] = function(host, repo, ref, path, firstline, lastline)
    -- https://sourcegraph.com/HOST/REPO@REF/-/blob/PATH?LN-M
    local line = ""
    if firstline == lastline then
        line = string.format("?L%d", firstline)
    else
        line = string.format("?L%d-%d", firstline, lastline)
    end
    return string.format("https://sourcegraph.com/%s/%s@%s/-/blob/%s%s", host, repo, ref, path, line)
end

function copylink(host_mode, ref_mode, firstline, lastline)
    local currentdir = shellexec("pwd")
    vim.api.nvim_command('lcd %:p:h')

    local ref_func = modes[ref_mode]
    if ref_func == nil then
      display("unknown ref_mode " .. ref_mode, "error")
      return
    end
    local ref = ref_func()

    local root = shellexec("git rev-parse --show-toplevel")
    root = string.gsub(root, '[\r\n ]', '')
    local p = vim.fn.expand('%:p')
    local s, e = string.find(p, root, 1, true)
    if s == nil or e == nil then
      display(string.format("%s is not found in \n%s", root, p), "error")
      return
    end
    local path_from_root = string.sub(p, tonumber(e)+2, p:len())

    local remotes = {}
    remotes['^git@(.*):(.*)$'] = function(uri)
        local host, repo = string.match(uri, '^git@(.*):(.*)$')
        if host == nil or repo == nil then
            display(uri .. " doesn't match to git protocol uri", "error")
            return nil, nil
        end
        local trimed = trim_git_suffix(repo)
        return  host, trimed
    end
    remotes["^ssh://git@(.*)/(.*/.*)$"] = function(uri)
        local host, repo = string.match(uri, '^ssh://git@(.*)/(.*/.*)$')
        if host == nil or repo == nil then
            display(uri .. " doesn't match to git protocol uri", "error")
            return nil, nil
        end
        local trimed = trim_git_suffix(repo)
        return  host, trimed
    end
    remotes['^https://(.*@)??(.*)/(.*)$'] = function(uri)
        local n, host, repo = string.match(uri, '^https://(.*@)??(.*)/(.*)$')
        if host == nil then
            display(uri .. " doesn't match to git protocol uri", "error")
            return ""
        end
        local trimed = trim_git_suffix(repo)
        return host, trimed
    end

    local host, repo = '', ''
    local remote = shellexec("git ls-remote --get-url origin")
    for pattern, f in pairs(remotes) do
        if string.find(remote, pattern) ~= nil then
            host, repo = f(remote)
            if host == nil or repo == nil then
                return
            end
        end
    end
    if host == '' or repo == '' then
        return
    end

    local link = ""
    local f = hosts[host_mode]
    if f == nil then
        return
    end
    link = f(host, repo, ref, path_from_root, firstline, lastline)

    link = string.gsub(link, "[\n\t ]", "")
    vim.cmd('let @+ = "' .. link .. '"')
    display("copied " .. link, "info")
    vim.api.nvim_command('lcd ' .. currentdir)
end

function shellexec(cmd)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  return result
end

function trim_git_suffix(str)
    local nospace = string.gsub(str, '[\r\n ]', '')
    return string.gsub(nospace, '%.git$', '')
end

function setup(config)
    local cfg_names = {mode=modes, host=hosts}
    for k, v in pairs(cfg_names) do
        if config[k] then
            for name, f in pairs(config[k]) do
                v[name] = f
            end
        end
    end
end

local cprl = {}
cprl.copylink = copylink
cprl.setup = setup
return cprl

