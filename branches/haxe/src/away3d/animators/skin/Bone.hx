package away3d.animators.skin;

	import away3d.animators.*;
	import away3d.containers.*;
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	
	use namespace arcane;
	
    class Bone extends ObjectContainer3D {
    	public var jointRotationX(getJointRotationX, setJointRotationX) : Float;
    	public var jointRotationY(getJointRotationY, setJointRotationY) : Float;
    	public var jointRotationZ(getJointRotationZ, setJointRotationZ) : Float;
    	public var jointScaleX(getJointScaleX, setJointScaleX) : Float;
    	public var jointScaleY(getJointScaleY, setJointScaleY) : Float;
    	public var jointScaleZ(getJointScaleZ, setJointScaleZ) : Float;
    	
    	public var joint:ObjectContainer3D;
    	
		//Collada 3.05B
		public var id:String;
		
		var _baseMatrix:Matrix3D ;
		var _jointTransform:Matrix3D ;
		
    	/**
    	 * Defines the euler angle of rotation of the 3d object around the x-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function getJointRotationX():Float{
            return joint.rotationX;
        }
    
        public function setJointRotationX(rot:Float):Float{
            joint.rotationX = rot;
        	return rot;
           }
		
    	/**
    	 * Defines the euler angle of rotation of the 3d object around the y-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function getJointRotationY():Float{
            return joint.rotationY;
        }
    
        public function setJointRotationY(rot:Float):Float{
            joint.rotationY = rot;
        	return rot;
           }
		
    	/**
    	 * Defines the euler angle of rotation of the 3d object around the z-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function getJointRotationZ():Float{
            return joint.rotationZ;
        }
    
        public function setJointRotationZ(rot:Float):Float{
            joint.rotationZ = rot;
        	return rot;
           }
		
    	/**
    	 * Defines the scale of the 3d object along the x-axis, relative to local coordinates.
    	 */
        public function getJointScaleX():Float{
            return joint.scaleX;
        }
    
        public function setJointScaleX(scale:Float):Float{
        	joint.scaleX = scale;
        	return scale;
        }
		
    	/**
    	 * Defines the scale of the 3d object along the y-axis, relative to local coordinates.
    	 */
        public function getJointScaleY():Float{
            return joint.scaleY;
        }
    
        public function setJointScaleY(scale:Float):Float{
			joint.scaleY = scale;
        	return scale;
		}
		
    	/**
    	 * Defines the scale of the 3d object along the z-axis, relative to local coordinates.
    	 */
        public function getJointScaleZ():Float{
            return joint.scaleZ;
        }
    
        public function setJointScaleZ(scale:Float):Float{
			joint.scaleZ = scale;
        	return scale;
		}
        
        public function new(?init:Dynamic = null, childarray:Array<Dynamic>) {
			
			_baseMatrix = new Matrix3D();
			_jointTransform = new Matrix3D();
			super(init);
			
			//create the joint for the bone
			addChild(joint = new ObjectContainer3D());
			//addChild(new Sphere({radius:3}));
        }
		
		/**
		 * Duplicates the 3d object's properties to another <code>Bone</code> object
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
        public override function clone(?object:Object3D = null):Object3D
        {
            var bone:Bone = (cast( object, Bone)) || new Bone();
            super.clone(bone);
            
            bone.joint = bone.children[0];
            
            return bone;
        }
        
        public override function cloneAll(?object:Object3D = null):Object3D
        {
            var bone:Bone = (cast( object, Bone)) || new Bone();
            bone.removeChild(joint);
            
            super.cloneAll(bone);
            
            bone.id = id;
            bone.joint = bone.children[0];
            
            return bone;
        }
    }
