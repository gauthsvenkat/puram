return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},

  -- NOTE: Using 'm,M' as harpoon is a glorified mark
  keys = {
    {
      "M",
      function()
        require("harpoon"):list():add()
      end,
      desc = "harpoon add",
    },
    {
      "<Tab>",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "harpoon quick menu",
    },
    {
      "]m",
      function()
        require("harpoon"):list():next({ ui_nav_wrap = true })
      end,
      desc = "harpoon next",
    },
    {
      "[m",
      function()
        require("harpoon"):list():prev({ ui_nav_wrap = true })
      end,
      desc = "harpoon prev",
    },
  },
}
