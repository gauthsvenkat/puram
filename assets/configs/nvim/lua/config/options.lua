-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- time between keypresses
vim.opt.timeoutlen = 300

-- use common clipboard
vim.opt.clipboard = "unnamedplus"

-- line numbering
vim.opt.number = true
vim.opt.relativenumber = true

-- window splitting
vim.opt.splitbelow = true
vim.opt.splitright = true

-- search
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- wrapped line will continue with the same indent
vim.opt.breakindent = true

-- column options
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 10

-- fast updatetime
vim.opt.updatetime = 50

-- more colors!!!
vim.opt.termguicolors = true

-- undo options
vim.opt.undodir = os.getenv("HOME") .. "/.undodir"
vim.opt.undofile = true

-- fold options
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- whitespace options
vim.opt.list = true
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  extends = "»",
  precedes = "«",
  nbsp = "␣",
}

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
