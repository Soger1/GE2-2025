extends Node

#this behavior simulates the fish resting behaviour when it wants to conserve energy

@export var rest_speed: float = 1.0       
@export var preferred_depth: float = 5.0  

var parent_fish = null
var resting_spot = null


#setup the parent fish
func initialize(fish):
	parent_fish = fish
	find_resting_spot()

#find a new resting spot with a 1% chance
func _process(delta):
	if randf() < 0.001:  
		find_resting_spot()

# caluclate force for the boid
func calculate_steering():
	if parent_fish == null or resting_spot == null:
		return Vector3.ZERO
	
	var fish_position = parent_fish.global_transform.origin
	var direction_to_spot = resting_spot - fish_position
	var distance = direction_to_spot.length()
	var target_velocity = direction_to_spot.normalized() * rest_speed
	var steering = target_velocity - parent_fish.velocity
	
	if distance < 2.0:
		steering = -parent_fish.velocity * 0.5
	
	return steering

# select a random spot in the tank 
func find_resting_spot():
	if parent_fish == null:
		return
	
	var tank_size: Vector3 = Vector3(20, 12, 12) #this is the tank size
	var half_size = tank_size / 2
	
	resting_spot = Vector3( #get random place
		randf_range(-half_size.x + 2.0, half_size.x - 2.0),
		preferred_depth,
		randf_range(-half_size.z + 2.0, half_size.z - 2.0)
	)
