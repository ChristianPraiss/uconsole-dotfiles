-- set local shortcut key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "
--
-- load lazy plugin manager and setup dependencies
require("config.lazy")

-- load mason configuration
require("config.mason")

-- load catppuccin colorscheme
require("catppuccin").setup({
	flavour = "mocha",
})

vim.cmd("colorscheme catppuccin-mocha")
vim.o.background = "dark"

vim.opt.clipboard = "unnamed"

vim.diagnostic.config({ virtual_text = true })
vim.opt.completeopt = { "menuone", "noselect", "popup" }
vim.keymap.set({ "n" }, "<leader>ee", function()
	vim.diagnostic.open_float()
end, { desc = "Display line diagnostics " })

-- setup leave terminal shortcut
vim.keymap.set("t", "<leader>lt", "<C-\\><C-n>", { silent = true, desc = "Leave Terminal" })

-- setup tabstops
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true
-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- sets how neovim will display certain whitespace characters in the editor.
--  see `:help 'list'`
--  and `:help 'listchars'`
--
--  notice listchars is set using `vim.opt` instead of `vim.o`.
--  it is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- show current linenumber and relative numbers for navigation
vim.opt.number = true
vim.opt.relativenumber = true

-- disable arrow keys to force proper usage :-)
vim.keymap.set("", "<up>", "<nop>", { noremap = true })
vim.keymap.set("", "<down>", "<nop>", { noremap = true })
vim.keymap.set("i", "<up>", "<nop>", { noremap = true })
vim.keymap.set("i", "<down>", "<nop>", { noremap = true })
vim.keymap.set("", "<right>", "<nop>", { noremap = true })
vim.keymap.set("i", "<right>", "<nop>", { noremap = true })
vim.keymap.set("", "<left>", "<nop>", { noremap = true })
vim.keymap.set("i", "<left>", "<nop>", { noremap = true })

-- disable mouse scrolling
vim.opt.mouse = ""
vim.opt.mousescroll = "ver:0,hor:0"
vim.opt.mousescroll = "ver:0,hor:0"

-- open help in a vertial split
vim.api.nvim_create_augroup("vertical_help", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = "vertical_help",
	pattern = "help",
	callback = function()
		-- Set the help buffer to unload when hidden
		vim.bo.bufhidden = "unload"

		-- Move help window to vertical split on the right
		vim.cmd("wincmd L")

		-- Resize the vertical split to 80 columns
		vim.cmd("vertical resize 80")
	end,
})
