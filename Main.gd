extends Spatial

onready var meshInstance = $Mesh

const SIZE = 20.0

func _ready():
    var TerrainMesh = load("res://TerrainMesh.gd").TerrainMesh
    var terrain = TerrainMesh.new(100.0)
    
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

#warning-ignore:unused_argument
func _process(delta):
    pass
    #angle += delta * 30
    #meshInstance.rotation_degrees = Vector3(0, 0, angle)