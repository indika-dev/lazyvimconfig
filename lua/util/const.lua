function Protect(tbl)
  return setmetatable({}, {
    __index = tbl,
    __newindex = function(t, key, value)
      error("attempting to change constant " .. tostring(key) .. " to " .. tostring(value), 2)
    end,
  })
end
