extends Node

# Food seeking parameters
@export var detection_radius: float = 10.0  # How far the fish can detect food
@export var arrival_radius: float = 1.0     # When to slow down near food
@export var max_targets: int = 5            # Maximum number of food items to consider

# Internal variables
var parent_fish = null
var current_target = null
var target_position = null

func initialize(fish):
	parent_fish = fish

func _process(delta):
	# Find the closest food item within detection radius
	find_closest_food()

func calculate_steering():
	if parent_fish == null or current_target == null:
		return Vector3.ZERO
	
	# Calculate direction to food
	var fish_position = parent_fish.global_transform.origin
	var direction_to_food = target_position - fish_position
	var distance = direction_to_food.length()
	
	# If we're within arrival radius, slow down
	var target_velocity = direction_to_food.normalized() * parent_fish.max_speed
	if distance < arrival_radius:
		target_velocity *= (distance / arrival_radius)
	
	# Calculate steering force (desired velocity - current velocity)
	return target_velocity - parent_fish.velocity

func find_closest_food():
	if parent_fish == null:
		return
	
	var fish_position = parent_fish.global_transform.origin
	var food_items = get_tree().get_nodes_in_group("food")
	var closest_distance = detection_radius
	current_target = null
	
	# Find the closest food item
	for food in food_items:
		var food_position = food.global_transform.origin
		var distance = fish_position.distance_to(food_position)
		
		if distance < closest_distance:
			closest_distance = distance
			current_target = food
			target_position = food_position
