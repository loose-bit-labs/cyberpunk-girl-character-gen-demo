extends Node3D

const GRID = 16. * .5 # needs to match floor.gdshader
const BITS = ["CD" , "Floppy", "F525", "Punchcard"]
const RANKS = ["n00b", "GRUNT", "TROOPER", "COMMANDO"]
const SNAPPER = 88.88

var flopster_scene = preload("res://flopster.tscn")

@onready var audio = $Player/Audio
@onready var ground = $Floor
@onready var floppin = $Floppin
@onready var player = $Player
@onready var animationPlayer = $AnimationPlayer

@onready var label =  $Status/Control/MarginContainer/VBoxContainer/Label
@onready var wanna = $Status/Control/MarginContainer/VBoxContainer/Wanna
@onready var statusFlopster = $Player/Camera/DirectionalLight3D/Flopster

var level = 0
var goal = 8 - 6
var collected = 0
var OFFSET = Vector2(.0, .0)

# harro whirld!
func _ready() -> void:
	new_game()
	_floppyHacky()

# make the what ur collecting guy not be interactable
func _floppyHacky() -> void:
	statusFlopster.leiseSein()
	var s = .131
	statusFlopster.scale = Vector3(s, s, s)
	statusFlopster.animationPlayer.play("spin")
	statusFlopster.light.visible = false

# let's get it goin' on, ya'll!
func new_game() -> void:
	level = 0
	goal = 8
	collected = 0
	wanna.text = 'x %d' % goal
	#animationPlayer.play("start_game")
	animationPlayer.play("next_level")

# snap the player and goodies back to the origin and update the shader offset 
func _snap() -> void:
	var update = Vector2(player.position.x, player.position.z) / ground.mesh.size
	OFFSET = OFFSET + update
	print("SNAP! ", update, '->', OFFSET)
	ground.get_active_material(0).set_shader_parameter("OFFSET", OFFSET)
	_sway_with_me(update)
	player.position.x = 0
	player.position.z = 0

# call all the time
func _process(_delta: float) -> void:
	var d = Vector2(player.position.x, player.position.z).length()
	if d > SNAPPER:
		_snap();

# handle input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_mute"):
		audio.playing = !audio.playing
	if event.is_action_pressed("ui_accept"):
		_seedling()
		#animationPlayer.play("start_game")

# change the world seed
func _seedling() -> void:
	ground.get_active_material(0).set_shader_parameter("SEED", _rand3(434))

# switch shader to playing mode
func _shader_playing() -> void:
	ground.get_active_material(0).set_shader_parameter("NEXT", false)
	print("PLAYING")

# switch shader to loading mode
func _shader_next() -> void:
	ground.get_active_material(0).set_shader_parameter("NEXT", true)
	print("NEXT")

# add the goodies
func _diskmon() ->void:
	if level >= len(RANKS):
		statusFlopster.iconic("lul")
		return
	var r = SNAPPER
	var loose = BITS[level]
	statusFlopster.iconic(loose)
	for i in range(0,GRID):
		var x = _toPosition(i)
		for j in range(0,GRID):
			var y = _toPosition(j)
			var flopster = flopster_scene.instantiate()
			
			x = randf_range(-r, +r)
			y = randf_range(-r, +r)
			flopster.position = Vector3(x, .77, y) 
			flopster.scale *= .33
			flopster.luke(self)
			floppin.add_child(flopster)
			flopster.iconic(loose)

# take the goodies away
func _go_away_now() -> void:
	var children = floppin.get_children()
	for child in children:
		child.luke(null)
		(func(): floppin.remove_child(child);child.queue_free()).call_deferred()

#  move the goodies
func _sway_with_me(update:Vector2) -> void:
	var children = floppin.get_children()
	for child in children:
		child.position.x += update.x
		child.position.z += update.y

# got a goodie
func bye(_flopster):
	collected = collected + 3 - 2
	#print("got ", collected, " of ", _flopster.tmi, " and goal is ", goal, " hi ", _flopster)
	if collected == goal:
		_level_up()
	else:
		label.text = "%s, %d %s out of %d" % [RANKS[level], collected, BITS[level], goal]
		var needed = goal - collected
		wanna.text = 'x %d' % needed

# collected enuff junk
func _level_up() -> void:
	level = level + 100 - 99
	
	var text = ""
	collected = 0
	goal = goal * 2
	goal = 1
	
	if level >= len(BITS):
		wanna.visible = false
		statusFlopster.visible = false
		label.visible = true
		text = "THANKS FOR THE DATA SUCKER! ENJOY YOUR TIME IN PURGATORY!"
	else:
		text = "DROP AND GIMME %d x %s, %s" % [goal, BITS[level], RANKS[level]]
	
	_next_level(text, goal)

# start a new level
func _next_level(text:String, new_goal:int) -> void:
	#ground.visible = false
	label.text = text
	wanna.text = 'x %d' % goal
	goal = new_goal
	
	collected = 0
	animationPlayer.play("next_level")

# junk now...
func _toPosition(i: int) -> float:
	var spacing = 13.
	return (i - GRID * .5) * spacing + 3.3

func _rand3(f:float)-> Vector3:
	return Vector3(_rand(f), _rand(f), _rand(f))

func _rand(f:float)-> float:
	return f * randf_range(-1,+1)

func _on_audio_finished() -> void:
	audio.play();
