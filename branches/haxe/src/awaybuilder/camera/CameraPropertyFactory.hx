package awaybuilder.camera;

import awaybuilder.vo.DynamicAttributeVO;
import awaybuilder.vo.SceneCameraVO;


class CameraPropertyFactory  {
	
	

	public function new() {
		
		
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Public Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	public function build(vo:SceneCameraVO):SceneCameraVO {
		
		for (__i in 0...vo.extras.length) {
			var attribute:DynamicAttributeVO = vo.extras[__i];

			if (attribute != null) {
				switch (attribute.key) {
					case CameraAttributes.TRANSITION_TIME :
						vo.transitionTime = (attribute.value);
						break;
					case CameraAttributes.TRANSITION_TYPE :
						vo.transitionType = attribute.value;
						break;
					

				}
			}
		}

		return vo;
	}

}

