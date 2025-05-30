extends Node3D

# this script enables the spawning of food using the mouse pointer

@export var food_scene: PackedScene
@export var max_food_items: int = 20
@export var mouse_button_spawn: int = MOUSE_BUTTON_LEFT
@export var water_surface_path: NodePath = "../FishTank/WaterSurface"
var water_surface: Area3D

@onready var camera = get_viewport().get_camera_3d() #get the camera
var debug_mesh: MeshInstance3D

func _ready(): #setup spawning mesh to give visual feedback on food being made
	debug_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.2
	debug_mesh.mesh = sphere
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.RED
	debug_mesh.material_override = mat
	add_child(debug_mesh)
	
	if water_surface_path: #setup water surface
		if has_node(water_surface_path):
			water_surface = get_node(water_surface_path)
			
func _input(event):# wait for mouse click
	if event is InputEventMouseButton and event.button_index == mouse_button_spawn and event.pressed:
		spawn_food_at_mouse()

#called when mouse pressed to spawn food where mouse is only if it intersects with water surface
func spawn_food_at_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var water_y = water_surface.global_position.y
	var t = (water_y - ray_origin.y) / ray_direction.y
	var spawn_position = ray_origin + ray_direction * t
	
	if t > 0 and spawn_position.x >= -9 and spawn_position.x <= 9 and spawn_position.z >= -4 and spawn_position.z <= 4:
		spawn_food_at_position(spawn_position)
		debug_mesh.global_transform.origin = spawn_position
		debug_mesh.visible = true
	else:
		print("Ray doesn't intersect with water plane in front of camera")

# create the food at point
func spawn_food_at_position(position):
	var food_instance = food_scene.instantiate()
	add_child(food_instance)
	food_instance.global_transform.origin = position
	food_instance.add_to_group("food")
	await get_tree().create_timer(1.0).timeout
	debug_mesh.visible = false # disable debug mesh when done
