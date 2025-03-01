pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- engine functions
snake_position = {}
wall_pos = {}
snake_size = 4
score = 0
tail_pos=nil

margin=0.1

--logic variables
tile_num={x=16,y=32}
tile_size={x=64/tile_num.x,y=128/tile_num.y}

--loop variables
update_speed = 0.1
update_time = 0


function _init()
	direction = {x=1,y=0}
	build_snake()
	build_wall()
	direction = {x=0,y=1}
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
	
	flip()
end
-->8
-- draw functions
function draw_tile(pos,col)
	rectfill(pos.x+margin,pos.y+margin,
		pos.x+tile_size.x-1-margin,pos.y+tile_size.y-1-margin,col)
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

function draw_score()
	color(9)
	print("score: "..score,1,1)
	print("["..snake_position[1].x..","..snake_position[1].y.."]",1,7)
	--print("["..snake_position[2].x..","..snake_position[2].y.."]",30,7)
	print("t: "..update_time,1,13)
	print(update_speed,1,20)
end
-->8
-- update functions
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
	tail_pos=pos_cpy(snake_position[snake_size])
	for cell=snake_size,2,-1 do
 		snake_position[cell]=pos_cpy(snake_position[cell-1])
 end
 //update head
 local pos = grid_game_position(direction)
 snake_position[1].x += pos.x
 snake_position[1].y += pos.y
 
end

function check_collision()
	for wall in all(wall_pos) do
		if pos_equals(wall,snake_position[1]) then
		 _init()
		end
	end
	for cell=2,#snake_position do
		if pos_equals(snake_position[cell],snake_position[1]) then
			_init()
		end
	end
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
	return pos_a.x==pos_b.x and pos_a.y==pos_b.y
end
-->8
--building functions
function build_snake()
	snake_position[1] = grid_game_position({x=tile_num.x/2,y=tile_num.y/2})
	for cell=2,snake_size do
		local pos=pos_cpy(snake_position[cell-1])
		local diff=grid_game_position({x=direction.x,y=direction.y})
		pos.x+=diff.x
		pos.y+=diff.y
		snake_position[cell]=pos
	end
end

function build_wall()
	slot=1
	--horizontal
	for i=0,tile_num.x-1 do
		wall_pos[slot]=grid_game_position({x=i,y=0})
		wall_pos[slot+1]=grid_game_position({x=i,y=tile_num.y-1})
		slot+=2
	end
	--vertical
	for i=0,tile_num.y-2 do
		wall_pos[slot]=grid_game_position({x=0,y=i})
		wall_pos[slot+1]=grid_game_position({x=tile_num.x-1,y=i})
		slot+=2
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
