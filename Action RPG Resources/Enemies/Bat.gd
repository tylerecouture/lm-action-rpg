extends KinematicBody2D

const EnemyDeathEffect = preload("res://Action RPG Resources/Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200


enum {
	IDLE,
	WANDER,
	CHASE
}

func _seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
	
	


var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = CHASE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			_seek_player()
		
		WANDER:
			pass
		
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = IDLE
	sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120


func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position - Vector2(0, 15)
