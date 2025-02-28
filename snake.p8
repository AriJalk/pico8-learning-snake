pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- engine functions
snake_position = {}
wall_pos = {}
snake_size = 4
score = 0

margin=0.1

--logic variables
tile_num=16
tile_size=128/tile_num

--loop variables
update_speed = 0.1
update_time = 0


function _init()
	direction = {x=1,y=0}
	build_snake()
	build_wall()
	direction = {x=0,y=1}
 last_time = time()
 draw()
end

function _update()
	update_input()
	update_time += time()-last_time
	last_time = time()
	if(update_time > update_speed) then
		update_time = 0
		update_snake()
		check_collision()
		draw()
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

function draw()
	cls(1)
 draw_wall()
 draw_snake()
 draw_score()
	flip()
end
-->8
-- draw functions
function draw_tile(x,y,col)
	rectfill(x+margin,y+margin,
		x+tile_size-1-margin,y+tile_size-1-margin,col)
end

function draw_snake()
 for i=2,snake_size do
 	local x = snake_position[i].x
	 local y = snake_position[i].y
	 draw_tile(x,y,10)
 end
 x = snake_position[1].x
	y = snake_position[1].y
	draw_tile(x,y,2)
end

function draw_wall()
	for wall in all(wall_pos) do
		draw_tile(wall.x,wall.y,5)
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
	for cell=snake_size,2,-1 do
 		snake_position[cell]=copy_position(snake_position[cell-1]) 		
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
	local x = tile_size*coordinates.x
	local y = tile_size*coordinates.y
	return {x=x,y=y}
end

function copy_position(origin)
	return {x=origin.x,y=origin.y}
end

function pos_equals(pos_a,pos_b)
	return pos_a.x==pos_b.x and pos_a.y==pos_b.y
end
-->8
--building functions
function build_snake()
	snake_position[1] = grid_game_position({x=tile_num/2,y=tile_num/2})
	for cell=2,snake_size do
		local pos=copy_position(snake_position[cell-1])
		local diff=grid_game_position({x=direction.x,y=direction.y})
		pos.x+=diff.x
		pos.y+=diff.y
		snake_position[cell]=pos
	end
end

function build_wall()
	slot=1
	--horizontal
	for i=0,tile_num-1 do
		wall_pos[slot]=grid_game_position({x=i,y=0})
		wall_pos[slot+1]=grid_game_position({x=i,y=tile_num-1})
		slot+=2
	end
	--vertical
	for i=0,tile_num-2 do
		wall_pos[slot]=grid_game_position({x=0,y=i})
		wall_pos[slot+1]=grid_game_position({x=tile_num-1,y=i})
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
