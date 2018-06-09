tool
extends PinJoint2D

export(float) var Stiffness = 10
export(float) var Damping = 64
export(float) var RestAngleDeg = 0
export(bool) var UseInitialAngle = true

var stiffness
var damping
var rest_angle_rads
var phys_fps

var body_a
var body_b

func _ready():
	body_a = get_node(node_a)
	body_b = get_node(node_b)
	
	damping = Damping * 400
	stiffness = Stiffness
	
	# glitches out without this
	if self.softness < 1:
		self.softness += 1
	
	if UseInitialAngle:
		rest_angle_rads = body_b.rotation - body_a.rotation
	else:
		rest_angle_rads = RestAngleDeg * PI / 180

func get_float(obj, prop):
	var v = obj.get(prop)
	if v == null:
		return 0.0
	return float(v)

# shortest ang between 2 normal angles -PI <= ang <= PI
func shortest_ang_to(to, from):
	if to < from:
		var _to = to + PI*2
		var a = _to-from
		var b = from-to
		if abs(a) < abs(b):
			return a
		else:
			return -b
	else:
		var _from = from + PI*2
		var a = _from-to
		var b = to-from
		if abs(a) < abs(b):
			return -a
		else:
			return b
			
func apply_rot_spring():
	var k = stiffness
	var d = damping
	var l = rest_angle_rads
	var x = shortest_ang_to(body_b.rotation, body_a.rotation)
	var u = get_float(body_b,"angular_velocity") - get_float(body_a,"angular_velocity")
	#print(get_float(body_a,"angular_velocity"))
	
	var torque = -k * (x - l) - (d * u)
	#var torque = -k * (x - l)
	#print(str(x-l) + ", " + str(torque))
	
	if body_a.get("applied_torque") != null:
		body_a.applied_torque -= torque
	if body_b.get("applied_torque") != null:
		body_b.applied_torque += torque

func _physics_process(delta):
	if body_a == null or body_b == null:
		return
	
	apply_rot_spring()