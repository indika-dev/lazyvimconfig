local SCANDIR = {}

--- Create a flat list of all files in a directory
-- @param directory - The directory to scan (default value = './')
-- @param recursive - Whether or not to scan subdirectories recursively (default value = true)
-- @param extensions - List of extensions to collect, if blank all will be collected
SCANDIR.scandir = function(directory, recursive, extensions)
  directory = directory or ""
  recursive = recursive or false
  -- if string.sub(directory, -1) ~= '/' then directory = directory .. '/' end
  local currentDirectory = directory
  local fileList = {}
  local command = "find " .. currentDirectory
  if not recursive then
    command = command .. " -maxdepth 1"
  end
  if extensions then
    if type(extensions) == "table" then
      command = command .. " \\( "
      for _, extension in ipairs(extensions) do
        command = command .. "-name '*." .. extension .. "' -o "
      end
      command = string.sub(command, 1, -4) .. " \\)"
    else
      command = command .. " -name '*." .. extensions .. "'"
    end
  end

  for fileName in io.popen(command):lines() do
    table.insert(fileList, fileName)
  end

  return fileList
end

return SCANDIR
