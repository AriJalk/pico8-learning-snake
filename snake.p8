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
margin=0.1

panel_size={x=128-96,y=128}


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
	direction = {x=1,y=0}
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
			 _init()
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
	flip()
end

function draw_update()
	draw_snake_update()
	draw_panel()
	if is_fruit_placed then
		draw_fruit()
	end
	flip()
end

--draw functions
function draw_tile(pos,col)
	local draw_pos=grid_game_position(pos)
	draw_pos.x += 128 - grid_size.x
	rectfill(draw_pos.x+margin,draw_pos.y+margin,
		draw_pos.x+tile_size.x-1-margin,draw_pos.y+tile_size.y-1-margin,col)	
end

function draw_fruit()
	draw_tile(fruit_pos,3)
	is_fruit_placed=false
end

function draw_snake_initial()
 for i=2,snake_size do
	 draw_tile(snake_pos[i],10)
 end
	draw_tile(snake_pos[1],2)
end

function draw_snake_update()
	--remove tail
	if tail_pos and not pos_equals(tail_pos,fruit_pos) then
		draw_tile(tail_pos,1)
	end
	--add head
	draw_tile(snake_pos[1],2)
	--change head to body
	if snake_size>1 then
		draw_tile(snake_pos[2],10)
	end
end

function draw_wall()
	for wall in all(wall_pos) do
		draw_tile(wall,5)
	end
end

function draw_panel()
	rectfill(0,0,panel_size.x-1,panel_size.y-1,1)
	color(9)
	print("s:"..score,1,1)
	//print("["..snake_pos[1].x..","..snake_pos[1].y.."]",1,7)
	//print("["..snake_position[2].x..","..snake_position[2].y.."]",30,7)
	//print("t: "..update_time,1,13)
	print('i:'..update_interval,1,10)
	
--	--debug
-- for i=1,#segments_map do
--  print('('..segments_map[i].s.x..','..segments_map[i].s.y..')'..'('..segments_map[i].e.x..','..segments_map[i].e.y..')',1,i*10+50)
-- 
-- end
--	print(fruit_pos.x..','..fruit_pos.y,1,50)
end

function draw_win_panel()
 rectfill(32,32,128-32,128-32,4)
 print('you win',32,64,6)
 print('press 🅾️ to reset',6)
end
-->8
-- update functions
//todo: buffer
function update_input()
	local new_dir
	if btn(➡️) then
		new_dir = {x=1, y=0}
	elseif btn(⬅️) then
		new_dir = {x=-1, y=0}
	elseif btn(⬇️) then
		new_dir = {x=0, y=1}
	elseif btn(⬆️) then
		new_dir = {x=0, y=-1}
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
	snake_pos[1] = {x=tile_num.x/2,y=tile_num.y/2}
	head_pos=snake_pos[1]
	for cell=2,snake_size do
		local pos=pos_cpy(snake_pos[cell-1])
		local diff={x=-direction.x,y=-direction.y}
		pos = pos_add(pos,diff)
		snake_pos[cell]=pos
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
