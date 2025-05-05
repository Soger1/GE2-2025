# EnergyConservationBehavior.gd
extends Node

# Energy conservation parameters
@export var rest_speed: float = 1.0       # Speed when conserving energy
@export var preferred_depth: float = 5.0  # Preferred y-position (depth) for resting

# Internal variables
var parent_fish = null
var resting_spot = null

func initialize(fish):
	parent_fish = fish
	find_resting_spot()

func _process(delta):
	# Occasionally find a new resting spot
	if randf() < 0.01:  # 1% chance per frame to change resting spot
		find_resting_spot()

func calculate_steering():
	if parent_fish == null or resting_spot == null:
		return Vector3.ZERO
	
	var fish_position = parent_fish.global_transform.origin
	var direction_to_spot = resting_spot - fish_position
	var distance = direction_to_spot.length()
	
	# Calculate target velocity - slower when conserving energy
	var target_velocity = direction_to_spot.normalized() * rest_speed
	
	# Calculate steering force (desired velocity - current velocity)
	var steering = target_velocity - parent_fish.velocity
	
	# If we're already at the resting spot, just slow down
	if distance < 2.0:
		steering = -parent_fish.velocity * 0.5
	
	return steering

func find_resting_spot():
	if parent_fish == null:
		return
	
	# Find a comfortable spot in the tank
	# This could be near plants, in a corner, or at a specific depth
	var tank_size = Vector3(20, 10, 20)  # Should match tank size from BoundaryBehavior
	var half_size = tank_size / 2
	
	# Generate random position within the tank, but at the preferred depth
	resting_spot = Vector3(
		randf_range(-half_size.x + 2.0, half_size.x - 2.0),
		preferred_depth,  # Stay at preferred depth
		randf_range(-half_size.z + 2.0, half_size.z - 2.0)
	)
