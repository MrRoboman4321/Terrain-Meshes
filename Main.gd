extends Spatial

onready var meshInstance = $Mesh
onready var cam = $Camera

const SIZE = 20.0
const SPEED = 4.0 #How long it takes the wave to propogate across the mesh

var deg = 0
var i = 0
var time = 0
var terrain
var home_heights

var first = false

func _ready():
    var TerrainMesh = load("res://TerrainMesh.gd").TerrainMesh
    terrain = TerrainMesh.new(SIZE)
    
    terrain.attachToMesh(meshInstance)
    home_heights = _deepCopyHeights(terrain.heights)
    
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
    
func _updateTerrain(time):
    time = fmod(time, SPEED)/SPEED
    
    var split = false
    
    var min_x = time * 20
    var max_x
    if(min_x > 16):
        max_x = (min_x + 4) - 20
        split = true
    else:
        max_x = min_x + 4
        
    if(split):
        for x in range(int(ceil(min_x)), SIZE):
            for z in range(0, SIZE):
                terrain.updateVert(x, z, home_heights[x][z] + _getWaveHeight(x - min_x))
                
        for x in range(0, int(ceil(max_x))):
            for z in range(0, SIZE):
                terrain.updateVert(x, z, home_heights[x][z] + _getWaveHeight(max_x - x))
    else:
        for x in range(int(ceil(min_x)), int(ceil(max_x))):
            for z in range(0, SIZE):
                $debug.text = str(_getWaveHeight(x - min_x))
                terrain.updateVert(x, z, home_heights[x][z] + _getWaveHeight(x - min_x))
           
    terrain.updateMesh(meshInstance)
    
func _getWaveHeight(x):
    return -4 * pow((x - 2)*(sqrt(0.5)/2), 2) + 2
    
func _deepCopyHeights(heights):
    var out = []
    for x in range(SIZE):
        out.append([])
        for z in range(SIZE):
            out[x].append(heights[x][z])
            
    return out
              
func _process(delta):
    time += delta
    
    #if(i % int(SIZE) == 0):
    _updateCamera(delta)
    if(!first):
        pass
        _updateTerrain(time)
        #first = !first
    
    i += 1