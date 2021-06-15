local _, telescope = pcall(require, "telescope")
local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local builtin = require("telescope.builtin")

local M = {}

telescope.setup {
  defaults = {
    file_previewer     = previewers.vim_buffer_cat.new,
    grep_previewer     = previewers.vim_buffer_vimgrep.new,
    qflist_previewer   = previewers.vim_buffer_qflist.new,
    scroll_strategy    = "cycle",
    selection_strategy = "reset",
    layout_strategy    = "flex",
    borderchars        = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    layout_defaults = {
      horizontal = {
        width_padding  = 0.1,
        height_padding = 0.1,
        preview_width  = 0.6,
      },
      vertical = {
        width_padding  = 0.05,
        height_padding = 1,
        preview_height = 0.5,
      },
    },
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,

        ["<C-v>"] = actions.select_vertical,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-t>"] = actions.select_tab,

        ["<C-c>"] = actions.close,
        ["<Esc>"] = actions.close,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,
        ["<Tab>"] = actions.toggle_selection,
        -- ["<C-r>"] = actions.refine_result,
      },
      n = {
        ["<CR>"]  = actions.select_default + actions.center,
        ["<C-v>"] = actions.select_vertical,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-t>"] = actions.select_tab,
        ["<Esc>"] = actions.close,

        ["j"]     = actions.move_selection_next,
        ["k"]     = actions.move_selection_previous,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,
        ["<C-q>"] = actions.send_to_qflist,
        ["<Tab>"] = actions.toggle_selection,
        -- ["<C-w>l"] = actions.preview_switch_window_right,
      },
    },
  },
  extensions = {
    fzf = {
      override_generic_sorter = true,
      override_file_sorter = true,
    },
    media_files = {
      filetypes = { "png", "webp", "jpg", "jpeg", "pdf", "mkv" },
      find_cmd  = "rg",
    },
    frecency = {
      show_scores     = false,
      show_unindexed  = true,
      ignore_patterns = { "*.git/*", "*/tmp/*" },
      workspaces = {
        ["nvim"]      = "/home/francisl/.config/nvim",
        ["alacritty"] = "/home/francisl/.config/alacritty",
      },
    },
    arecibo = {
      ["selected_engine"]   = "duckduckgo",
      ["url_open_command"]  = "xdg-open",
      ["show_http_headers"] = false,
      ["show_domain_icons"] = true,
    },
  },
}

pcall(require("telescope").load_extension, "fzf") -- superfast sorter
pcall(require("telescope").load_extension, "media_files") -- media preview
pcall(require("telescope").load_extension, "frecency") -- frecency
-- pcall(require("telescope").load_extension, "arecibo") -- websearch
pcall(require("telescope").load_extension, "dap") -- DAP integrations

M.no_preview = function(opts)
  opts = opts or {}
  return require("telescope.themes").get_dropdown(vim.tbl_extend("force", {
    borderchars = {
      { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
      results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
      preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    },
    width = 0.8,
    previewer = false,
  }, opts))
end

local delta = previewers.new_termopen_previewer {
  get_command = function(entry)
    return {
      "git",
      "-c",
      "core.pager=delta",
      "-c",
      "delta.side-by-side=false",
      "diff",
      entry.value .. "^!",
    }
  end,
}

M.git_commits = function(opts)
  opts = opts or {}
  opts.previewer = {
    delta,
    previewers.git_commit_message.new(opts),
    previewers.git_commit_diff_as_was.new(opts),
  }

  builtin.git_commits(opts)
end

M.git_bcommits = function(opts)
  opts = opts or {}
  opts.previewer = {
    delta,
    previewers.git_commit_message.new(opts),
    previewers.git_commit_diff_as_was.new(opts),
  }

  builtin.git_bcommits(opts)
end

M.grep_prompt = function()
  builtin.grep_string {
    shorten_path = true,
    search = vim.fn.input "Grep String > ",
  }
end

M.files = function()
  builtin.find_files { file_ignore_patterns = { "%.png", "%.jpg", "%.webp" } }
end

M.buffer_fuzzy = function()
  builtin.current_buffer_fuzzy_find(M.no_preview())
end

M.arecibo = function()
    require("telescope").extensions.arecibo.websearch(M.no_preview())
end

M.frecency = function()
    require("telescope").extensions.frecency.frecency(M.no_preview())
end

M.reload = function()
    require("telescope.builtin").reloader(M.no_preview())
end

M.code_actions = function()
    require("telescope.builtin").lsp_code_actions(M.no_preview())
end


return setmetatable({}, {
  __index = function(_, k)
    if M[k] then
      return M[k]
    else
      return require("telescope.builtin")[k]
    end
  end,
})