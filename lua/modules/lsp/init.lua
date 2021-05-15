vim.cmd [[packadd nvim-lspconfig]]

local nvim_lsp = require("lspconfig")
local is_cfg_present = require("modules._util").is_cfg_present

-- override handlers
pcall(require, "modules.lsp._handlers")

-- specific language server configuration
pcall(require, "modules.lsp._sumneko")
pcall(require, "modules.lsp._flutter")
pcall(require, "modules.lsp._rust")

local custom_capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  return capabilities
end

-- use eslint if the eslint config file present
local is_using_eslint = function(_, _, result, client_id)
  if is_cfg_present("/.eslintrc.json") or is_cfg_present("/.eslintrc.js") then
    return
  end

  return vim.lsp.handlers["textDocument/publishDiagnostics"](_, _, result, client_id)
end

local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintIgnoreExitCode = true,
  lintStdin = true,
  lintFormats = { "%f:%l:%c: %m" },
}

local servers = {
  tsserver = {
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    init_options = {
      documentFormatting = false,
    },
    handlers = {
      ["textDocument/publishDiagnostics"] = is_using_eslint,
    },
    on_init = Util.lsp_on_init,
    on_attach = function()
      require("modules.lsp._mappings").lsp_mappings()
      require("nvim-lsp-ts-utils").setup {}
    end,
    root_dir = vim.loop.cwd,
  },
  --[[ denols = {
    filetypes = { "javascript", "typescript", "typescriptreact" },
    root_dir = vim.loop.cwd,
    settings = {
      documentFormatting = true
    }
  }, ]]
  html = {
    cmd = { "html-languageserver", "--stdio" }
  },
  cssls = {
    cmd = { "css-languageserver", "--stdio" }
  },
  jsonls = {
    cmd = { "vscode-json-languageserver", "--stdio" },
    filetypes = { "json", "jsonc" },
    root_dir = vim.loop.cwd
  },
  clangd = {},
  solargraph = {
    cmd = {"solargraph", "stdio"},
    filetypes = { "ruby" },
    root_dir = vim.loop.cwd,
    settings = {
      solargraph = {
        -- commandPath = "/home/francisl/.local/share/gem/ruby/3.0.0/bin/solargraph",
        diagnostics = true,
        logLevel = "debug",
        transport = "stdio",
      },
    },
  },
  gopls = {
    root_dir = vim.loop.cwd,
  },
  efm = {
    cmd = { "efm-langserver" },
    on_attach = function(client)
      client.resolved_capabilities.rename = false
      client.resolved_capabilities.hover = false
      client.resolved_capabilities.document_formatting = true
      client.resolved_capabilities.completion = false
    end,
    on_init = Util.lsp_on_init,
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte" },
    settings = {
      rootMarkers = { ".git", "package.json" },
      languages = {
        javascript = { eslint },
        typescript = { eslint },
        typescriptreact = { eslint },
        svelte = { eslint },
      },
    },
  },
  svelte = {
    on_attach = function(client)
      require("modules.lsp._mappings").lsp_mappings()

      client.server_capabilities.completionProvider.triggerCharacters = {
        ".", '"', "'", "`", "/", "@", "*",
        "#", "$", "+", "^", "(", "[", "-", ":"
      }
    end,
    handlers = {
      ["textDocument/publishDiagnostics"] = is_using_eslint,
    },
    on_init = Util.lsp_on_init,
    filetypes = { "svelte" },
    settings = {
      svelte = {
        plugin = {
          html = {
            completions = {
              enable = true,
              emmet = false,
            },
          },
          svelte = {
            completions = {
              enable = true,
              emmet = false,
            },
          },
          css = {
            completions = {
              enable = true,
              emmet = false,
            },
          },
        },
      },
    },
  },
}

for name, opts in pairs(servers) do
  local client = nvim_lsp[name]
  if opts.extra_setup then
    opts.extra_setup()
  end
  client.setup({
    cmd = opts.cmd or client.cmd,
    filetypes = opts.filetypes or client.filetypes,
    on_attach = opts.on_attach or Util.lsp_on_attach,
    on_init = opts.on_init or Util.lsp_on_init,
    handlers = opts.handlers or client.handlers,
    root_dir = opts.root_dir or client.root_dir,
    capabilities = opts.capabilities or custom_capabilities(),
    settings = opts.settings or {},
  })
end
