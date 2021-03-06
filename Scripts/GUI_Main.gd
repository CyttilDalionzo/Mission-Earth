
extends Control

var main_node = null
var drawing_device = null

var single = Vector2(1,1)
var horizontal = Vector2(2,1)
var vertical = Vector2(1,2)
var square = Vector2(2,2)

func _ready():
	main_node = get_tree().get_root().get_node("Main")
	drawing_device = main_node.get_node("DrawingDevice")

# Switch between build and maintenance mode
func _on_MaintenanceToggle_toggled( pressed ):
	main_node.maintenance_mode = pressed
	drawing_device.turned_on = pressed
	drawing_device.update()

func change_tile(num, map, dir, size):
	main_node.current_tile = num
	main_node.current_tile_map = map
	main_node.current_flip_dir = dir
	main_node.current_tile_size = size

#### ALL TILES ####
func _on_Door_pressed():
	change_tile(2, 1, 0, square)

func _on_Bed_pressed():
	change_tile(3, 1, 0, horizontal)

func _on_FloorNormal_pressed():
	change_tile(4, 1, 1, single)

func _on_FloorCarpet_pressed():
	change_tile(5, 1, 1, single)

func _on_FloorCeramic_pressed():
	change_tile(6, 1, 1, single)

func _on_FloorCork_pressed():
	change_tile(7, 1, 1, single)

func _on_WallWood_pressed():
	change_tile(9, 0, 0, single)

func _on_WallWoodBack_pressed():
	change_tile(10, 3, 0, single)

func _on_WallStone_pressed():
	change_tile(13, 0, 0, single)

func _on_WallStoneBack_pressed():
	change_tile(14, 3, 0, single)

func _on_WallBrick_pressed():
	change_tile(11, 0, 0, single)

func _on_WallBrickBack_pressed():
	change_tile(12, 3, 0, single)

func _on_WallCork_pressed():
	change_tile(15, 0, 0, single)

func _on_WallCorkBack_pressed():
	change_tile(16, 3, 0, single)

func _on_RoofFlat_pressed():
	change_tile(17, 1, 1, single)

func _on_RoofAngled_pressed():
	change_tile(18, 0, 0, single)

func _on_Stairs_pressed():
	change_tile(8, 1, 1, single)

func _on_WindowOpen_pressed():
	change_tile(19, 3, 0, single)

func _on_WindowGlass_pressed():
	change_tile(20, 3, 0, single)

func _on_LightBulbBad_pressed():
	change_tile(21, 2, 1, single)

func _on_LightBulbGood_pressed():
	change_tile(22, 2, 1, single)

func _on_LightBulbLED_pressed():
	change_tile(23, 2, 1, single)

func _on_Toilet_pressed():
	change_tile(24, 1, 0, vertical)

func _on_Shower_pressed():
	change_tile(25, 1, 0, vertical)

func _on_Sink_pressed():
	change_tile(26, 1, 0, single)

func _on_Cabinet_pressed():
	change_tile(27, 1, 0, single)

func _on_Microwave_pressed():
	change_tile(28, 1, 0, single)

func _on_Fridge_pressed():
	change_tile(29, 1, 0, vertical)

func _on_Stove_pressed():
	change_tile(30, 1, 0, single)

func _on_Dishwasher_pressed():
	change_tile(31, 1, 0, single)

func _on_WashingMachine_pressed():
	change_tile(32, 1, 0, single)

func _on_Dryer_pressed():
	change_tile(33, 1, 0, single)

func _on_Heater_pressed():
	change_tile(34, 1, 0, single)

func _on_LitterBin_pressed():
	change_tile(35, 1, 0, single)

func _on_Table_pressed():
	change_tile(36, 1, 0, single)

func _on_Chair_pressed():
	change_tile(37, 1, 0, single)

#### CHANGE BETWEEN GRIDS ####
func _on_ElectricGrid_pressed():
	drawing_device.current_mode = 0
	drawing_device.update()
	print("ElectroGrid!")

func _on_WaterGrid_pressed():
	drawing_device.current_mode = 1
	drawing_device.update()
	print("WaterGrid!")
	
func _on_WasteGrid_pressed():
	drawing_device.current_mode = 2
	drawing_device.update()
	print("WasteGrid!")

func _on_GasGrid_pressed():
	drawing_device.current_mode = 3
	drawing_device.update()
	print("GasGrid!")


