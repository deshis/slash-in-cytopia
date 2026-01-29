@tool
extends GridMap # Straight from another project :D

@export var grid_2d: TileMapLayer 
@export var grass: MultiMeshInstance3D

@export_tool_button("generate") var gen = _generate

@export_range(1, 10, 1) var height := 5:
	set(v):
		height=v
		#_generate()
@export_tool_button("clear map") var clr = _clear

@export var ground_map: GridMap
@export var noise_scale: int =6
@export var noise_sharp: FastNoiseLite
@export var noise_gradual: FastNoiseLite

@onready var enemy_spawner = $"../../../EnemySpawner"

func _notification(notification):
	if notification == NOTIFICATION_EDITOR_PRE_SAVE:
		grass.multimesh.instance_count = 0

func _clear():
	clear()
	ground_map.clear()
	grass.multimesh.instance_count = 0
	#print("clear!")
	
func _generate():
	_clear()
	
	# random offset
	noise_sharp.offset.x = randf_range(-1000, 1000)
	noise_sharp.offset.y = randf_range(-1000, 1000)
	
	var texture = NoiseTexture2D.new()
	texture.noise = noise_gradual
	await texture.changed
	var noiseImage = texture.get_image()
	
	var peaks =NoiseTexture2D.new()
	peaks.noise=noise_sharp
	await peaks.changed
	var noisePeaks =peaks.get_image()
	
	var tex_width = texture.width / noise_scale
	var tex_height = texture.height / noise_scale
	
	

	
	var xi=tex_height/2
	var yj=tex_width/2
	for i in tex_height:
		for j in tex_width:
			var flow:int = noiseImage.get_pixel(i,j).r * height
			var points:int = noisePeaks.get_pixel(i,j).r * height
			

	

			var loc=Vector3(i-xi,0,j-yj)
			

			
			
			ground_map.set_cell_item(loc,0)
			
			if abs(loc.x)==xi or abs(loc.z)==yj:
				points=0
				loc.y=5
				self.set_cell_item(loc,5)
			#if abs(loc.z)==yj:
			#	points=height-1
			
			
			var rot = get_orthogonal_index_from_basis(Basis(Vector3.UP, PI*randi()*2.0))
			loc.y=2
			if abs(loc.x)>=2 or (abs(loc.z)>=2):
				if points == 0:
					self.set_cell_item(loc,3, rot)
				elif points == height-1:
					self.set_cell_item(loc,4, rot)
			

			if flow+points >= height:
				loc.y=1
				self.set_cell_item(loc,2)
			elif flow <= 2:
				loc.y=0				
				self.set_cell_item(loc,1)
	
	print_debug(texture.height)
	#print("gridmap done!")
	bake_gridmap_navmesh()
	#print("navmesh done!")
	_generate_grass()
	#print("grass done!")
	#enemy_spawner.start_spawner()

func bake_gridmap_navmesh():
	get_parent().bake_navigation_mesh(true)

func _generate_grass():
	var grass_positions: Array[Transform3D] = []

	for cell in self.get_used_cells():
		if self.get_cell_item(cell) == 1:
			var tile_center := self.map_to_local(cell)
			
			for i in range(200):
				var rand_offset = Vector3(randf() - 0.5,0,randf() - 0.5) * 2.0   # keeps blades within the tile

				var pos = tile_center + rand_offset

				var xf = Transform3D()
				xf = xf.rotated(Vector3.UP, randf() * TAU)
				xf = xf.rotated(Vector3.RIGHT, deg_to_rad(-55))
				xf.origin = pos

				grass_positions.append(xf)

	var mm = grass.multimesh
	mm.instance_count = grass_positions.size()

	for i in grass_positions.size():
		mm.set_instance_transform(i, grass_positions[i])
	
func _enter_tree():
	_generate()

func _ready():
	#_generate() #This is called the engine even touches the file becaus of the "tool" tag
	_generate_grass() #Place the grass when loaded
