local function augroup(name)
  return vim.api.nvim_create_augroup("pvim_" .. name, { clear = true })
end

-- Toggling relative numbers outside of insert mode
local number_toggle = augroup("relativenumber")

vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.cmd("set norelativenumber")
  end,
  group = number_toggle,
  pattern = "*",
})

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.cmd("set relativenumber")
  end,
  group = number_toggle,
  pattern = "*",
})

-- Make lazygit interactable once it's opened in a terminal
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup("lazygit_startinsert"),
  pattern = "term://*lazygit*",
  callback = function()
    vim.cmd("startinsert")
  end,
})

-- Closing/hiding some buffers easily
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help",
    "lspinfo",
    "notify",
    "qf",
    "query",
    "checkhealth",
    "fugitiveblame",
    "oil",
    "health",
    "lazy",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("hide_with_<C-q>"),
  pattern = {
    "term://*lazygit*",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("t", "<C-q>", function()
      vim.cmd("stopinsert")
      vim.cmd("hide")
    end, { buffer = event.buf, silent = true })
  end,
})

-- Conceallevel
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("conceallevel"),
  pattern = {
    "markdown",
  },
  callback = function()
    vim.o.conceallevel = 2
  end,
})

-- Highlight yanking
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- LSP keybinds
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
    vim.keymap.set("n", "gr", "<cmd>Trouble lsp_references focus=true<cr>", { buffer = args.buf })

    if vim.version().minor < 10 then
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf })
      vim.keymap.set("n", "crn", vim.lsp.buf.rename, { buffer = args.buf })
      vim.keymap.set({ "n", "v" }, "crr", vim.lsp.buf.code_action, { buffer = args.buf })
    end
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  callback = function(args)
    vim.keymap.del("n", "gd", { buffer = args.buf })
    vim.keymap.del("n", "gr", { buffer = args.buf })

    if vim.version().minor < 10 then
      vim.keymap.del("n", "K", { buffer = args.buf })
      vim.keymap.del("n", "crr", { buffer = args.buf })
      vim.keymap.del({ "n", "v" }, "crn", { buffer = args.buf })
    end
  end,
})

-- LSP capabilities
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client then
      if client.name == "eslint" then
        client.server_capabilities.documentFormattingProvider = true
      elseif client.name == "tsserver" then
        client.server_capabilities.documentFormattingProvider = false
      end
      if client.supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable()
      end
    end
  end,
})

-- Linting
vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

-- Indentscope toggling
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "help",
    "alpha",
    "dashboard",
    "neo-tree",
    "Trouble",
    "trouble",
    "lazy",
    "mason",
    "notify",
    "toleterm",
    "lazyterm",
  },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})
