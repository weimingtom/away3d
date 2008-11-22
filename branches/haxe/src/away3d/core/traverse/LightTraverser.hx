package away3d.core.traverse;

	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.block.*;
	import away3d.core.light.*;
    

    /**
    * Traverser that gathers blocker primitives for occlusion culling.
    */
    class LightTraverser extends Traverser { 	
		/**
		 * Creates a new <code>LightTraverser</code> object.
		 */
         	
		/**
		 * Creates a new <code>LightTraverser</code> object.
		 */
        public function new()
        {
        }
        
		/**
		 * @inheritDoc
		 */
		public override function match(node:Object3D):Bool
        {
            if (!node.visible)
                return false;
            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function apply(node:Object3D):Void
        {
            //clear light arrays
            if (node.ownLights)
            	node.lightarray.clear();
            
            if (Std.is( node, ILightProvider))
                (cast( node, ILightProvider)).light(node.parent.lightarray);
        }

    }
