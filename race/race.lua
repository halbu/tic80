-- title:  race
-- author: halbu
-- desc:   out run, but bad
-- script: lua

sw, sh = 240, 136

trackWidth = 0.8
trueCentre = 0.5

chevronCounter, chevronLength, chevronWidth = 0, 15, 0.075
stripeCounter, stripeLength, stripeWidth = 0, 40, 0.02

speed = 0.0
topSpeed = 3.1
curve = 0
curveDir = 3
curveChangeSpeed = 0.005
maxCurve = 0.6
grassColor, roadColor = 3, 2
carX = 0.5
xv = 0
dir = 0
turnSpeed = 0.0005
maxTurnSpeed = 0.0125
horizon = sh/2

-- aliases as these improve performance somehow?
sin, flr = math.sin, math.floor

function TIC()
 if speed < topSpeed then speed = speed + 0.01 end
 cls()
 cfloor = flr(chevronCounter)
 sfloor = flr(stripeCounter)
 
 updateCurve()
 carDrift()
 drawTrack()
 handleInput()
 
 spr(dir, carX * sw - 16, 100, 7, 2, 0, 0, 2, 2)

 chevronCounter = chevronCounter + speed
 if chevronCounter > chevronLength then
  chevronCounter = chevronCounter - chevronLength
 end

 stripeCounter = stripeCounter + speed
 if stripeCounter > stripeLength then
  stripeCounter = stripeCounter - stripeLength
 end
end

function carDrift()
 carX = carX - ((curve/50) * speed) / topSpeed
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
 carX = carX + xv
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
-- <TILES>
-- 000:7777777777777777777777777777777777777777777777777776666677610000
-- 001:7777777777777777777777777777777777777777777777776666677700000677
-- 002:7777777777777777777777777777777777777777777777777776666677061100
-- 003:7777777777777777777777777777777777777777777777776666667700000667
-- 004:7777777777777777777777777777777777777777777777777766666676610000
-- 005:7777777777777777777777777777777777777777777777776666677700006077
-- 006:7777755577755555775555557755555577755550775555557555555575055555
-- 007:5577777755557777555557775555557755555557555555575555555755555557
-- 016:761001007610000066666666600ccccc66666666600000006666666670000077
-- 017:000000670000006766666666ccccc00666666666000000066666666677000007
-- 018:700610010006100066666666666600cc66666666660000000666666600000077
-- 019:000000660000006666666666ccccc00666666666000000666666666777000007
-- 020:661001006610000066666666600ccccc66666666660000007666666670000077
-- 021:000060070000600066666666cc00666666666666000000666666666077000000
-- 022:7555555577555555777555557777770077777770777777707777777077777777
-- 023:5555557755555777555577770777777707777777077777770777777777777777
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- </PALETTE>

