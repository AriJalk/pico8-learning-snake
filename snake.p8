pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- engine functions

--game variables
snake_position = {}
wall_pos = {}
snake_size = 3
score = 0
tail_pos=nil
fruit_pos=nil

--input
dir_buffer=nil

--grid variables
grid_size={x=64,y=128}
--x should be even and y/2
tile_num={x=8,y=16}
tile_size={x=grid_size.x/tile_num.x,y=grid_size.y/tile_num.y}
panel_size={x=64,y=128}
margin=0.5

segment_num = {x=1,y=2}
segments = {}
segments_map = {}

seg_ratio={x=tile_num.x/segment_num.x,y=tile_num.y/segment_num.y}

--loop variables
update_speed = 0.1
update_time = 0


function _init()
	build_segments_map()
	direction = {x=1,y=0}
	build_snake()
	build_wall()
 last_time = time()
 draw_initial()
end

function _update()
	update_input()
	update_time += time()-last_time
	last_time = time()
	if(update_time > update_speed) then
		update_time = 0
		update_snake()
		check_collision()
		draw_update()
	end
	if (btn(❎)) then
		update_speed += 0.01
		update_speed = min(update_speed,1)
		--update_speed = mid(0, updade_speed, 2)
	elseif (btn(🅾️)) then
		update_speed -= 0.01
		update_speed = max(0,update_speed)
		--update_speed = mid(0, update_speed, 2)
	end
end

--todo: draw only changes
function draw_initial()
	cls(1)
 draw_wall()
 draw_snake_initial()
	flip()
end

function draw_update()
	draw_snake_update()
	draw_panel()
	flip()
end
-->8
-- draw functions
function draw_tile(pos,col)
	local x = pos.x + 128 - grid_size.x
	rectfill(x+margin,pos.y+margin,
		x+tile_size.x-1-margin,pos.y+tile_size.y-1-margin,col)
end

function draw_snake_initial()
 for i=2,snake_size do
	 draw_tile(snake_position[i],10)
 end
	draw_tile(snake_position[1],2)
end

function draw_snake_update()
	--remove tail
	draw_tile(tail_pos,1)
	--add head
	draw_tile(snake_position[1],2)
	--change head to body
	if snake_size>1 then
		draw_tile(snake_position[2],10)
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
	print("score: "..score,1,1)
	print("["..snake_position[1].x..","..snake_position[1].y.."]",1,7)
	--print("["..snake_position[2].x..","..snake_position[2].y.."]",30,7)
	print("t: "..update_time,1,13)
	print(update_speed,1,20)
	
	--debug
 for i=1,#segments_map do
  print('('..segments_map[i].s.x..','..segments_map[i].s.y..')'..'('..segments_map[i].e.x..','..segments_map[i].e.y..')',1,i*10+50)
 
 end
end
-->8
-- update functions
//todo: buffer
function update_input()
	if btn(➡️) then
		direction = {x=1, y=0}
	elseif btn(⬅️) then
		direction = {x=-1, y=0}
	elseif btn(⬇️) then
		direction = {x=0, y=1}
	elseif btn(⬆️) then
		direction = {x=0, y=-1}
	end
end



function update_snake()
	--update tail
	tail_pos=pos_cpy(snake_position[snake_size])
	del_collision(tail_pos)
	--update body
	for cell=snake_size,2,-1 do
 		snake_position[cell]=pos_cpy(snake_position[cell-1])
 end
 --update head
 local dir=grid_game_position(direction)
 snake_position[1] = pos_add(snake_position[1],dir)
 if snake_position[2]!=nil then
  add_collision(snake_position[2])
 end 
end

function check_collision()
 local head=snake_position[1]
	local seg=get_segment(head)
	for col in all(seg) do
		if pos_equals(col,head) then
			_init()
		end
	end
	if pos_equals(head_fruit_pos) then
	
	end

--	for wall in all(wall_pos) do
--		if pos_equals(wall,snake_position[1]) then
--		 _init()
--		end
--	end
--	for cell=2,#snake_position do
--		if pos_equals(snake_position[cell],snake_position[1]) then
--			_init()
--		end
--	end 
end

-->8
-- utilities
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
-->8
--building functions


function build_snake()
	snake_position[1] = grid_game_position({x=tile_num.x/2,y=tile_num.y/2})
	for cell=2,snake_size do
		local pos=pos_cpy(snake_position[cell-1])
		local diff=grid_game_position({x=-direction.x,y=-direction.y})
		pos.x+=diff.x
		pos.y+=diff.y
		snake_position[cell]=pos
		add_collision(pos)
	end
end

function build_wall()
	slot=1
	--horizontal
	for i=0,tile_num.x-1 do
		wall_pos[slot]=grid_game_position({x=i,y=0})
		add_collision(wall_pos[slot])
		wall_pos[slot+1]=grid_game_position({x=i,y=tile_num.y-1})
		add_collision(wall_pos[slot+1])
		slot+=2
	end
	--vertical
	for i=0,tile_num.y-2 do
		wall_pos[slot]=grid_game_position({x=0,y=i})
		add_collision(wall_pos[slot])
		wall_pos[slot+1]=grid_game_position({x=tile_num.x-1,y=i})
		add_collision(wall_pos[slot+1])
		slot+=2
	end
end
-->8
--segments

function get_segment(pos)
	for i=1,#segments_map do
		local seg=segments_map[i]
		if pos.x>=seg.s.x and pos.x<=seg.e.x and pos.y>=seg.s.y and pos.y<=seg.e.y then
			return segments[i]
		end
	end
	return nil
end

function add_collision(pos)
 local seg=get_segment(pos)
 for col in all(seg) do
  if pos_equals(col,pos) then
   break
  end
 end
 add(seg,pos_cpy(pos))
end

function del_collision(pos)
	local seg=get_segment(pos)
	for col in all(seg) do
		if pos_equals(col,pos) then
			del(seg,col)
			break
		end
	end
end

function build_segments_map()
	counter=1
	for i=0,segment_num.x do
		for j=0,segment_num.y do
		 local x_min=i*seg_ratio.x
		 local x_max=(i+1)*seg_ratio.x
		 local y_min=j*seg_ratio.y
		 local y_max=(j+1)*seg_ratio.y
		 segments_map[counter]={s={x=x_min,y=y_min},e={x=x_max,y=y_max}}
		 segments[counter]={}
		 counter+=1
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
