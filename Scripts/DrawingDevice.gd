
extends Node2D

var level_width
var level_height
var cell_size
var electric_grid = []

func set_variables(a, b, c):
	level_width = a
	level_height = b
	cell_size = c
	
	electric_grid.resize(level_height)
	
	for i in range(0, level_height):
		electric_grid[i] = []
		electric_grid[i].resize(level_width)
		for j in range(0, level_width):
			electric_grid[i][j] = round(randf()*3)

func _draw():
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
				
				start_two = Vector2(j*cell_size, (i+0.5)*cell_size)
				end_two = Vector2((j+1)*cell_size, (i+0.5)*cell_size)
			
			if(num != 0):
				draw_line(start, end, Color(0.75, 0.5, 0.0), 5)
				if(num > 2):
					draw_line(start_two, end_two, Color(0.75, 0.75, 0.0), 5)
