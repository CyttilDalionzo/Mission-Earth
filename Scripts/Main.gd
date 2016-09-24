
extends Node2D

var main_camera = null

var screen_width = 0
var screen_height = 0

var grid_width = 0
var grid_height = 0
var cell_size = 150

var level_width = 15
var level_height = 15
var current_tile = 0
var current_tile_map = 0
var current_flip_x = 0
var current_flip_y = 0
var current_transpose = 0

var level_grid = []
var tile_map = [null, null, null]
var preview_tile_map = null
var old_preview = [0,0]

# main_camera.set_zoom(Vector2(2,2))

func _ready():
	set_process_input(true)
	set_process(true)
	
	main_camera = get_node("MainCamera")
	tile_map[0] = get_node("TileMapFront")
	tile_map[1] = get_node("TileMapMiddle")
	tile_map[2] = get_node("TileMapBack")
	preview_tile_map = get_node("PreviewTileMap")
	
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
				tile_map[0].set_cell(j,i,0)
			elif(i > level_height*0.5):
				level_grid[i][j] = 2
				tile_map[0].set_cell(j,i,1)
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
	# check if mouse button clicked      (or use ev.pos)
	var mouse_pos = get_global_mouse_pos()
	var grid_pos_x = floor(mouse_pos.x/cell_size)
	var grid_pos_y = floor(mouse_pos.y/cell_size)
	
	# arbitrary check to make sure we can't place things underneath GUI  (NEEDS TO BE IMPROVED)
	if(ev != null && ev.pos.length() > 0 && ev.pos.y > get_node("CanvasLayer/Control/TabContainer").get_pos().y):
		return
	
	if (ev.type == InputEvent.MOUSE_BUTTON):
		if(ev.pressed):
			var button = ev.button_index
			if(button == BUTTON_LEFT):
				tile_map[current_tile_map].set_cell(grid_pos_x,grid_pos_y, current_tile, current_flip_x, current_flip_y, current_transpose)
			elif(button == BUTTON_MIDDLE):
				current_flip_x = (current_flip_x+1+current_transpose)%2
				current_transpose = (current_transpose+1)%2
				current_flip_y = abs(current_flip_x - current_transpose)
			elif(button == BUTTON_RIGHT):
				for i in range(3):
					if(tile_map[i].get_cell(grid_pos_x, grid_pos_y) != -1):
						tile_map[i].set_cell(grid_pos_x, grid_pos_y, -1)
						break
			elif(button == BUTTON_WHEEL_UP):
				main_camera.set_zoom(Vector2(1.5,1.5))
			elif(button == BUTTON_WHEEL_DOWN):
				main_camera.set_zoom(Vector2(1,1))
		# check if mouse is moving
	elif (ev.type == InputEvent.MOUSE_MOTION):
		# get_node("Light2D").set_pos(Vector2(mouse_pos.x, mouse_pos.y))
		if(grid_pos_x != old_preview[0] || grid_pos_y != old_preview[1]): 
			preview_tile_map.set_cell(old_preview[0], old_preview[1], -1)
			preview_tile_map.set_cell(grid_pos_x, grid_pos_y, current_tile, current_flip_x, current_flip_y, current_transpose)
			old_preview = [grid_pos_x, grid_pos_y]
		# test_sprite.set_pos(Vector2(grid_pos_x*cell_size, grid_pos_y*cell_size))

func _process(delta):
	move_camera()

func move_camera():
	# move camera if mouses comes at the edges
	# clamp movement according to grid limits
	# TO DO: Take into account zoom
	var mouse_pos = main_camera.get_viewport().get_mouse_pos()
	# var temp_zoom = main_camera.get_zoom()
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



