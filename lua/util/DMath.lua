---------------------------------------- [ math functions ] ----------------------------------------

DMath = {
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

return DMath
