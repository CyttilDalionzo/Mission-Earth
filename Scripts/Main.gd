
extends Node2D

var main_camera = null

var screen_width = 0
var screen_height = 0

var grid_width = 0
var grid_height = 0
var cell_size = 150

var level_width = 20
var level_height = 15
var current_tile = 0
var current_tile_map = 0
var current_flip_x = 0
var current_flip_y = 0
var current_flip_dir = 0

var level_grid = []
var tile_map = [null, null, null, null]
var preview_tile_map = null
var old_preview = [0,0]

var bg = null
var canvas_mod = null
var bg_blue = 0
var day_is_done = 0
var day_tracker = 0

var light_preload = null

# main_camera.set_zoom(Vector2(2,2))

#current_flip_x = (current_flip_x+1+current_transpose)%2
#current_transpose = (current_transpose+1)%2
#current_flip_y = abs(current_flip_x - current_transpose)

func _ready():
	tile_map[0] = get_node("TileMapFront")
	tile_map[1] = get_node("TileMapMiddleFront")
	tile_map[2] = get_node("TileMapMiddleBack")
	tile_map[3] = get_node("TileMapBack")
	preview_tile_map = get_node("PreviewTileMap")
	
	light_preload = preload("res://Light.tscn")
	
	bg = get_node("Background/SolidWhite")
	canvas_mod = get_node("CanvasModulate")
	
	screen_width = get_viewport_rect().size.width
	screen_height = get_viewport_rect().size.height
	
	grid_width = cell_size*level_width
	grid_height = cell_size*level_height
	
	main_camera = get_node("MainCamera")
	main_camera.set_limit(MARGIN_TOP, 0)
	main_camera.set_limit(MARGIN_LEFT, 0)    
	main_camera.set_limit(MARGIN_RIGHT, grid_width)
	main_camera.set_limit(MARGIN_BOTTOM, grid_height)
	
	initialize_tiles()
	
	set_process_input(true)
	set_process(true)

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
	
	if (ev.type == InputEvent.MOUSE_BUTTON):
		# arbitrary check to make sure we can't place things underneath GUI  (NEEDS TO BE IMPROVED)
		if(ev != null && ev.pos.length() > 0 && ev.pos.y > get_node("CanvasLayer/Control/TabContainer").get_pos().y):
			return
		if(ev.pressed):
			var button = ev.button_index
			if(button == BUTTON_LEFT):
				tile_map[current_tile_map].set_cell(grid_pos_x,grid_pos_y, current_tile, current_flip_x, current_flip_y)
				finish_placement(current_tile, grid_pos_x, grid_pos_y)
			elif(button == BUTTON_MIDDLE):
				if(current_flip_dir == 0):
					current_flip_x = (current_flip_x+1)%2
					current_flip_y = 0
				else:
					current_flip_y = (current_flip_y+1)%2
					current_flip_x = 0
			elif(button == BUTTON_RIGHT):
				for i in range(3):
					if(tile_map[i].get_cell(grid_pos_x, grid_pos_y) != -1):
						tile_map[i].set_cell(grid_pos_x, grid_pos_y, -1)
						break
			elif(button == BUTTON_WHEEL_UP):
				var max_zoom = min(grid_width/screen_width, grid_height/screen_height)
				var next_zoom = clamp(main_camera.get_zoom().x+1.1, 1, max_zoom)
				main_camera.set_zoom(Vector2(next_zoom, next_zoom))
			elif(button == BUTTON_WHEEL_DOWN):
				main_camera.set_zoom(Vector2(1,1))
		# check if mouse is moving
	elif (ev.type == InputEvent.MOUSE_MOTION):
		if(grid_pos_x != old_preview[0] || grid_pos_y != old_preview[1]): 
			preview_tile_map.set_cell(old_preview[0], old_preview[1], -1)
			preview_tile_map.set_cell(grid_pos_x, grid_pos_y, current_tile, current_flip_x, current_flip_y)
			old_preview = [grid_pos_x, grid_pos_y]

func _process(delta):
	move_camera()
	day_night_cycle()

func day_night_cycle():
	day_tracker += 0.001
	if(day_is_done == 0):
		bg_blue += 0.001
	else:
		bg_blue -= 0.001
	
	if(bg_blue >= 1):
		day_is_done = 1
	elif(bg_blue <= -1):
		day_is_done = 0
		
	bg.set_modulate(Color(bg_blue, bg_blue, bg_blue))
	get_node("SunLight").set_pos(Vector2(cos(PI+0.5*PI*day_tracker)*screen_width*0.5 + screen_width*0.5, sin(PI+0.5*PI*day_tracker)*screen_height + screen_height))
	get_node("SunLight").set_energy(bg_blue*20)
	canvas_mod.set_color(Color(bg_blue, bg_blue, bg_blue))

func finish_placement(n, pos_x, pos_y):
	if(n >= 19 && n <= 21):
		var new_light = light_preload.instance()
		if(n == 19):
			new_light.set_energy(1)
			new_light.set_texture_scale(4)
		elif(n == 20):
			new_light.set_energy(1.25)
			new_light.set_color(Color(0.9, 0.9, 0.9))
			new_light.get_child(0).set_modulate(Color(0.9, 0.9, 0.9))
			new_light.set_texture_scale(4.5)
		elif(n == 21):
			new_light.set_energy(1.5)
			new_light.set_color(Color(0.95, 0.95, 0.95))
			new_light.get_child(0).set_modulate(Color(1.0, 1.0, 1.0))
			new_light.set_texture_scale(5)
		new_light.set_pos(Vector2((pos_x+0.5)*cell_size, (pos_y+0.5)*cell_size))
		self.add_child(new_light)

func move_camera():
	# Somehow, the camera lags behind a bit?
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
		main_camera.set_pos(Vector2(main_camera.get_pos().x+8*left_side, main_camera.get_pos().y))
	
	if check_bounds_y > screen_height*0.4:
		main_camera.set_pos(Vector2(main_camera.get_pos().x, main_camera.get_pos().y+8*top_side))



