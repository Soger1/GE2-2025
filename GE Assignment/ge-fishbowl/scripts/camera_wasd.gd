extends Camera3D

@export var move_speed = 5.0
@export var smoothing = 0.1

var velocity = Vector3.ZERO
var target_velocity = Vector3.ZERO

func _process(delta):
	# Reset target velocity each frame
	target_velocity = Vector3.ZERO
	
	# Get input direction
	if Input.is_key_pressed(KEY_W):
		target_velocity -= transform.basis.z
	if Input.is_key_pressed(KEY_S):
		target_velocity += transform.basis.z
	if Input.is_key_pressed(KEY_A):
		target_velocity -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		target_velocity += transform.basis.x
	if target_velocity.length() > 0:
		target_velocity = target_velocity.normalized() * move_speed
	
	velocity = velocity.lerp(target_velocity, smoothing)
	
	transform.origin += velocity * delta
