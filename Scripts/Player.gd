extends KinematicBody2D

const GRAVITY = 1400.0
var velocity = Vector2()
const WALK_SPEED = 500

func _fixed_process(delta):
	if (Input.is_action_pressed("ui_left")):
		velocity.x = -WALK_SPEED
	elif (Input.is_action_pressed("ui_right")):
		velocity.x = WALK_SPEED
	else:
		velocity.x = 0
	
	if (Input.is_action_pressed("ui_up")):
		velocity.y = -GRAVITY*0.4
	elif (Input.is_action_pressed("ui_down")):
		pass # velocity.y = 1
	
	# velocity = velocity.normalized()
	velocity.y += delta * GRAVITY
	
	var motion = velocity * delta
	motion = move(motion)
	
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)

func _ready():
	set_fixed_process(true)


