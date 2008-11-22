package away3d.core.traverse;

	import away3d.core.base.*;
	
    /**
    * Traverser that fires a time-based method for all objects in scene
    */
    class TickTraverser extends Traverser {
    	/**
    	 * Defines the current time in milliseconds from the start of the flash movie.
    	 */
        
    	/**
    	 * Defines the current time in milliseconds from the start of the flash movie.
    	 */
        public var now:Int;
		    	
		/**
		 * Creates a new <code>TickTraverser</code> object.
		 */
        public function new()
        {
        }
        
		/**
		 * @inheritDoc
		 */
        public override function enter(node:Object3D):Void
        {
            node.tick(now);
        }
    }
