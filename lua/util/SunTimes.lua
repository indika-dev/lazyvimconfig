---@meta

function Protect(tbl)
  return setmetatable({}, {
    __index = tbl,
    __newindex = function(t, key, value)
      error("attempting to change constant " .. tostring(key) .. " to " .. tostring(value), 2)
    end,
  })
end

---@class SunTimes
local M = {}

M.dawnAngle, M.duskAngle = 6, 6
M.sunRiseSetTimes = { 6, 6, 6, 12, 13, 18, 18, 18, 24 }
M.lat = 0
M.long = 0
M.timeOffset = 0
M.jDateSun = 0
M.NoSunRise, M.NoSunSet = false, false

M.DIRECTIONS = Protect({
  Clockwise = "CW",
  CounterClockWise = "CCW",
})

----------------------------------------------------------------------------------------------------
---compute sun times
---@param nLatitude number
---@param nLongitude number
---@return table{latitude: number, longitude: number, timezone:number, rawtimestamp:number, timestamp: date, dawn: timestamp, sunrise: timestamp, sunset: timestamp, twilight: timestamp, daylength: number, angle: number, polarday: boolean, polarnight: boolean }
M.GetSunTimes = function(nLatitude, nLongitude)
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
  M.dawnAngle, M.duskAngle = 6, 6
  M.sunRiseSetTimes = { 6, 6, 6, 12, 13, 18, 18, 18, 24 }
  M.lat = nLatitude or 0
  M.long = nLongitude or 0
  M.timeOffset = nLocalTz
  M.jDateSun = M.julian(tDate.year, tDate.month, tDate.day) - (M.long / (15 * 24))
  M.NoSunRise, M.NoSunSet = false, false

  -- sun time calculations
  M.calcSunRiseSet()
  if M.NoSunRise or M.NoSunSet then
    -- adjust times to solar noon
    M.sunRiseSetTimes[2] = (M.sunRiseSetTimes[2] - 12)
    if M.NoSunRise then
      M.sunRiseSetTimes[3] = M.sunRiseSetTimes[2] + 0.0001
    else
      M.sunRiseSetTimes[3] = (M.sunRiseSetTimes[2] - 0.0001)
    end
    M.sunRiseSetTimes[1] = 0
    M.sunRiseSetTimes[4] = 0
  end

  -- calculate day length and sun angle
  -- NOTE:  Sunrise = 180, solar noon = 90, sunset = 0.
  local nAngle
  local nDayLength

  if M.NoSunRise then
    -- sun will not come up today
    nDayLength = 0.0
    nAngle = 270
  elseif M.NoSunSet then
    -- sun is up all day
    nDayLength = 24.0
    nAngle = 90
  else
    local nSunRise -- sunrise time in hours
    local nSunSet -- sunset time in hours
    local nCurrTime -- current time in hours

    nSunRise = M.sunRiseSetTimes[2]
    nSunSet = M.sunRiseSetTimes[3]
    nCurrTime = ((tDate.hour * 3600) + (tDate.min * 60)) / 3600
    nDayLength = nSunSet - nSunRise

    -- convert fraction of day to fraction of 180 degrees, fix for night time (negative values)
    nAngle = (((nSunSet - nCurrTime) / nDayLength) * 180)
    nAngle = DMath.fixAngle(nAngle)

    -- if southern hemisphere, calculate supplementary angle (so sun will move right to left)
    if nLatitude < 0 then
      if nAngle < 180 then
        nAngle = 180 - nAngle
      else
        nAngle = 180 + (360 - nAngle)
      end
    end
  end

  local result = {}
  result.latitude = nLatitude
  result.longitude = nLongitude
  result.timezone = nLocalTz
  result.timestamp = os.date("%m/%d/%Y %I:%M:%S %p", os.time(tDate) - (os.date("*t")["isdst"] and 3600 or 0))
  -- result.dawn = M.timeToTable(M.sunRiseSetTimes[1], nTimeStyle) -- just a reminder
  -- TimeString(sunRiseSetTimes[2], nTimeLZero, nTimeStyle)
  result.dawn = M.timeToUnixEpoch(M.sunRiseSetTimes[1], tDate)
  result.sunrise = M.timeToUnixEpoch(M.sunRiseSetTimes[2], tDate)
  result.sunset = M.timeToUnixEpoch(M.sunRiseSetTimes[3], tDate)
  result.twilight = M.timeToUnixEpoch(M.sunRiseSetTimes[4], tDate)
  result.daylength = nDayLength
  result.angle = nAngle
  result.polarday = M.NoSunSet
  result.polarnight = M.NoSunRise

  return result
end -- function GetSunMoonTimes

------------------------------------ [ sun time calculations ] -------------------------------------

M.midDay = function(Ftime)
  local eqt = M.sunPosition(M.jDateSun + Ftime, 0)
  local noon = DMath.fixHour(12 - eqt)
  return noon
end -- function midDay

M.sunAngleTime = function(angle, Ftime, direction)
  --
  -- time at which sun reaches a specific angle below horizon
  --
  local decl = M.sunPosition(M.jDateSun + Ftime, 1)
  local noon = M.midDay(Ftime)
  local t = (-DMath.Msin(angle) - DMath.Msin(decl) * DMath.Msin(M.lat)) / (DMath.Mcos(decl) * DMath.Mcos(M.lat))

  if t > 1 then
    -- the sun doesn't rise today
    M.NoSunRise = true
    return noon
  elseif t < -1 then
    -- the sun doesn't set today
    M.NoSunSet = true
    return noon
  end

  t = 1 / 15 * DMath.arccos(t)
  return noon + ((direction == M.DIRECTIONS.CounterClockWise) and -t or t)
end -- function sunAngleTime

M.sunPosition = function(jd, Declination)
  --
  -- compute declination angle of sun
  --
  local D = jd - 2451545
  local g = DMath.fixAngle(357.529 + 0.98560028 * D)
  local q = DMath.fixAngle(280.459 + 0.98564736 * D)
  local L = DMath.fixAngle(q + 1.915 * DMath.Msin(g) + 0.020 * DMath.Msin(2 * g))
  local R = 1.00014 - 0.01671 * DMath.Mcos(g) - 0.00014 * DMath.Mcos(2 * g)
  local e = 23.439 - 0.00000036 * D
  local RA = DMath.arctan2(DMath.Mcos(e) * DMath.Msin(L), DMath.Mcos(L)) / 15
  local eqt = q / 15 - DMath.fixHour(RA)
  local decl = DMath.arcsin(DMath.Msin(e) * DMath.Msin(L))

  if Declination == 1 then
    return decl
  else
    return eqt
  end
end -- function sunPosition

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

---comment compute sunrise, sunset, dawn and dusk
---@param sunRiseSetTimes any
---@return table{dawn: number, sunrise: number, sunset: number, dusk: number}
M.setTimes = function(sunRiseSetTimes)
  Ftimes = M.dayPortion(sunRiseSetTimes)
  local dawn = M.sunAngleTime(M.dawnAngle, Ftimes[2], M.DIRECTIONS.CounterClockWise)
  local sunrise = M.sunAngleTime(M.riseSetAngle(), Ftimes[3], M.DIRECTIONS.CounterClockWise)
  local sunset = M.sunAngleTime(M.riseSetAngle(), Ftimes[8], M.DIRECTIONS.Clockwise)
  local dusk = M.sunAngleTime(M.duskAngle, Ftimes[7], M.DIRECTIONS.Clockwise)
  return { dawn, sunrise, sunset, dusk }
end -- function setTimes

M.calcSunRiseSet = function()
  M.sunRiseSetTimes = M.setTimes(M.sunRiseSetTimes)
  return M.adjustTimes(M.sunRiseSetTimes)
end -- function calcSunRiseSet

M.adjustTimes = function(sunRiseSetTimes)
  for i = 1, #sunRiseSetTimes do
    sunRiseSetTimes[i] = sunRiseSetTimes[i] + (M.timeOffset - M.long / 15)
  end
  sunRiseSetTimes = M.adjustHighLats(sunRiseSetTimes)
  return sunRiseSetTimes
end -- function adjustTimes

M.riseSetAngle = function()
  --
  -- sun angle for sunset/sunrise
  --
  -- local angle = 0.0347 * math.sqrt( elv )
  local angle = 0.0347
  return 0.833 + angle
end -- function riseSetAngle

M.adjustHighLats = function(sunRiseSetTimes)
  --
  -- adjust times for higher latitudes
  --
  local nightTime = M.timeDiff(sunRiseSetTimes[3], sunRiseSetTimes[2])
  sunRiseSetTimes[1] =
    M.refineHLtimes(sunRiseSetTimes[1], sunRiseSetTimes[2], M.dawnAngle, nightTime, M.DIRECTIONS.CounterClockWise)
  return sunRiseSetTimes
end -- function adjustHighLats

M.refineHLtimes = function(Ftime, base, angle, night, direction)
  --
  -- refine time for higher latitudes
  --
  local portion = night / 2
  FtimeDiff = (direction == M.DIRECTIONS.CounterClockWise) and M.timeDiff(Ftime, base) or M.timeDiff(base, Ftime)
  if not ((Ftime * 2) > 2) or (FtimeDiff > portion) then
    Ftime = base + ((direction == M.DIRECTIONS.CounterClockWise) and -portion or portion)
  end
  return Ftime
end -- function refineHLtimes

M.dayPortion = function(sunRiseSetTimes)
  --
  --  convert hours to day portions
  --
  for i = 1, #sunRiseSetTimes do
    M.sunRiseSetTimes[i] = M.sunRiseSetTimes[i] / 24
  end
  return sunRiseSetTimes
end -- function dayPortion

M.timeDiff = function(time1, time2)
  --
  --  difference between two times
  --
  return DMath.fixHour(time2 - time1)
end -- function timeDiff

----------------------------------------------------------------------------------------------------
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
