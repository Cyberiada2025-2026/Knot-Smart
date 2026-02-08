extends Node
class_name BiomeTriangle

var line_a: BiomeLine
var line_b: BiomeLine
var line_c: BiomeLine

func get_area() -> float:
	#print("getArea")
	var a: float = line_a.get_length()
	var b: float = line_b.get_length()
	var c: float = line_c.get_length()
	var p: float = (a+b+c)/2
	#print(a, "   ", b, "   ", c, "   ", sqrt(p*(p-a)*(p-b)*(p-c)))
	return sqrt(p*(p-a)*(p-b)*(p-c))
