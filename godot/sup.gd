extends Node3D

var root_scene = "res://root.tscn"

@onready var background = $Background
@onready var chique = $"Node3D/Node3D/toon/AnimationPlayer"
@onready var boxo = $"Node3D/Node3D"
@onready var ground = $Node3D/Node3D/Ground
@onready var flopster = $Start/Flopster
@onready var audio = $AudioStreamPlayer3D
@onready var camera = $Camera3D
@onready var labels = $Start/Labels
@onready var title = $Title

var last_label:Label3D = null
var start_time : float = .0
var last_second : int = 0

var OFFSET = Vector2(.0,.0)
var GO = Vector2(.0,.0)
const BLACK = Color(.0,.0,.0)
const WHITE = Color(1.,1.,1.)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var s = .22
	flopster.scale = Vector3(s,s,s)
	flopster.light.visible = false
	start_time = now();
	chique.play("running")

func now() -> float:
	return Time.get_unix_time_from_system()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	chique.play("running")
	background.get_active_material(0).set_shader_parameter("OFFSET", OFFSET)
	
	var elapsed = now()
	var sex = int(elapsed)
	var tex = int(elapsed * 6.)
	
	if elapsed - start_time > 3. and  tex != last_second:
		title.text = title.text.substr(1) + title.text[0]
		last_second = tex
	
	var f = .000300
	if sex % 2:
		OFFSET.x += f
	else:
		OFFSET.y += f
	
	var b4 = sex % 4
	boxo.rotation.y = deg_to_rad(b4 * 90)
	GO.y += .01
	ground.get_active_material(0).set_shader_parameter("OFFSET", GO)
	
	var iTime = int(elapsed * .125) % flopster.icons.size()
	flopster.iconic(flopster.icons[iTime])

func start_game() -> void:
	get_tree().change_scene_to_file(root_scene)

func end_game() -> void:
	# TODO prompt
	get_tree().quit() 

func show_info() -> void:
	pass

func _on_audio_stream_player_3d_finished() -> void:
	audio.play()

########################################################################################################
# event handling is boring...

func _input(event) -> void:
	if Input.is_action_just_pressed("ui_fullscreen"):
		return toggle_fullscreen()
	if event.is_action_pressed("ui_accept"):
		start_game()
	if event.is_action_pressed("ui_renounce"):
		end_game()
	
	if event is InputEventMouseMotion:
		mouse_move(event)
	if event is InputEventMouseButton and event.pressed:
		mouse_click(event)
		
func toggle_fullscreen() -> void:
	if DisplayServer.WINDOW_MODE_FULLSCREEN == DisplayServer.window_get_mode():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func mouse_move(event):		
	var under = camera_mouse(labels, camera)
	if not under:
		if last_label:
			last_label.outline_modulate = BLACK
			last_label = null
		return
		
	var parent = under.get_parent()
	if not parent is Label3D:
		if last_label:
			last_label.outline_modulate = BLACK
			last_label = null
		return
		
	var label : Label3D = parent
	if last_label and label != last_label:
		last_label.outline_modulate = BLACK
	last_label = label
	label.outline_modulate = WHITE

func mouse_click(event) -> void:
	if not last_label:
		return
	if "Enter" == last_label.name:
		return start_game()
	if "Escape" == last_label.name:
		return end_game()
	if "Information" == last_label.name:
		return show_info()

# c/p from our scaletris project
func camera_mouse(context:Node3D, camera:Camera3D, exclude = [], rayLength:float=1000) -> Node3D:
	var space_state = context.get_world_3d().direct_space_state
	var mousepos = context.get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * rayLength
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.exclude = exclude

	var result = space_state.intersect_ray(query)
	if !result or not "collider" in result: 
		return null
	return result.collider
