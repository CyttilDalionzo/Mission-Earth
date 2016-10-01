
extends Node2D

var level_width
var level_height
var cell_size
var current_mode = 0

# for electricity (0)
var electric_grid = []
var connected_grid = []

# for water (1)
var water_grid = []
var connected_water_grid = []

# for waste/sewer stuff (2)
var waste_grid = []
var connected_waste_grid = []

# for gas (3)
var gas_grid = []
var connected_gas_grid = []

# variable that holds reference to current grid we're working on
var current_grid 
var current_conn_grid

var turned_on
var cable_start
var base_color

var light_sprites = []

func set_variables(a, b, c, d):
	level_width = a
	level_height = b
	cell_size = c
	turned_on = d
	
	cable_start = Vector2(0,round(level_height*0.5+1))
	
	resize_grid_pair(electric_grid, connected_grid)
	resize_grid_pair(water_grid, connected_water_grid)
	resize_grid_pair(waste_grid, connected_waste_grid)
	resize_grid_pair(gas_grid, connected_gas_grid)

func resize_grid_pair(a, b):
	a.resize(level_height)
	b.resize(level_height)
	
	for i in range(0, level_height):
		a[i] = []
		b[i] = []
		a[i].resize(level_width)
		b[i].resize(level_width)
		for j in range(0, level_width):
			a[i][j] = 0
			b[i][j] = 0
			if(i == round(level_height*0.5+1)):
				a[i][j] = 1

func check_connections(i, j):
	var cur_val = current_grid[j][i]
	if(cur_val == 1 || cur_val == 3):
		# check left and right
		if(i > 0 && current_conn_grid[j][i-1] == 0):
			if(current_grid[j][i-1] == 1 || current_grid[j][i-1] == 3):
				current_conn_grid[j][i-1] = 1
				check_connections(i-1, j)
		
		if(i < (level_width-1) && current_conn_grid[j][i+1] == 0):
			if(current_grid[j][i+1] == 1 || current_grid[j][i+1] == 3):
				current_conn_grid[j][i+1] = 1
				check_connections(i+1, j)
	
	if(cur_val == 2 || cur_val == 3):
		# check up and down
		if(j > 0 && current_conn_grid[j-1][i] == 0):
			if(current_grid[j-1][i] == 2 || current_grid[j-1][i] == 3):
				current_conn_grid[j-1][i] = 1
				check_connections(i, j-1)
		
		if(j < (level_height-1) && current_conn_grid[j+1][i] == 0):
			if(current_grid[j+1][i] == 2 || current_grid[j+1][i] == 3):
				current_conn_grid[j+1][i] = 1
				check_connections(i, j+1)

func check_lights():
	for i in range(light_sprites.size()):
		var light_coord = light_sprites[i].corresponding_coord
		light_sprites[i].check_connection(connected_grid[light_coord.y][light_coord.x])

func delete_light(x,y):
	for i in range(light_sprites.size()):
		if(light_sprites[i].corresponding_coord == Vector2(x,y)):
			light_sprites[i].queue_free()
			light_sprites.remove(i)
			break

func clear_grid():
	for i in range(level_height):
		for j in range(level_width):
			current_conn_grid[i][j] = 0

func _draw():
	# temporary fix to eliminate automatic drawing - is there a better way? there must be.
	if(!turned_on):
		return
	
	if(current_mode == 0):
		current_grid = electric_grid
		current_conn_grid = connected_grid
		base_color = Color(0.75, 0.5, 0.0)
	elif(current_mode == 1):
		current_grid = water_grid
		current_conn_grid = connected_water_grid
		base_color = Color(0.0, 0.25, 0.65)
	elif(current_mode == 2):
		current_grid = waste_grid
		current_conn_grid = connected_waste_grid
		base_color = Color(0.55, 0.17, 0.17)
	else:
		current_grid = gas_grid
		current_conn_grid = connected_gas_grid
		base_color = Color(0.075, 0.65, 0.075)
	
	clear_grid()
	
	check_connections(cable_start.x, cable_start.y)
	
	if(current_mode == 0):
		check_lights()
	
	for i in range(level_height):
		for j in range(level_width):
			var num = current_grid[i][j]
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
			
			var color = base_color
			if(current_conn_grid[i][j] == 1):
				color = Color(base_color.r+0.3, base_color.g+0.3, base_color.b+0.3)
			
			if(num != 0):
				draw_line(start, end, color, 5)
				if(num > 2):
					draw_line(start_two, end_two, color, 5)
