package awaybuilder.geometry;



class GeometryAttributes  {
	
	public static inline var ASSET_CLASS:String = "assetClass";
	public static inline var ASSET_FILE:String = "assetFile";
	public static inline var ASSET_FILE_BACK:String = "assetFileBack";
	public static inline var BOTHSIDES:String = "bothsides";
	public static inline var CLASS:String = "class";
	public static inline var DEPTH:String = "depth";
	public static inline var ENABLED:String = "enabled";
	public static inline var HEIGHT:String = "height";
	public static inline var MOUSE_DOWN_ENABLED:String = "mouseDownEnabled";
	public static inline var MOUSE_MOVE_ENABLED:String = "mouseMoveEnabled";
	public static inline var MOUSE_OUT_ENABLED:String = "mouseOutEnabled";
	public static inline var MOUSE_OVER_ENABLED:String = "mouseOverEnabled";
	public static inline var MOUSE_UP_ENABLED:String = "mouseUpEnabled";
	public static inline var OWN_CANVAS:String = "ownCanvas";
	public static inline var RADIUS:String = "radius";
	public static inline var SEGMENTS_H:String = "segmentsH";
	public static inline var SEGMENTS_W:String = "segmentsW";
	public static inline var SEGMENTS_R:String = "segmentsR";
	public static inline var SEGMENTS_T:String = "segmentsT";
	public static inline var TARGET_CAMERA:String = "targetCamera";
	public static inline var TUBE:String = "tube";
	public static inline var USE_HAND_CURSOR:String = "useHandCursor";
	public static inline var WIDTH:String = "width";
	public static inline var Y_UP:String = "yUp";
	

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

