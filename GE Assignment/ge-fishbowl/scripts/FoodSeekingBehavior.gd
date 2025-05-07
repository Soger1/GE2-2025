extends Node

@export var detection_radius: float = 10.0
@export var arrival_radius: float = 1.0 
@export var max_targets: int = 5      

var parent_fish = null
var current_target = null
var target_position = null

func initialize(fish):
	parent_fish = fish

func _process(delta):
	find_closest_food()

func calculate_steering():
	if parent_fish == null or current_target == null:
		return Vector3.ZERO
	
	var fish_position = parent_fish.global_transform.origin
	var direction_to_food = target_position - fish_position
	var distance = direction_to_food.length()
	var target_velocity = direction_to_food.normalized() * (parent_fish.max_speed + 1)
	if distance < arrival_radius:
		target_velocity *= (distance / arrival_radius)

	return target_velocity - parent_fish.velocity

func find_closest_food():
	if parent_fish == null:
		return
	
	var fish_position = parent_fish.global_transform.origin
	var food_items = get_tree().get_nodes_in_group("food")
	var closest_distance = detection_radius
	current_target = null
	
	for food in food_items:
		var food_position = food.global_transform.origin
		var distance = fish_position.distance_to(food_position)
		
		if distance < closest_distance:
			closest_distance = distance
			current_target = food
			target_position = food_position
