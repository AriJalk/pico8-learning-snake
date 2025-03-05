pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- engine functions

--game variables
snake_pos=nil
wall_pos=nil
--must be >1
snake_size=2
score=nil
head_pos=nil
tail_pos=nil
fruit_pos=nil

direction=nil
directions=
{
	left={x=-1,y=0},
	right={x=1,y=0},
	up={x=0,y=-1},
	down={x=0,y=1}
}

--game flags
is_fruit_placed=false


--grid variables
--pixel size
grid_size={x=96,y=128}
//grid_size={x=96,y=96}
--number of tiles
tile_num={x=12,y=16}
//tile_num={x=6,y=6}
tile_size={x=grid_size.x/tile_num.x,y=grid_size.y/tile_num.y}
win_size=(tile_num.x-2)*(tile_num.y-2)

panel_size={x=32,y=32}

spr_size={sw=8,sh=8,dw=tile_size.x,dh=tile_size.y}

sprites={
	body_v={sx=8,sy=0},
	body_h={sx=16,sy=0},
	elbow={sx=24,sy=0},
	tail_v={sx=32,sy=0},
	tail_h={sx=40,sy=0},
	head_v={sx=48,sy=0},
	head_h={sx=56,sy=0},
	fruit={sx=64,sy=0},
	wall={sx=72,sy=0},
	floor={sx=80,sy=0}
}

--collision segments
segments=nil
segment_num={x=4,y=4}
segment_size={x=tile_num.x/segment_num.x,y=tile_num.y/segment_num.y}

--loop variables
tick_rate = 300
last_tick = 0
dec_value=5


function _init()
	is_game_running=true
 tick_rate=300
 last_tick=0
 snake_size=3
 snake_pos={}
 score=0
	build_segments()
	direction=dir_rnd()
	build_wall()
	build_snake()
	tail_pos=nil
	add_fruit()
	is_fruit_placed=true
 last_time = time()
 draw_initial()
end

function _update()
	if is_game_running then
		update_input()
		local now=time()*1000
		--check for update tick
		if now-last_tick>=tick_rate then
			last_tick=now
			update_snake()
			if check_victory() then
				is_game_running=false
				draw_win_panel()
				return	
			end
			if is_fruit_placed and is_game_running then
				add_fruit()
			end
			--check if lost by collision
			if check_collision(snake_pos[1]) then
			 is_game_running=false
			 draw_lose_panel()
			 return
			end
		end
	draw_update()
 end
 --test button to decelerate
	if (btn(❎)) then
		update_interval += 0.01
		update_interval = min(update_interval,1)
	--reset button
	elseif (btnp(🅾️)) then
		_init()
		return
	end
end


-->8
-- draw functions

--engine draw managers

function draw_initial()
	cls(1)
	draw_floor()
 draw_walls()
 draw_snake_initial()
 draw_fruit()
 flip()
end

function draw_update()
	draw_snake_update()
	draw_panel()
	if is_fruit_placed then
		draw_fruit()
		is_fruit_placed=false
	end
	flip()
end

--core draw functions

function draw_sprite(sprite,pos,flip_x,flip_y)
	if flip_x==nil then flip_x=false end
	if flip_y==nil then flip_y=false end
	local draw_pos=grid_game_position(pos)
	draw_pos.x += 128 - grid_size.x
	sspr(
		sprite.sx,sprite.sy,
		spr_size.sw,spr_size.sh,
		draw_pos.x,draw_pos.y,
		spr_size.dw,spr_size.dh,
		flip_x,flip_y)
end

--draw horizontal/vertical sprites
function draw_orientation(spr_name,pos,dir)
 if dir==nil then
  dir=pos.dir
 end
 local flip_x=false
 local flip_y=false
 local o=nil
 local right=(dir==directions.right)
 local left=(dir==directions.left)
 local up=(dir==directions.up)
 local down=(dir==directions.down)

 if right or left then
  o='h'
  if left then
   flip_x=true
  end
 elseif up or down then
  o='v'
  if down then
  	flip_y=true
  end
 end
 local str=spr_name..'_'..o
 draw_sprite(sprites[str],pos,flip_x,flip_y)
end

--initial draw functions

function draw_snake_initial()
 draw_head()
 draw_body_initial()
 draw_tail()
end

function draw_body_initial()
 for i=1,snake_size-1 do
  draw_orientation('body',snake_pos[i])
 end
end

function draw_walls()
	for wall in all(wall_pos) do
		draw_sprite(sprites.wall,wall)
	end
end

function draw_floor()
 for i=1,tile_num.x-1 do
 	for j=1, tile_num.y-1 do
 		draw_sprite(sprites.floor,{x=i,y=j})
 	end
 end
end

--loop draw functions

function draw_snake_update()
	--remove tail
	if tail_pos and not pos_equals(tail_pos,fruit_pos) then
		draw_sprite(sprites.floor,tail_pos)
	end
	--add head
	draw_head()
	--change previous head to body and set tail
	if snake_size>2 then
	 	draw_body_update()
	end
	draw_tail()
end

function draw_body_update()
 --continuous
 if snake_pos[2].dir==snake_pos[1].dir then
 	draw_orientation('body',snake_pos[2])
 else
  --corner
  draw_elbow() 	
 end
end

--element draw functions

function draw_fruit()
	draw_sprite(sprites.fruit,fruit_pos)
end

function draw_head()
	draw_orientation('head',head_pos)
end

function draw_tail()
 if snake_size>1 then
 	draw_orientation('tail',snake_pos[snake_size],snake_pos[snake_size-1].dir)
 end
end

--draws a corner between cells[1,3]
--only call when direction changed and size>2
function draw_elbow()	
	local sprite=sprites.elbow
	local pos_a=snake_pos[1]
	local pos_b=snake_pos[2]
	--check elbow type
 local flip_x=(pos_a.dir==directions.left)or(pos_b.dir==directions.right)
 local flip_y=(pos_a.dir==directions.down)or(pos_b.dir==directions.up)
 --draw the elbow based on elbow type
	  draw_sprite(sprite,pos_b,flip_x,flip_y)
end

--panels

function draw_panel()
	rectfill(0,0,panel_size.x-1,panel_size.y-1,1)
	color(9)
	print("s:"..score,1,1)
	print('i:'..tick_rate,1,10)
end

function draw_win_panel()
-- rectfill(25,25,128-25,128-25,4)
 print('you win',32,64,10)
 print('press 🅾️ to reset',10)
end

function draw_lose_panel()
-- rectfill(25,25,128-25,128-25,2)
 print('you lose, score:'..score,32,64,10)
 print('press 🅾️ to reset',10)
end
-->8
-- logic update functions

//todo: buffer
function update_input()
	local new_dir
	if btn(➡️) then
		new_dir=directions.right
	elseif btn(⬅️) then
		new_dir=directions.left
	elseif btn(⬇️) then
		new_dir=directions.down
	elseif btn(⬆️) then
		new_dir=directions.up
	end
	if new_dir and (not pos_equals(pos_add(snake_pos[1], new_dir), snake_pos[2])) then
		direction = new_dir
	end
end



function update_snake()
	head_pos=pos_add(snake_pos[1],direction)
	--check if fruit eaten
	if not pos_equals(head_pos,fruit_pos) then
		--update tail
		tail_pos=snake_pos[snake_size]
		del_collision(tail_pos)
	else
		is_fruit_placed=true
		snake_size+=1
		score+=1
		--speed up
 	tick_rate=max(0,tick_rate-dec_value)
	end
	--update body inward
	for cell=snake_size,2,-1 do
 		snake_pos[cell]=snake_pos[cell-1]
 end
 --update head
 add_collision(snake_pos[1])
 snake_pos[1]=head_pos
 snake_pos[1].dir=direction
end

function add_fruit()
 while true do
 	local pos=pos_rnd()
 	if not check_collision(pos) and not pos_equals(pos,head_pos) then
 	 fruit_pos=pos
 		return
 	end
 end
end

function check_victory()
	return snake_size==win_size
end
-->8
-- position functions

--convert logic position to pixel position
function grid_game_position(coordinates)
	local x = tile_size.x*coordinates.x
	local y = tile_size.y*coordinates.y
	return {x=x,y=y}
end

--hard copy position
function pos_cpy(origin)
	return {x=origin.x,y=origin.y}
end

--check if two positions identical
function pos_equals(pos_a,pos_b)
	if pos_a==nil or pos_b==nil then 
		return false
	end
	return pos_a.x==pos_b.x and pos_a.y==pos_b.y
end

--add two positions
function pos_add(pos_a,pos_b)
	return {x=pos_a.x+pos_b.x,y=pos_a.y+pos_b.y}
end

--random position in logic game space
function pos_rnd()
	return {x=flr(rnd(tile_num.x-1))+1,y=flr(rnd(tile_num.y-1))+1}
end

--convert position to string
function pos_str(pos)
 return pos.x..','..pos.y
end

--random direction
function dir_rnd()
 local num=flr(rnd(4)+1)
 if num==1 then
 	return directions.right
 elseif num==2 then
 	return directions.left
 elseif num==3 then
  return directions.up
 elseif num==4 then
  return directions.down
 end
end
-->8
--building functions

--initialize snake
function build_snake()
	snake_pos[1]={x=tile_num.x/2,y=tile_num.y/2,dir=direction}
	head_pos=snake_pos[1]
	for cell=2,snake_size do
		local pos=pos_cpy(snake_pos[cell-1])
		local diff={x=-direction.x,y=-direction.y}
		pos=pos_add(pos,diff)
		snake_pos[cell]=pos
		snake_pos[cell].dir=direction
		add_collision(pos)
	end
end

--initialize wall
function build_wall()
	wall_pos={}
	slot=1
	--horizontal
	for i=0,tile_num.x-1 do
		wall_pos[slot]={x=i,y=0}
		add_collision(wall_pos[slot])
		wall_pos[slot+1]={x=i,y=tile_num.y-1}
		add_collision(wall_pos[slot+1])
		slot+=2
	end
	--vertical
	for i=0,tile_num.y-2 do
		wall_pos[slot]={x=0,y=i}
		add_collision(wall_pos[slot])
		wall_pos[slot+1]={x=tile_num.x-1,y=i}
		add_collision(wall_pos[slot+1])
		slot+=2
	end
end
-->8
--collision segments

function build_segments()
	segments={}
 for i=0,segment_num.x do
 	for j=0,segment_num.y do
 	 segments[i..','..j]={}
 	end
 end
end

--get matching segment for position
function get_segment(pos)
	local x=flr(pos.x/segment_size.x)
	local y=flr(pos.y/segment_size.y)
 return segments[x..','..y]
end

--add position to segment table
function add_collision(pos)
	local seg=get_segment(pos)
	local str=pos_str(pos)
	if seg[str]==nil then
		seg[str]=pos_cpy(pos)
	end	
end

--delete position from segment table
function del_collision(pos)
 local seg=get_segment(pos)
	local str=pos_str(pos)
	if seg[str]!=nil then
		seg[str]=nil
	end	
end

--return true/false if position collides
function check_collision(pos)
	local seg=get_segment(pos)
	if seg[pos_str(pos)]!=nil then
	 return true
	end
	return false
end


__gfx__
000000001111111111111111111111111111111111111111111111111111111111bb111111111111111111110000000000000000000000000000000000000000
000000001139931111111111113993111139931111111111188bb88118888881111bb11114444441155555510000000000000000000000000000000000000000
007007001139931113333331113993311139931113333331188888811888a881118b811114444441151111510000000000000000000000000000000000000000
00077000113993111999999111399991113993111399999118a88a81188888b11888881114444441151111510000000000000000000000000000000000000000
00077000113993111999999111399991113993111399999118888881188888b11888781114444441151111510000000000000000000000000000000000000000
007007001139931113333331113333311139931113333331188888811888a8811888881114444441151111510000000000000000000000000000000000000000
00000000113993111111111111111111113333111111111118888881188888811188811114444441155555510000000000000000000000000000000000000000
00000000111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000000000000000
