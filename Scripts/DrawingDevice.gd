
extends Node2D

var level_width
var level_height
var cell_size
var electric_grid = []
var connected_grid = []
var turned_on
var cable_start

var light_sprites = []

func set_variables(a, b, c, d):
	level_width = a
	level_height = b
	cell_size = c
	turned_on = d
	
	electric_grid.resize(level_height)
	connected_grid.resize(level_height)
	
	cable_start = Vector2(0,round(level_height*0.5+1))
	
	for i in range(0, level_height):
		electric_grid[i] = []
		connected_grid[i] = []
		electric_grid[i].resize(level_width)
		connected_grid[i].resize(level_width)
		for j in range(0, level_width):
			electric_grid[i][j] = 0
			connected_grid[i][j] = 0
			if(i == round(level_height*0.5+1)):
				electric_grid[i][j] = 1

func check_connections(i, j):
	var cur_val = electric_grid[j][i]
	if(cur_val == 1 || cur_val == 3):
		# check left and right
		if(i > 0 && connected_grid[j][i-1] == 0):
			if(electric_grid[j][i-1] == 1 || electric_grid[j][i-1] == 3):
				connected_grid[j][i-1] = 1
				check_connections(i-1, j)
		
		if(i < (level_width-1) && connected_grid[j][i+1] == 0):
			if(electric_grid[j][i+1] == 1 || electric_grid[j][i+1] == 3):
				connected_grid[j][i+1] = 1
				check_connections(i+1, j)
	
	if(cur_val == 2 || cur_val == 3):
		# check up and down
		if(j > 0 && connected_grid[j-1][i] == 0):
			if(electric_grid[j-1][i] == 2 || electric_grid[j-1][i] == 3):
				connected_grid[j-1][i] = 1
				check_connections(i, j-1)
		
		if(j < (level_height-1) && connected_grid[j+1][i] == 0):
			if(electric_grid[j+1][i] == 2 || electric_grid[j+1][i] == 3):
				connected_grid[j+1][i] = 1
				check_connections(i, j+1)

func check_lights():
	for i in range(light_sprites.size()):
		var light_coord = light_sprites[i].corresponding_coord
		light_sprites[i].check_connection(connected_grid[light_coord.y][light_coord.x])

func delete_light(x,y):
	for i in range(light_sprites.size()):
		if(light_sprites[i].corresponding_coord == Vector2(x,y)):
			light_sprites[i].free()
			light_sprites.remove(i)

func _draw():
	# temporary fix to eliminate automatic drawing - is there a better way? there must be.
	if(!turned_on):
		return
	
	for i in range(level_height):
		for j in range(level_width):
			connected_grid[i][j] = 0
	
	check_connections(cable_start.x, cable_start.y)
	check_lights()
	
	for i in range(level_height):
		for j in range(level_width):
			var num = electric_grid[i][j]
			var start
			var end
			var start_two
			var end_two
			
			if(num == 1):
				# Full horizontal
				start = Vector2(j*cell_size, (i+0.5)*cell_size)
				end = Vector2((j+1)*cell_size, (i+0.5)*cell_size)
			elif(num == 2):
				# Full vertical
				start = Vector2((j+0.5)*cell_size, i*cell_size)
				end = Vector2((j+0.5)*cell_size, (i+1)*cell_size)
			elif(num == 3):
				# Crossroads
				start = Vector2(j*cell_size, (i+0.5)*cell_size)
				end = Vector2((j+1)*cell_size, (i+0.5)*cell_size)
				
				start_two = Vector2((j+0.5)*cell_size, i*cell_size)
				end_two = Vector2((j+0.5)*cell_size, (i+1)*cell_size)
			
			var color = Color(0.75, 0.5, 0.0)
			if(connected_grid[i][j] == 1):
				color = Color(1.0, 0.0, 0.0)
			
			if(num != 0):
				draw_line(start, end, color, 5)
				if(num > 2):
					draw_line(start_two, end_two, color, 5)
