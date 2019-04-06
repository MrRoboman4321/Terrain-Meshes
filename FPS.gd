extends Node

class FPS:
    var deltas = []
    var fps = []
    
    func _init():
        pass
        
    func update(delta):
        deltas.append(delta)
        #if(deltas.length() > 10):