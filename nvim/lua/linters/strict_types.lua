return {
  cmd = "cat",
  stdin = true,
  args = {},
  stream = "stdout",
  ignore_exitcode = true,
  parser = function(_, bufnr)
    local diagnostics = {}
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 10, false)
    local has_php_tag = false
    local has_strict_types = false

    for _, line in ipairs(lines) do
      if line:match("<%?php") or line:match("<\\?") then
        has_php_tag = true
      end
      if line:match("declare%s*%(%s*strict_types%s*=%s*1") then
        has_strict_types = true
      end
    end

    if has_php_tag and not has_strict_types then
      table.insert(diagnostics, {
        lnum = 0,
        col = 0,
        end_lnum = 0,
        end_col = 5,
        severity = vim.diagnostic.severity.WARN,
        message = "Missing declare(strict_types=1);",
        source = "strict_types",
      })
    end

    return diagnostics
  end,
}
