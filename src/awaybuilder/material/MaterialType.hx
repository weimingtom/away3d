package awaybuilder.material;



class MaterialType  {
	
	public static inline var BITMAP_MATERIAL:String = "BitmapMaterial";
	public static inline var BITMAP_FILE_MATERIAL:String = "BitmapFileMaterial";
	public static inline var COLOR_MATERIAL:String = "ColorMaterial";
	public static inline var MOVIE_MATERIAL:String = "MovieMaterial";
	public static inline var SHADING_COLOR_MATERIAL:String = "ShadingColorMaterial";
	public static inline var WIRE_COLOR_MATERIAL:String = "WireColorMaterial";
	public static inline var WIREFRAME_MATERIAL:String = "WireframeMaterial";
	

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

