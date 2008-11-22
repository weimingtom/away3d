package away3d.loaders.data;

	import away3d.core.math.*;
	/**
	 * Data class for a bone used in SkinAnimation.
	 */
	class BoneData extends ContainerData {
		/**
		 * Transform information for the joint in a SkinAnimation
		 */
		public function new() {
		jointTransform = new Matrix3D();
		}
		
		/**
		 * Transform information for the joint in a SkinAnimation
		 */
		public var jointTransform:Matrix3D ;
	}
