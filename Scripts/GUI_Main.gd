
extends Control

var main_node = null

func _ready():
	main_node = get_tree().get_root().get_node("Main")

func change_tile(num, map, dir):
	main_node.current_tile = num
	main_node.current_tile_map = map
	main_node.current_flip_dir = dir
	# check number, decide whether it can be flipped horizontally (x) or vertically (y), 
	# then restrict movement in the main_node script

func _on_FloorSupports_pressed():
	change_tile(4, 0, 0)

func _on_WallWood_pressed():
	change_tile(7, 0, 0)

func _on_WallWoodBack_pressed():
	change_tile(8, 3, 0)

func _on_WallStone_pressed():
	change_tile(11, 0, 0)

func _on_WallStoneBack_pressed():
	change_tile(12, 3, 0)

func _on_WallBrick_pressed():
	change_tile(9, 0, 0)

func _on_WallBrickBack_pressed():
	change_tile(10, 3, 0)

func _on_WallCork_pressed():
	change_tile(13, 0, 0)

func _on_WallCorkBack_pressed():
	change_tile(14, 3, 0)

func _on_FloorNormal_pressed():
	change_tile(5, 1, 1)

func _on_RoofFlat_pressed():
	change_tile(15, 1, 1)

func _on_RoofAngled_pressed():
	change_tile(16, 0, 0)

func _on_Stairs_pressed():
	change_tile(6, 1, 1)

func _on_Door_pressed():
	change_tile(2, 1, 0)

func _on_Bed_pressed():
	change_tile(3, 1, 0)

func _on_WindowOpen_pressed():
	change_tile(17, 3, 0)

func _on_WindowGlass_pressed():
	change_tile(18, 3, 0)

func _on_LightBulbBad_pressed():
	change_tile(19, 2, 1)

func _on_LightBulbGood_pressed():
	change_tile(20, 2, 1)

func _on_LightBulbLED_pressed():
	change_tile(21, 2, 1)
