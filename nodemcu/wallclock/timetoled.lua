-- global varialble
buffer = ws2812.newBuffer(24, 3)
buffer:fill(0, 0, 0)

timezone_corr = 1

-- leds 1 - 12 are assigned for 5 minute indicators
-- minute = 0..59
function Min2Led(minute)
--  return math.floor(minute / 5) + 1
  return math.floor( (minute / 5) + 0.5 )
end

-- leds 13 - 24 are assigned for hour indicators
-- note led 24 is the 1'oclock and led 13 is 12'oclock
-- hour = 0..23
function Hour2Led(hour)
  -- convert the 24h clock to a 12h clock (1..12)
  hour = (hour % 12)
  if ( hour == 0 ) then
    hour = 12
  end

  return 24 - (hour - 1)
end

-- Sets the minute leds
function SetMinute(minute)
  minuteLed = Min2Led(minute)

  -- when the first led needs to be enabled
  for i = 1, 12, 1 
  do
    buffer:set(i, 0, 0, 0) 
  end

  -- Enable all the minute leds upto the minuteLed
  for i = 1,minuteLed,1 
  do
    -- Color all 15 minutes indicators red and the remainder green
    if ( ((i - 3) % 3) == 0 ) then
      buffer:set(i, 0, 25, 0) 
    else
      buffer:set(i, 25, 0, 0) 
    end    
  end
end

-- Sets the hour leds
function SetHour(hour)
  hourLed = Hour2Led(hour)

  -- Clear all leds when the first hour led needs to be enabled
  for i = 13, 24, 1 
  do
    buffer:set(i, 0, 0, 0) 
  end

  -- Enable all the hour leds upto the hourLed
  for i = 24,hourLed,-1 
  do
    -- Color all the quarters leds red and the remainder green
    if ( ((i - 13) % 3) == 0 ) then
      buffer:set(i, 0, 25, 0) 
    else
      buffer:set(i, 25, 0, 0) 
    end    
  end
end

-- Updates the local time and sets the minute and hour leds accordingly
function ShowTime()
  time = rtctime.epoch2cal(rtctime.get())

  minute = time['min']
  hour   = time['hour'] + timezone_corr

  SetMinute(minute)
  SetHour(hour)

  print(hour)
  print(minute)
  print("--")

  -- Update the LED strip
  ws2812.write(buffer)
end

-- Connect to the ntp server
sntp.sync('0.nl.pool.ntp.org')

-- Initialise the ledstrip buffer
ws2812.init()

-- Set an alarm to wakeup every minute
tmr.alarm(0, 60000, tmr.ALARM_AUTO, ShowTime)

