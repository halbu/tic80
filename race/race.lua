-- title:  race
-- author: halbu
-- desc:   out run, but bad
-- script: lua

sw, sh = 240, 136
cx, cy, cr = sw - 20, 20, 18 -- speedometer circle x / y / radius

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
trees = {}
dist = 0
totalDist = 0
timer = 3659

-- aliases as these improve performance somehow?
sin, flr = math.sin, math.floor
twoPi = 2 * math.pi
menu = 1

function TIC()
 if menu == 1 then
  drawMenu()
  if btn(4) then menu = 0 end
  return
 end

 -- engine hum
 pitch = (speed / topSpeed) * 24
 wbl = math.random(0, 1)
 if math.random(1, 2) == 1 then wbl = -wbl end
 sfx(0, flr(pitch + wbl), -1, 0, 8, 2)

 -- tyre screech
 if math.abs(xv) > (maxTurnSpeed * 0.875) and (speed / topSpeed) > 0.8 then
	 swbl = math.random(0, 2)
	 if math.random(1, 2) == 1 then swbl = -swbl end
  sfx(1, 60 + swbl, 2, 1, 8, 2)
 end
	
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

 pDist = dist
 dist = dist + (speed / 2)
 totalDist = totalDist + (speed / 2) -- why are there 3 different distance variables
 if (pDist < 60 and dist > 60) or (pDist < 80 and dist > 80) or (pDist < 100 and dist > 100) then
  table.insert(bollards, {y=horizon})
 end
 
 if math.random() >= 0.98 then
  if math.random() < (speed/topSpeed) then
   treeSide = math.random(0, 1)
   table.insert(trees, {side=treeSide, y=horizon})
  end
 end

 filterTableByObjectYValue(bollards, sh + 40)
 filterTableByObjectYValue(trees, sh + 40)

 if dist > 100 then dist = dist - 100 end

 timer = timer - 1
end

function drawMenu()
 cls(11)
 tx = sw / 2 - 48
 ty = 20
 spr(160, tx,      ty,      7, 1, 0, 0, 4, 4)
 spr(164, tx + 32, ty,      7, 1, 0, 0, 4, 4)
 spr(168, tx + 64, ty,      7, 1, 0, 0, 4, 4)
 spr(224, tx,      ty + 32, 7, 1, 0, 0, 2, 2)
 spr(226, tx + 16, ty + 32, 7, 1, 0, 0, 2, 2)
 spr(228, tx + 32, ty + 32, 7, 1, 0, 0, 2, 2)
 spr(230, tx + 48, ty + 32, 7, 1, 0, 0, 2, 2)
 spr(232, tx + 64, ty + 32, 7, 1, 0, 0, 2, 2)
 spr(234, tx + 80, ty + 32, 7, 1, 0, 0, 2, 2)
 drawTextCentredAtPoint("PRESS Z!", sw / 2 - 1, 90 - 1, 9, 2, false)
 drawTextCentredAtPoint("PRESS Z!", sw / 2, 90, 15, 2, false)
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
 for k,v in pairs(trees) do
  v.y = v.y + (speed / 2)
 end
end

function handleInput()
 xv = xv * 0.96
 dir = 0
 if btn(0) or btn(4) then
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
  chevronColor, stripeColor = 11, roadColor
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

  brkPt1 = (horizon + ((sh-horizon) / 10) * 1.5)
  brkPt2 = (horizon + ((sh-horizon) / 10) * 3)
  brkPt3 = (horizon + ((sh-horizon) / 10) * 5)
  brkPt4 = (horizon + ((sh-horizon) / 10) * 7)

  for k, v in pairs(bollards) do
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

  for k, v in pairs(trees) do
   if flr(v.y) == j then
    treeX = chevronLeft - (0.075 * perspSqz)
    if v.side == 1 then treeX = chevronRight + (0.075 * perspSqz) end
    if v.y > brkPt4 then
     spr(14, treeX * sw - 8, v.y - 32, 7, 2, 0, 0, 2, 2)
    elseif v.y > brkPt3 then
     spr(14, treeX * sw - 8, v.y - 32, 7, 2, 0, 0, 2, 2)
    elseif v.y > brkPt2 then
     spr(12, treeX * sw - 8, v.y - 32, 7, 2, 0, 0, 2, 2)
    elseif v.y > brkPt1 then
     spr(7, treeX * sw - 4, v.y - 16, 7, 2, 0, 0, 1, 1)
    elseif v.y > horizon then
     spr(6, treeX * sw - 4, v.y - 16, 7, 2, 0, 0, 1, 1)
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

function drawTextCentredAtPoint(str, x, y, color, scale, smallFont)
 tw = print(str, x, -10, color, false, scale, smallFont)
 print(str, x - tw / 2, y, color, false, scale, smallFont)
end

function drawGui()
 drawTextCentredAtPoint(flr(timer/60), sw / 2 - 1, 2, 14, 2, false)
 drawTextCentredAtPoint(flr(timer/60), sw / 2, 2, 15, 2, false)
 miles = totalDist / 1000
 displayDist = tonumber(string.format("%.1f", miles)) 

 print("DISTANCE", 2, 2, 15, false, 1, true)
 print(displayDist.." mi", 2, 9, 15, false, 1, false)

 circb(cx, cy, cr, 15)
 drawTextCentredAtPoint(flr(speed * 36)..'mph', cx, cy+cr+5, 15, 1, false)

 speedometerStartAngle = 135

 -- speedometer outline. i'd cache these values if i wasn't lazy
 for i = 0, 300, 30 do
  x1 = math.cos((speedometerStartAngle - 15 + i) / 360 * twoPi) * 11 + 0.5
  x2 = math.cos((speedometerStartAngle - 15 + i) / 360 * twoPi) * (cr - 3) + 0.5
  y1 = math.sin((speedometerStartAngle - 15 + i) / 360 * twoPi) * 11 + 0.5
  y2 = math.sin((speedometerStartAngle - 15 + i) / 360 * twoPi) * (cr - 3) + 0.5
  line(cx + x1, cy + y1, cx + x2, cy + y2, 7)
 end

 -- speedometer needle
 speedoLength = 13
 speedoAngle = speedometerStartAngle + (speed * 90)
 dx = math.cos(speedoAngle/360 * twoPi) * speedoLength
 dy = math.sin(speedoAngle/360 * twoPi) * speedoLength
 circ(cx, cy, 2, 14)
 circ(cx, cy, 1, 15)
 line(cx, cy, cx + dx, cy + dy, 15)
 pix(cx + dx, cy + dy, 8)
end

function filterTableByObjectYValue(tbl, maxY)
 local removeTable, counter = {}, 1
 for k, v in pairs(tbl) do
  if v.y > sh + 30 then
   table.insert(removeTable, counter)
  end
  counter = counter + 1
 end
 for k, v in pairs(removeTable) do table.remove(tbl, v) end
end
-- <TILES>
-- 000:7777777777777777777777777777777777777777777777777776666677630000
-- 001:7777777777777777777777777777777777777777777777776666677700000677
-- 002:7777777777777777777777777777777777777777777777777776666677063300
-- 003:7777777777777777777777777777777777777777777777776666667700000667
-- 004:7777777777777777777777777777777777777777777777777766666676630000
-- 005:7777777777777777777777777777777777777777777777776666677700006077
-- 006:7777777777777777777777777775577777755777775555777755557777744777
-- 007:7775577777755777775555777755557777555577755555577555555777744777
-- 008:7777777777777777777777777777777777777777777777777777777777777777
-- 009:7777777777777777777777777777777777777777777777777777777777777777
-- 010:7777777777777777777777777777777777777777777777777777777777777777
-- 011:7777777777777777777777777777777777777777777777777777777777777777
-- 012:7777777777777777777777777777777777777775777777557777777577777755
-- 013:7777777777777777777777777777777757777777557777775777777755777777
-- 014:7777777577777775777777557777755577775555777555557777755577775555
-- 015:5777777757777777557777775557777755557777555557775557777755557777
-- 016:763003007630000066666666600eeeee66666666600000006666666670000077
-- 017:000000670000006766666666eeeee00666666666000000066666666677000007
-- 018:700630030006300066666666666600ee66666666660000000666666600000077
-- 019:000000660000006666666666eeeee00666666666000000666666666777000007
-- 020:663003006630000066666666600eeeee66666666660000007666666670000077
-- 021:000060070000600066666666ee00666666666666000000666666666077000000
-- 022:7555555577555555777555557777774477777774777777747777777477777777
-- 023:5555557755555777555577774777777747777777477777774777777777777777
-- 024:7777777777777777777777777777777777777777777777777777777777777777
-- 025:7777777777777777777777777777777777777777777777777777777777777777
-- 026:7777777777777777777777777777777777777777777777777777777777777777
-- 027:7777777777777777777777777777777777777777777777777777777777777777
-- 028:7777755577775555777775557777555577755555775555557777774477777744
-- 029:5557777755557777555777775555777755555777555555774477777744777777
-- 030:7775555575555555775555555555555555555555777774447777744477777444
-- 031:5555577755555557555555775555555755555555444777774447777744477777
-- 040:7777777777777777777777777777777777777777777777777777777777777777
-- 041:7777777777777777777777777777777777777777777777777777777777777777
-- 042:7777777777777777777777777777777777777777777777777777777777777777
-- 043:7777777777777777777777777777777777777777777777777777777777777777
-- 056:7777777777777777777777777777777777777777777ddddd7ddddddddddddddd
-- 057:777777777777777777777777777777777ddddd77dddddddddddddddddddddddd
-- 058:7777777777777777777777777777777777777777dddddd77dddddddddddddddd
-- 059:777777777777777777777777777777777777777777777777dd777777dddddddd
-- 160:7777777777777777777777777777777777777777777777777777777777777777
-- 161:7777777777777000777702227770222277022222770222227022222270222222
-- 162:700000000222222222222222222222222222222222222222200000000eeeeeee
-- 163:00000777222200072222222022222222222222222222222200222222ee022222
-- 164:7777777770000000702222220022222200222222002222220222222202222222
-- 165:7777777700000000222222222222222222222222222222222222222200000000
-- 166:7777777700000777222220772222220722222220222222202222222002222220
-- 167:7777777700000000022222200222222002222220022222200222222022222220
-- 168:7777777700000000222222222222222222222222222222222222222222222222
-- 169:7777777700000000222222222222222222222222222222222222222222222222
-- 170:777777770000077722220777222007772220e7772220e7772220777722207777
-- 171:7777777777777777777777777777777777777777777777777777777777777777
-- 176:7777777777777777777777777777777777777777777777777777777777777777
-- 177:702222227e0222227e02222277e0222277022222702222220222222202222220
-- 178:0777777720000000222222222222222222222222222222222222222200000000
-- 179:7022222202222222222222202222220e2222222022222222222222220022222f
-- 180:0222222202222222022222220222222202222222022222220222222202222220
-- 181:0eeeeeee00000000222222222222222222222222222222222222222200000000
-- 182:022222200222222022222220222222202222220e2222222022222220f2222220
-- 183:2222222022222220222222202222220e2222220e2222220e2222220e2222220e
-- 184:0222222202222222022222220222222002222220022222200222222002222220
-- 185:000000000eeeeeee07777777e7777777e7777777777777777777777777777777
-- 186:00007777eeee7777777777777777777777777777777777777777777777777777
-- 187:7777777777777777777777777777777777777777777777777777777777777777
-- 192:7777777777777777777777777777777777777777777777777777777777777777
-- 193:022f2f0e02f2f2e00fffffff0fffffff07ffffffe0efffff7e07ffff77e00000
-- 194:eeeeeeee0000000022e22e22ffffffffffffffffffffffffffffffff00000000
-- 195:e0e2f2f200fffffffffffffffffffff0ffffffe0fffffe00ffff00e00000ee70
-- 196:02f2f2f002f2f2f00fffffffffffffffffffffffffffffffffffffff00000000
-- 197:eeeeeeee00000000ffffffffffffffffffffffffffffffffffffffff00000000
-- 198:0f2f2f20f2f2ff20fffffff0fffffff0ffffff0ffffff00ffffe0e0f0000e700
-- 199:22f2f20e2f2f2f0efffff20efffffe07fffff0e7fffff0e7fffff0e700000077
-- 200:02f2f2f20ff2f2ff02ffff2f0fffffff0fffffffe0ffffff7e0fffff77e00000
-- 201:00000000f2f2f2f22fff2f2fffffffffffffffffffffffffffffffff00000000
-- 202:00000007f2f2ff072f2f2f07fffff207ffff2f07fff2f207ff2f2f0700000007
-- 203:7777777777777777777777777777777777777777777777777777777777777777
-- 208:7777000077702222777022227770222277022222770222227702222277022222
-- 209:0000000022222222222222222222222222222222222222222222222222000000
-- 210:000eeeee22200077222222002222222222222222222222222222222200022222
-- 211:eeee777e77777700777770220777022207702222200222222002222220222222
-- 212:e000000002222222222222222222222222222222222222222200000020eeeeee
-- 213:00007eee222200772222220722222220222222222222222202222222e0222222
-- 214:eeee77e077777002777702227770222207022222002222220022222202222222
-- 215:0000000022222222222222222222222222222222222222222222222200000000
-- 216:0000000022222220222222202222222022222220222222202222222000000000
-- 217:eeeeee0077770022770022227022222200222222022222222222222222222220
-- 218:0000000022222222222222222222222222222222222222222222222200000000
-- 219:0000000722222207222222072222220722222207222222072222220700000007
-- 224:7702222277022222770222227702222277022222770222227702222270222222
-- 225:20eeeeee20777777220000002222222222222222222222222222222222222222
-- 226:eee022227702222200222222222222222222222222222222222222202222220e
-- 227:202222222022222220222222202222222022222200222222e022222270222222
-- 228:0e77777707777777000000002222222222222222222222222222222222222222
-- 229:7022222270222222002222222222222222222222222222202222222022222220
-- 230:022222200222222002222220022222000222220e2222220e2222220722222207
-- 231:eeeeeeee77777777777777777777777777777777777777777777777777777777
-- 232:eeeeeee077777770777777707777770277777702777777027777770277777702
-- 233:2222220e22222220222222222222222222222222222222222222222222222200
-- 234:eeeeeeee00000000222222222222222222222222222222222222222200000000
-- 235:eeeeee7700000077222220772222207722222077222220772222207700000077
-- 240:7022222270222222702222227022222270222222702222227022222270000000
-- 241:200000220eeeee02077777e007777770077777700777777e0777777707777777
-- 242:22222207222222072222222022222220222222220222222202222222e0000000
-- 243:7022222270222220702222207022222002222220022222200222222000000000
-- 244:00000000eeeeeeee777777777777777777777777777777777777777777777777
-- 245:0222222002222220022222200222222002222220022222200222222000000000
-- 246:2222222022222222022222220222222202222222e02222227e05222277e00000
-- 247:7777777700000000222222222222222222222222222222222222222200000000
-- 248:77777702000000022222220222222202222222002222220e22222207000000e7
-- 249:2222220e2222220022222222222222222222222202222222e02222227e000000
-- 250:eeeeeeee00000000222222222222222222222222222222222222222200000000
-- 251:eeeee77700000777222207772222077722220777222207772222077700000777
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:700870087008700870087008700870087008700870087008700870087008700870087008700870087008700870087008700870087008700870087008040000000000
-- 001:a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000300000000000
-- </SFX>

-- <PALETTE>
-- 000:140c1cff00ffc2c2204e4a4e854c30346524d04648757161a51818a114616918a524246d0430000c3808aeaaaedeeed6
-- </PALETTE>

