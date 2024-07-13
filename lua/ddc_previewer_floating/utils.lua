local M = {}

---@generic T
---@param list T[]
---@param cb fun(x: T): number
---@return number
function M.max(list, cb)
	assert(#list > 0, "Array is empty")
	local max_value = -math.huge
	for _, elem in ipairs(list) do
		local m = cb and cb(elem) or elem
		if m > max_value then
			max_value = m
		end
	end
	return max_value
end

local timer = {}

---@param name string
local function timer_reset(name)
	if timer[name] then
		timer[name]:stop()
		timer[name]:close()
		timer[name] = nil
	end
end

---@param name string
---@param fn function
---@param time number milliseconds
function M.debounce(name, fn, time)
	timer_reset(name)
	timer[name] = vim.uv.new_timer()
	timer[name]:start(
		time,
		0,
		vim.schedule_wrap(function()
			fn()
			timer_reset(name)
		end)
	)
end

---@param x any
---@return boolean
function M.is_truthy(x)
	return vim.fn.empty(x) == 0
end

function M.stylize_markdown_treesitter(bufnr, contents, opts)
	width, height = vim.lsp.util._make_floating_popup_size(contents, opts)
	contents = vim.lsp.util._normalize_markdown(contents, {
		width = width,
		height = height,
	})
	vim.bo[bufnr].filetype = "markdown"
	vim.treesitter.start(bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, contents)

	vim.bo[bufnr].syntax = "markdown"
	vim.bo[bufnr].modifiable = false
	vim.bo[bufnr].bufhidden = "wipe"
	return contents
end

function M.stylize_markdown(bufnr, contents, opts)
	contents = vim.lsp.util.stylize_markdown(bufnr, contents, opts)
	return contents
end

return M
