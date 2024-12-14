-- All the garbage code I don't like writing twice

local M = {}

---@param cmd string
---@param prefix? string
---@return string
M.cmd = function(cmd, prefix)
  return (prefix or "<cmd>") .. cmd .. "<cr>"
end

---@param package_name string
M.install_mason_package = function(package_name)
  local mr = require("mason-registry")

  local function notify(msg, level)
    -- Helper function to notify the user.
    -- msg is a string that can contain a placeholder for the package name
    vim.notify(msg:format(package_name), level or vim.log.levels.INFO, { title = "utils.install_mason_package" })
  end

  if mr.is_installed(package_name) then
    notify("%s is already installed!", vim.log.levels.WARN)
    return
  end

  if not mr.has_package(package_name) then
    notify("%s cannot be found in the mason registry!", vim.log.levels.ERROR)
    return
  end

  notify("Installing %s ...")

  local pkg = mr.get_package(package_name)

  pkg:install():once(
    "closed",
    vim.schedule_wrap(function()
      if pkg:is_installed() then
        notify("%s was successfully installed")
      else
        notify("Failed to install %s. Logs are available in :Mason and :MasonLog", vim.log.levels.ERROR)
      end
    end)
  )
end

---@param package_names string[]
M.ensure_installed = function(package_names)
  local mr = require("mason-registry")

  for _, package_name in ipairs(package_names) do
    if not mr.is_installed(package_name) then
      M.install_mason_package(package_name)
    end
  end
end

return M
