pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- engine functions

--game variables
snake_pos = {}
wall_pos = {}
snake_size = 0
score = 0
head_pos=nil
tail_pos=nil
fruit_pos=nil

last_dir=nil
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

--input
dir_buffer=nil

--grid variables
--pixel size
grid_size={x=96,y=128}
--grid_size={x=96,y=96}
--number of tiles, in proportion to grid_size
tile_num={x=12,y=16}
--tile_num={x=6,y=6}
tile_size={x=grid_size.x/tile_num.x,y=grid_size.y/tile_num.y}
margin=0

panel_size={x=128-96,y=128}

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
	empty={sx=80,sy=0}
}



--collision segments
segments = {}
segment_num={x=4,y=4}
segment_size={x=tile_num.x/segment_num.x,y=tile_num.y/segment_num.y}

--loop variables
update_interval = 0.3
update_time = 0


function _init()
	win_size=(tile_num.x-2)*(tile_num.y-2)
	printh('winsize:'..win_size)
	is_game_running=true
 update_interval=0.3
 snake_size=3
 snake_pos={}
 score=0
 segments={}
	build_segments()
	direction=directions.right
	build_wall()
	build_snake()
	tail_pos=nil
	fruit_pos=pos_add(head_pos,direction)
	is_fruit_placed=true
 last_time = time()
 draw_initial()
end

function _update()
	if is_game_running then
		update_input()
		update_time += time()-last_time
		last_time = time()
		if(update_time > update_interval) then
			update_time = 0
			update_snake()
			if check_victory() then
				is_game_running=false
				draw_win_panel()
				return	
			end
			if is_fruit_placed and is_game_running then
				add_fruit()
			end
			if check_collision(snake_pos[1]) then
			 is_game_running=false
			 draw_lose_panel()
			 return
			end
		end
	draw_update()
 end
	if (btn(❎)) then
		update_interval += 0.01
		update_interval = min(update_interval,1)
		--update_speed = mid(0, updade_speed, 2)
	elseif (btnp(🅾️)) then
		_init()
		return
--		update_interval -= 0.01
--		update_interval = max(0,update_interval)
--		--update_speed = mid(0, update_speed, 2)
	end
end


-->8
-- draw functions

--engine draw managers

function draw_initial()
	cls(1)
 draw_wall()
 draw_snake_initial()
 draw_fruit()
end

function draw_update()
	draw_snake_update()
	draw_panel()
	if is_fruit_placed then
		draw_fruit()
	end
	flip()
end

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


function draw_orientation(spr_name,pos,dir)
 if dir==nil then
  dir=pos.dir
 end
 local flip_x=false
 local flip_y=false
 local o=nil
 if dir==directions.right or dir==directions.left then
 	o='h'
 	if dir==directions.left then
 	 flip_x=true
 	end
 elseif dir==directions.up or dir==directions.down then
  o='v'
  if dir==directions.down then
   flip_y=true
  end
 end
 local str=spr_name..'_'..o
 draw_sprite(sprites[str],pos,flip_x,flip_y)
end

--draw functions
function draw_tile(pos,col)
	local draw_pos=grid_game_position(pos)
	draw_pos.x += 128 - grid_size.x
	rectfill(
		draw_pos.x+margin,draw_pos.y+margin,
		draw_pos.x+tile_size.x-1-margin,draw_pos.y+tile_size.y-1-margin,col)	
end

function draw_fruit()
	draw_sprite(sprites.fruit,fruit_pos)
	--todo:somwhere else
	is_fruit_placed=false
end

function draw_snake_initial()
 draw_head()
 draw_body_initial()
 draw_tail()
end

function draw_snake_update()
	--remove tail
	if tail_pos and not pos_equals(tail_pos,fruit_pos) then
		draw_sprite(sprites.empty,tail_pos)
	end
	--add head
	draw_head()
	--change previous head to body and set tail
	draw_body_update()
	draw_tail()
end

function draw_wall()
	for wall in all(wall_pos) do
		draw_sprite(sprites.wall,wall)
	end
end

function draw_panel()
	rectfill(0,0,panel_size.x-1,panel_size.y-1,1)
	color(9)
	print("s:"..score,1,1)
	print('i:'..update_interval,1,10)
end

--snake parts

function draw_head()
	draw_orientation('head',head_pos)
end

function draw_tail()
 if snake_size>1 then
  draw_tile(snake_pos[snake_size],1)
 	draw_orientation('tail',snake_pos[snake_size],snake_pos[snake_size-1].dir)
 end
end


function draw_body_initial()
 for i=1,snake_size-1 do
  draw_orientation('body',snake_pos[i])
 end
end

--only call when cells[2-3] are orthogonal
function draw_elbow()	
	local sprite=sprites.elbow
	local pos_a=snake_pos[1]
	local pos_b=snake_pos[2]
	
	local right_a=(pos_a.dir==directions.right)
	local left_a=(pos_a.dir==directions.left)
	local up_a=(pos_a.dir==directions.up)
	local down_a=(pos_a.dir==directions.down)
	
	local right_b=(pos_b.dir==directions.right)
	local left_b=(pos_b.dir==directions.left)
	local up_b=(pos_b.dir==directions.up)
	local down_b=(pos_b.dir==directions.down)
	
	if right_a or left_b then
	 if up_a or down_b then
	  draw_sprite(sprite,pos_b,false,true)
	 else
	  draw_sprite(sprite,pos_b,false,false)
	 end
	elseif left_a or right_b then
	 if up_a or down_b then
	 	draw_sprite(sprite,pos_b,true,true)
	 else
	 	draw_sprite(sprite,pos_b,true,false)
		end
	end
end

function draw_body_update()
 --continuous
 if snake_size>2 then
   draw_tile(snake_pos[2],1)
	 if snake_pos[2].dir==snake_pos[1].dir then
  	draw_orientation('body',snake_pos[2])
 	else
 	 draw_elbow() 	
 	end
 end
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
-- update functions
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
	if new_dir and snake_size>1 then
		local new_pos=pos_add(snake_pos[1],new_dir)
		if pos_equals(new_pos,snake_pos[2]) then
			return
		end
		direction=new_dir
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
 	update_interval-=0.01
 	update_interval=max(0,update_interval)
	end
	--update body
	for cell=snake_size,2,-1 do
 		snake_pos[cell]=snake_pos[cell-1]
 end
 --update head
 add_collision(snake_pos[1])
 snake_pos[1] = head_pos
 snake_pos[1].dir=direction
end

function check_collision(pos)
	local seg=get_segment(pos)
	if seg[pos_str(pos)]!=nil then
	 return true
	end
	return false
end

--function check_collision()
-- local head=snake_pos[1]
--	local seg=get_segment(head)
--	for col in all(seg) do
--		if pos_equals(col,head) then
--			_init()
--		end
--	end
--	if pos_equals(head_fruit_pos) then
--	
--	end 
--end
--
--function generate_fruit()
-- 
--end

function add_fruit()
 while true do
 	local pos=pos_rnd()
 	if not check_collision(pos) and not pos_equals(pos,head_pos) then
 	 fruit_pos=pos
-- 	 printh('pos:'..pos_str(fruit_pos))
--			printh('head:'..pos_str(head_pos))
 		return
 	end
 end
end

function check_victory()
	return snake_size==win_size
end
-->8
-- position
function grid_game_position(coordinates)
	local x = tile_size.x*coordinates.x
	local y = tile_size.y*coordinates.y
	return {x=x,y=y}
end

function pos_cpy(origin)
	return {x=origin.x,y=origin.y}
end

function pos_equals(pos_a,pos_b)
	if pos_a==nil or pos_b==nil then 
		return false
	end
	return pos_a.x==pos_b.x and pos_a.y==pos_b.y
end

function pos_add(pos_a,pos_b)
	return {x=pos_a.x+pos_b.x,y=pos_a.y+pos_b.y}
end

function pos_rnd()
	return {x=flr(rnd(tile_num.x-1)),y=flr(rnd(tile_num.y-1))}
end

function pos_str(pos)
 return pos.x..','..pos.y
end
-->8
--building functions


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

function build_wall()
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
--segments

function get_segment(pos)
	local x=flr(pos.x/segment_size.x)
	local y=flr(pos.y/segment_size.y)
 return segments[x..','..y]
end

function add_collision(pos)
	local seg=get_segment(pos)
	local str=pos_str(pos)
	if seg[str]==nil then
		seg[str]=pos_cpy(pos)
	end	
end

function del_collision(pos)
 local seg=get_segment(pos)
	local str=pos_str(pos)
	if seg[str]!=nil then
		seg[str]=nil
	end	
end

function build_segments()
 for i=0,segment_num.x do
 	for j=0,segment_num.y do
 	 segments[i..','..j]={}
 	end
 end
end
__gfx__
000000000399993000000000000000000399993000000000000000000000000000bb0000dddddddd111111110000000000000000000000000000000000000000
000000000399993003333333033333300399993033333333088bb88008888880000bb000d555555d111111110000000000000000000000000000000000000000
007007000399993009999999039999900399993039999999088888800888a880008b8000d555555d111111110000000000000000000000000000000000000000
00077000039999300999999903999990039999303999999908a88a80088888b008888800d555555d111111110000000000000000000000000000000000000000
00077000039999300999999903999990039999303999999908888880088888b008887800d555555d111111110000000000000000000000000000000000000000
007007000399993009999999039999900399993039999999088888800888a88008888800d555555d111111110000000000000000000000000000000000000000
000000000399993003333333039999300399993033333333088888800888888000888000d555555d111111110000000000000000000000000000000000000000
000000000000000000000000000000000333333000000000000000000000000000000000dddddddd111111110000000000000000000000000000000000000000
