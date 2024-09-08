extends Node3D

@onready var animationPlayer = $AnimationPlayer
@onready var models = $Models
@onready var particles = $GPUParticles3D # TODO: need one per model really
@onready var hitbox = $HitBox
@onready var light = $OmniLight3D

var fodder = null
var tmi = null
var current = null
var quiet = false

func luke(f) -> void:
	fodder = f

func leiseSein() -> void:
	quiet = true
	animationPlayer.play("stfu")

func iconic(iconicName:String) -> bool:
	var found = false
	models.visible = false
	for kid in models.get_children():
		if iconicName == kid.name:
			kid.visible = true
			found = true
			tmi = iconicName
			current = kid
		else:
			kid.visible = false
	models.visible = true
	return found

func _on_rigid_body_3d_body_entered(_body: Node) -> void:
	if quiet:
		return
	particles.emitting = true
	animationPlayer.play("bye")
	if null != fodder:
		fodder.bye(self) # sure the is nicer way with signals :-/
