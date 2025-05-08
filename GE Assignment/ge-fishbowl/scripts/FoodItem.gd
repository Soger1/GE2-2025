extends RigidBody3D

#this is the fooditem that the fish are feed

@export var nutritional_value: float = 1.0  
@export var lifetime: float = 60.0

var time_alive: float = 0.0
var initial_position: Vector3
@onready var audio_player = $AudioStreamPlayer3D

#set food position
func _ready():
	initial_position = global_transform.origin
	add_to_group("food")
	gravity_scale = 0.1
	audio_player.play()

#have the food sink then stop slowly
func _process(delta):
	time_alive += delta
	gravity_scale = gravity_scale -0.001
	if gravity_scale <0:
		gravity_scale = 0
	if time_alive > lifetime:
		queue_free()
