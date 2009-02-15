package awaybuilder.camera;

import awaybuilder.vo.DynamicAttributeVO;
import awaybuilder.vo.SceneCameraVO;


class CameraPropertyFactory  {
	
	

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

	////////////////////////////////////////////////////////////////////////////////
	//
	// Public Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	public function build(vo:SceneCameraVO):SceneCameraVO {
		
		for (__i in 0...vo.extras.length) {
			var attribute:DynamicAttributeVO = vo.extras[__i];

			switch (attribute.key) {
				case CameraAttributes.TRANSITION_TIME :
					vo.transitionTime = (attribute.value);
					break;
				case CameraAttributes.TRANSITION_TYPE :
					vo.transitionType = attribute.value;
					break;
				

			}
		}

		return vo;
	}

}

