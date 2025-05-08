extends Node

# wander behaviour for fish to wander

@export var wander_radius: float = 2.0
@export var wander_distance: float = 4.0
@export var wander_jitter: float = 1.0
@export var wander_interval: float = 1.0

var parent_fish = null
var wander_target = Vector3.ZERO
var timer = 0.0

# set target fish
func initialize(fish):
	parent_fish = fish
	randomize()
	wander_target = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized() #set random target to wander to


func _process(delta):
	timer += delta
	if timer >= wander_interval:
		update_wander_target()#update target every few frames
		timer = 0.0

func calculate_steering(): #calucate steering force for boid to seek target
	if parent_fish == null:
		return Vector3.ZERO
	var circle_center = parent_fish.velocity.normalized() * wander_distance
	var displacement = Vector3(wander_target.x, wander_target.y, wander_target.z) * wander_radius
	var target = circle_center + displacement
	return target - parent_fish.velocity

func update_wander_target(): #update target randomly
	wander_target += Vector3(
		randf_range(-1, 1) * wander_jitter,
		randf_range(-1, 1) * wander_jitter,
		randf_range(-1, 1) * wander_jitter
	)
	wander_target = wander_target.normalized()
