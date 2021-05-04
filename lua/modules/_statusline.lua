local fn = vim.fn
local api = vim.api

local M = {}

-- possible values are 'arrow' | 'rounded' | 'blank'
local active_sep = "blank"

-- change them if you want different separators
M.separators = {
  arrow   = { "", "" },
  rounded = { "", "" },
  blank   = { "", "" },
}

-- highlight groups
M.colors = {
  active       = "%#StatusLine#",
  inactive     = "%#StatusLineNC#",
  mode         = "%#StatusLineMode#",
  mode_alt     = "%#StatusLineModeAlt#",
  git          = "%#StatusLineGit#",
  git_alt      = "%#StatusLineGitAlt#",
  filetype     = "%#StatusLineFT#",
  filetype_alt = "%#StatusLineFTAlt#",
  line_col     = "%#StatusLineLCol#",
  line_col_alt = "%#StatusLineLColAlt#",
  lsp          = "%#StatusLineLSP#",
}

M.trunc_width = setmetatable({
  git_status = 90,
  filename   = 140,
}, {
  __index = function()
    return 80
  end,
})

M.is_truncated = function(_, width)
  local current_width = api.nvim_win_get_width(0)
  return current_width < width
end

M.modes = setmetatable({
  ["n"]  = "N",
  ["no"] = "N·P",
  ["v"]  = "V",
  ["V"]  = "V·L",
  [""] = "V·B", -- this is not ^V, but it's , they're different
  ["s"]  = "S",
  ["S"]  = "S·L",
  [""] = "S·B", -- same with this one, it's not ^S but it's 
  ["i"]  = "I",
  ["ic"] = "I",
  ["R"]  = "R",
  ["Rv"] = "V·R",
  ["c"]  = "C",
  ["cv"] = "V·E",
  ["ce"] = "E",
  ["r"]  = "P",
  ["rm"] = "M",
  ["r?"] = "C",
  ["!"]  = "S",
  ["t"]  = "T",
}, {
  __index = function()
    return "U" -- handle edge cases
  end,
})

M.get_current_mode = function(self)
  local current_mode = api.nvim_get_mode().mode
  return string.format(" %s ", self.modes[current_mode]):upper()
end

M.get_git_status = function(self)
  -- use fallback because it doesn't set this variable on the initial `BufEnter`
  local signs = vim.b.gitsigns_status_dict
    or { head = "", added = 0, changed = 0, removed = 0 }
  local is_head_empty = signs.head ~= ""

  if self:is_truncated(self.trunc_width.git_status) then
    return is_head_empty and string.format("  %s ", signs.head or "") or ""
  end

  return is_head_empty and string.format(
    " +%s ~%s -%s |  %s ",
    signs.added,
    signs.changed,
    signs.removed,
    signs.head
  ) or ""
end

M.get_filename = function(self)
  if self:is_truncated(self.trunc_width.filename) then
    return " %<%f "
  end
  return " %<%F "
end

M.get_filetype = function()
  local file_name, file_ext = fn.expand("%:t"), fn.expand("%:e")
  local icon = require("nvim-web-devicons").get_icon(file_name, file_ext, { default = true })
  local filetype = vim.bo.filetype

  if filetype == "" then
    return " No FT "
  end
  return string.format(" %s %s ", icon, filetype):lower()
end

M.get_line_col = function()
  return " %l:%c "
end

M.lsp_progress = function()
  local lsp = vim.lsp.util.get_progress_messages()[1]
  if lsp then
    local name = lsp.name or ""
    local msg = lsp.message or ""
    local percentage = lsp.percentage or 0
    local title = lsp.title or ""
    return string.format(" %s: %s %s (%s%%%%) ", name, title, msg, percentage)
  end

  return ""
end

M.set_active = function(self)
  local colors = self.colors

  local mode = colors.mode .. self:get_current_mode()
  local mode_alt = colors.mode_alt .. self.separators[active_sep][1]
  local git = colors.git .. self:get_git_status()
  local git_alt = colors.git_alt .. self.separators[active_sep][1]
  local filename = colors.inactive .. self:get_filename()
  local filetype_alt = colors.filetype_alt .. self.separators[active_sep][2]
  local filetype = colors.filetype .. self:get_filetype()
  local line_col = colors.line_col .. self:get_line_col()
  local line_col_alt = colors.line_col_alt .. self.separators[active_sep][2]
  local lsp = colors.lsp .. self:lsp_progress()

  return table.concat({
    colors.active,
    mode,
    mode_alt,
    line_col,
    line_col_alt,
    "%=",
    filename,
    "%=",
    lsp,
    filetype_alt,
    filetype,
    git,
    git_alt,
  })
end

M.set_inactive = function(self)
  return self.colors.inactive .. "%= %F %="
end

M.set_explorer = function(self)
  local title = self.colors.mode .. "   "
  local title_alt = self.colors.mode_alt .. self.separators[active_sep][2]

  return table.concat({ self.colors.active, title, title_alt })
end

Statusline = setmetatable(M, {
  __call = function(statusline, mode)
    if mode == "active" then
      return statusline:set_active()
    end
    if mode == "inactive" then
      return statusline:set_inactive()
    end
    if mode == "explorer" then
      return statusline:set_explorer()
    end
  end,
})

-- set statusline
-- TODO: replace this once we can define autocmd using lua
api.nvim_exec([[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline('active')
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline('inactive')
  au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline('explorer')
  augroup END
]], false)

----[[
--  NOTE: I don't use this since the statusline already has
--  so much stuff going on. Feel free to use it!
--  credit: https://github.com/nvim-lua/lsp-status.nvim
--  also, this might be broken lol idk
--
--  I now use `tabline` to display these errors, go to `_bufferline.lua` if you
--  want to check that out
----]]
-- Statusline.get_lsp_diagnostic = function(self)
--   local result = {}
--   local levels = {
--     errors = 'Error',
--     warnings = 'Warning',
--     info = 'Information',
--     hints = 'Hint'
--   }

--   for k, level in pairs(levels) do
--     result[k] = vim.lsp.diagnostic.get_count(0, level)
--   end

--   if self:is_truncated(120) then
--     return ''
--   else
--     return string.format(
--       "| :%s :%s :%s :%s ",
--       result['errors'] or 0, result['warnings'] or 0,
--       result['info'] or 0, result['hints'] or 0
--     )
--   end
-- end
