-- title:  race
-- author: halbu
-- desc:   out run, but bad
-- script: lua

sw, sh = 240, 136

trackWidth = 0.8
trueCentre = 0.5

chevronCounter = 0
chevronLength = 15
chevronWidth = 0.075 -- width of barrier thing on either side

stripeCounter = 0
stripeLength = 40
stripeWidth = 0.02

speed = 0.0
topSpeed = 3.1
curve = 0
curveDir = 3
curveChangeSpeed = 0.005
maxCurve = 0.6
grassColor, roadColor = 3, 2
car_x = 0.5
xv = 0
dir = 0
turnSpeed = 0.0005
maxTurnSpeed = 0.0125
horizon = sh/2

-- aliases as these improve performance somehow?
sin = math.sin
flr = math.floor

function TIC()
 if speed < topSpeed then speed = speed + 0.01 end
 cls()
 cfloor = flr(chevronCounter)
 sfloor = flr(stripeCounter)
 
 updateCurve()
 carDrift()
 drawTrack()
 handleInput()
 
 spr(dir, car_x * sw - 16, 100, 7, 2, 0, 0, 2, 2)

 chevronCounter=chevronCounter+speed
 if chevronCounter>chevronLength then chevronCounter=chevronCounter-chevronLength end

 stripeCounter=stripeCounter+speed
 if stripeCounter>stripeLength then stripeCounter=stripeCounter-stripeLength end
end

function carDrift()
 car_x = car_x - ((curve/50) * speed) / topSpeed
end

function updateCurve()
 if math.random(1, 30) == 1 then
  curveDir = math.random(1, 3)
 end

 if curveDir == 1 then
  curve = curve - curveChangeSpeed
 elseif curveDir == 2 then
  curve = curve + curveChangeSpeed
 end

 if curve < -maxCurve then curve = -maxCurve end
 if curve > maxCurve then curve = maxCurve end
end

function handleInput()
 xv = xv * 0.96
	dir = 0
 if btn(2) then
  xv = xv - turnSpeed
 end
 if btn(3) then
  xv = xv + turnSpeed
  dir = 4
 end
 if xv > maxTurnSpeed then xv = maxTurnSpeed end
 if xv < -maxTurnSpeed then xv = -maxTurnSpeed end
 car_x = car_x + xv
 if xv > 0.004 then dir = 4 end
 if xv < -0.004 then dir = 2 end
end

function drawTrack()
 rect(0, horizon, sw, horizon, grassColor)
	
 for j = horizon, sh do
  chevronColor, stripeColor = 1, 2
  if (j - cfloor) % chevronLength < 6 then chevronColor = 15 end
  if (j - sfloor) % stripeLength < 14 then stripeColor = 15 end
  
  perspSqz = (j - horizon) / horizon -- perspective squeeze
  curveAmount = (0.5 - (j - horizon) / (sh)) * 1.8 -- curvature squeeze

  centre = trueCentre + (curve * curveAmount ^ 2)

  trackLeft = centre - (trackWidth / 2) * perspSqz
  trackRight = centre + (trackWidth / 2) * perspSqz
  chevronLeft = trackLeft - chevronWidth * perspSqz
  chevronRight = trackRight + chevronWidth * perspSqz

  stripeLeft = centre - (stripeWidth / 2) * perspSqz
  stripeRight = centre + (stripeWidth / 2) * perspSqz

  for i = 0, sw do
   if i >= (stripeLeft * sw) and i <= (stripeRight * sw) then
    pix(i, j, stripeColor)
   elseif i >= (trackLeft * sw) and i <= (trackRight * sw) then
    pix(i, j, roadColor)
   elseif i > (chevronLeft * sw) and (i < trackLeft * sw) then
    pix(i, j, chevronColor)
   elseif i > (trackRight * sw) and (i < chevronRight * sw) then
    pix(i, j, chevronColor)
   end
  end
		
  print(flr(speed * 36)..'mph', 2, 2, 15, true, 1, false)
 end
end