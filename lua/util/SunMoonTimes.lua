local M = {}

M.dawnAngle, M.duskAngle = 6, 6
M.DR = math.pi / 180
M.K1 = 15 * math.pi * 1.0027379 / 180
M.sunRiseSetTimes = { 6, 6, 6, 12, 13, 18, 18, 18, 24 }
M.moonRiseSetTimes = { 0, 23.9 }
M.Sky = { 0, 0, 0 }
M.Dec = { 0, 0, 0 }
M.VHz = { 0, 0, 0 }
M.RAn = { 0, 0, 0 }
M.lat = 0
M.long = 0
M.timeOffset = 0
M.moonTimeOffset = 0
M.jDateSun = 0
M.jDateMoon = 0
M.NoSunRise, M.NoSunSet = false, false

----------------------------------------------------------------------------------------------------

M.GetSunMoonTimes = function(nLatitude, nLongitude, nTimeZone, nTimestamp, nShiftTz)
  --
  -- This function returns a timestamp for the sunrise time for a specific location and date.  Can
  -- be called on demand via inline Lua.
  --
  -- Where:  nLatitude    = latitude
  --         nLongitude   = longitude
  --         nTimeZone    = timezone offset for the location of interest (in hours)
  --         nTimestamp   = timestamp for location of interest (Windows timestamp)
  --         nShiftTz     = "true" to shift timestamp to the timezone of the location of interest*
  --
  -- Note: The "nShiftTz" parameter is used to offset a timestamp from your location to the timezone
  --       of the location of interest, if needed.  This case happens if you use a Time measure to
  --       get your current time, but need to know what that time is in another timezone; e.g.,
  --       if you are in New York (Tz = -5) and need to calculate the current time in Los Angeles
  --       (Tz = -8).  Set this value to "false" if the timestamp is ALREADY converted to the target
  --       timezone.
  --
  local nLocalTz = (M.getTimeOffset() / 3600)

  -- set default values
  M.dawnAngle, M.duskAngle = 6, 6
  M.DR = math.pi / 180
  M.K1 = 15 * math.pi * 1.0027379 / 180
  M.sunRiseSetTimes = { 6, 6, 6, 12, 13, 18, 18, 18, 24 }
  M.moonRiseSetTimes = { 0, 23.9 }
  M.Sky = { 0, 0, 0 }
  M.Dec = { 0, 0, 0 }
  M.VHz = { 0, 0, 0 }
  M.RAn = { 0, 0, 0 }
  M.lat = 0
  M.long = 0
  M.timeOffset = 0
  M.moonTimeOffset = 0
  M.jDateSun = 0
  M.jDateMoon = 0
  M.NoSunRise, M.NoSunSet = false, false

  if vim.fn.has("win32") == 1 then
    -- convert Windows timestamp (0 = 1/1/1601) to Unix/Lua timestamp (0 = 1/1/1970)
    nTimestamp = nTimestamp - 11644473600
  end

  -- NOTE:  Lua os.date appears to convert timestamps to dates while adding the timezone offset of
  --        THIS machine.  In cases where you are monitoring weather in a timezone not your own,
  --        the resulting date will be incorrect.  If the current timezone is not the same as the
  --        one coming from the weather.com data, offset the timestamp by the difference.
  local tDate
  if nTimeZone == nLocalTz or not nShiftTz then
    tDate = os.date("!*t", nTimestamp)
  else
    tDate = os.date("!*t", nTimestamp - M.getTimeOffset() + (nTimeZone * 3600))
  end

  -- set time and gregorian date
  M.setDateTime(nLatitude, nLongitude, nTimeZone, tDate)

  -- sun time calculations
  M.calcSunRiseSet()
  if NoSunRise or NoSunSet then
    -- adjust times to solar noon
    M.sunRiseSetTimes[2] = (M.sunRiseSetTimes[2] - 12)
    if NoSunRise then
      M.sunRiseSetTimes[3] = M.sunRiseSetTimes[2] + 0.0001
    else
      M.sunRiseSetTimes[3] = (M.sunRiseSetTimes[2] - 0.0001)
    end
    M.sunRiseSetTimes[1] = 0
    M.sunRiseSetTimes[4] = 0
  end

  -- moon time calculations
  M.calcMoonRiseSet(nLatitude, nLongitude, M.jDateMoon, M.moonTimeOffset)

  -- calculate day length and sun angle
  -- NOTE:  Sunrise = 180, solar noon = 90, sunset = 0.
  local nAngle
  local nDayLength

  if NoSunRise then
    -- sun will not come up today
    nDayLength = 0.0
    nAngle = 270
  elseif NoSunSet then
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
  result.twctimezone = nTimeZone
  result.mytimezone = nLocalTz
  result.rawtimestamp = nTimestamp
  result.timestamp = os.date("%m/%d/%Y %I:%M:%S %p", os.time(tDate) - (os.date("*t")["isdst"] and 3600 or 0))
  -- result.dawn = M.timeToTable(M.sunRiseSetTimes[1], nTimeStyle) -- just a reminder
  -- TimeString(sunRiseSetTimes[2], nTimeLZero, nTimeStyle)
  result.dawn = M.timeToUnixEpoch(M.sunRiseSetTimes[1], tDate)
  result.sunrise = M.timeToUnixEpoch(M.sunRiseSetTimes[2], tDate)
  result.sunset = M.timeToUnixEpoch(M.sunRiseSetTimes[3], tDate)
  result.twilight = M.timeToUnixEpoch(M.sunRiseSetTimes[4], tDate)
  result.moonrise = M.timeToUnixEpoch(M.moonRiseSetTimes[1], tDate)
  result.moonset = M.timeToUnixEpoch(M.moonRiseSetTimes[2], tDate)
  -- result.daylength = M.timeToTable(nDayLength, 1) -- just a reminder
  result.daylength = nDayLength
  result.angle = nAngle
  result.polarday = M.NoSunSet
  result.polarnight = M.NoSunRise

  return result
end -- function GetSunMoonTimes

----------------------------------------------------------------------------------------------------

M.setDateTime = function(xlat, ylong, tmzone, today)
  M.lat = xlat or 0
  M.long = ylong or 0
  M.timeOffset = tmzone

  local iTimeNow = ((today.hour * 3600) + (today.min * 60) + today.sec) / 3600
  local Gday = today.day
  local Gmonth = today.month
  local Gyear = today.year

  M.moonTimeOffset = -60 * M.timeOffset
  M.jDateSun = M.julian(Gyear, Gmonth, Gday) - (M.long / (15 * 24))
  M.jDateMoon = M.julian(Gyear, Gmonth, Gday)
end -- function setDateTime

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
  return noon + ((direction == "CCW") and -t or t)
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

M.julian = function(year, month, day)
  --
  -- convert Gregorian date to Julian day
  --
  if month <= 2 then
    year = year - 1
    month = month + 12
  end
  local A = math.floor(year / 100)
  local B = 2 - A + math.floor(A / 4)
  local JD = math.floor(365.25 * (year + 4716)) + math.floor(30.6001 * (month + 1)) + day + B - 1524.5 -- NOTE this might be a global variable
  return JD
end -- function julian

M.setTimes = function(sunRiseSetTimes)
  Ftimes = M.dayPortion(sunRiseSetTimes)
  local dawn = M.sunAngleTime(M.dawnAngle, Ftimes[2], "CCW")
  local sunrise = M.sunAngleTime(M.riseSetAngle(), Ftimes[3], "CCW")
  local sunset = M.sunAngleTime(M.riseSetAngle(), Ftimes[8], "CW")
  local dusk = M.sunAngleTime(M.duskAngle, Ftimes[7], "CW")
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
  sunRiseSetTimes[1] = M.refineHLtimes(sunRiseSetTimes[1], sunRiseSetTimes[2], M.dawnAngle, nightTime, "CCW")
  return sunRiseSetTimes
end -- function adjustHighLats

M.refineHLtimes = function(Ftime, base, angle, night, direction)
  --
  -- refine time for higher latitudes
  --
  portion = night / 2
  FtimeDiff = (direction == "CCW") and M.timeDiff(Ftime, base) or M.timeDiff(base, Ftime)
  if not ((Ftime * 2) > 2) or (FtimeDiff > portion) then
    Ftime = base + ((direction == "CCW") and -portion or portion)
  end
  return Ftime
end -- function refineHLtimes

M.dayPortion = function(sunRiseSetTimes)
  --
  --  convert hours to day portions
  --
  for i = 1, #sunRiseSetTimes do
    sunRiseSetTimes[i] = sunRiseSetTimes[i] / 24
  end
  return sunRiseSetTimes
end -- function dayPortion

M.timeDiff = function(time1, time2)
  --
  --  difference between two times
  --
  return DMath.fixHour(time2 - time1)
end -- function timeDiff

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
  local ha = { 0, 0, 0 } -- NOTE this might be a global variable
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
  local zone = M.moonTimeOffset / 60
  local ph
  local jd = M.jDateMoon - 2451545 -- Julian day relative to Jan 1.5, 2000
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
------------------------------------- [ other odds and sods ] --------------------------------------

M.getTimeOffset = function()
  return (os.time() - os.time(os.date("!*t")) + (os.date("*t")["isdst"] and 3600 or 0))
end

M.timeToTable = function(Ftime, nTimeStyle)
  --
  -- put time in string format
  --
  -- Where:  Ftime      = floating point time (hours with fractional minutes)
  --         nTimeStyle = 0 (12-hour clock) 1 (24-hour clock)
  --
  local result = {}
  local hours = math.floor(Ftime)
  local minutes = math.floor((Ftime - hours) * 60)
  if nTimeStyle == 1 then
    -- 24-hour clock
    result.hours = hours
    result.minutes = minutes
  else
    -- 12-hour clock
    if hours > 11 and hours < 24 then
      AmPm = " PM"
    else
      AmPm = " AM"
    end

    -- convert 24-hour time to 12-hour time
    if hours >= 0 then
      hours = ((hours + 12 - 1) % 12 + 1)
    end
    result.hours = hours
    result.minutes = minutes
    result.AMPM = AmPm
  end
  return result
end -- function TimeTable

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

StringUtils = {
  twoDigitsFormat = function(num)
    --
    -- add a leading 0
    --
    if num < 10 then
      return "0" .. tostring(num)
    else
      return tostring(num)
    end
  end, -- function twoDigitsFormat

  TimeString = function(Ftime, nTimeLZero, nTimeStyle)
    --
    -- put time in string format
    --
    -- Where:  Ftime      = floating point time (hours with fractional minutes)
    --         nTimeLZero = 0 (no leading zeros on hour), 1 (leading zeros on hour)
    --         nTimeStyle = 0 (12-hour clock) 1 (24-hour clock)
    --
    local hours = math.floor(Ftime)
    local minutes = math.floor((Ftime - hours) * 60)

    if nTimeStyle == 0 then
      -- 12-hour clock
      if hours > 11 and hours < 24 then
        AmPm = " PM"
      else
        AmPm = " AM"
      end

      -- convert 24-hour time to 12-hour time
      if hours >= 0 then
        hours = ((hours + 12 - 1) % 12 + 1)
      end

      if nTimeLZero == 0 then
        -- no leading zeros
        return hours .. ":" .. StringUtils.twoDigitsFormat(minutes) .. AmPm
      else
        -- leading zeros
        return StringUtils.twoDigitsFormat(hours) .. ":" .. StringUtils.twoDigitsFormat(minutes) .. AmPm
      end
    else
      -- 24-hour clock
      if nTimeLZero == 0 then
        -- no leading zeros
        return hours .. ":" .. StringUtils.twoDigitsFormat(minutes)
      else
        -- leading zeros
        return StringUtils.twoDigitsFormat(hours) .. ":" .. StringUtils.twoDigitsFormat(minutes)
      end
    end
  end, -- function TimeString
}

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
