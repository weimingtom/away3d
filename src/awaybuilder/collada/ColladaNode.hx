package awaybuilder.collada;



class ColladaNode  {
	
	public static inline var LIBRARY_VISUAL_SCENES:String = "library_visual_scenes";
	public static inline var VISUAL_SCENE:String = "visual_scene";
	public static inline var TRANSLATE:String = "translate";
	public static inline var ROTATE:String = "rotate";
	public static inline var ROTATE_X:String = "rotateX";
	public static inline var ROTATE_Y:String = "rotateY";
	public static inline var ROTATE_Z:String = "rotateZ";
	public static inline var SCALE:String = "scale";
	public static inline var VALUE_TYPE_POSITION:String = "value_type_position";
	public static inline var VALUE_TYPE_ROTATION:String = "value_type_rotation";
	public static inline var VALUE_TYPE_SCALE:String = "value_type_scale";
	public static inline var NODE:String = "node";
	public static inline var EXTRA:String = "extra";
	public static inline var TECHNIQUE:String = "technique";
	public static inline var DYNAMIC_ATTRIBUTES:String = "dynamic_attributes";
	

	public function new() {
		
		OPPOSITE_OR[X | X] = N;
		OPPOSITE_OR[XY | X] = Y;
		OPPOSITE_OR[XZ | X] = Z;
		OPPOSITE_OR[XYZ | X] = YZ;
		OPPOSITE_OR[Y | Y] = N;
		OPPOSITE_OR[XY | Y] = X;
		OPPOSITE_OR[XYZ | Y] = XZ;
		OPPOSITE_OR[YZ | Y] = Z;
		OPPOSITE_OR[Z | Z] = N;
		OPPOSITE_OR[XZ | Z] = X;
		OPPOSITE_OR[XYZ | Z] = XY;
		OPPOSITE_OR[YZ | Z] = Y;
		SCALINGS[1] = [1, 1, 1];
		SCALINGS[2] = [-1, 1, 1];
		SCALINGS[4] = [-1, 1, -1];
		SCALINGS[8] = [1, 1, -1];
		SCALINGS[16] = [1, -1, 1];
		SCALINGS[32] = [-1, -1, 1];
		SCALINGS[64] = [-1, -1, -1];
		SCALINGS[128] = [1, -1, -1];
		
	}

}

