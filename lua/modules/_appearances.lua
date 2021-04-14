local set_hl = require("modules._util").set_hl

ColorUtil = {}

ColorUtil.override_gruvbox = function()
  local highlights = {
    -- normal stuff
    { "Normal",      { bg  = "NONE"    }},
    { "Comment",     { gui = "italic"  }},
    { "SignColumn",  { bg  = "NONE"    }},
    { "ColorColumn", { bg  = "#3C3836" }},
    { "String",      { gui = "NONE"    }},
    { "Special",     { gui = "NONE"    }},
    { "Folded",      { gui = "NONE"    }},
    { "EndOfBuffer", { bg  = "NONE",fg = "#282828" }},

    -- tabline stuff
    { "Tabline",            { bg = "NONE"  }},
    { "TablineSuccess",     { bg = "NONE", fg = "#b8bb26", gui = "bold" }},
    { "TablineError",       { bg = "NONE", fg = "#fb4934"  }},
    { "TablineWarning",     { bg = "NONE", fg = "#d79921"  }},
    { "TablineInformation", { bg = "NONE", fg = "#458588"  }},
    { "TablineHint",        { bg = "NONE", fg = "#689D6A"  }},

    -- vim-illuminate
    { "illuminatedWord", { gui = "underline" } },

    -- git stuff
    { "SignAdd",    { fg = "#458588", bg = "NONE" }},
    { "SignChange", { fg = "#D79921", bg = "NONE" }},
    { "SignDelete", { fg = "#fb4934", bg = "NONE" }},

    -- lsp saga stuff
    { "TargetWord",             { fg = "#d79921", bg  = "NONE",    gui = "bold" }},
    { "LspDiagErrorBorder",     { fg = "#fb4934", gui = "bold" }},
    { "LspDiagWarnBorder",      { fg = "#d79921", gui = "bold" }},
    { "LspDiagInfoBorder",      { fg = "#458588", gui = "bold" }},
    { "LspDiagHintBorder",      { fg = "#458588", gui = "bold" }},

    -- octo.nvim stuff
    { "OctoNvimIssueOpen",         { fg = "#b8bb26" }},
    { "OctoNvimIssueClosed",       { fg = "#fb4934" }},
    { "OctoNvimDirty",             { fg = "#fb4934" }},
    { "OctoNvimPullAdditions",     { fg = "#b8bb26" }},
    { "OctoNvimPullDeletions",     { fg = "#fb4934" }},
    { "OctoNvimPullModifications", { fg = "#d79921" }},

    -- misc
    { "jsonNoQuotesError",     { fg  = "#fb4934" }},
    { "jsonMissingCommaError", { fg  = "#fb4934" }},
    { "mkdLineBreak",          { bg  = "NONE"    }},
    { "htmlLink",              { gui = "NONE",    fg  = "#ebdbb2"   }},
    { "IncSearch",             { bg  = "#282828", fg  = "#928374"   }},
    { "mkdLink",               { fg  = "#458588", gui = "underline" }},
    { "markdownCode",          { bg  = "NONE",    fg  = "#fe8019"   }},
    -- { "StrikeThrough",         { gui = "strikethrough" }},

    -- statusline colours
    { "StatusLine",   { bg = "#3C3836", fg = "#EBDBB2", gui = "NONE" }},
    { "StatusLineNC", { bg = "#3C3836", fg = "#928374", gui = "NONE" }},
    { "Mode",         { bg = "#928374", fg = "#1D2021", gui = "bold" }},
    { "LineCol",      { bg = "#504945", fg = "#ebdbb2", gui = "bold" }},
    { "LineColAlt",   { bg = "#3C3836", fg = "#ebdbb2" }},
    { "Git",          { bg = "#928374", fg = "#1D2021", gui = "bold" }},
    { "Filetype",     { bg = "#504945", fg = "#EBDBB2" }},
    { "Filename",     { bg = "#504945", fg = "#EBDBB2" }},
    { "ModeAlt",      { bg = "#504945", fg = "#928374" }},
    { "GitAlt",       { bg = "#3C3836", fg = "#504945" }},
    { "FiletypeAlt",  { bg = "#3C3836", fg = "#504945" }},

    -- nvimtree
    { "NvimTreeFolderIcon",   { fg = "#d79921" }},
    { "NvimTreeIndentMarker", { fg = "#928374" }},

    -- telescope
    { "TelescopeSelection", { bg = "NONE", fg = "#d79921", gui = "bold" }},
    { "TelescopeMatching",  { bg = "NONE", fg = "#fb4934", gui = "bold" }},
    { "TelescopeBorder",    { bg = "NONE", fg = "#928374", gui = "bold" }},

    -- diagnostic stuff
    { "LspDiagnosticsDefaultError",         { bg  = "NONE", fg = "#fb4934" }},
    { "LspDiagnosticsDefaultWarning",       { bg  = "NONE", fg = "#d79921" }},
    { "LspDiagnosticsDefaultInformation",   { bg  = "NONE", fg = "#458588" }},
    { "LspDiagnosticsDefaultHint",          { bg  = "NONE", fg = "#689D6A" }},
    { "LspDiagnosticsUnderlineError",       { gui = "underline" }},
    { "LspDiagnosticsUnderlineWarning",     { gui = "underline" }},
    { "LspDiagnosticsUnderlineInformation", { gui = "underline" }},
    { "LspDiagnosticsUnderlineHint",        { gui = "underline" }},

    -- ts override
    -- { "TSKeywordOperator", { bg = "NONE", fg = "#fb4934" }},
    -- { "TSOperator",        { bg = "NONE", fg = "#fe8019" }},
  }

  for _, highlight in ipairs(highlights) do
    set_hl(highlight[1], highlight[2])
  end
end

-- italicize comments
set_hl("Comment", { gui = "italic" })

-- automatically override colourscheme
vim.api.nvim_exec([[
  augroup NewColor
  au!
  au ColorScheme gruvbox call v:lua.ColorUtil.override_gruvbox()
  augroup END
]], false)

-- disable invert selection for gruvbox
vim.g.gruvbox_invert_selection = false
vim.cmd [[colorscheme gruvbox]]

-- needs to be loaded after setting colourscheme
vim.cmd [[packadd nvim-web-devicons]]
require("nvim-web-devicons").setup {
  override = {
    svg = {
      icon  = "",
      color = "#ebdbb2",
      name  = "Svg",
    },
  },
  default = true
}
