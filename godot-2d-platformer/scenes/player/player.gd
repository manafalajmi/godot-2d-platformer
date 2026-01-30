extends CharacterBody2D

# Movement constants
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ACCELERATION = 1800.0  # How fast we reach max speed
const FRICTION = 1200.0      # How fast we slow down

# Jump improvements
const COYOTE_TIME = 10      # Grace period after leaving platform (seconds)
const JUMP_BUFFER_TIME = 0.1 # Grace period for early jump press (seconds)
const JUMP_RELEASE_MULTIPLIER = 0.5  # How much to reduce jump when releasing early

# Timers for jump mechanics
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var was_on_floor = false

func _physics_process(delta: float) -> void:
	# Track if we were on floor last frame
	var on_floor = is_on_floor()
	
	# Coyote time: grace period after leaving platform
	if on_floor:
		coyote_timer = COYOTE_TIME
		was_on_floor = true
	else:
		coyote_timer -= delta
		if was_on_floor and coyote_timer <= 0:
			was_on_floor = false
	
	# Apply gravity
	if not on_floor:
		velocity += get_gravity() * delta
	
	## Variable jump height: release jump early for shorter jump
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_RELEASE_MULTIPLIER
	
	# Jump buffer: count down if jump was pressed recently
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta
	
	# Handle jump with coyote time and jump buffering
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0  # Consume the buffered jump
		coyote_timer = 0       # Consume coyote time
	
	# Get input direction
	var direction := Input.get_axis("move_left", "move_right")
	
	# Smooth acceleration and deceleration
	if direction != 0:
		# Accelerate towards max speed
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		# Apply friction when no input
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	move_and_slide()
