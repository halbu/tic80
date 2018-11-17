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
grassColor, roadColor = 12, 3
carX = 0.5
xv = 0
dir = 0
turnSpeed = 0.0005
maxTurnSpeed = 0.0125
horizon = sh / 2
horizonXOffset = 0

bollards = {}
dist = 0
timer = 3659

-- aliases as these improve performance somehow?
sin, flr = math.sin, math.floor
twoPi = 2 * math.pi

function TIC()
 cls(11)
 cfloor = flr(chevronCounter)
 sfloor = flr(stripeCounter)
 
 carHandling()
 updateTrack()
 drawTrack()
 drawGui()
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

 preDist = dist
 dist = dist + (speed / 2)
 if (preDist<60 and dist>60) or (preDist<80 and dist>80) or (preDist<100 and dist>100) then
  bollard = {side=0, y=horizon}
  table.insert(bollards, bollard)
 end
 if dist > 100 then dist = dist - 100 end

 timer = timer - 1
end

function carHandling()
 carX = carX - ((curve/50) * speed) / topSpeed

 if (carX <= trueCentre - (trackWidth / 2)) or (carX >= trueCentre + (trackWidth / 2)) then
  speed = speed * 0.93
 end
end

function updateTrack()
 if math.random(1, 30) == 1 then
  curveDir = math.random(1, 3)
 end

 if curveDir == 1 then
  curve = curve - (curveChangeSpeed * (speed / topSpeed))
 elseif curveDir == 2 then
  curve = curve + (curveChangeSpeed * (speed / topSpeed))
 end

 if curve < -maxCurve then curve = -maxCurve end
 if curve > maxCurve then curve = maxCurve end

 horizonXOffset = horizonXOffset - ((curve / 6) * (speed / topSpeed)) -- scroll horizon
 for k,v in pairs(bollards) do
  v.y = v.y + (speed / 2)
 end
end

function handleInput()
 xv = xv * 0.96
 dir = 0
 if btn(0) then
  if speed < topSpeed then speed = speed + 0.01 end
 elseif btn(1) then
  speed = speed * 0.97
 else speed = speed * 0.99 end
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
 rect(0, horizon, sw, sh - horizon, grassColor)
	rect(0, horizon - 2, sw, 2, 8)
	rect(0, horizon - 4, sw, 2, 9)
	rect(0, horizon - 6, sw, 2, 10)
	
 spr(8, 20 + horizonXOffset, horizon - 32, 7, 1, 0, 0, 4, 4)
 spr(8, 150 + horizonXOffset, horizon - 64, 7, 2, 1, 0, 4, 4)
	
 for j = horizon, sh do
  chevronColor, stripeColor = 1, roadColor
  if (j - cfloor) % chevronLength < 6 then chevronColor = 15 end
  if (j - sfloor) % stripeLength < 14 then stripeColor = 15 end
  
  perspSqz = (j - horizon + 2) / (sh - horizon) -- perspective squeeze
  curveAmount = (0.5 - (j - horizon) / (sh)) * 1.8 -- curvature squeeze

  centre = trueCentre + (curve * curveAmount ^ 2)

  trackLeft =    centre - (trackWidth / 2) * perspSqz
  trackRight =   centre + (trackWidth / 2) * perspSqz
  chevronLeft =  trackLeft - chevronWidth * perspSqz
  chevronRight = trackRight + chevronWidth * perspSqz
  stripeLeft =   centre - (stripeWidth / 2) * perspSqz
  stripeRight =  centre + (stripeWidth / 2) * perspSqz

  line(trackLeft * sw, j, trackRight * sw, j, roadColor)
  line(stripeLeft * sw, j, stripeRight * sw, j, stripeColor)
  line(chevronLeft * sw, j, trackLeft * sw, j, chevronColor)
  line(trackRight * sw, j, chevronRight * sw, j, chevronColor)

  brkPt1 = (horizon + ((sh-horizon)/10)*2)
  brkPt2 = (horizon + ((sh-horizon)/10)*4)
  brkPt3 = (horizon + ((sh-horizon)/10)*6)
  brkPt4 = (horizon + ((sh-horizon)/10)*8)

  for k, v in pairs(bollards) do
   ground = sh - horizon
   if flr(v.y) == j then
    bollardLeft = chevronLeft - (0.1 * perspSqz)
    bollardRight = chevronRight + (0.1 * perspSqz)
    if v.y > brkPt4 then
     drawBollardPair(bollardLeft, bollardRight, v.y, 3)
    elseif v.y > brkPt3 then
      drawBollardPair(bollardLeft, bollardRight, v.y, 2.5)
    elseif v.y > brkPt2 then
     drawBollardPair(bollardLeft, bollardRight, v.y, 2)
    elseif v.y > brkPt1 then
     drawBollardPair(bollardLeft, bollardRight, v.y, 1.5)
    elseif v.y > horizon then
     drawBollardPair(bollardLeft, bollardRight, v.y, 1)
    end
   end
  end
 end
end

function drawBollardPair(l, r, y, s)
 drawBollard(l, y, s)
 drawBollard(r, y, s)
end

function drawBollard(x, y, s)
 rect(x * sw, y - s * 4, s, s * 4, 15)
 rect(x * sw, y - s * 2, s, s, 0)
 rect(x * sw, y - s * 4, s, s, 8)
end

function drawGui()
 print(flr(speed * 36)..'mph', 2, 2, 15, true, 1, false)
 tw = print(flr(timer/60), 100, -60, 14, true, 2, false)
 print(flr(timer/60), sw / 2 - (tw / 2) - 1, 2, 14, true, 2, false)
 print(flr(timer/60), sw / 2 - (tw / 2), 3, 15, true, 2, false)

 cx, cy, cr = sw - 20, 20, 18
 circb(cx, cy, cr, 15)

 speedometerStartAngle = 135

 -- speedometer outline. i'd cache these values if i wasn't lazy
 for i = 0, 300, 30 do
  x1 = math.cos((speedometerStartAngle - 15 + i)/360 * twoPi) * 11 + 0.5
  x2 = math.cos((speedometerStartAngle - 15 + i)/360 * twoPi) * (cr - 3) + 0.5
  y1 = math.sin((speedometerStartAngle - 15 + i)/360 * twoPi) * 11 + 0.5
  y2 = math.sin((speedometerStartAngle - 15 + i)/360 * twoPi) * (cr - 3) + 0.5
  line(cx + x1, cy + y1, cx + x2, cy + y2, 7)
 end

 -- speedometer
 speedoLength = 13
 speedoAngle = speedometerStartAngle + (speed * 90)
 dx = math.cos(speedoAngle/360 * twoPi) * speedoLength
 dy = math.sin(speedoAngle/360 * twoPi) * speedoLength
 circ(cx, cy, 2, 14)
 circ(cx, cy, 1, 15)
 line(cx, cy, cx + dx, cy + dy, 15)
 pix(cx + dx, cy + dy, 8)
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
-- 008:7777777777777777777777777777777777777777777777777777777777777777
-- 009:7777777777777777777777777777777777777777777777777777777777777777
-- 010:7777777777777777777777777777777777777777777777777777777777777777
-- 011:7777777777777777777777777777777777777777777777777777777777777777
-- 016:761001007610000066666666600eeeee66666666600000006666666670000077
-- 017:000000670000006766666666eeeee00666666666000000066666666677000007
-- 018:700610010006100066666666666600ee66666666660000000666666600000077
-- 019:000000660000006666666666eeeee00666666666000000666666666777000007
-- 020:661001006610000066666666600eeeee66666666660000007666666670000077
-- 021:000060070000600066666666ee00666666666666000000666666666077000000
-- 022:7555555577555555777555557777770077777770777777707777777077777777
-- 023:5555557755555777555577770777777707777777077777770777777777777777
-- 024:7777777777777777777777777777777777777777777777777777777777777777
-- 025:7777777777777777777777777777777777777777777777777777777777777777
-- 026:7777777777777777777777777777777777777777777777777777777777777777
-- 027:7777777777777777777777777777777777777777777777777777777777777777
-- 040:7777777777777777777777777777777777777777777777777777777777777777
-- 041:7777777777777777777777777777777777777777777777777777777777777777
-- 042:7777777777777777777777777777777777777777777777777777777777777777
-- 043:7777777777777777777777777777777777777777777777777777777777777777
-- 056:7777777777777777777777777777777777777777777ddddd7ddddddddddddddd
-- 057:777777777777777777777777777777777ddddd77dddddddddddddddddddddddd
-- 058:7777777777777777777777777777777777777777dddddd77dddddddddddddddd
-- 059:777777777777777777777777777777777777777777777777dd777777dddddddd
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:140c1c44243430346d4e4a4e854c30346524d04648757161a51818a114616918a524246d0430000c3808aeaaaedeeed6
-- </PALETTE>

