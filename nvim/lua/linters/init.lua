local lint = require("lint")

local ok, strict_types = pcall(require, "linters.strict_types")

if ok then
  lint.linters.strict_types = strict_types
else
  vim.notify("Failed to load strict_types linter: " .. tostring(strict_types), vim.log.levels.WARN)
end
