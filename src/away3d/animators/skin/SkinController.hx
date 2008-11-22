package away3d.animators.skin;

	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	
    class SkinController
     {
    	public function new() {
    	sceneTransform = new Matrix3D();
    	}
    	
    	public var name:String;
		public var joint:ObjectContainer3D;
        public var bindMatrix:Matrix3D;
        public var sceneTransform:Matrix3D ;
        public var inverseTransform:Matrix3D;
        public var updated:Bool;
        
        public function update():Void
        {
        	if (!joint)
        		return;
        	
        	if (!joint.scene.updatedObjects[joint]) {
        		updated = false;
        		return;
        	} else {
        		updated = true;
        	}
        	
        	sceneTransform.multiply(joint.sceneTransform, bindMatrix);
        	sceneTransform.multiply(inverseTransform, sceneTransform);
        }
        
    }
