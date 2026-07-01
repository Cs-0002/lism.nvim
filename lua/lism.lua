local M = {}


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

--- Setup lism.nvim nator highlight on cursor position
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
      local node = vim.treesitter.get_node()
      vim.api.nvim_buf_clear_namespace(0, mark_ns, 0, -1)
      local cursor = vim.api.nvim_win_get_cursor(0)
      local line = vim.api.nvim_get_current_line()
      -- cursor[2] is 0-indexed column, sub() is 1-indexed
      local undercursor = line:sub(cursor[2] + 1, cursor[2] + 1)
      if undercursor == "(" then
        if node and node:type() == "list_lit" then
          -- subtract 2 to exclude opening and closing parentheses
          for i = 1, node:child_count() - 2 do
            if node:child(i):type() ~= "comment" then
              local sr, sc, er, ec = node:child(i):range()
              local color = hsl_to_rgb((i-1) * 360 / (node:child_count() - 2 ), saturation, lightness)
              vim.api.nvim_set_hl(0, "ArgPos"..i, {bg = color})
              vim.api.nvim_buf_set_extmark(0, mark_ns, sr, sc, {hl_group = 'ArgPos'..i, end_row = er, end_col = ec})
            end
          end
        end
      end
    end
  })
end

return M
