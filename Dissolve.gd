extends ShaderMaterial

var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    print("READY")

func _process(delta):
    time += delta
    print(time)
    
    self.set_shader_param("Threshold", (sin(time) + 1)/2)