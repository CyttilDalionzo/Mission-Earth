
extends Control

var main_node = null

func _ready():
	main_node = get_tree().get_root().get_node("Main")

func change_tile(num, map):
	main_node.current_tile = num
	main_node.current_tile_map = map

func _on_FloorSupports_pressed():
	change_tile(3, 0)

func _on_WallWood_pressed():
	change_tile(5, 0)

func _on_WallWoodBack_pressed():
	change_tile(6, 2)

func _on_WallStone_pressed():
	change_tile(13,0)

func _on_WallBrick_pressed():
	change_tile(12,0)

func _on_WallCork_pressed():
	change_tile(14,0)

func _on_FloorNormal_pressed():
	change_tile(4,1)

func _on_RoofFlat_pressed():
	change_tile(7,1)

func _on_Stairs_pressed():
	change_tile(11,1)
