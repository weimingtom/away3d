package away3d.animators;

	import away3d.containers.ObjectContainer3D;
	

    /**
    * Interface for objects containing animation information for meshes.
    */
    interface IMeshAnimation
    {
    	function update(time:Float, ?interpolate:Bool = true):Void;
    	
    	function clone(object:ObjectContainer3D):IMeshAnimation;
    }
