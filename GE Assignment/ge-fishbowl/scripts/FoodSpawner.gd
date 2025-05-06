extends Node3D

# Food parameters
@export var food_scene: PackedScene  # Assign in inspector
@export var max_food_items: int = 20  # Limit food to prevent performance issues

# Input parameters
@export var mouse_button_spawn: int = MOUSE_BUTTON_LEFT  # Left mouse button by default

# Water surface reference
@export var water_surface_path: NodePath = "../FishTank/tankstruct/WaterSurface"
var water_surface: Area3D

# Camera reference for raycasting
@onready var camera = get_viewport().get_camera_3d()  # Use get_camera_2d() for 2D

# Debug visualization 
var debug_mesh: MeshInstance3D

func _ready():
	# Debug mesh for visualizing ray hits
	debug_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.2
	debug_mesh.mesh = sphere
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.RED
	debug_mesh.material_override = mat
	add_child(debug_mesh)
	debug_mesh.visible = false

	# Ensure we have the food scene
	if not food_scene:
		push_error("Food scene not assigned to FoodSpawner!")
		return
	
	# Get the water surface reference
	if water_surface_path:
		if has_node(water_surface_path):
			water_surface = get_node(water_surface_path)
			if not water_surface or not water_surface is Area3D:
				push_error("Node at path is not an Area3D: " + str(water_surface_path))
		else:
			push_error("Could not find node at path: " + str(water_surface_path))
			# Try to find the water surface by name
			var candidates = get_tree().get_nodes_in_group("water_surface")
			if candidates.size() > 0:
				water_surface = candidates[0]
				print("Found water surface in 'water_surface' group instead")
	else:
		push_error("Water surface path not assigned to FoodSpawner!")

func _input(event):
	# Check for mouse button press
	if event is InputEventMouseButton and event.button_index == mouse_button_spawn and event.pressed:
		spawn_food_at_mouse()

func spawn_food_at_mouse():
	# If we don't have references to required objects, try to get them
	if not camera:
		camera = get_viewport().get_camera_3d()
		if not camera:
			push_error("No camera found!")
			return
	
	if not food_scene:
		push_error("No food scene assigned!")
		return
	
	if not water_surface:
		push_error("No water surface found!")
		return
		
	# Print debug info
	print("Attempting to spawn food. Water surface collision layer: ", water_surface.collision_layer)
		
	# Limit the number of food items
	var existing_food = get_tree().get_nodes_in_group("food")
	if existing_food.size() >= max_food_items:
		# Remove oldest food item if at limit
		existing_food[0].queue_free()
	
	# Get mouse position in world space
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Cast ray from camera to mouse position
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 1000  # Extend ray length
	
	var space_state = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = ray_origin
	ray_query.to = ray_end
	
	# Method 1: Try with water surface collision layer (assuming it's layer 4)
	ray_query.collision_mask = 4  # Binary: 0...0100
	var result = space_state.intersect_ray(ray_query)
	
	# Method 2: If that doesn't work, try with all layers
	if not result:
		ray_query.collision_mask = 0xFFFFFFFF  # All layers
		result = space_state.intersect_ray(ray_query)
		print("Using all collision layers instead")
	
	if result:
		print("Ray hit: ", result.collider.name)
		
		# Update debug visualization to show where ray hit
		debug_mesh.global_transform.origin = result.position
		debug_mesh.visible = true
		
		# Either spawn at exact hit location or at water surface Y level
		var spawn_position = result.position
		
		# Option 1: Spawn if we hit the exact water surface
		if result.collider == water_surface:
			print("Hit water surface directly")
			spawn_food_at_position(spawn_position)
		
		# Option 2: Spawn even if we didn't hit water surface directly, but project to water plane
		else:
			print("Hit something else, projecting to water level")
			# Get water surface global position Y
			var water_y = water_surface.global_position.y
			# Create a new position at the water level
			spawn_position.y = water_y
			spawn_food_at_position(spawn_position)
	else:
		print("Ray did not hit anything")
		debug_mesh.visible = false

func spawn_food_at_position(position):
	var food_instance = food_scene.instantiate()
	add_child(food_instance)
	food_instance.global_transform.origin = position
	
	# Add to food group for fish to detect
	food_instance.add_to_group("food")
	print("Food spawned at: ", position)
	
	# Hide debug visualization after 1 second
	await get_tree().create_timer(1.0).timeout
	debug_mesh.visible = false
