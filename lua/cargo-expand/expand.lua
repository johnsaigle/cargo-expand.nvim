local M = {}
local cache = require('cargo-expand.cache')

M.buffer_locations = {}

local function get_word_under_cursor()
    return vim.fn.expand('<cword>')
end

-- Find locations of word in expanded code
local function find_word_locations(expanded_code, word)
    local locations = {}
    local lines = vim.split(expanded_code, '\n')

    for i, line in ipairs(lines) do
        -- Find all occurrences in the line
        local start_pos = 1
        while true do
            local from, to = line:find('%f[%w_]' .. word .. '%f[^%w_]', start_pos)
            if not from then break end

            -- Store both line and column position
            table.insert(locations, {
                line = i,
                col = from - 1,        -- Convert to 0-based column index for nvim
                length = to - from + 1 -- Store word length for highlighting
            })
            start_pos = to + 1
        end
    end

    return locations
end

-- Find or create cargo expand buffer
local function get_expand_buffer()
    local buf_name = '[Cargo Expand]'

    -- Check if buffer already exists
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(buf) == buf_name then
            return buf
        end
    end

    -- Create new buffer if it doesn't exist
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].bufhidden = 'hide'
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = 'rust'
    vim.api.nvim_buf_set_name(buf, buf_name)

    return buf
end

-- Add locations to quickfix list
local function populate_quickfix(buf, locations, word)
    local qf_items = {}
    for _, loc in ipairs(locations) do
        local line = vim.api.nvim_buf_get_lines(buf, loc.line - 1, loc.line, false)[1]
        table.insert(qf_items, {
            bufnr = buf,
            lnum = loc.line,
            col = loc.col + 1, -- 1-based column number for quickfix
            text = line,
            pattern = word
        })
    end

    vim.fn.setqflist(qf_items)
end

function M.expand()
    local word = get_word_under_cursor()
    if not word then
        vim.notify("No word under cursor", vim.log.levels.WARN)
        return
    end

    local expanded_code = cache.get_cached_expansion()
    local cache_status = "cached"

    if not expanded_code then
        expanded_code = vim.fn.system("cargo expand")
        cache_status = "new"

        if vim.v.shell_error ~= 0 then
            vim.notify("Error running cargo expand: " .. expanded_code, vim.log.levels.ERROR)
            return
        end

        cache.cache_expansion(expanded_code)
    end

    local buf = get_expand_buffer()

    -- Create or reuse window
    local win = nil
    for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(w) == buf then
            win = w
            break
        end
    end

    if not win then
        win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(win, buf)
    end

    -- Update buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(expanded_code, '\n'))

    local locations = find_word_locations(expanded_code, word)

    -- Store locations for this buffer
    M.buffer_locations[buf] = locations

    if #locations > 0 then

        -- Populate quickfix list
        populate_quickfix(buf, locations, word)

        -- Jump to first occurrence
        vim.api.nvim_win_set_cursor(win, { locations[1].line, locations[1].col })

        vim.notify(string.format("Found %d occurrences of '%s' (%s)",
                #locations, word, cache_status),
            vim.log.levels.INFO)
    else
        vim.notify(string.format("No occurrences of '%s' found (%s)",
                word, cache_status),
            vim.log.levels.WARN)
    end

end


return M

