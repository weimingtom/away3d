package away3d.loaders.data;

	import away3d.animators.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	
	import flash.utils.*;
	
	/**
	 * Data class for the animation of a mesh.
	 * 
	 * @see away3d.loaders.data.MeshData
	 */
	class AnimationData
	 {
		/**
		 * String representing a vertex animation.
		 */
		public function new() {
		start = Infinity;
		end = 0;
		animationType = SKIN_ANIMATION;
		channels = new Dictionary(true);
		}
		
		/**
		 * String representing a vertex animation.
		 */
		inline public static var VERTEX_ANIMATION:String = "vertexAnimation";
		
		/**
		 * String representing a skin animation.
		 */
		inline public static var SKIN_ANIMATION:String = "skinAnimation";
		
		/**
		 * The name of the animation used as a unique reference.
		 */
		public var name:String;
		
		/**
		 * Reference to the animation object of the resulting animation.
		 */
		public var animation:IMeshAnimation;
		
		/**
		 * Reference to the time the animation starts.
		 */
		public var start:Int ;
		
		/**
		 * Reference to the number of seconds the animation ends.
		 */
		public var end:Int ;
		
		/**
		 * String representing the animation type.
		 */
		public var animationType:String ;
		
		/**
		 * Dictonary of names representing the animation channels used in the animation.
		 */
		public var channels:Dictionary ;
		
		public function clone(object:Object3D):AnimationData
		{
			var animationData:AnimationData = object.animationLibrary.addAnimation(name);
			
    		animationData.start = start;
    		animationData.end = end;
    		animationData.animationType = animationType;
    		animationData.animation = animation.clone(cast( object, ObjectContainer3D));
    		
    		return animationData;
		}
	}
