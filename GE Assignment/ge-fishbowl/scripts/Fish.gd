extends CharacterBody3D

# this is the fish boid

@export var max_speed: float = 2.0
@export var mass: float = 1.0
@export var hunger_rate: float = 0.1
@export var rotation_speed: float = 5.0

var hunger: float = 0.0
var current_target = null
var repo: float = 0.0
@export var fishscene:PackedScene

@export var wander_weight: float = 1.0
@export var boundary_weight: float = 3.0 
@export var food_weight: float = 2.0
@export var energy_conservation_weight: float = 0.5
@export var flocking_weight: float = 1.5

var wander_behavior
var boundary_behavior
var food_seeking_behavior
var energy_conservation_behavior
var flocking_behavior

func _ready():
	collision_layer = 2
	collision_mask = 1 | 4 | 8
	fishscene = load("res://scenes/Fish.tscn")
	
	add_to_group("fish")
	
	#behaviours for fish
	wander_behavior = $Behaviors/WanderBehavior
	boundary_behavior = $Behaviors/BoundaryBehavior
	food_seeking_behavior = $Behaviors/FoodSeekingBehavior
	energy_conservation_behavior = $Behaviors/EnergyConservationBehavior
	flocking_behavior = $Behaviors/FlockingBehavior
	
	#setup the behaviours
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
		
	#randomise the weights of each behviour to make each fish more unique
	randomize_fish()
		
func randomize_fish():
	max_speed = max_speed * randf_range(0.8, 1.2)
	mass = mass * randf_range(0.9, 1.1)
	wander_weight *= randf_range(0.8, 1.2)
	food_weight *= randf_range(0.9, 1.1)
	flocking_weight *= randf_range(0.8, 1.2)
	pass

# physics process for applying force from behaviours
func _physics_process(delta):
	hunger = min(hunger + hunger_rate * delta, 1.0)
	food_weight = 2.0 *(1 + hunger)
	
	var final_steering = Vector3.ZERO
	
	if wander_behavior:
		var wander_force = wander_behavior.calculate_steering() * wander_weight
		final_steering += wander_force

	if boundary_behavior:
		var boundary_force = boundary_behavior.calculate_steering() * boundary_weight
		final_steering += boundary_force
	
	if food_seeking_behavior and hunger > 0.3:
		food_weight = lerp(1.0, 3.0, hunger) 
		var food_force = food_seeking_behavior.calculate_steering() * food_weight
		final_steering += food_force
	
	if energy_conservation_behavior and hunger < 0.3:
		var conservation_force = energy_conservation_behavior.calculate_steering() * energy_conservation_weight
		final_steering += conservation_force
	
	apply_steering(final_steering, delta)
	
	var collision = move_and_slide()
	
	handle_collisions()

func apply_steering(steering: Vector3, delta: float): # apply the forces made from the behaviours and move
	steering = steering.limit_length(max_speed)
	steering = steering / mass
	velocity += steering * delta
	velocity = velocity.limit_length(max_speed)
	if velocity.length() > 0.1:
		var target_transform = transform.looking_at(transform.origin + velocity, Vector3.UP)
		transform = transform.interpolate_with(target_transform, rotation_speed * delta)

func handle_collisions():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("food"): #if collide with food eat it
			eat_food(collider)

func eat_food(food_item):
	#reduce hunger
	hunger = max(hunger - 0.5, 0)
	repo = repo + 1
	if repo >= 10: #if repo is more then 10 reproduce
		repo = 0
		var fish = fishscene.instantiate()
		fish.transform.origin = global_transform.origin
		get_parent().add_child(fish)
	food_item.queue_free()
	emit_signal("food_eaten")
signal food_eaten
