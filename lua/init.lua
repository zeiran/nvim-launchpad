local M = {}

local window_ids = {}
local last_command = nil
local pad_file_name = '_.nvim-launchpad'

function M.Open()
	vim.cmd('7split '..pad_file_name)
	table.insert(window_ids, vim.fn.win_getid())
end

local function exec_with_mod_var(expr, ctrl)
	local env = _G
	env['MOD'] = ctrl
	load(expr, 'launchpad chunk', "t", env)()
end

local function choose_last_command()
	last_command = vim.fn.getline('.')
	for _,v in pairs(window_ids) do
		vim.fn.win_execute(v, 'quit', true)
	end
	window_ids = {}
end

function M.ExecLine(ctrl)
	choose_last_command()
	exec_with_mod_var(last_command, ctrl)
end

function M.ExecLast(ctrl)
	if last_command then
		exec_with_mod_var(last_command, ctrl)
	else
		vim.notify("no last command", vim.log.levels.WARN)
	end
end

local function set_launchpad_buffer_mappings()
	print(vim.inspect(arg))
	vim.keymap.set('n', '<Enter>', function ()
		M.ExecLine('')
	end, {buffer=true, desc='[launchpad plugin] execute current line as Lua chunk'})
	vim.keymap.set('n', '<S-Enter>', function ()
		choose_last_command()
	end, {buffer=true, desc='[launchpad plugin] choose current line'})
	vim.keymap.set('n', '<C-Enter>', function ()
		M.ExecLine('C')
	end, {buffer=true, desc='[launchpad plugin] execute current line as Lua chunk (MOD="C")'})
	vim.keymap.set('n', '<A-Enter>', function ()
		M.ExecLine('A')
	end, {buffer=true, desc='[launchpad plugin] execute current line as Lua chunk (MOD="A")'})
end

local key = 'F5'

local function write_help()
	vim.fn.append(0, {
		'vim.notify("my cmd 1 "..MOD)',
		'vim.notify("my cmd 2 "..MOD)',
		'-- <Enter>, <C-Enter> <A-Enter> (in this buffer) - run current line as Lua expression and close this window',
		'-- <S-Enter> (in this buffer) - remember current line and close window',
		'-- <'..key..'>, <C-'..key..'>, <A-'..key..'> (outside this buffer) - run last used command',
		'-- <S-'..key..'> (outside this buffer) - open `launchpad` window',
	})
	vim.cmd.normal('gg')
end

function M.setup(opts)
	if opts['key'] then key = opts.key:gsub('[<>%s]', '') end
	local group_name = 'nvim-launchpad'
	vim.api.nvim_create_augroup(group_name, {clear=true})
	vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'},
		{pattern='*.nvim-launchpad', group=group_name, desc='creates <Enter> keymap to execute selected command', callback=function(args)
			if args.event == 'BufNewFile' then
				write_help()
			end
			set_launchpad_buffer_mappings()
			vim.o.filetype='lua'
		end})

	vim.keymap.set('n', '<S-'..key..'>', M.Open,                         {desc="[launchpad plugin] open launchpad window"})
	vim.keymap.set('n', '<'..key..'>',   function() M.ExecLast('') end,  {desc='[launchpad plugin] execute last used command'})
	vim.keymap.set('n', '<C-'..key..'>', function() M.ExecLast('C') end, {desc='[launchpad plugin] execute last used command (MOD="C")'})
	vim.keymap.set('n', '<A-'..key..'>', function() M.ExecLast('A') end, {desc='[launchpad plugin] execute last used command (MOD="A")'})
end

return M
