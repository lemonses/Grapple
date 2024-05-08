extends Node2D

var hook_scene:PackedScene = preload("res://scenes/projectiles/hook.tscn")
var rope_scene:PackedScene = preload("res://scenes/projectiles/rope.tscn")
var left_grappling:bool = false
var right_grappling:bool = false
var left_stop_rope:bool = false
var right_stop_rope:bool = false
var stop:bool = false

func _process(_delta):
	create_rope(true)
	create_rope(false)

func _on_player_grapple(pos, direction, hand):
	var hand_base_node
	if hand:
		left_grappling = true
		hand_base_node = $Projectiles/Left
	else:
		right_grappling = true
		hand_base_node = $Projectiles/Right
	var hook = hook_scene.instantiate() as RigidBody2D
	hook.hand = hand
	hook.position = pos
	hook.linear_velocity = (direction * hook.hook_speed) + Globals.player_velocity
	hook.rotation = direction.angle()
	hook.connect('hook_collision',_on_hook_collision)
	hand_base_node.add_child(hook)

func _on_hook_collision(hand):
	if hand:
		left_stop_rope = true
	else:
		right_stop_rope = true
	$Player.stop()
	stop = not stop

func _on_player_ungrapple(hand):
	var children
	if hand:
		left_grappling = false
		left_stop_rope = false
		children = $Projectiles/Left.get_children()
	else:
		right_grappling = false
		right_stop_rope = false
		children =  $Projectiles/Right.get_children()
	if stop:
		$Player.stop()
		stop = not stop
	for child in children:
		child.queue_free()

func create_rope(hand):
	var hand_base_node
	var grapple
	var hand_pos
	var stop_rope
	if hand:
		hand_base_node = $Projectiles/Left
		grapple = left_grappling
		stop_rope = left_stop_rope
		hand_pos = $Player.left_pos
	else:
		hand_base_node = $Projectiles/Right
		grapple = right_grappling
		stop_rope = right_stop_rope
		hand_pos = $Player.right_pos
	var ropes = hand_base_node.get_children()
	if grapple:
		var hook = ropes[ropes.size()-1]
		var pos = hook.get_node("Marker2D").global_position
		var distance = pos.distance_to(hand_pos)
		if distance > 10 and not hook.get_node("BackPin").node_b:
			var rope = rope_scene.instantiate() as RigidBody2D
			rope.position = pos
			hook.rotation = (rope.position - hand_pos).angle() + 90
			rope.rotation = hook.rotation
			rope.linear_velocity = hook.linear_velocity * 0.90
			hand_base_node.add_child(rope)
			hook.get_node("BackPin").node_b = rope.get_path()
			distance = rope.global_position.distance_to(hand_pos)
			if distance < 20 and stop_rope:
				if hand:
					left_stop_rope = false
				else:
					right_stop_rope = false
				rope.get_node("BackPin").node_b = $Player.get_path()
				$Player.stop()
				stop = not stop
