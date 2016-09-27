
extends Node2D

var grid_width
var grid_height
var cell_size

func set_variables(a, b, c):
	grid_width = a
	grid_height = b
	cell_size = c

# GRID
func _draw():
	var cur_width = 0
	var cur_height = 0
	
	while cur_width < grid_width:
		draw_line(Vector2(cur_width,0), Vector2(cur_width, grid_height), Color(0, 0.17, 0, 0.5), 3)
		cur_width += cell_size
	
	while cur_height < grid_height:
		draw_line(Vector2(0,cur_height), Vector2(grid_width, cur_height), Color(0, 0.17, 0, 0.5), 3)
		cur_height += cell_size

