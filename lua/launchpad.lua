local M = {}

local window_ids = {}
local last_command = nil
local pad_file_name = '_.nvim-launchpad'

local function open_pad_window()
    table.insert(window_ids, vim.api.nvim_open_win(
        vim.fn.bufnr(pad_file_name, true),
        true,
        {relative='editor', row=5, col=5, border='single', height=10, width=150, title='[launchpad for `'..vim.uv.cwd()..'`]'}))
end

local function close_pad_windows()
    for _, v in pairs(window_ids) do
        vim.fn.win_execute(v, 'close', true)
    end
    window_ids = {}
end

local function exec_with_mod_var(expr, ctrl)
    local env = _G
    env['MOD'] = ctrl
    load(expr, 'launchpad chunk', "t", env)()
end

local function choose_last_command()
    last_command = vim.fn.getline('.')
    close_pad_windows()
end

local function execute_line(ctrl)
    choose_last_command()
    exec_with_mod_var(last_command, ctrl)
end

local function execute_last(ctrl)
    if last_command then
        exec_with_mod_var(last_command, ctrl)
    else
        vim.notify("no last command", vim.log.levels.WARN)
    end
end

local function set_launchpad_buffer_mappings()
    vim.keymap.set('n', '<Esc>', function()
        close_pad_windows()
    end, { buffer = true, desc = '[launchpad plugin] close pad windows' })
    vim.keymap.set('n', '<Enter>', function()
        execute_line('')
    end, { buffer = true, desc = '[launchpad plugin] execute current line as Lua chunk' })
    vim.keymap.set('n', '<S-Enter>', function()
        choose_last_command()
    end, { buffer = true, desc = '[launchpad plugin] choose current line' })
    vim.keymap.set('n', '<C-Enter>', function()
        execute_line('C')
    end, { buffer = true, desc = '[launchpad plugin] execute current line as Lua chunk (MOD="C")' })
    vim.keymap.set('n', '<A-Enter>', function()
        execute_line('A')
    end, { buffer = true, desc = '[launchpad plugin] execute current line as Lua chunk (MOD="A")' })
end

local key = 'F5'

local function write_help()
    vim.fn.append(0, {
        '',
        'vim.notify("my cmd 1 "..MOD)',
        'vim.notify("my cmd 2 "..MOD)',
        '-- <Enter>, <C-Enter> <A-Enter> (in this buffer) - run current line as Lua expression and close this window',
        '-- <S-Enter> (in this buffer) - remember current line and close window',
        '-- <Esc> (in this buffer) - close window',
        '-- <' .. key .. '>, <C-' .. key .. '>, <A-' .. key .. '> (outside this buffer) - run last used command',
        '-- <S-' .. key .. '> (outside this buffer) - open `launchpad` window',
    })
    vim.cmd.normal('2gg')
end

function M.setup(opts)
    opts = opts or {}
    if opts['key'] then key = opts.key:gsub('[<>%s]', '') end
    local group_name = 'nvim-launchpad'
    vim.api.nvim_create_augroup(group_name, { clear = true })
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' },
        {
            pattern = '*.nvim-launchpad',
            group = group_name,
            desc = 'creates <Enter> keymap to execute selected command',
            callback = function(args)
                if args.event == 'BufNewFile' then
                    write_help()
                end
                set_launchpad_buffer_mappings()
                vim.o.filetype = 'lua'
            end
        })

    vim.keymap.set('n', '<S-' .. key .. '>', open_pad_window, { desc = "[launchpad plugin] open launchpad window" })
    vim.keymap.set('n', '<' .. key .. '>', function() execute_last('') end,
        { desc = '[launchpad plugin] execute last used command' })
    vim.keymap.set('n', '<C-' .. key .. '>', function() execute_last('C') end,
        { desc = '[launchpad plugin] execute last used command (MOD="C")' })
    vim.keymap.set('n', '<A-' .. key .. '>', function() execute_last('A') end,
        { desc = '[launchpad plugin] execute last used command (MOD="A")' })
end

return M
