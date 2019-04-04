extends Spatial

onready var meshInstance = $Mesh
onready var cam = $Camera

const SIZE = 20.0

var deg = 0

func _ready():
    var TerrainMesh = load("res://TerrainMesh.gd").TerrainMesh
    var terrain = TerrainMesh.new(30.0)
    
    terrain.attachToMesh(meshInstance)
    
func allBelowWater(v1, v2, v3, size):
    if(map(v1, 0, (400/size), 0, 1) < 0.55 and
       map(v2, 0, (400/size), 0, 1) < 0.55 and
       map(v3, 0, (400/size), 0, 1) < 0.55):
        return true
    return false
    
        
func map(x, x1, x2, y1, y2):
    var leftSpan = x2 - x1
    var rightSpan = y2 - y1
    
    var scaled = (x - x1)/(leftSpan)
    
    return y1 + (scaled * rightSpan)

func _updateCamera(delta):
    var x = 3*sqrt(20) * cos(delta * PI/4 + deg) + 10
    var z = 3*sqrt(20) * sin(delta * PI/4 + deg) + 10
    deg += delta * PI/4
    
    cam.set_translation(Vector3(x, 20, z))
    cam.look_at(Vector3(10, 0, 10), Vector3(0, 1, 0))

func _process(delta):
    _updateCamera(delta)