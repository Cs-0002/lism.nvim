local M = {}


local list_types = {
  list_lit = true,
  defun = true,
  loop_macro = true,
  vec_lit = true,
  map_lit = true,
  list = true
}
local open_bracket_types = {
  ["("] = true,
  ["["] = true,
  ["{"] = true
}
local skip_types = {
  ["("] = true, [")"] = true,
  ["["] = true, ["]"] = true,
  ["{"] = true, ["}"] = true,
  comment = true,
}

--- Convert HSL color to RGB hex string
--- @param H number Hue (0-360)
--- @param S number Saturation (0-100)
--- @param L number Lightness (0-100)
--- @return string hex color code (e.g. '#FF9E64')
local function hsl_to_rgb(H, S, L)
  local cmax, cmin, R, G, B
  if L < 50 then 
    cmax = 2.55 * (L + L * (S / 100))
    cmin = 2.55 * (L - L * (S / 100))
  else
    cmax = 2.55 * (L + (100 - L) * (S / 100))
    cmin = 2.55 * (L - (100 - L) * (S / 100))
  end
  if H < 60 then
    R = cmax
    G = (H / 60) * (cmax - cmin) + cmin
    B = cmin
  elseif H < 120 then
    R = ((120 - H) / 60) * (cmax - cmin) + cmin
    G = cmax
    B = cmin
  elseif H < 180 then
    R = cmin
    G = cmax
    B = ((H - 120) / 60) * (cmax - cmin) + cmin
  elseif H < 240 then
    R = cmin
    G = ((240 - H) / 60) * (cmax - cmin) + cmin
    B = cmax
  elseif H < 300 then
    R = ((H - 240) / 60) * (cmax - cmin) + cmin
    G = cmin
    B = cmax
  else
    R = cmax
    G = cmin
    B = ((360 - H) / 60) * (cmax - cmin) + cmin
  end
  return string.format('#%02X%02X%02X', math.floor(R), math.floor(G), math.floor(B))
end

--- Collect the elements of a form, expanding defun_header
--- @param node TSNode
--- @return TSNode[]
local function collect_elements(node)
  local elems = {}
  for child in node:iter_children() do
    local t = child:type()
    if t == "defun_header" then
      for c in child:iter_children() do
        if not skip_types[c:type()] then
          table.insert(elems, c)
        end
      end
    elseif not skip_types[t] then
      table.insert(elems, child)
    end
  end
  return elems
end

--- Set up lism.nvim to highlight list elements under the cursor
--- @param opts table | nil Optional configuration
--- @param opts.saturation number Saturation of highlight colors (0-100)
--- @param opts.lightness number Lightness of highlight colors (0-100)
function M.setup(opts)
  local mark_ns = vim.api.nvim_create_namespace('lism.nvim')
  opts = opts or {}
  local saturation = opts.saturation or 50
  local lightness = opts.lightness or 20
  vim.api.nvim_create_autocmd({"CursorMoved", "BufWinEnter"}, {
    pattern = {"*"},
    callback = function()
      vim.api.nvim_buf_clear_namespace(0, mark_ns, 0, -1)
      local ok, parser = pcall(vim.treesitter.get_parser)
      if not ok or not parser then return end
      parser:parse()

      local node = vim.treesitter.get_node()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local line = vim.api.nvim_get_current_line()
      -- cursor[2] is 0-indexed column, sub() is 1-indexed
      local undercursor = line:sub(cursor[2] + 1, cursor[2] + 1)

      if open_bracket_types[undercursor] and node and list_types[node:type()] then
        local elems = collect_elements(node)
        for i, elem in ipairs(elems) do
          local sr, sc, er, ec = elem:range()
          local color = hsl_to_rgb((i - 1) * 360 / #elems, saturation, lightness)
          vim.api.nvim_set_hl(0, "ArgPos" .. i, { bg = color })
          vim.api.nvim_buf_set_extmark(0, mark_ns, sr, sc, { hl_group = "ArgPos" .. i, end_row = er, end_col = ec })
        end
      end
    end
  })
end

return M
