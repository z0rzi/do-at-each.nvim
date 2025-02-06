local M = {
    config = {
        mappings = {
            do_at_each_normal_mode = 'M',
            do_at_each_visual_mode = 'M',
        },
    },
}

local function clean_macro(macro)
    -- let clean_macro = substitute(substitute(a:macro, '<>', '\<ESC>', 'g'), '<[a-zA-Z-]\+>\|"', '\\&', 'gi')
    return macro:gsub('<>', '<ESC>'):gsub('<[a-zA-Z-]+>', function(s) return '\\'..s end)
end

function M.setup_mappings()
    -- Helper function to map a normal mode key with arguments
    local function map(mode, key)
        vim.keymap.set(mode, key, function()
            -- Save current view
            local save = vim.fn.winsaveview()

            local mmode = vim.fn.mode(true)
            local from_line = 1
            local to_line = vim.fn.line('$')

            if mmode ~= 'n' then
                -- If we are in visual mode, we ESC to access '< and '>
                vim.cmd([[ execute "normal! \<ESC>" ]])
                from_line = vim.fn.line("'<")
                to_line = vim.fn.line("'>")
            end

            if mmode ~= 'n' and mmode ~= vim.api.nvim_replace_termcodes('<c-v>', true, false, true) then
                -- Not in block mode.
                mmode = 'n'
            end

            local macro = vim.fn.input('Macro: ')
            if macro == '' then
                return
            end
            macro = clean_macro(macro)

            if mmode == 'n' then
                -- Normal mode
                local rx = vim.fn.getreg('/')
                M.do_at_each_match(from_line, to_line, rx, macro)
            else
                -- Visual mode
                local col = math.min(vim.fn.col("'<"), vim.fn.col("'>"))
                M.do_at_each_line(from_line, to_line, col, macro)
            end

            vim.fn.winrestview(save)
        end, { silent = true })
    end

    map('n', M.config.mappings.do_at_each_normal_mode)
    map('v', M.config.mappings.do_at_each_visual_mode)
end

function M.do_at_each_line(from_line, to_line, column, macro)
    local ns_id = vim.api.nvim_create_namespace('do_at_each_line')
    
    for line = from_line, to_line do
        -- Move to the line
        vim.api.nvim_win_set_cursor(0, {line, 0})
        
        -- Get line length
        local line_length = #vim.api.nvim_get_current_line()
        
        -- Calculate column position (don't go beyond line length)
        local col = math.min(column - 1, line_length)
        
        -- Move to column
        vim.api.nvim_win_set_cursor(0, {line, col})
        
        -- Place extmark
        local mark_id = vim.api.nvim_buf_set_extmark(0, ns_id, line - 1, col, {})
        
        -- Execute the macro
        vim.cmd([[ execute "normal! ]]..macro..[[" ]])
        
        -- Return to marked position
        local mark_pos = vim.api.nvim_buf_get_extmark_by_id(0, ns_id, mark_id, {})
        if #mark_pos > 0 then
            vim.api.nvim_win_set_cursor(0, {mark_pos[1] + 1, mark_pos[2]})
        end
        
        -- Clean up the mark
        vim.api.nvim_buf_del_extmark(0, ns_id, mark_id)
    end
end

function M.do_at_each_match(from_line, to_line, regex, macro)
    -- Create namespace for our extmarks
    local ns_id = vim.api.nvim_create_namespace('do_at_each_match')

    print(from_line, to_line)
    
    -- Go to first line of range
    vim.api.nvim_win_set_cursor(0, {from_line, 0})
    
    while true do
        -- Find next match
        local found = vim.fn.search(regex, 'W')
        
        -- Break if no match or match is beyond our range
        if found == 0 or found > to_line then
            break
        end
        
        -- Get current position
        local pos = vim.api.nvim_win_get_cursor(0)
        local line = pos[1]
        local col = pos[2]
        
        -- Place extmark at match position
        local mark_id = vim.api.nvim_buf_set_extmark(0, ns_id, line - 1, col, {})
        
        -- Execute the macro
        vim.cmd([[ execute "normal! ]]..macro..[[" ]])
        
        -- Return to marked position
        local mark_pos = vim.api.nvim_buf_get_extmark_by_id(0, ns_id, mark_id, {})
        if #mark_pos > 0 then
            vim.api.nvim_win_set_cursor(0, {mark_pos[1] + 1, mark_pos[2]})
        end
        
        -- Clean up the mark
        vim.api.nvim_buf_del_extmark(0, ns_id, mark_id)
    end
end

function M.setup(user_opts)
    M.config = vim.tbl_extend('force', M.config, user_opts or {})
    M.setup_mappings()
end

return M
