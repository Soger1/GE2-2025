extends RigidBody3D

@export var nutritional_value: float = 1.0  
@export var lifetime: float = 60.0
@export var bob_height: float = 0.2
@export var bob_speed: float = 2.0
@export var debug_mode: bool = true

var time_alive: float = 0.0
var initial_position: Vector3

func _ready():
	initial_position = global_transform.origin
	add_to_group("food")
	
	freeze = false 
	gravity_scale = 0.1
	collision_layer = 8  
	collision_mask = 2

func _process(delta):
	time_alive += delta
	if time_alive > lifetime:
		if debug_mode:
			print("Food expired after lifetime: ", lifetime, " seconds")
		queue_free()
	apply_bobbing_effect(delta)
	rotate_y(delta * 0.5)

func apply_bobbing_effect(delta):
	if time_alive > 2.0:
		var bob_offset = sin(time_alive * bob_speed) * bob_height
		global_transform.origin.y = initial_position.y + bob_offset

func _on_body_entered(body):
	if debug_mode:
		print("Food detected collision with: ", body.name)
		
	if body.is_in_group("fish"):
		if debug_mode:
			print("Food collided with fish: ", body.name)
