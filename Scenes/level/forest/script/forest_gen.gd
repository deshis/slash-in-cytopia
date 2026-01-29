@tool
extends Node2D


@onready var sky :TileMapLayer =$sky
@onready var play :TileMapLayer =$"play-level"
@onready var ground:TileMapLayer =$ground

@export var navReg:NavigationRegion2D
@export var mapsize:Vector2= Vector2i(255, 255)

const tree =[11,1,0,2] # Trunk, center, corner, side
const gnd =[3,4] # ground, rocks



@export_tool_button("generate") var gen = _generate
@export_range(1, 10, 1) var height := 4:
	set(v):
		height=v
		#_generate()
@export_tool_button("clear map") var clr = _clear

@export var noise: FastNoiseLite:
	set(new_noise):
		noise=new_noise
		_generate()




func _clear():
	sky.clear()
	play.clear()
	ground.clear()
	self.position=Vector2i(0,0)
	print("clear!")
	
func _generate():
	var texture = NoiseTexture2D.new()
	texture.noise = noise
	await texture.changed
	var noiseImage = texture.get_image()
	
	for i in mapsize.x:
		for j in mapsize.y:
			var value:int = noiseImage.get_pixel(i,j).r * height
			var location=Vector2i(i,j)
			
			if value==1:
				ground.set_cell(location, 1, Vector2i(gnd[1],0)) #add rocks
			else:
				ground.set_cell(location, 1, Vector2i(gnd[0],0))
				
			if value==3:
				create_tree(location)
				
			
	
	print("not working offset I guess")
	var furthest = ground.map_to_local(ground.get_used_cells()[-1])
	print(furthest)
	print(ground.get_used_cells()[-1])
	self.position.x=-furthest.x
	self.position.y=-furthest.y
	
	#_gen_navpoly()
	
func _gen_navpoly():
	## Probably should change how the pathfinding map is mande
	var used_rect = ground.get_used_rect()
	#Outer corners	
	var corner_a:Vector2 = ground.map_to_local(Vector2i(0,0))
	
	var corner_c:Vector2 = ground.map_to_local(used_rect.size)
	
	# Far corners
	var corner_b:Vector2 = Vector2(corner_c.x, corner_a.y) #inverse
	var corner_d:Vector2 = Vector2(corner_a.x, corner_c.y) #inverse
	print(corner_a)
	print(corner_b)
	print(corner_c)
	print(corner_d)
	var bounding_outline = PackedVector2Array([corner_a, corner_b, corner_c, corner_d])

	var nav_poly = NavigationPolygon.new()
	nav_poly.add_outline(bounding_outline)
	nav_poly.source_geometry_group_name="navigation"
	nav_poly.source_geometry_mode=2

	navReg.navigation_polygon = nav_poly
	


	

	
func create_tree( location:Vector2i):
	var x=location.x
	var y=location.y
	#Trunk
	play.set_cell(location,1 ,Vector2i(tree[0],0))
	#Center of leavage
	sky.set_cell(location,1 ,Vector2i(tree[1],0))
	sky.set_cell(Vector2i(x,y+1),1 ,Vector2i(tree[1],0))	
	sky.set_cell(Vector2i(x,y-1),1 ,Vector2i(tree[1],0))		
	sky.set_cell(Vector2i(x+1,y),1 ,Vector2i(tree[1],0))	
	sky.set_cell(Vector2i(x-1,y),1 ,Vector2i(tree[1],0))	
	
	##Large tree, need rotation for corners :weary:
	#leavage 
	#sky.set_cell(Vector2i(x-1,y-1),1 ,Vector2i(tree[2],0))
	#sky.set_cell(Vector2i(x-1,y+1),1 ,Vector2i(tree[2],0))
	#sky.set_cell(Vector2i(x+1,y-1),1 ,Vector2i(tree[2],0))
	#sky.set_cell(Vector2i(x+1,y+1),1 ,Vector2i(tree[2],0))
	
	# Edge of middle
	#sky.set_cell(Vector2i(x,y+2),1 ,Vector2i(tree[3],0))	
	#sky.set_cell(Vector2i(x,y-2),1 ,Vector2i(tree[3],0))		
	#sky.set_cell(Vector2i(x+2,y),1 ,Vector2i(tree[3],0))	
	#sky.set_cell(Vector2i(x-2,y),1 ,Vector2i(tree[3],0))	
	
	
	
func _enter_tree():
	pass

func _ready():
	pass
