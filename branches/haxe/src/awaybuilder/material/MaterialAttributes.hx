package awaybuilder.material;



class MaterialAttributes  {
	
	public static inline var ALPHA:String = "alpha";
	public static inline var AMBIENT:String = "ambient";
	public static inline var ASSET_CLASS:String = "assetClass";
	public static inline var ASSET_FILE:String = "assetFile";
	public static inline var ASSET_FILE_BACK:String = "assetFileBack";
	public static inline var CLASS:String = "class";
	public static inline var COLOR:String = "color";
	public static inline var DIFFUSE:String = "diffuse";
	public static inline var PRECISION:String = "precision";
	public static inline var SMOOTH:String = "smooth";
	public static inline var SPECULAR:String = "specular";
	public static inline var WIDTH:String = "width";
	public static inline var WIREALPHA:String = "wirealpha";
	public static inline var WIRECOLOR:String = "wirecolor";
	

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

