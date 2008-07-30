package away3d.animators.skin
{
	import away3d.animators.*;
	import away3d.containers.*;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	
    public class Bone extends ObjectContainer3D
    {
    	use namespace arcane;
    	
    	public var joint:ObjectContainer3D;
    	
		//Collada 3.05B
		public var id:String;
		
		private var _baseMatrix:Matrix3D = new Matrix3D();
		private var _jointTransform:Matrix3D = new Matrix3D();
		
    	/**
    	 * Defines the euler angle of rotation of the 3d object around the x-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function get jointRotationX():Number
        {
            return joint.rotationX;
        }
    
        public function set jointRotationX(rot:Number):void
        {
            joint.rotationX = rot;
        }
		
    	/**
    	 * Defines the euler angle of rotation of the 3d object around the y-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function get jointRotationY():Number
        {
            return joint.rotationY;
        }
    
        public function set jointRotationY(rot:Number):void
        {
            joint.rotationY = rot;
        }
		
    	/**
    	 * Defines the euler angle of rotation of the 3d object around the z-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function get jointRotationZ():Number
        {
            return joint.rotationZ;
        }
    
        public function set jointRotationZ(rot:Number):void
        {
            joint.rotationZ = rot;
        }
		
    	/**
    	 * Defines the scale of the 3d object along the x-axis, relative to local coordinates.
    	 */
        public function get jointScaleX():Number
        {
            return joint.scaleX;
        }
    
        public function set jointScaleX(scale:Number):void
        {
        	joint.scaleX = scale;
        }
		
    	/**
    	 * Defines the scale of the 3d object along the y-axis, relative to local coordinates.
    	 */
        public function get jointScaleY():Number
        {
            return joint.scaleY;
        }
    
        public function set jointScaleY(scale:Number):void
        {
			joint.scaleY = scale;
        }
		
    	/**
    	 * Defines the scale of the 3d object along the z-axis, relative to local coordinates.
    	 */
        public function get jointScaleZ():Number
        {
            return joint.scaleZ;
        }
    
        public function set jointScaleZ(scale:Number):void
        {
			joint.scaleZ = scale;
        }
        
        public function Bone(init:Object = null, ...childarray) : void
        {
			super(init);
			
			//create the joint for the bone
			addChild(joint = new ObjectContainer3D());
			//addChild(new Sphere({radius:3}));
        }
        
		/**
		 * Get frame name Collada 3.02
		 * @param	frameName
		 * @return
        public function getBoneByName(boneName:String):Bone
        {
			if (name)
				if (name == boneName)
					return this;
			
            var bone:Bone;
            for each(var object3D:Object3D in joint.children) {
                if (object3D is Bone){
                    bone = (object3D as Bone).getBoneByName(boneName);
                    if (bone)
                        return bone;
                }
            }
            return null;
        }
		
		 */
		/**
		 * Get frame id Collada 3.05B
		 * @param	frameId
		 * @return
        public function getBoneById(frameId:String):Bone
        {
			if (id)
				if (id == frameId)
					return this;
			
            var bone:Bone;
            for each(var object3D:Object3D in joint.children) {
                if (object3D is Bone) {
					bone = (object3D as Bone).getBoneById(frameId);
                    if (bone)
                        return bone;
                }
            }
            return null;
        }
		 */
    }
}
