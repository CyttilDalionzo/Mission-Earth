
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
var current_tile_size = Vector2(1,1)

var grids = [null, null, null, null]
var tile_map = [null, null, null, null]
var preview_tile_map = null
var old_preview = [0,0]
var placement_allowed = true

var bg = null
var canvas_mod = null
var bg_blue = 0
var day_is_done = 0
var day_tracker = 0

var light_preload = null

var money = 1234
var health = 100
var hunger = 100
var thirst = 100
var happiness = 100

var maintenance_mode = false
var drawing_device = null

var start_mouse_pos
var max_zoom

# main_camera.set_zoom(Vector2(2,2))

#current_flip_x = (current_flip_x+1+current_transpose)%2
#current_transpose = (current_transpose+1)%2
#current_flip_y = abs(current_flip_x - current_transpose)

func _ready():
	randomize()
	
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
	
	max_zoom = min(grid_width/screen_width, grid_height/screen_height)
	
	main_camera = get_node("MainCamera")
	main_camera.set_limit(MARGIN_TOP, 0)
	main_camera.set_limit(MARGIN_LEFT, 0)    
	main_camera.set_limit(MARGIN_RIGHT, grid_width)
	main_camera.set_limit(MARGIN_BOTTOM, grid_height)
	
	drawing_device = get_node("DrawingDevice")
	drawing_device.set_variables(level_width, level_height, cell_size, false)
	
	get_node("Grid").set_variables(grid_width, grid_height, cell_size)
	
	for i in range(4):
		initialize_tiles(i)
	
	update_player_properties()
	
	set_process_input(true)
	set_process(true)

func initialize_tiles(n):
	grids[n] = []
	grids[n].resize(level_height)
	
	for i in range(level_height):
		grids[n][i] = []
		grids[n][i].resize(level_width)
		for j in range(level_width):
			grids[n][i][j] = 0
	
	if(n == 0):
		get_node("UndergroundMud").set_pos(Vector2(0, level_height*0.5*cell_size-cell_size*0.5))
		get_node("UndergroundMud").set_region_rect(Rect2(0,0, grid_width, grid_height*0.5))
		for i in range(level_height):
			for j in range(level_width):
				if(i == floor(level_height*0.5)):
					grids[n][i][j] = 1
					tile_map[0].set_cell(j,i,0)
				elif(i > level_height*0.5):
					grids[n][i][j] = 2
					tile_map[0].set_cell(j,i,1)
				else:
					grids[n][i][j] = 0

func _input(ev):
	if(ev.type == InputEvent.KEY):
		if(Input.is_action_pressed("secondary_left")):
			move_camera(Vector2(-1,0))
		elif(Input.is_action_pressed("secondary_right")):
			move_camera(Vector2(1,0))
		
		if(Input.is_action_pressed("secondary_up")):
			move_camera(Vector2(0,-1))
		elif(Input.is_action_pressed("secondary_down")):
			move_camera(Vector2(0,1))
	
	# check if mouse button clicked      (or use ev.pos)
	var mouse_pos = get_global_mouse_pos()
	var grid_pos_x = floor(mouse_pos.x/cell_size)
	var grid_pos_y = floor(mouse_pos.y/cell_size)
	
	if (ev.type == InputEvent.MOUSE_BUTTON):
		# arbitrary check to make sure we can't place things underneath GUI  (NEEDS TO BE IMPROVED)
		if(ev.pos.y > get_node("GUI/Control/TabContainer").get_pos().y):
			return
		
		var button = ev.button_index
		if(ev.pressed):
			if(button == BUTTON_LEFT || button == BUTTON_RIGHT):
				start_mouse_pos = Vector2(grid_pos_x, grid_pos_y)
			elif(button == BUTTON_MIDDLE):
				if(current_flip_dir == 0):
					current_flip_x = (current_flip_x+1)%2
					current_flip_y = 0
				else:
					current_flip_y = (current_flip_y+1)%2
					current_flip_x = 0
			elif(button == BUTTON_WHEEL_UP):
				var next_zoom = clamp(main_camera.get_zoom().x+0.05, 1, max_zoom)
				main_camera.set_zoom(Vector2(next_zoom, next_zoom))
			elif(button == BUTTON_WHEEL_DOWN):
				var next_zoom = clamp(main_camera.get_zoom().x-0.05, 1, max_zoom)
				main_camera.set_zoom(Vector2(next_zoom,next_zoom))
		else:
			if(button == BUTTON_LEFT || button == BUTTON_RIGHT):
				var delete_tiles = false
				if(button == BUTTON_RIGHT):
					delete_tiles = true
				
				if(grid_pos_x == start_mouse_pos.x):
					# Place stuff on vertical line
					var dist = abs(start_mouse_pos.y - grid_pos_y)
					var min_y = min(start_mouse_pos.y, grid_pos_y)
					for i in range(dist+1):
						if(delete_tiles):
							remove_part(grid_pos_x, min_y+i)
						else:
							finish_placement(current_tile, grid_pos_x, min_y+i, 2)
				elif(grid_pos_y == start_mouse_pos.y):
					# Place stuff on horizontal line
					var dist = abs(start_mouse_pos.x - grid_pos_x)
					var min_x = min(start_mouse_pos.x, grid_pos_x)
					for i in range(dist+1):
						if(delete_tiles):
							remove_part(min_x+i, grid_pos_y)
						else:
							finish_placement(current_tile, min_x+i, grid_pos_y, 1)
				else:
					# Place a single block
					if(delete_tiles):
						remove_part(grid_pos_x, grid_pos_y)
					else:
						finish_placement(current_tile, grid_pos_x, grid_pos_y, 0)
	# check if mouse is moving
	elif (ev.type == InputEvent.MOUSE_MOTION):
		if(!maintenance_mode):
			if(grid_pos_x != old_preview[0] || grid_pos_y != old_preview[1]): 
				preview_tile_map.set_cell(old_preview[0], old_preview[1], -1)
				preview_tile_map.set_cell(grid_pos_x, grid_pos_y, current_tile, current_flip_x, current_flip_y)
				old_preview = [grid_pos_x, grid_pos_y]
				placement_allowed = true
				for i in range(current_tile_size.y):
					for j in range(current_tile_size.x):
						if(grids[current_tile_map][grid_pos_y+i][grid_pos_x+j] != 0):
							# need to find a way to show something can't be placed, and to actually forbid placement
							preview_tile_map.set_cell(grid_pos_x, grid_pos_y, 0)
							placement_allowed = false

func remove_part(pos_x, pos_y):
	if(maintenance_mode):
		drawing_device.current_grid[pos_y][pos_x] = 0
		drawing_device.update()
	else:
		var remove_this = -1
		var cur_num = -1
		for i in range(4):
			cur_num = tile_map[i].get_cell(pos_x, pos_y)
			if(cur_num != -1):
				remove_this = i
				break
		for i in range(4):
			cur_num = tile_map[i].get_cell(pos_x, pos_y)
			if(cur_num == current_tile):
				remove_this = i
				break
		if(remove_this != -1):
			tile_map[remove_this].set_cell(pos_x, pos_y, -1)
			if(cur_num >= 21 && cur_num <= 23):
				drawing_device.delete_light(pos_x, pos_y)

func finish_placement(n, pos_x, pos_y, dir):
	if(maintenance_mode):
		var current_tile = drawing_device.current_grid[pos_y][pos_x]
		if(current_tile != 0 && current_tile != dir):
			dir = 3
		drawing_device.current_grid[pos_y][pos_x] = dir
		drawing_device.update()
	else:
		if(!placement_allowed):
			return
		
		# set tile map, and corresponding grid array cell(s), to correct number
		tile_map[current_tile_map].set_cell(pos_x, pos_y, n, current_flip_x, current_flip_y)
		for i in range(current_tile_size.y):
			for j in range(current_tile_size.x):
				grids[current_tile_map][pos_y+i][pos_x+j] = n
		
		
		# add lights, if applicable
		if(n >= 21 && n <= 23):
			var new_light = light_preload.instance()
			if(n == 21):
				new_light.set_energy(1)
				new_light.set_texture_scale(4)
			elif(n == 22):
				new_light.set_energy(1.25)
				new_light.set_color(Color(0.9, 0.9, 0.9))
				new_light.get_child(0).set_modulate(Color(0.9, 0.9, 0.9))
				new_light.set_texture_scale(4.5)
			elif(n == 23):
				new_light.set_energy(1.5)
				new_light.set_color(Color(0.95, 0.95, 0.95))
				new_light.get_child(0).set_modulate(Color(1.0, 1.0, 1.0))
				new_light.set_texture_scale(5)
			new_light.set_pos(Vector2((pos_x+0.5)*cell_size, (pos_y+0.5)*cell_size))
			self.add_child(new_light)
			new_light.corresponding_coord = Vector2(pos_x, pos_y)
			new_light.check_connection(drawing_device.connected_grid[pos_y][pos_x])
			drawing_device.light_sprites.append(new_light)

func move_camera(dir):
	main_camera.set_pos(Vector2(clamp(main_camera.get_pos().x+dir.x*25, 0, grid_width), clamp(main_camera.get_pos().y+dir.y*25, 0, grid_height)))

func _process(delta):
	day_night_cycle()

func update_player_properties():
	get_node("GUI/PlayerProperties/Health").set_size(Vector2(health*1.8,20))
	get_node("GUI/PlayerProperties/Hunger").set_size(Vector2(hunger*1.8,20))
	get_node("GUI/PlayerProperties/Thirst").set_size(Vector2(thirst*1.8,20))
	get_node("GUI/PlayerProperties/Happiness").set_size(Vector2(happiness*1.8,20))
	
	get_node("GUI/PlayerProperties/Money").set_text(str(money))

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
	
	if(maintenance_mode):
		bg.set_modulate(Color(0.25, 0.25, 0.25))
		canvas_mod.set_color(Color(0.25, 0.25, 0.25))
	else:
		bg.set_modulate(Color(bg_blue, bg_blue, bg_blue))
		get_node("SunLight").set_pos(Vector2(cos(PI+0.5*PI*day_tracker)*screen_width*0.5 + screen_width*0.5, sin(PI+0.5*PI*day_tracker)*screen_height + screen_height))
		get_node("SunLight").set_energy(bg_blue*20)
		canvas_mod.set_color(Color(bg_blue, bg_blue, bg_blue))

#func move_camera():
#	var mouse_pos = main_camera.get_viewport().get_mouse_pos()
#
#	var left_side = 1
#	if(mouse_pos.x < screen_width*0.5):
#		left_side = -1
#	var top_side = 1
#	if(mouse_pos.y < screen_height*0.5):
#		top_side = -1
#	
#	var check_bounds_x = abs(mouse_pos.x - screen_width*0.5)
#	var check_bounds_y = abs(mouse_pos.y - screen_height*0.5)
#	
#	if check_bounds_x > screen_width*0.4:
#		main_camera.set_pos(Vector2(clamp(main_camera.get_pos().x+8*left_side, 0, grid_width), main_camera.get_pos().y))
#	
#	if check_bounds_y > screen_height*0.4:
#		main_camera.set_pos(Vector2(main_camera.get_pos().x, clamp(main_camera.get_pos().y+8*top_side, 0, grid_height)))
	



