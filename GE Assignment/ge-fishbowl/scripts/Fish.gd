# Fish.gd
extends CharacterBody3D

# Properties
@export var max_speed: float = 2.0
@export var mass: float = 1.0
@export var hunger_rate: float = 0.1  # How quickly the fish gets hungry
@export var rotation_speed: float = 5.0

# Current state
var hunger: float = 0.0  # 0 = full, 1 = starving
var current_target = null
var repo: float = 0.0
@export var fishscene:PackedScene

# Behavior weights - can be adjusted dynamically
@export var wander_weight: float = 1.0
@export var boundary_weight: float = 3.0  # High priority to avoid walls
@export var food_weight: float = 2.0
@export var energy_conservation_weight: float = 0.5
@export var flocking_weight: float = 1.5

# Behavior nodes - will be assigned in _ready()
var wander_behavior
var boundary_behavior
var food_seeking_behavior
var energy_conservation_behavior
var flocking_behavior

# Debug
@export var debug_mode: bool = true

func _ready():
	# Setup collision detection
	collision_layer = 2  # Layer 2 for fish
	collision_mask = 1 | 4 | 8  # Collide with environment (1), water surface (4), and food (8)
	fishscene = load("res://scenes/Fish.tscn")
	
	# Add to fish group
	add_to_group("fish")
	
	# Get behavior nodes
	wander_behavior = $Behaviors/WanderBehavior
	boundary_behavior = $Behaviors/BoundaryBehavior
	food_seeking_behavior = $Behaviors/FoodSeekingBehavior
	energy_conservation_behavior = $Behaviors/EnergyConservationBehavior
	flocking_behavior = $Behaviors/FlockingBehavior
	
	# Initialize behaviors
	if wander_behavior:
		wander_behavior.initialize(self)
	if boundary_behavior:
		boundary_behavior.initialize(self)
	if food_seeking_behavior:
		food_seeking_behavior.initialize(self)
	if energy_conservation_behavior:
		energy_conservation_behavior.initialize(self)
	if flocking_behavior:
		flocking_behavior.initialize(self)
		
	randomize_fish()
	
	# Debug info
	if debug_mode:
		print("Fish initialized with collision layer: ", collision_layer)
		print("Fish collision mask: ", collision_mask)
		
func randomize_fish():
	max_speed = max_speed * randf_range(0.8, 1.2)
	mass = mass * randf_range(0.9, 1.1)
	wander_weight *= randf_range(0.8, 1.2)
	food_weight *= randf_range(0.9, 1.1)
	flocking_weight *= randf_range(0.8, 1.2)
	pass

func _physics_process(delta):
	# Update hunger
	hunger = min(hunger + hunger_rate * delta, 1.0)
	food_weight = 2.0 *(1 + hunger)
	
	# Calculate steering forces from each behavior
	var final_steering = Vector3.ZERO  # Use Vector2 for 2D
	
	# Apply wander force
	if wander_behavior:
		var wander_force = wander_behavior.calculate_steering() * wander_weight
		final_steering += wander_force
	
	# Apply boundary avoidance force (high priority)
	if boundary_behavior:
		var boundary_force = boundary_behavior.calculate_steering() * boundary_weight
		final_steering += boundary_force
	
	# Apply food seeking force if hungry
	if food_seeking_behavior and hunger > 0.3:  # Only seek food when somewhat hungry
		food_weight = lerp(1.0, 3.0, hunger)  # Food becomes more important as hunger increases
		var food_force = food_seeking_behavior.calculate_steering() * food_weight
		final_steering += food_force
		
		# Debug - print when fish is seeking food
		if debug_mode and food_seeking_behavior.current_target != null:
			print("Fish is seeking food. Distance to food: ", 
				  global_transform.origin.distance_to(food_seeking_behavior.target_position))
	
	# Apply energy conservation when not hungry
	if energy_conservation_behavior and hunger < 0.3:
		var conservation_force = energy_conservation_behavior.calculate_steering() * energy_conservation_weight
		final_steering += conservation_force
	
	# Apply the steering force
	apply_steering(final_steering, delta)
	
	# Move the fish
	var collision = move_and_slide()
	
	# Handle collisions
	handle_collisions()

func apply_steering(steering: Vector3, delta: float):
	# Clamp the steering force to max force
	steering = steering.limit_length(max_speed)
	
	# Apply mass (F = ma)
	steering = steering / mass
	
	# Apply the force to velocity
	velocity += steering * delta
	
	# Limit velocity to max speed
	velocity = velocity.limit_length(max_speed)
	
	# Rotate the fish to face the direction of movement if moving
	if velocity.length() > 0.1:
		var target_transform = transform.looking_at(transform.origin + velocity, Vector3.UP)
		transform = transform.interpolate_with(target_transform, rotation_speed * delta)

func handle_collisions():
	# Check if we're colliding with food
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("food"):
			if debug_mode:
				print("Fish collided with food: ", collider.name)
			eat_food(collider)

# Alternative method to detect food via Area3D
func _on_food_detector_area_entered(area):
	if area.is_in_group("food"):
		if debug_mode:
			print("Fish detected food in detector area: ", area.name)
		eat_food(area)

func eat_food(food_item):
	# Reduce hunger
	hunger = max(hunger - 0.5, 0)
	repo = repo + 1
	if repo >= 10:
		repo = 0
		var fish = fishscene.instantiate()
		fish.transform.origin = global_transform.origin
		get_parent().add_child(fish)
	
	if debug_mode:
		print("Fish eating food. New hunger level: ", hunger)
	
	# Destroy the food
	food_item.queue_free()
	
	# Emit signal that food was eaten (optional, for effects or scoring)
	emit_signal("food_eaten")

# Signal for other systems to react to
signal food_eaten
