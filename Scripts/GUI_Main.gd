
extends Control

var main_node = null

func _ready():
	main_node = get_tree().get_root().get_node("Main")

func change_tile(num, map):
	main_node.current_tile = num
	main_node.current_tile_map = map
	# check number, decide whether it can be flipped horizontally (x) or vertically (y), 
	# then restrict movement in the main_node script

func _on_FloorSupports_pressed():
	change_tile(4, 0)

func _on_WallWood_pressed():
	change_tile(7, 0)

func _on_WallWoodBack_pressed():
	change_tile(8, 2)

func _on_WallStone_pressed():
	change_tile(11,0)

func _on_WallStoneBack_pressed():
	change_tile(12,2)

func _on_WallBrick_pressed():
	change_tile(9,0)

func _on_WallBrickBack_pressed():
	change_tile(10,2)

func _on_WallCork_pressed():
	change_tile(13,0)

func _on_WallCorkBack_pressed():
	change_tile(14,2)

func _on_FloorNormal_pressed():
	change_tile(5,1)

func _on_RoofFlat_pressed():
	change_tile(15,1)

func _on_RoofAngled_pressed():
	change_tile(16,0)

func _on_Stairs_pressed():
	change_tile(6,1)

func _on_Door_pressed():
	change_tile(2,1)

func _on_Bed_pressed():
	change_tile(3,1)
