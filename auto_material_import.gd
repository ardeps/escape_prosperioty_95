@tool
extends EditorScenePostImport

# Directory where your external materials live (e.g., "res://materials/")
const MATERIAL_DIR = "res://materials/"

func _post_import(scene: Node) -> Object:
	var dir = DirAccess.open(MATERIAL_DIR)
	if dir == null:
		DirAccess.make_dir_recursive_absolute(MATERIAL_DIR)

	_process_node(scene)
	return scene # Return the modified root node

func _process_node(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			for surface_idx in mesh.get_surface_count():
				var mat = mesh.surface_get_material(surface_idx)
				if mat:
					var mat_name = mat.resource_name
					if mat_name == "":
						mat_name = node.name + "_mat"
					
					var save_path = MATERIAL_DIR + mat_name + ".tres"
					
					# If material already exists, load and reuse it
					if ResourceLoader.exists(save_path):
						var existing_mat = ResourceLoader.load(save_path)
						node.set_surface_override_material(surface_idx, existing_mat)
					else:
						# Save out the imported material so you can edit its textures directly
						ResourceSaver.save(mat, save_path)
						var saved_mat = ResourceLoader.load(save_path)
						node.set_surface_override_material(surface_idx, saved_mat)
						
	for child in node.get_children():
		_process_node(child)
