package away3d.cameras;

	import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;
	
	
    /**
    * Extended camera used to automatically look at a specified target object.
    * 
    * @see away3d.containers.View3D
    */
    class TargetCamera3D extends Camera3D {
        public var parent(null, setParent) : ObjectContainer3D;
        public var view(getView, null) : Matrix3D
        ;
        /**
        * The 3d object targeted by the camera.
        */
        
        /**
        * The 3d object targeted by the camera.
        */
        public var target:Object3D;
    	
	    /**
	    * Creates a new <code>TargetCamera3D</code> object.
	    * 
	    * @param	init	[optional]	An initialisation object for specifying default instance properties.
	    */
        public function new(?init:Dynamic = null)
        {
            super(init);

            target = ini.getObject3D("target") || new Object3D();
        }
        
		/**
		 * @inheritDoc
		 */
        public override function getView():Matrix3D
        {
            if (target != null)
                lookAt(target.scene ? target.scenePosition : target.position);
    
            return super.view;
        }
        
		/**
		 * Cannot parent a <code>TargetCamera3D</code> object.
		 * 
		 * @throws	Error	TargetCamera can't be parented.
		 */
        public override function setParent(value:ObjectContainer3D):ObjectContainer3D{
            if (value != null)
                throw new Error("TargetCamera can't be parented");
        	return value;
           }

    }

