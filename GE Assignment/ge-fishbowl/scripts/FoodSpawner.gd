# FoodSpawner.gd
extends Node3D  # Use Node2D for 2D games

# Food parameters
@export var food_scene: PackedScene  # Assign in inspector
@export var max_food_items: int = 20  # Limit food to prevent performance issues

# Input parameters
@export var mouse_button_spawn: int = MOUSE_BUTTON_LEFT  # Left mouse button by default

# Camera reference for raycasting
@onready var camera = get_viewport().get_camera_3d()  # Use get_camera_2d() for 2D

func _ready():
	# Ensure we have the food scene
	if not food_scene:
		push_error("Food scene not assigned to FoodSpawner!")

func _input(event):
	# Check for mouse button press
	if event is InputEventMouseButton and event.button_index == mouse_button_spawn and event.pressed:
		spawn_food_at_mouse()

func spawn_food_at_mouse():
	if not food_scene:
		return
		
	# Limit the number of food items
	var existing_food = get_tree().get_nodes_in_group("food")
	if existing_food.size() >= max_food_items:
		# Remove oldest food item if at limit
		existing_food[0].queue_free()
	
	# Get mouse position in world space
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Cast ray from camera to mouse position
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 100
	
	var space_state = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = ray_origin
	ray_query.to = ray_end
	ray_query.collision_mask = 1  # Use appropriate collision layers
	
	var result = space_state.intersect_ray(ray_query)
	
	if result:
		# Spawn food at the point where the ray hits
		var food_instance = food_scene.instantiate()
		add_child(food_instance)
		food_instance.global_transform.origin = result.position
		
		# Move slightly up from surface
		food_instance.global_transform.origin.y += 0.5
		
		# Add to food group for fish to detect
		food_instance.add_to_group("food")
