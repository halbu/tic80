-- title:  snake
-- author: halbu
-- desc:   it's snake
-- script: lua

c=0
dir=1 
px=4
py=2
apple={x=-1,y=-1}
player={
 {x=2, y=2},
 {x=3, y=2},
 {x=4, y=2},
}
ateThisTurn=false
playing=true
bgColor=8
TILE_SIZE=8
score=0
framesPerTick=9

function TIC()
 -- input handling
 if btn(0) then dir=0 end
 if btn(1) then dir=2 end
 if btn(2) then dir=3 end
 if btn(3) then dir=1 end

 -- logic
 testCollision()
 spawnApple()

 if playing then c=c+1 end

 if (c>framesPerTick) then
  c=0
  movePlayer()
 end

 -- rendering
 cls(bgColor)
 drawWalls()
 drawPlayer()
 drawApple()
end

function testCollision()
 head = player[#player]

 -- test eating apple
 if (head.x==apple.x and head.y==apple.y) then
  apple.x=-1
  score=score+1
  if (score%10==0 and framesPerTick>3) then
   framesPerTick=framesPerTick-1
  end
  ateThisTurn=true
 end

 -- test for collision against self
 for i, item in pairs(player) do
  if (item~=head) then
   if (item.x==head.x and item.y==head.y) then
    endGame()
   end
  end
 end

 -- test for collision against boundaries of play area
 if (head.x==0 or head.x==29 or head.y==0 or head.y==16) then
  endGame()
 end
end

function endGame()
 playing=false
 bgColor=1
end

function drawPlayer()
 for i,item in pairs(player) do
  if (i==#player) then
   spr(1,item.x*TILE_SIZE,item.y*TILE_SIZE,0)
  else
   spr(2,item.x*TILE_SIZE,item.y*TILE_SIZE,0)
  end
 end
end

function drawWalls()
 for i=0,30,1 do
  for j=0,17,1 do
   if(i==0 or j==0 or i==29 or j==16) then
    spr(0,i*TILE_SIZE,j*TILE_SIZE)
   end
  end
 end
end

function drawApple()
 if (apple.x>-1) then
  spr(3,apple.x*TILE_SIZE,apple.y*TILE_SIZE,0)
 end
end

function spawnApple()
 if (apple.x==-1) then
  apple.x = math.random(1, 28)
  apple.y = math.random(1, 15)
 end
end

function movePlayer()
 if dir==0 then py=py-1 end
 if dir==1 then px=px+1 end
 if dir==2 then py=py+1 end
 if dir==3 then px=px-1 end

 table.insert(player, {x=px, y=py})

 if (ateThisTurn==false) then
  table.remove(player, 1)
 end

 ateThisTurn=false
end

-- <TILES>
-- 000:c111111c1c5555c115c55c51155cc551155c155115c55c511c5555c1c111111c
-- 001:066666606eeeeee66e6ee6e66eeeeee66eeeeee66e6666e66eeeeee606666660
-- 002:066666606eeeeee66eeeeee66eeeeee66eeeeee66eeeeee66eeeeee606666660
-- 003:000440b000044b000666666006dd666666d66666666666660666666000666600
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:140c1c082c0830346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2c104018ff5555dad45edeeed6
-- </PALETTE>

