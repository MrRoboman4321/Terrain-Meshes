class TerrainMesh:
    const WIDTH = 20.0
    const HEIGHT = 20.0

    var heights = []
    var material
    var mesh
    
    func _init(size):
        randomize()
        heights = _generateHeightSimplex(size)
        material = _createMaterial()
        mesh = _meshFromHeights(heights, material, size)
        
    func attachToMesh(meshInstance):
        meshInstance.mesh = mesh
        meshInstance.set_surface_material(0, material)
        
    func _meshFromHeights(heights, material, size):
        var surfaceTool = SurfaceTool.new()
        surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
    
        surfaceTool.add_normal(Vector3(0, 0, 1))
        
        var min_y = 1000
        var max_y = -1000
        
        for r in range(0, size):
            for c in range(0, size):
                if(heights[r][c] < min_y):
                    min_y = heights[r][c]
                if(heights[r][c] > max_y):
                    max_y = heights[r][c]
        
        var scale = WIDTH/size;
        
        for row in range(0, size):
            for col in range(0, size):
                if(row != size - 1 and col != size - 1):
                    #if(allBelowWater(heights[row][col], heights[row + 1][col], heights[row][col + 1], size)):
                    #    surfaceTool.add_color(Color.blue)
                    #else:
                    #    surfaceTool.add_color(Color.red)
    
                    var v = Vector3(row*scale, heights[row][col], col*scale)
                    surfaceTool.add_color(_getVertexColor(v, min_y, max_y, size))
                    surfaceTool.add_vertex(v)
                    v = Vector3((row + 1)*scale, heights[row + 1][col], col*scale)
                    surfaceTool.add_color(_getVertexColor(v, min_y, max_y, size))
                    surfaceTool.add_vertex(v)
                    v = Vector3(row*scale, heights[row][col + 1], (col + 1)*scale)
                    surfaceTool.add_color(_getVertexColor(v, min_y, max_y, size))
                    surfaceTool.add_vertex(v)
                    
                if(row != 0 and col != 0):
                    #if(allBelowWater(heights[row][col], heights[row - 1][col], heights[row][col - 1], size)):
                    #    surfaceTool.add_color(Color.blue)
                    #else:
                    #    surfaceTool.add_color(Color.red)
                    var v = Vector3(row*scale, heights[row][col], col*scale)
                    surfaceTool.add_color(_getVertexColor(v, min_y, max_y, size))
                    surfaceTool.add_vertex(v)
                    v = Vector3((row - 1)*scale, heights[row - 1][col], col*scale)
                    surfaceTool.add_color(_getVertexColor(v, min_y, max_y, size))
                    surfaceTool.add_vertex(v)
                    v = Vector3(row*scale, heights[row][col - 1], (col - 1)*scale)
                    surfaceTool.add_color(_getVertexColor(v, min_y, max_y, size))
                    surfaceTool.add_vertex(v)
    
        surfaceTool.generate_normals()
        return surfaceTool.commit()
        
        
    func _createMaterial():
        var mat = SpatialMaterial.new()
        mat.set("vertex_color_use_as_albedo", true)
        
        return mat
    
    func _generateHeightSimplex(size):
        var noise = OpenSimplexNoise.new()
    
        noise.seed = randi()
        noise.octaves = 4
        noise.period = 20.0
        noise.persistence = 0.8
        
        var heights = []
        
        var noise_image = noise.get_image(size, size)
        noise_image.lock()
        
        for i in range(size):
            var row = []
            for j in range(size):
                row.append(400.0/size * noise_image.get_pixel(i, j).gray())
            heights.append(row)
            
        return heights
    
    func _getVertexColor(vert, min_y, max_y, size):
        var v = _map(vert.y, min_y, max_y, 0, 1)
        
        #Side length is always 20
        var max_dist = sqrt(200.0) * 0.8
        var s = max(1 - abs(Vector2(vert.x - WIDTH/2, vert.z - HEIGHT/2).length()/max_dist), 0)
        
        if(s < 0):
            print("< 0")
            print("len: " + str(Vector2(vert.x - WIDTH/2, vert.z - HEIGHT/2).length()/max_dist))
        
        #print(s)
        
        #Side length is always 20, so -10 in each direction to center
        var vec = Vector2(vert.x - 10, vert.z - 10).normalized()
        var h = _map(atan2(vec.y, vec.x), -PI, PI, 0, 1)
        
        return Color.from_hsv(h, s*2.5, v)
        
    func _saturationSigmoid(s):
        return (-1.0 / (0.97 + exp(-8*s + 4)) + 1)
        
    func _map(x, x1, x2, y1, y2):
        var leftSpan = x2 - x1
        var rightSpan = y2 - y1
        
        var scaled = (x - x1)/(leftSpan)
        
        return y1 + (scaled * rightSpan)