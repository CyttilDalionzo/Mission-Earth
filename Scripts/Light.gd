
extends Light2D

var corresponding_coord

func check_connection(c):
	if(c == 0):
		hide()
	else:
		show()