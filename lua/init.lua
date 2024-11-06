local M = {}

local window_ids = {}
local last_command = nil
local pad_file_name = '_.nvim-launchpad'

function M.Open()
	vim.cmd('7split '..pad_file_name)
	table.insert(window_ids, vim.fn.win_getid())
end

local function exec_with_crtl_var(expr, ctrl)
	local env = _G
	env['ctrl'] = ctrl
	load(expr, 'launchpad chunk', "t", env)()
end

function M.ExecLine(ctrl)
	last_command = vim.fn.getline('.')
	for k,v in pairs(window_ids) do
		vim.fn.win_execute(v, 'quit', true)
	end
	window_ids = {}
	exec_with_crtl_var(last_command, ctrl)
end
function M.ExecLast(ctrl)
	if last_command then
		exec_with_crtl_var(last_command, ctrl)
	else
		print("no last command")
	end
end

vim.filetype.add({
	extension = {
		launchpad = 'launchpad'
	}
})

function M.setup(opts)
	print('launchpad cfg: '..opts['key'])
	local group_name = 'nvim-launchpad'
	vim.api.nvim_create_augroup(group_name, {clear=true})
	vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {pattern='*.nvim-launchpad', group=group_name, desc='creates <Enter> keymap to execute selected command', callback=function ()
		print("launchpad buf read callback")
		vim.keymap.set('n', '<Enter>', function ()
			M.ExecLine(false)
		end, {buffer=true, desc='[launchpad plugin] execute current line as Lua chunk'})
		vim.keymap.set('n', '<C-Enter>', function ()
			M.ExecLine(true)
		end, {buffer=true, desc='[launchpad plugin] execute current line as Lua chunk (alternative)'})
	end})

	vim.keymap.set('n', '<S-F5>', M.Open, {desc="[launchpad plugin] open launchpad window"})
	vim.keymap.set('n', '<F5>', function() M.ExecLast(false) end, {desc='[launchpad plugin] execute last used command'})
	vim.keymap.set('n', '<C-F5>', function() M.ExecLast(true) end, {desc='[launchpad plugin] execute last used command (alternative)'})
end

return M
