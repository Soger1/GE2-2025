extends Camera3D

# Camera movement speed
@export var move_speed = 5.0

# Optional variables for sprint and movement smoothing
@export var sprint_multiplier = 2.0
@export var smoothing = 0.1

# Variables to track movement
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
	
	# Optional: Sprint when holding Shift
	var final_speed = move_speed
	if Input.is_key_pressed(KEY_SHIFT):
		final_speed *= sprint_multiplier
	
	# Normalize to prevent diagonal movement being faster
	if target_velocity.length() > 0:
		target_velocity = target_velocity.normalized() * final_speed
	
	# Smoothly interpolate current velocity towards target
	velocity = velocity.lerp(target_velocity, smoothing)
	
	# Apply movement
	transform.origin += velocity * delta
