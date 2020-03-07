extends Node
signal on_closest_unit_changed
signal on_group_changed
signal on_unit_entered
signal on_unit_exited

var nearby_units := []
var closest_unit:Node2D = null

onready var detection_area = $DetectionArea

func _ready():
	detection_area.connect("body_entered", self, "on_body_entered")
	detection_area.connect("body_exited", self, "on_body_exited")

func nearby_units():
	return detection_area.get_overlapping_bodies()
	
func on_body_entered(body:Node2D):
	var old_closest := closest_unit
	closest_unit = select_closest_unit(closest_unit, body)
	emit_signal("on_unit_entered", body)
	emit_signal("on_group_changed")
	if closest_unit != old_closest:
		emit_signal("on_closest_unit_changed")
		
func on_body_exited(body:Node):
	var old_closest := closest_unit
	if closest_unit == body:
		closest_unit = select_closest_unit_from_group(nearby_units())
	emit_signal("on_unit_exited", body)
	emit_signal("on_group_changed")
	if closest_unit != old_closest:
		emit_signal("on_closest_unit_changed")
	
func select_closest_unit_from_group(bodies:Array)->Node2D:
	var unit:Node2D = null
	for body in bodies:
		unit = select_closest_unit(unit, body)
	return unit
	
func select_closest_unit(body1:Node2D, body2:Node2D)->Node2D:
	if body1 == null:
		return body2
	if body2 == null:
		return body1
		
	var my_position:Vector2 = detection_area.global_position
	var distance1:float = body1.global_position.distance_to(my_position)
	var distance2:float = body2.global_position.distance_to(my_position)
	
	if distance1 < distance2:
		return body1
	return body2