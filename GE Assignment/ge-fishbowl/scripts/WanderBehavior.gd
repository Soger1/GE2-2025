# WanderBehavior.gd
extends Node

# Wander parameters
@export var wander_radius: float = 2.0
@export var wander_distance: float = 4.0
@export var wander_jitter: float = 1.0
@export var wander_interval: float = 1.0  # Time between direction changes

# Internal variables
var parent_fish = null
var wander_target = Vector3.ZERO
var timer = 0.0

func initialize(fish):
	parent_fish = fish
	# Initialize a random wander target
	randomize()
	wander_target = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()

func _process(delta):
	# Update timer
	timer += delta
	if timer >= wander_interval:
		# Time to update wander target
		update_wander_target()
		timer = 0.0

func calculate_steering():
	if parent_fish == null:
		return Vector3.ZERO
	
	# Calculate the wander force
	# 1. Calculate the center of the wander circle
	var circle_center = parent_fish.velocity.normalized() * wander_distance
	
	# 2. Calculate the displacement force
	var displacement = Vector3(wander_target.x, wander_target.y, wander_target.z) * wander_radius
	
	# 3. Project the target onto the wander circle
	var target = circle_center + displacement
	
	# 4. Calculate steering force towards this target
	return target - parent_fish.velocity

func update_wander_target():
	# Add a small random displacement to the target
	wander_target += Vector3(
		randf_range(-1, 1) * wander_jitter,
		randf_range(-1, 1) * wander_jitter,
		randf_range(-1, 1) * wander_jitter
	)
	
	# Normalize to keep on unit circle
	wander_target = wander_target.normalized()
