class_name TestBase
extends GdUnitTestSuite

var runner : GdUnitSceneRunner

func load_scene(path : String) -> void:
	runner = scene_runner(path)

func find_node(node_name : String) -> Node:
	return runner.find_child(node_name)
	
