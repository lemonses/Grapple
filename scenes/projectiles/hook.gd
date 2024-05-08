extends RigidBody2D
@export var hook_speed:int = 1000
var collision:bool
var hand:bool

signal hook_collision(hand)

func _on_body_entered(body):
	hook_collision.emit(hand)
	$FrontPin.node_a = body.get_path()
	collision = true
