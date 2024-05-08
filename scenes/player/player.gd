extends RigidBody2D

var on_floor:bool = false
@export var left_pos:Vector2
@export var right_pos:Vector2

signal grapple(pos,direction,hand)
signal ungrapple(hand)
var stop_movement = false
var stored_velocity

func _physics_process(delta):
	if Input.is_action_pressed("right") and linear_velocity.x < 500 :
		linear_velocity.x += 3000 * delta
	if Input.is_action_pressed("left") and linear_velocity.x > -500 :
		linear_velocity.x -= 3000 * delta
	if Input.is_action_pressed("jump"):
		if on_floor:
			linear_velocity.y -= 200
		elif linear_velocity.y < 50:
			linear_velocity.y -= 10
	if linear_velocity.y > 500: linear_velocity.y = 500

func _process(_delta):
	grapple_check()
	Globals.player_pos = global_position
	Globals.player_velocity = linear_velocity
	if stop_movement:
		linear_velocity = Vector2(0,0)
	

func _on_area_2d_body_entered(_body):
	on_floor = true

func _on_area_2d_body_exited(_body):
	on_floor = false

func grapple_check():
	right_pos = $RightHand.global_position
	left_pos = $LeftHand.global_position
	if Input.is_action_just_pressed("LeftGrapple"):
		var direction = (get_global_mouse_position() - position).normalized()
		var pos = left_pos
		grapple.emit(pos,direction,true)
	if Input.is_action_just_released("LeftGrapple"):
		ungrapple.emit(true)
	if Input.is_action_just_pressed("RightGrapple"):
		var direction = (get_global_mouse_position() - position).normalized()
		var pos = right_pos
		grapple.emit(pos,direction,false)
	if Input.is_action_just_released("RightGrapple"):
		ungrapple.emit(false)

func stop():
	stop_movement = not stop_movement
	stored_velocity = linear_velocity
	if not stop_movement:
		linear_velocity = stored_velocity
