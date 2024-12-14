local cmd = require("utils").cmd

local _cond_breakpoint = function()
  require("dap").set_breakpoint(vim.fn.input("Condition: "))
end

return {
  "jay-babu/mason-nvim-dap.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    {
      "rcarriga/nvim-dap-ui",
      dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
      },
      opts = {},
    },
    {
      "theHamsta/nvim-dap-virtual-text",
      dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-treesitter/nvim-treesitter",
      },
      opts = {},
    },
  },
  opts = {
    ensure_installed = {
      "debugpy",
    },
    handlers = {
      function(config)
        require("mason-nvim-dap").default_setup(config)

        local dap, dapui = require("dap"), require("dapui")

        dap.listeners.before.attach.dapui_config = dapui.open
        dap.listeners.before.launch.dapui_config = dapui.open
        dap.listeners.before.event_terminated.dapui_config = dapui.close
        dap.listeners.before.event_exited.dapui_config = dapui.close

        -- Not done yet, but it is possible to configure floating
        -- elements and whatnot.
      end,
    },
  },
  keys = {
    { "<F4>", cmd("DapToggleBreakpoint"), desc = "debug | breakpoint toggle" },
    { "<leader>db", cmd("DapToggleBreakpoint"), desc = "[b]reakpoint toggle" },
    { "<F3>", _cond_breakpoint, desc = "debug | conditional breakpoint" },
    { "<leader>dc", _cond_breakpoint, desc = "[c]onditional breakpoint" },
    { "<F5>", cmd("DapContinue"), desc = "debug | start / continue" },
    { "<leader>dd", cmd("DapContinue"), desc = "start / continue [d]ebugging" },
    { "<F10>", cmd("DapStepOver"), desc = "debug | step over" },
    { "<leader>do", cmd("DapStepOver"), desc = "step [o]ver" },
    { "<F11>", cmd("DapStepInto"), desc = "debug | step into" },
    { "<leader>di", cmd("DapStepInto"), desc = "step [i]nto" },
    { "<F12>", cmd("DapStepOut"), desc = "debug | step out" },
    { "<leader>dO", cmd("DapStepOut"), desc = "step [O]ut" },
    { "<leader>dv", cmd("DapVirtualTextToggle"), desc = "[v]irtual text toggle" },
    { "<leader>dV", cmd("DapVirtualTextForceRefresh"), desc = "virtual text [r]efresh" },
  },
}
