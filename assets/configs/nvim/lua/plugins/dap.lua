local cmd = require("utils").cmd

return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "toggle [u]i",
      },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")

      -- Setup dapui with default config
      dapui.setup()

      -- Auto-open/close UI on debug events
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = { "rcarriga/nvim-dap-ui" },
    keys = {
      -- Basic debugging commands with <leader>d prefix
      { "<leader>db", cmd("DapToggleBreakpoint"), desc = "toggle [b]reakpoint" },
      {
        "<leader>dB",
        function()
          vim.ui.input({ prompt = "Breakpoint condition: " }, function(condition)
            if condition then
              require("dap").set_breakpoint(condition)
            end
          end)
        end,
        desc = "conditional [B]reakpoint",
      },
      { "<leader>dC", cmd("DapClearBreakpoints"), desc = "[C]lear all breakpoints" },
      { "<leader>dc", cmd("DapContinue"), desc = "[c]ontinue" },
      { "<leader>di", cmd("DapStepInto"), desc = "step [i]nto" },
      { "<leader>do", cmd("DapStepOver"), desc = "step [o]ver" },
      { "<leader>dO", cmd("DapStepOut"), desc = "step [O]ut" },
      { "<leader>dt", cmd("DapTerminate"), desc = "[t]erminate" },

      -- Function key bindings for common operations
      { "<F5>", cmd("DapToggleBreakpoint"), desc = "Debug: Toggle Breakpoint" },
      { "<F6>", cmd("DapContinue"), desc = "Debug: Continue" },
      { "<F7>", cmd("DapStepOver"), desc = "Debug: Step Over" },
      { "<F8>", cmd("DapStepInto"), desc = "Debug: Step Into" },
      { "<F9>", cmd("DapStepOut"), desc = "Debug: Step Out" },
    },
    config = function()
      -- Sign configuration for breakpoints
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = "python",
    config = function()
      require("dap-python").setup("uv")
    end,
  },
}
