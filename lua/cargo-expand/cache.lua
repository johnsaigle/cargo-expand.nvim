
-- lua/cargo-expand/cache.lua
local M = {}

-- Get the cache directory following XDG spec
function M.get_cache_dir()
    local cache_dir = vim.fn.stdpath('cache')
    local plugin_cache = cache_dir .. '/cargo-expand'

    if vim.fn.isdirectory(plugin_cache) == 0 then
        vim.fn.mkdir(plugin_cache, 'p')
    end

    return plugin_cache
end

-- Generate cache key based on project and file
function M.get_cache_key()
    local cwd = vim.fn.getcwd()
    local cargo_toml = vim.fn.findfile('Cargo.toml', cwd .. ';')

    if cargo_toml == '' then
        return nil
    end

    local mod_time = vim.fn.getftime(cargo_toml)
    local hash = vim.fn.sha256(cargo_toml .. mod_time)
    return hash:sub(1, 16)
end

-- Check cache and return expanded code if valid
function M.get_cached_expansion()
    local cache_key = M.get_cache_key()
    if not cache_key then return nil end

    local cache_file = M.get_cache_dir() .. '/' .. cache_key

    if vim.fn.filereadable(cache_file) == 1 then
        local cache_time = vim.fn.getftime(cache_file)
        local current_time = os.time()

        if current_time - cache_time < 300 then
            local lines = vim.fn.readfile(cache_file)
            return table.concat(lines, '\n')
        end
    end

    return nil
end

-- Save expansion to cache
function M.cache_expansion(expanded_code)
    local cache_key = M.get_cache_key()
    if not cache_key then return end

    local cache_file = M.get_cache_dir() .. '/' .. cache_key
    vim.fn.writefile(vim.split(expanded_code, '\n'), cache_file)
end

return M
