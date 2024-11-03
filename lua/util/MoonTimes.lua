---@meta

function Protect(tbl)
  return setmetatable({}, {
    __index = tbl,
    __newindex = function(t, key, value)
      error("attempting to change constant " .. tostring(key) .. " to " .. tostring(value), 2)
    end,
  })
end

---@class MoonTimes
local M = {}

M.DR = math.pi / 180
M.K1 = 15 * math.pi * 1.0027379 / 180
M.moonRiseSetTimes = { 0, 23.9 }
M.Sky = { 0, 0, 0 }
M.Dec = { 0, 0, 0 }
M.VHz = { 0, 0, 0 }
M.RAn = { 0, 0, 0 }
M.lat = 0
M.long = 0
M.timeOffset = 0
M.moonTimeOffset = 0
M.jDateMoon = 0

----------------------------------------------------------------------------------------------------
---compute sun and moon times
---@param nLatitude number
---@param nLongitude number
---@return table{latitude: number, longitude: number, timezone:number, rawtimestamp:number, timestamp: date,  moonrise: timestamp, moonset: timestamp }
M.GetMoonTimes = function(nLatitude, nLongitude)
  --
  -- This function returns a timestamp for the sunrise time for a specific location and date.  Can
  -- be called on demand via inline Lua.
  --
  -- Where:  nLatitude    = latitude
  --         nLongitude   = longitude

  local tDate = os.date("!*t")
  local nTimestamp = os.time(tDate)
  if vim.fn.has("win32") == 1 then
    -- convert Windows timestamp (0 = 1/1/1601) to Unix/Lua timestamp (0 = 1/1/1970)
    nTimestamp = nTimestamp - 11644473600
  end
  local nLocalTz = (os.time() - nTimestamp + (os.date("*t")["isdst"] and 3600 or 0)) / 3600

  -- set default values
  M.DR = math.pi / 180
  M.K1 = 15 * math.pi * 1.0027379 / 180
  M.moonRiseSetTimes = { 0, 23.9 }
  M.Sky = { 0, 0, 0 }
  M.Dec = { 0, 0, 0 }
  M.VHz = { 0, 0, 0 }
  M.RAn = { 0, 0, 0 }
  M.lat = nLatitude or 0
  M.long = nLongitude or 0
  M.timeOffset = nLocalTz
  M.moonTimeOffset = -60 * nLocalTz
  M.jDateMoon = M.julian(tDate.year, tDate.month, tDate.day)

  -- moon time calculations
  M.calcMoonRiseSet(nLatitude, nLongitude, M.jDateMoon, M.moonTimeOffset)

  local result = {}
  result.latitude = nLatitude
  result.longitude = nLongitude
  result.timezone = nLocalTz
  result.timestamp = os.date("%m/%d/%Y %I:%M:%S %p", os.time(tDate) - (os.date("*t")["isdst"] and 3600 or 0))
  result.moonrise = M.timeToUnixEpoch(M.moonRiseSetTimes[1], tDate)
  result.moonset = M.timeToUnixEpoch(M.moonRiseSetTimes[2], tDate)

  return result
end -- function GetSunMoonTimes

----------------------------------- [ moon time calaculations ] ------------------------------------

M.moon = function(jd)
  --
  -- moon's position using fundamental arguments (Van Flandern & Pulkkinen, 1979)
  --
  local d, f, g, h, m, n, s, u, v, w
  h = 0.606434 + 0.03660110129 * jd
  m = 0.374897 + 0.03629164709 * jd
  f = 0.259091 + 0.0367481952 * jd
  d = 0.827362 + 0.03386319198 * jd
  n = 0.347343 - 0.00014709391 * jd
  g = 0.993126 + 0.0027377785 * jd

  h = h - math.floor(h)
  m = m - math.floor(m)
  f = f - math.floor(f)
  d = d - math.floor(d)
  n = n - math.floor(n)
  g = g - math.floor(g)

  h = h * 2 * math.pi
  m = m * 2 * math.pi
  f = f * 2 * math.pi
  d = d * 2 * math.pi
  n = n * 2 * math.pi
  g = g * 2 * math.pi

  v = 0.39558 * math.sin(f + n)
  v = v + 0.082 * math.sin(f)
  v = v + 0.03257 * math.sin(m - f - n)
  v = v + 0.01092 * math.sin(m + f + n)
  v = v + 0.00666 * math.sin(m - f)
  v = v - 0.00644 * math.sin(m + f - 2 * d + n)
  v = v - 0.00331 * math.sin(f - 2 * d + n)
  v = v - 0.00304 * math.sin(f - 2 * d)
  v = v - 0.0024 * math.sin(m - f - 2 * d - n)
  v = v + 0.00226 * math.sin(m + f)
  v = v - 0.00108 * math.sin(m + f - 2 * d)
  v = v - 0.00079 * math.sin(f - n)
  v = v + 0.00078 * math.sin(f + 2 * d + n)

  u = 1 - 0.10828 * math.cos(m)
  u = u - 0.0188 * math.cos(m - 2 * d)
  u = u - 0.01479 * math.cos(2 * d)
  u = u + 0.00181 * math.cos(2 * m - 2 * d)
  u = u - 0.00147 * math.cos(2 * m)
  u = u - 0.00105 * math.cos(2 * d - g)
  u = u - 0.00075 * math.cos(m - 2 * d + g)

  w = 0.10478 * math.sin(m)
  w = w - 0.04105 * math.sin(2 * f + 2 * n)
  w = w - 0.0213 * math.sin(m - 2 * d)
  w = w - 0.01779 * math.sin(2 * f + n)
  w = w + 0.01774 * math.sin(n)
  w = w + 0.00987 * math.sin(2 * d)
  w = w - 0.00338 * math.sin(m - 2 * f - 2 * n)
  w = w - 0.00309 * math.sin(g)
  w = w - 0.0019 * math.sin(2 * f)
  w = w - 0.00144 * math.sin(m + n)
  w = w - 0.00144 * math.sin(m - 2 * f - n)
  w = w - 0.00113 * math.sin(m + 2 * f + 2 * n)
  w = w - 0.00094 * math.sin(m - 2 * d + g)
  w = w - 0.00092 * math.sin(2 * m - 2 * d)

  s = w / math.sqrt(u - v * v) -- compute moon's right ascension ...
  M.Sky[1] = h + math.atan(s / math.sqrt(1 - s * s))

  s = v / math.sqrt(u) -- declination ...
  M.Sky[2] = math.atan(s / math.sqrt(1 - s * s))

  M.Sky[3] = 60.40974 * math.sqrt(u) -- and parallax
end -- function moon

M.test_moon = function(k, t0, lat, plx)
  --
  -- test an hour for an event
  --
  local ha = { 0, 0, 0 }
  local hr, _min
  local az, hz, nz, dz
  if M.RAn[3] < M.RAn[1] then
    M.RAn[3] = M.RAn[3] + 2 * math.pi
  end

  ha[1] = t0 - M.RAn[1] + (k * M.K1)
  ha[3] = t0 - M.RAn[3] + (k * M.K1) + M.K1
  ha[2] = (ha[3] + ha[1]) / 2 -- hour angle at half hour
  M.Dec[2] = (M.Dec[3] + M.Dec[1]) / 2 -- declination at half hour
  local s = math.sin(M.DR * lat)
  local c = math.cos(M.DR * lat)

  -- refraction + sun semidiameter at horizon + parallax correction
  local z = math.cos(M.DR * (90.567 - 41.685 / plx))

  if k <= 0 then
    -- first call of function
    M.VHz[1] = s * math.sin(M.Dec[1]) + c * math.cos(M.Dec[1]) * math.cos(ha[1]) - z
  end
  M.VHz[3] = s * math.sin(M.Dec[3]) + c * math.cos(M.Dec[3]) * math.cos(ha[3]) - z
  if DMath.sgn(M.VHz[1]) == DMath.sgn(M.VHz[3]) then
    -- no event this hour
    return M.VHz[3]
  end
  M.VHz[2] = s * math.sin(M.Dec[2]) + c * math.cos(M.Dec[2]) * math.cos(ha[2]) - z
  local a = 2 * M.VHz[3] - 4 * M.VHz[2] + 2 * M.VHz[1]
  local b = 4 * M.VHz[2] - 3 * M.VHz[1] - M.VHz[3]
  local d = b * b - 4 * a * M.VHz[1]

  if d < 0 then
    -- no event this hour
    return M.VHz[3]
  end

  d = math.sqrt(d)
  local e = (-b + d) / (2 * a)
  if (e > 1) or (e < 0) then
    e = (-b - d) / (2 * a)
  end
  local _time = k + e + 1 / 120 -- time of an event + round up

  if (M.VHz[1] < 0) and (M.VHz[3] > 0) then
    M.moonRiseSetTimes[1] = _time
  end

  if (M.VHz[1] > 0) and (M.VHz[3] < 0) then
    M.moonRiseSetTimes[2] = _time
  end

  return M.VHz[3]
end -- function testmoon

M.lst = function(lon, jd, z)
  --
  -- Local Sidereal Time for zone
  --
  local s = 24110.5 + 8640184.812999999 * jd / 36525 + 86636.6 * z + 86400 * lon
  s = s / 86400
  s = s - math.floor(s)
  return s * 360 * M.DR
end -- function lst

M.calcMoonRiseSet = function(lat, lon, jDateMoon, moonTimeOffset)
  --
  -- calculate moonrise and moonset times
  --
  local zone = moonTimeOffset / 60
  local ph
  local jd = jDateMoon - 2451545 -- Julian day relative to Jan 1.5, 2000
  local mp = {}
  local lon_local = lon

  for i = 1, 3 do
    mp[i] = {}
    for j = 1, 3 do
      mp[i][j] = 0
    end
  end

  lon_local = lon / 360
  local tz = zone / 24
  local t0 = M.lst(lon_local, jd, tz) -- local sidereal time
  jd = jd + tz -- get moon position at start of day
  for k = 1, 3 do
    M.moon(jd)
    mp[k][1] = M.Sky[1]
    mp[k][2] = M.Sky[2]
    mp[k][3] = M.Sky[3]
    jd = jd + 0.5
  end

  if mp[2][1] <= mp[1][1] then
    mp[2][1] = mp[2][1] + 2 * math.pi
  end
  if mp[3][1] <= mp[2][1] then
    mp[3][1] = mp[3][1] + 2 * math.pi
  end
  M.RAn[1] = mp[1][1]
  M.Dec[1] = mp[1][2]

  -- check each hour of this day
  for k = 0, 23 do
    ph = (k + 1) / 24
    M.RAn[3] = DMath.interpolate(mp[1][1], mp[2][1], mp[3][1], ph)
    M.Dec[3] = DMath.interpolate(mp[1][2], mp[2][2], mp[3][2], ph)
    M.VHz[3] = M.test_moon(k, t0, lat, mp[2][3])
    M.RAn[1] = M.RAn[3] -- advance to next hour
    M.Dec[1] = M.Dec[3]
    M.VHz[1] = M.VHz[3]
  end
end -- function calcMoonRiseSet

----------------------------------------------------------------------------------------------------

---comment convert Gregorian date to Julian day
---@param year number
---@param month number
---@param day number
---@return number
M.julian = function(year, month, day)
  if month <= 2 then
    year = year - 1
    month = month + 12
  end
  local A = math.floor(year / 100)
  local B = 2 - A + math.floor(A / 4)
  local JD = math.floor(365.25 * (year + 4716)) + math.floor(30.6001 * (month + 1)) + day + B - 1524.5
  return JD
end -- function julian

------------------------------------- [ other odds and sods ] --------------------------------------

M.timeToUnixEpoch = function(Ftime, tDate)
  --
  -- convert time to epoch time
  --
  -- Where:  Ftime      = floating point time (hours with fractional minutes)
  --         tDate = date of interest
  --
  local toWindowsEpochTime = 0
  if vim.fn.has("win32") == 1 then
    -- convert Unix/Lua timestamp (0 = 1/1/1970) to Windows timestamp (0 = 1/1/1601)
    toWindowsEpochTime = 11644473600
  end
  local hours = math.floor(Ftime)
  local minutes = math.floor((Ftime - hours) * 60)
  return os.time({ year = tDate.year, month = tDate.month, day = tDate.day, hour = hours, min = minutes, sec = 0 })
    + toWindowsEpochTime
end

---------------------------------------- [ math functions ] ----------------------------------------

DMath = {
  interpolate = function(f0, f1, f2, p)
    --
    -- 3-point interpolation
    --
    local a = f1 - f0
    local b = f2 - f1 - a
    local f = f0 + p * (2 * a + b * (2 * p - 1))
    return f
  end,
  sgn = function(x)
    --
    -- returns value for sign of argument
    --
    if x == 0 then
      return 0
    end
    if x > 0 then
      return 1
    end
    return -1
  end,
  fix = function(a, b)
    a = a - b * (math.floor(a / b))
    return (a < 0) and a + b or a
  end,
  dtr = function(d)
    return (d * math.pi) / 180
  end,
  rtd = function(r)
    return (r * 180) / math.pi
  end,
  Msin = function(d)
    return math.sin(DMath.dtr(d))
  end,
  Mcos = function(d)
    return math.cos(DMath.dtr(d))
  end,
  Mtan = function(d)
    return math.tan(DMath.dtr(d))
  end,
  arcsin = function(d)
    return DMath.rtd(math.asin(d))
  end,
  arccos = function(d)
    return DMath.rtd(math.acos(d))
  end,
  arctan = function(d)
    return DMath.rtd(math.atan(d))
  end,
  arccot = function(x)
    return DMath.rtd(math.atan(1 / x))
  end,
  arctan2 = function(y, x)
    if jit then
      return DMath.rtd(math.atan2(y, x))
    else
      -- atan2 is deprecated
      return DMath.rtd(math.atan(y, x))
    end
  end,
  fixAngle = function(a)
    return DMath.fix(a, 360)
  end,
  fixHour = function(a)
    return DMath.fix(a, 24)
  end,
}

return M
