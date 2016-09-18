
extends Node2D

var test_sprite = null
var main_camera = null

var screen_width = 0
var screen_height = 0

var grid_width = 0
var grid_height = 0
var cell_size = 150

var level_width = 15
var level_height = 15

var level_grid = []
var tile_map = null

# main_camera.set_zoom(Vector2(2,2))

func _ready():
	set_process_input(true)
	set_process(true)
	
	test_sprite = get_node("Sprite")
	main_camera = get_node("MainCamera")
	tile_map = get_node("TileMap")
	
	screen_width = get_viewport_rect().size.width
	screen_height = get_viewport_rect().size.height
	
	grid_width = cell_size*level_width
	grid_height = cell_size*level_height
	
	initialize_tiles()

func initialize_tiles():
	level_grid.resize(level_height)
	
	for i in range(0, level_height):
		level_grid[i] = []
		level_grid[i].resize(level_width)
		for j in range(0, level_width):
			if(i == floor(level_height*0.5)):
				level_grid[i][j] = 1
				tile_map.set_cell(j,i,0)
			elif(i > level_height*0.5):
				level_grid[i][j] = 2
				tile_map.set_cell(j,i,1)
			else:
				level_grid[i][j] = 0

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

func _input(ev):
	# check if mouse button clicked
	var mouse_pos = get_global_mouse_pos()
	var grid_pos_x = round(mouse_pos.x/cell_size)
	var grid_pos_y = round(mouse_pos.y/cell_size)
	
	if (ev.type == InputEvent.MOUSE_BUTTON):
		if(ev.pressed):
			print("Mouse Click/Unclick at: ", ev.pos)
			tile_map.set_cell(grid_pos_x,grid_pos_y,0)
		# check if mouse is moving
	elif (ev.type == InputEvent.MOUSE_MOTION):
		test_sprite.set_pos(Vector2(grid_pos_x*cell_size, grid_pos_y*cell_size))

func _process(delta):
	move_camera()

func move_camera():
	# move camera if mouses comes at the edges
	# clamp movement according to grid limits
	# TO DO: Take into account zoom
	var mouse_pos = main_camera.get_viewport().get_mouse_pos()
	var left_side = 1
	if(mouse_pos.x < screen_width*0.5):
		left_side = -1
	var top_side = 1
	if(mouse_pos.y < screen_height*0.5):
		top_side = -1
	
	var check_bounds_x = abs(mouse_pos.x - screen_width*0.5)
	var check_bounds_y = abs(mouse_pos.y - screen_height*0.5)
	
	if check_bounds_x > screen_width*0.4:
		main_camera.set_pos(Vector2(clamp(main_camera.get_pos().x+8*left_side, 0, grid_width-screen_width), main_camera.get_pos().y))
	
	if check_bounds_y > screen_height*0.4:
		main_camera.set_pos(Vector2(main_camera.get_pos().x, clamp(main_camera.get_pos().y+8*top_side, 0, grid_height-screen_height)))



