--[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]][][][][][][][]
-- Author = Mordasius
-- Name = SunMoonTimes.lua
-- Version = 300313
-- Information = Script to calculate sun and moon rise and set times based  on date, latitude and
--               longitude.
-- License = Creative Commons BY-NC-SA 3.0

-- copied from: https://gist.github.com/eDave56/6dfae1b62c4cf743afe0ad61e300f091
-- Functions for sunrise, sunset and twilight were converted from javascript on http://praytimes.org/
-- The parts for moonrise and moonset were converted by Stone from C which came from javascript on
-- http://mysite.verizon.net/res148h4j/javascript/script_moon_rise_set.html
-- (see Stone's post on http://rainmeter.net/forum/viewtopic.php?f=27&t=15071)
--
--[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]][][][][][][][]
--
----------------------------------------------------------------------------------------------------
--
-- Weather Meter by SilverAzide
--
-- This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 3.0 License.
--
-- Attribution: Sunset-Moonrise (v.2.1) by Mordasius
--                http://fav.me/d5ybxqr
--                https://mordasius.deviantart.com/art/Sunset-Moonrise-v-2-1-359994771
--
-- History:
-- 4.0.0 - 2018-03-17:  Revised Mordasius' Lua script to allow execution on demand for specified
--                      dates and removed skin-specific references.  Minor additional refactoring.
--                      Added code to calculate sun angle. NOTE: the sun angle calculation is NOT
--                      the same as the real "azimuth"; this calc is just the apparent angle between
--                      sunrise and sunset.
-- 5.1.0 - 2019-07-13:  Corrected Windows/Unix timestamp conversion.  Corrected sunrise/sunset time
--                      display when no sunrise or no sunset.
--
local class = require("util.class")

local SunsetMoonrise = class({})

function SunsetMoonrise:Initialize()
  --
  -- this function is called when the script measure is initialized or reloaded
  --
  dawnAngle, duskAngle = 6, 6
  DR = math.pi / 180
  K1 = 15 * math.pi * 1.0027379 / 180
end -- function Initialize

----------------------------------------------------------------------------------------------------
function SunsetMoonrise:GetSunMoonTimes(nLatitude, nLongitude, nTimeZone, nTimestamp, nShiftTz, nTimeLZero, nTimeStyle)
  --
  -- This function returns a timestamp for the sunrise time for a specific location and date.  Can
  -- be called on demand via inline Lua.
  --
  -- Where:  nLatitude    = latitude
  --         nLongitude   = longitude
  --         nTimeZone    = timezone offset for the location of interest (in hours)
  --         nTimestamp   = timestamp for location of interest (Windows timestamp)
  --         nShiftTz     = "true" to shift timestamp to the timezone of the location of interest*
  --         nTimeLZero   = 0 (no leading zeros on hour), 1 (leading zeros on hour)
  --         nTimeStyle   = 0 (12-hour clock) 1 (24-hour clock)
  --
  -- Note: The "nShiftTz" parameter is used to offset a timestamp from your location to the timezone
  --       of the location of interest, if needed.  This case happens if you use a Time measure to
  --       get your current time, but need to know what that time is in another timezone; e.g.,
  --       if you are in New York (Tz = -5) and need to calculate the current time in Los Angeles
  --       (Tz = -8).  Set this value to "false" if the timestamp is ALREADY converted to the target
  --       timezone.
  --
  local nLocalTz = (self:getTimeOffset() / 3600)

  -- set default values
  sunRiseSetTimes = { 6, 6, 6, 12, 13, 18, 18, 18, 24 }
  moonRiseSetTimes = { 0, 23.9 }
  NoSunRise, NoSunSet = False, False
  Sky = { 0, 0, 0 }
  Dec = { 0, 0, 0 }
  VHz = { 0, 0, 0 }
  RAn = { 0, 0, 0 }

  -- convert Windows timestamp (0 = 1/1/1601) to Unix/Lua timestamp (0 = 1/1/1970)
  -- nTimestamp = nTimestamp - 11644473600

  -- NOTE:  Lua os.date appears to convert timestamps to dates while adding the timezone offset of
  --        THIS machine.  In cases where you are monitoring weather in a timezone not your own,
  --        the resulting date will be incorrect.  If the current timezone is not the same as the
  --        one coming from the weather.com data, offset the timestamp by the difference.
  if nTimeZone == nLocalTz or not nShiftTz then
    tDate = os.date("!*t", nTimestamp)
  else
    tDate = os.date("!*t", nTimestamp - self:getTimeOffset() + (nTimeZone * 3600))
  end

  -- debugging
  -- print("latitude = " .. nLatitude)
  -- print("longitude = " .. nLongitude)
  -- print("twc timezone = " .. nTimeZone)
  -- print("my timezone = " .. nLocalTz)
  -- print("raw timestamp = " .. nTimestamp)
  -- print("timestamp = " .. os.date("%m/%d/%Y %I:%M:%S %p", os.time(tDate) - (os.date("*t")["isdst"] and 3600 or 0)))

  -- set time and gregorian date
  self:setDateTime(nLatitude, nLongitude, nTimeZone, tDate)

  -- sun time calculations
  self:calcSunRiseSet()
  if NoSunRise or NoSunSet then
    -- adjust times to solar noon
    sunRiseSetTimes[2] = (sunRiseSetTimes[2] - 12)
    if NoSunRise then
      sunRiseSetTimes[3] = sunRiseSetTimes[2] + 0.0001
    else
      sunRiseSetTimes[3] = (sunRiseSetTimes[2] - 0.0001)
    end
    sunRiseSetTimes[1] = 0
    sunRiseSetTimes[4] = 0
  end

  -- moon time calculations
  self:calcMoonRiseSet(nLatitude, nLongitude, jDateMoon, moonTimeOffset)

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

    nSunRise = sunRiseSetTimes[2]
    nSunSet = sunRiseSetTimes[3]
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

  -- debugging
  -- print("dawn = " .. TimeString(sunRiseSetTimes[1], nTimeLZero, nTimeStyle) .. " (" .. sunRiseSetTimes[1] .. ")")
  -- print("sunrise = " .. TimeString(sunRiseSetTimes[2], nTimeLZero, nTimeStyle) .. " (" .. sunRiseSetTimes[2] .. ")")
  -- print("sunset = " .. TimeString(sunRiseSetTimes[3], nTimeLZero, nTimeStyle) .. " (" .. sunRiseSetTimes[3] .. ")")
  -- print("twilight = " .. TimeString(sunRiseSetTimes[4], nTimeLZero, nTimeStyle) .. " (" .. sunRiseSetTimes[4] .. ")")
  -- print("moonrise = " .. TimeString(moonRiseSetTimes[1], nTimeLZero, nTimeStyle) .. " (" .. moonRiseSetTimes[1] .. ")")
  -- print("moonset = " .. TimeString(moonRiseSetTimes[2], nTimeLZero, nTimeStyle) .. " (" .. moonRiseSetTimes[2] .. ")")
  -- print("day length = " .. TimeString(nDayLength, 0, 1) .. " (" .. nDayLength .. ")")
  -- print("angle = " .. nAngle .. " deg")

  local result = {}
  result.latitude = nLatitude
  result.longitude = nLongitude
  result.twctimezone = nTimeZone
  result.mytimezone = nLocalTz
  result.rawtimestamp = nTimestamp
  result.timestamp = os.date("%m/%d/%Y %I:%M:%S %p", os.time(tDate) - (os.date("*t")["isdst"] and 3600 or 0))
  result.dawn = self:TimeTable(sunRiseSetTimes[1], nTimeStyle)
  result.sunrise = self:TimeTable(sunRiseSetTimes[2], nTimeStyle)
  result.sunset = self:TimeTable(sunRiseSetTimes[3], nTimeStyle)
  result.twilight = self:TimeTable(sunRiseSetTimes[4], nTimeStyle)
  result.moonrise = self:TimeTable(moonRiseSetTimes[1], nTimeStyle)
  result.moonset = self:TimeTable(moonRiseSetTimes[2], nTimeStyle)
  result.daylength = self:TimeTable(nDayLength, 1)
  result.angle = nAngle

  return result
end -- function GetSunMoonTimes

----------------------------------------------------------------------------------------------------

function SunsetMoonrise:setDateTime(xlat, ylong, tmzone, today)
  lat = xlat or 0
  long = ylong or 0
  timeOffset = tmzone

  iTimeNow = ((today.hour * 3600) + (today.min * 60) + today.sec) / 3600
  Gday = today.day
  Gmonth = today.month
  Gyear = today.year

  ----------- for testing ------
  -- Gday = 12
  -- Gmonth = 4
  -- Gyear = 2013

  moonTimeOffset = -60 * timeOffset
  jDateSun = self:julian(Gyear, Gmonth, Gday) - (long / (15 * 24))
  jDateMoon = self:julian(Gyear, Gmonth, Gday)
end -- function setDateTime

------------------------------------ [ sun time calculations ] -------------------------------------

function SunsetMoonrise:midDay(Ftime)
  local eqt = self:sunPosition(jDateSun + Ftime, 0)
  local noon = DMath.fixHour(12 - eqt)
  return noon
end -- function midDay

function SunsetMoonrise:sunAngleTime(angle, Ftime, direction)
  --
  -- time at which sun reaches a specific angle below horizon
  --
  local decl = self:sunPosition(jDateSun + Ftime, 1)
  local noon = self:midDay(Ftime)
  local t = (-DMath.Msin(angle) - DMath.Msin(decl) * DMath.Msin(lat)) / (DMath.Mcos(decl) * DMath.Mcos(lat))

  if t > 1 then
    -- the sun doesn't rise today
    NoSunRise = 1
    return noon
  elseif t < -1 then
    -- the sun doesn't set today
    NoSunSet = 1
    return noon
  end

  t = 1 / 15 * DMath.arccos(t)
  return noon + ((direction == "CCW") and -t or t)
end -- function sunAngleTime

--function asrTime(factor, Ftime)
--  --
--  -- compute asr time
--  --
--  local decl = sunPosition(jDateSun + Ftime, 1)
--  local angle = -DMath.arccot(factor + DMath.Mtan(math.abs(lat - decl)))
--  return sunAngleTime(angle, Ftime, "ASR")
--end

function SunsetMoonrise:sunPosition(jd, Declination)
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

function SunsetMoonrise:julian(year, month, day)
  --
  -- convert Gregorian date to Julian day
  --
  if month <= 2 then
    year = year - 1
    month = month + 12
  end
  local A = math.floor(year / 100)
  local B = 2 - A + math.floor(A / 4)
  JD = math.floor(365.25 * (year + 4716)) + math.floor(30.6001 * (month + 1)) + day + B - 1524.5
  return JD
end -- function julian

function SunsetMoonrise:setTimes(sunRiseSetTimes)
  Ftimes = self:dayPortion(sunRiseSetTimes)
  local dawn = self:sunAngleTime(dawnAngle, Ftimes[2], "CCW")
  local sunrise = self:sunAngleTime(self:riseSetAngle(), Ftimes[3], "CCW")
  local sunset = self:sunAngleTime(self:riseSetAngle(), Ftimes[8], "CW")
  local dusk = self:sunAngleTime(duskAngle, Ftimes[7], "CW")
  return { dawn, sunrise, sunset, dusk }
end -- function setTimes

function SunsetMoonrise:calcSunRiseSet()
  sunRiseSetTimes = self:setTimes(sunRiseSetTimes)
  return self:adjustTimes(sunRiseSetTimes)
end -- function calcSunRiseSet

function SunsetMoonrise:adjustTimes(sunRiseSetTimes)
  for i = 1, #sunRiseSetTimes do
    sunRiseSetTimes[i] = sunRiseSetTimes[i] + (timeOffset - long / 15)
  end
  sunRiseSetTimes = self:adjustHighLats(sunRiseSetTimes)
  return sunRiseSetTimes
end -- function adjustTimes

function SunsetMoonrise:riseSetAngle()
  --
  -- sun angle for sunset/sunrise
  --
  -- local angle = 0.0347 * math.sqrt( elv )
  local angle = 0.0347
  return 0.833 + angle
end -- function riseSetAngle

function SunsetMoonrise:adjustHighLats(sunRiseSetTimes)
  --
  -- adjust times for higher latitudes
  --
  local nightTime = self:timeDiff(sunRiseSetTimes[3], sunRiseSetTimes[2])
  sunRiseSetTimes[1] = self:refineHLtimes(sunRiseSetTimes[1], sunRiseSetTimes[2], dawnAngle, nightTime, "CCW")
  return sunRiseSetTimes
end -- function adjustHighLats

function SunsetMoonrise:refineHLtimes(Ftime, base, angle, night, direction)
  --
  -- refine time for higher latitudes
  --
  portion = night / 2
  FtimeDiff = (direction == "CCW") and self:timeDiff(Ftime, base) or self:timeDiff(base, Ftime)
  if not ((Ftime * 2) > 2) or (FtimeDiff > portion) then
    Ftime = base + ((direction == "CCW") and -portion or portion)
  end
  return Ftime
end -- function refineHLtimes

function SunsetMoonrise:dayPortion(sunRiseSetTimes)
  --
  --  convert hours to day portions
  --
  for i = 1, #sunRiseSetTimes do
    sunRiseSetTimes[i] = sunRiseSetTimes[i] / 24
  end
  return sunRiseSetTimes
end -- function dayPortion

function SunsetMoonrise:timeDiff(time1, time2)
  --
  --  difference between two times
  --
  return DMath.fixHour(time2 - time1)
end -- function timeDiff

----------------------------------- [ moon time calaculations ] ------------------------------------

function SunsetMoonrise:sgn(x)
  --
  -- returns value for sign of argument
  --
  local rv
  if x > 0 then
    rv = 1
  else
    if x < 0 then
      rv = -1
    else
      rv = 0
    end
  end
  return rv
end -- function sgn(x)

function SunsetMoonrise:moon(jd)
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
  Sky[1] = h + math.atan(s / math.sqrt(1 - s * s))

  s = v / math.sqrt(u) -- declination ...
  Sky[2] = math.atan(s / math.sqrt(1 - s * s))

  Sky[3] = 60.40974 * math.sqrt(u) -- and parallax
end -- function moon

function SunsetMoonrise:test_moon(k, t0, lat, plx)
  --
  -- test an hour for an event
  --
  ha = { 0, 0, 0 }
  local a, b, c, d, e, s, z
  local hr, _min, _time
  local az, hz, nz, dz
  if RAn[3] < RAn[1] then
    RAn[3] = RAn[3] + 2 * math.pi
  end

  ha[1] = t0 - RAn[1] + (k * K1)
  ha[3] = t0 - RAn[3] + (k * K1) + K1
  ha[2] = (ha[3] + ha[1]) / 2 -- hour angle at half hour
  Dec[2] = (Dec[3] + Dec[1]) / 2 -- declination at half hour
  s = math.sin(DR * lat)
  c = math.cos(DR * lat)

  -- refraction + sun semidiameter at horizon + parallax correction
  z = math.cos(DR * (90.567 - 41.685 / plx))

  if k <= 0 then
    -- first call of function
    VHz[1] = s * math.sin(Dec[1]) + c * math.cos(Dec[1]) * math.cos(ha[1]) - z
  end
  VHz[3] = s * math.sin(Dec[3]) + c * math.cos(Dec[3]) * math.cos(ha[3]) - z
  if self:sgn(VHz[1]) == self:sgn(VHz[3]) then
    -- no event this hour
    return VHz[3]
  end
  VHz[2] = s * math.sin(Dec[2]) + c * math.cos(Dec[2]) * math.cos(ha[2]) - z
  a = 2 * VHz[3] - 4 * VHz[2] + 2 * VHz[1]
  b = 4 * VHz[2] - 3 * VHz[1] - VHz[3]
  d = b * b - 4 * a * VHz[1]

  if d < 0 then
    -- no event this hour
    return VHz[3]
  end

  d = math.sqrt(d)
  e = (-b + d) / (2 * a)
  if (e > 1) or (e < 0) then
    e = (-b - d) / (2 * a)
  end
  _time = k + e + 1 / 120 -- time of an event + round up

  if (VHz[1] < 0) and (VHz[3] > 0) then
    moonRiseSetTimes[1] = _time
  end

  if (VHz[1] > 0) and (VHz[3] < 0) then
    moonRiseSetTimes[2] = _time
  end

  return VHz[3]
end -- function testmoon

function SunsetMoonrise:lst(lon, jd, z)
  --
  -- Local Sidereal Time for zone
  --
  s = 24110.5 + 8640184.812999999 * jd / 36525 + 86636.6 * z + 86400 * lon
  s = s / 86400
  s = s - math.floor(s)
  return s * 360 * DR
end -- function lst

function SunsetMoonrise:interpolate(f0, f1, f2, p)
  --
  -- 3-point interpolation
  --
  a = f1 - f0
  b = f2 - f1 - a
  f = f0 + p * (2 * a + b * (2 * p - 1))
  return f
end -- function interpolate

function SunsetMoonrise:calcMoonRiseSet(lat, lon, jDateMoon, moonTimeOffset)
  --
  -- calculate moonrise and moonset times
  --
  local i, j, k
  local zone = moonTimeOffset / 60
  local ph
  jd = jDateMoon - 2451545 -- Julian day relative to Jan 1.5, 2000
  local mp = {}
  lon_local = lon

  for i = 1, 3 do
    mp[i] = {}
    for j = 1, 3 do
      mp[i][j] = 0
    end
  end

  lon_local = lon / 360
  tz = zone / 24
  t0 = self:lst(lon_local, jd, tz) -- local sidereal time
  jd = jd + tz -- get moon position at start of day
  for k = 1, 3 do
    self:moon(jd)
    mp[k][1] = Sky[1]
    mp[k][2] = Sky[2]
    mp[k][3] = Sky[3]
    jd = jd + 0.5
  end

  if mp[2][1] <= mp[1][1] then
    mp[2][1] = mp[2][1] + 2 * math.pi
  end
  if mp[3][1] <= mp[2][1] then
    mp[3][1] = mp[3][1] + 2 * math.pi
  end
  RAn[1] = mp[1][1]
  Dec[1] = mp[1][2]

  -- check each hour of this day
  for k = 0, 23 do
    ph = (k + 1) / 24
    RAn[3] = self:interpolate(mp[1][1], mp[2][1], mp[3][1], ph)
    Dec[3] = self:interpolate(mp[1][2], mp[2][2], mp[3][2], ph)
    VHz[3] = self:test_moon(k, t0, lat, mp[2][3])
    RAn[1] = RAn[3] -- advance to next hour
    Dec[1] = Dec[3]
    VHz[1] = VHz[3]
  end
end -- function calcMoonRiseSet

----------------------------------------------------------------------------------------------------
------------------------------------- [ other odds and sods ] --------------------------------------

function SunsetMoonrise:getTimeOffset()
  return (os.time() - os.time(os.date("!*t")) + (os.date("*t")["isdst"] and 3600 or 0))
end

function SunsetMoonrise:twoDigitsFormat(num)
  --
  -- add a leading 0
  --
  if num < 10 then
    return "0" .. tostring(num)
  else
    return tostring(num)
  end
end -- function twoDigitsFormat

function SunsetMoonrise:TimeString(Ftime, nTimeLZero, nTimeStyle)
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
      return hours .. ":" .. self:twoDigitsFormat(minutes) .. AmPm
    else
      -- leading zeros
      return self:twoDigitsFormat(hours) .. ":" .. self:twoDigitsFormat(minutes) .. AmPm
    end
  else
    -- 24-hour clock
    if nTimeLZero == 0 then
      -- no leading zeros
      return hours .. ":" .. self:twoDigitsFormat(minutes)
    else
      -- leading zeros
      return self:twoDigitsFormat(hours) .. ":" .. self:twoDigitsFormat(minutes)
    end
  end
end -- function TimeString

function SunsetMoonrise:TimeString2(Ftime, nTimeLZero)
  --
  -- put time in string format
  --
  -- Where:  Ftime      = floating point time (hours with fractional minutes)
  --         nTimeLZero = 0 (no leading zeros on hour), 1 (leading zeros on hour)
  --         nTimeStyle = 0 (12-hour clock) 1 (24-hour clock)
  --
  local nTimeStyle = Ftime.AMPM ~= nil
  local hours = Ftime.hours
  local minutes = Ftime.minutes

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
      return hours .. ":" .. self:twoDigitsFormat(minutes) .. AmPm
    else
      -- leading zeros
      return self:twoDigitsFormat(hours) .. ":" .. self:twoDigitsFormat(minutes) .. AmPm
    end
  else
    -- 24-hour clock
    if nTimeLZero == 0 then
      -- no leading zeros
      return hours .. ":" .. self:twoDigitsFormat(minutes)
    else
      -- leading zeros
      return self:twoDigitsFormat(hours) .. ":" .. self:twoDigitsFormat(minutes)
    end
  end
end -- function TimeString

function SunsetMoonrise:TimeTable(Ftime, nTimeStyle)
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

---------------------------------------- [ math functions ] ----------------------------------------

DMath = {
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
    -- atan2 is deprecated
    return DMath.rtd(math.atan(y, x))
  end,
  fixAngle = function(a)
    return DMath.fix(a, 360)
  end,
  fixHour = function(a)
    return DMath.fix(a, 24)
  end,
}

local LocalSunsetMoonrise = SunsetMoonrise()
LocalSunsetMoonrise:Initialize()
return LocalSunsetMoonrise
