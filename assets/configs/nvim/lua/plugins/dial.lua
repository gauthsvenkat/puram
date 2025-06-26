return {
  "monaqa/dial.nvim",
  opts = function()
    local augend = require("dial.augend")

    local ordinal_numbers = augend.constant.new({
      elements = {
        "first",
        "second",
        "third",
        "fourth",
        "fifth",
        "sixth",
        "seventh",
        "eighth",
        "ninth",
        "tenth",
      },
      -- if true, it only matches strings with word boundary. firstDate wouldn't work for example
      word = false,
      cyclic = true,
    })

    local weekdays = augend.constant.new({
      elements = {
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
      },
      word = true,
      cyclic = true,
    })

    local months = augend.constant.new({
      elements = {
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      },
      word = true,
      cyclic = true,
    })

    local capitalized_boolean = augend.constant.new({
      elements = {
        "True",
        "False",
      },
      word = true,
      cyclic = true,
    })

    return {
      groups = {
        default = {
          augend.integer.alias.binary,
          augend.integer.alias.decimal_int,
          augend.integer.alias.hex,
          augend.integer.alias.octal,

          augend.date.alias["%Y/%m/%d"],
          augend.date.alias["%Y-%m-%d"],

          augend.date.alias["%d/%m/%Y"],
          augend.date.alias["%d/%m/%y"],

          augend.date.alias["%d.%m.%Y"],
          augend.date.alias["%d.%m.%y"],

          augend.date.alias["%m/%d/%Y"],
          augend.date.alias["%m/%d/%y"],

          augend.date.alias["%H:%M:%S"],

          augend.constant.alias.bool,

          augend.constant.alias.alpha,
          augend.constant.alias.Alpha,

          augend.semver.alias.semver,

          ordinal_numbers,
          weekdays,
          months,
          capitalized_boolean,
        },
      },
    }
  end,
  config = function(_, opts)
    require("dial.config").augends:register_group(opts.groups)
  end,
  keys = {
    {
      "<C-a>",
      function()
        require("dial.map").manipulate("increment", "normal")
      end,
      desc = "increment",
    },
    {
      "<C-x>",
      function()
        require("dial.map").manipulate("decrement", "normal")
      end,
      desc = "decrement",
    },
    {
      "<C-a>",
      function()
        require("dial.map").manipulate("increment", "visual")
      end,
      desc = "increment",
      mode = { "v" },
    },
    {
      "<C-x>",
      function()
        require("dial.map").manipulate("decrement", "visual")
      end,
      desc = "decrement",
      mode = { "v" },
    },
    {
      "g<C-a>",
      function()
        require("dial.map").manipulate("increment", "gnormal")
      end,
      desc = "cumulative increment",
    },
    {
      "g<C-x>",
      function()
        require("dial.map").manipulate("decrement", "gnormal")
      end,
      desc = "cumulative decrement",
    },
    {
      "g<C-a>",
      function()
        require("dial.map").manipulate("increment", "gvisual")
      end,
      desc = "cumulative increment",
      mode = { "v" },
    },
    {
      "g<C-x>",
      function()
        require("dial.map").manipulate("decrement", "gvisual")
      end,
      desc = "cumulative decrement",
      mode = { "v" },
    },
  },
}
