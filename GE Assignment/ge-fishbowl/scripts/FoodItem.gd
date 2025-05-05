# FoodItem.gd
extends RigidBody3D  # Use RigidBody2D for 2D games

# Food properties
@export var nutritional_value: float = 1.0  # How much this reduces fish hunger
@export var lifetime: float = 60.0  # How long the food exists before despawning

# Visual properties
@export var bob_height: float = 0.2
@export var bob_speed: float = 2.0

# Internal variables
var time_alive: float = 0.0
var initial_position: Vector3

func _ready():
	# Store initial position for bobbing effect
	initial_position = global_transform.origin
	
	# Add to the "food" group so fish can find it
	add_to_group("food")
	
	# Set up physics
	freeze = false  # Allow physics to move the food
	gravity_scale = 0.2  # Make it sink slowly
	
	# Set collision layer/mask
	collision_layer = 2  # Layer 2 for food items
	collision_mask = 1   # Collide with environment (layer 1)

func _process(delta):
	# Update lifetime
	time_alive += delta
	if time_alive > lifetime:
		queue_free()
	
	# Make the food bob up and down in water
	apply_bobbing_effect(delta)
	
	# Optional: make food slowly spin
	rotate_y(delta * 0.5)

func apply_bobbing_effect(delta):
	# Only apply bobbing after food has settled
	if time_alive > 2.0:
		var bob_offset = sin(time_alive * bob_speed) * bob_height
		# Apply bobbing only to the y-axis
		global_transform.origin.y = initial_position.y + bob_offset

func _on_body_entered(body):
	# If a fish collides with us, we'll be eaten through the Fish script
	# This is just in case we want additional collision handling
	if body.is_in_group("fish"):
		pass  # The fish will handle the eating logic
