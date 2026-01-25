return {
  -- Formatting with Ruff via uv run ruff format
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
      },
      formatters = {
        ruff_format = {
          command = "uv",
          args = { "run", "ruff", "format", "-" },
          stdin = true,
        },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },

  -- Linting with Ruff and Type Checking with ty
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.python = { "ruff", "ty" }

      opts.linters = opts.linters or {}

      -- Ruff linter via uv run ruff check
      opts.linters.ruff = {
        cmd = "uv",
        args = { "run", "ruff", "check", "--output-format", "json" },
        stdin = false,
        ignore_exitcode = true,
        parser = function(output, bufnr)
          if output == "" or output == "[]" then
            return {}
          end

          local ok, diagnostics = pcall(vim.json.decode, output)
          if not ok or not diagnostics then
            return {}
          end

          local results = {}
          for _, item in ipairs(diagnostics) do
            table.insert(results, {
              lnum = item.location.row - 1,
              col = item.location.column - 1,
              message = item.message.text,
              code = item.code,
              severity = "W",
              source = "ruff",
            })
          end
          return results
        end,
      }

      -- Type checker via uv run ty check
      opts.linters.ty = {
        cmd = "uv",
        args = { "run", "ty", "check" },
        stdin = false,
        ignore_exitcode = true,
        parser = function(output, bufnr)
          local results = {}
          for line in vim.gsplit(output, "\n") do
            -- Parse lines like: file.py:10:5: error: message
            local fname, lnum, col, severity, message = line:match("^([^:]+):(%d+):(%d+): (%w+): (.+)$")
            if fname and lnum then
              table.insert(results, {
                lnum = tonumber(lnum) - 1,
                col = tonumber(col) - 1,
                message = message,
                severity = severity == "error" and "E" or "W",
                source = "ty",
              })
            end
          end
          return results
        end,
      }
    end,
  },

  -- Treesitter support for Python
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "python",
      },
    },
  },
}
