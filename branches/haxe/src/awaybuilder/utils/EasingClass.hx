package awaybuilder.utils;



class EasingClass  {
	
	public static inline var BACK:String = "Back";
	public static inline var BOUNCE:String = "Bounce";
	public static inline var CIRC:String = "Circ";
	public static inline var CUBIC:String = "Cubic";
	public static inline var ELASTIC:String = "Elastic";
	public static inline var EXPO:String = "Expo";
	public static inline var LINEAR:String = "Linear";
	public static inline var QUAD:String = "Quad";
	public static inline var QUART:String = "Quart";
	public static inline var QUINT:String = "Quint";
	public static inline var SINE:String = "Sine";
	public static inline var STRONG:String = "Strong";
	

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

