-- title:  race
-- author: halbu
-- desc:   super hang on, but bad
-- script: lua

sw, sh = 240, 136

t_width = 0.8
e_width = 0.075 -- width of barrier thing on either side

chevron = 0
chevronWidth = 15
speed = 2.4
true_centre = 0.5
curve = 0
curve_dir = 3
curve_change_speed = 0.005
max_curve = 0.6
c_grass = 3
car_x = sw / 2 - 8

-- aliases as these improve performance somehow?
sin = math.sin
flr = math.floor

function TIC()
	cls()
 cfloor = flr(chevron)
 
 updateCurve()
 carDrift()
 drawTrack()
 handleInput()
 
	spr(0, car_x, 112, 7, 1, 0, 0, 2, 2)

	chevron=chevron+speed
	if chevron>chevronWidth then chevron=chevron-chevronWidth end
end

function carDrift()
 car_x = car_x - curve*3
end

function updateCurve()
 if math.random(1, 30) == 1 then
  curve_dir = math.random(1, 3)
 end

 if curve_dir == 1 then
  curve = curve - curve_change_speed
 elseif curve_dir == 2 then
  curve = curve + curve_change_speed
 end

 if curve < -max_curve then curve = -max_curve end
 if curve > max_curve then curve = max_curve end
end

function handleInput()
 if btn(2) then car_x = car_x - 2 end
 if btn(3) then car_x = car_x + 2 end
end

function drawTrack()
 rect(0, sh/2, sw, sh/2, c_grass)
	
 for j=sh/2,sh do
  ccol = 1
  if (j-cfloor)%chevronWidth < 6 then ccol = 15 end
  
  persp_sqz = (j - sh/2) / (sh/2) -- perspective squeeze
  curv_amount = (0.5 - ((j - sh/2) / (sh))) * 1.8 -- curvature squeeze

  centre = true_centre + (curve * (curv_amount^2))

  t_left=centre-(t_width/2) * persp_sqz
  t_right=centre+(t_width/2) * persp_sqz
  e_left=t_left-e_width * persp_sqz
  e_right=t_right+e_width * persp_sqz

  for i=0,sw do
   if i>=(t_left*sw) and i<=(t_right*sw) then
    pix(i,j,2)
   elseif i>(e_left*sw) and (i<t_left*sw) then
    pix(i,j,ccol)
   elseif i>(t_right*sw) and (i<e_right*sw) then
    pix(i,j,ccol)
   end
  end
 end
end