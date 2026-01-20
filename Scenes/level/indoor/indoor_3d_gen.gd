@tool
extends GridMap # Straight from another project :D

@export var grid_2d: TileMapLayer 
@export var grass: MultiMeshInstance3D

@export_tool_button("generate") var gen = _generate
@export_tool_button("navmesh") var bake = bake_gridmap_navmesh

@export_range(1, 10, 1) var height := 5:
	set(v):
		height=v
		#_generate()
@export_tool_button("clear map") var clr = _clear

@export var noise_scale: int
@export var noise_sharp: FastNoiseLite
@export var noise_gradual: FastNoiseLite

@onready var enemy_spawner = $"../../../EnemySpawner"



var light_load= preload("res://Scenes/level/indoor/light.tscn")

#func _notification(notification):
#	#if notification == NOTIFICATION_EDITOR_PRE_SAVE:
	#	grass.multimesh.instance_count = 0

func _clear():
	clear()
	#grass.multimesh.instance_count = 0
	
	for child in $"../Lights".get_children():
		print(child)

		child.queue_free()
	print("clear!")
	
func _generate():
	clear()
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
	
	#var xi=tex_height/2
	#var yj=tex_width/2
	#0 ground
	#1 obstacle
	#2 wall
	#3 ????
	var ground = []
	var light_loc = []
	for cell in grid_2d.get_used_cells():
		if grid_2d.get_cell_atlas_coords(cell)==Vector2i(42,0): # Ground gray
			self.set_cell_item(Vector3i(cell.x,0,cell.y),0)
			ground.append(cell)
		if grid_2d.get_cell_atlas_coords(cell)==Vector2i(23,0): # Ground gray
			self.set_cell_item(Vector3i(cell.x,0,cell.y),0)
			self.set_cell_item(Vector3i(cell.x,3,cell.y),3)
			light_loc.append(cell)
		if grid_2d.get_cell_atlas_coords(cell)==Vector2i(41,0): # Wall gray
			self.set_cell_item(Vector3i(cell.x,1,cell.y),2) 
			self.set_cell_item(Vector3i(cell.x,2,cell.y),2)
			self.set_cell_item(Vector3i(cell.x,3,cell.y),2)	
		#Boss door location red?
		
		
	for cell in ground:
		var xtmp=abs(cell.x)
		var ytmp=abs(cell.y)
		var flow:int = noiseImage.get_pixel(xtmp, ytmp).r * height
		var points:int = noisePeaks.get_pixel(xtmp, ytmp).r * height
		if points+flow>=8:
			self.set_cell_item(Vector3i(cell.x,1,cell.y),1)



	
	print_debug(texture.height)
	print("gridmap done!")
	#bake_gridmap_navmesh()
	dupe_light()
	#_generate_grass()
	#print("grass done!")
	#enemy_spawner.start_spawner()

func dupe_light():
	
	for cell in grid_2d.get_used_cells():
		if grid_2d.get_cell_atlas_coords(cell)==Vector2i(23,0):
			
			var light_instance:Node3D = $"../../../Light".duplicate(8)
			$"../Lights".add_child(light_instance)
			light_instance.global_position=	self.map_to_local((Vector3(cell.x,3,cell.y)))
			var orient = [	self.get_cell_item((Vector3(cell.x-1,2,cell.y))), 
						self.get_cell_item((Vector3(cell.x+1,2,cell.y))),
		 				self.get_cell_item((Vector3(cell.x,2,cell.y-1))), 
						self.get_cell_item((Vector3(cell.x,2,cell.y+1)))]
			if orient[0]==2:
				light_instance.rotate_y(0)
			if orient[1]==2:
				light_instance.rotate_y(deg_to_rad(180))
			if orient[2]==2:
				light_instance.rotate_y(deg_to_rad(270))
			if orient[3]==2:
				light_instance.rotate_y(deg_to_rad(90))




func bake_gridmap_navmesh():
	get_parent().bake_navigation_mesh(true)
	print("navmesh done!")




func _enter_tree():
	pass
func _ready():
	dupe_light()
	#grid_2d.visible=false
	#_generate() #This is called the engine even touches the file becaus of the "tool" tag
	#_generate_grass() #Place the grass when loaded
