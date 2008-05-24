package away3d.core.traverse
{
	import away3d.containers.*;
    import away3d.core.block.*;
    import away3d.core.base.*;
    

    /**
    * Traverser that gathers blocker primitives for occlusion culling.
    */
    public class BlockerTraverser extends Traverser
    {
		/**
		 * Defines the view being used.
		 */
    	public var view:View3D;
		
		/**
		 * Defines the blocker consumer being used.
		 */
        public var consumer:IBlockerConsumer;
		    	
		/**
		 * Creates a new <code>BlockerTraverser</code> object.
		 */
        public function BlockerTraverser()
        {
        }
        
		/**
		 * @inheritDoc
		 */
		public override function match(node:Object3D):Boolean
        {
            if (!node.visible)
                return false;
            if (node is ILODObject)
                return (node as ILODObject).matchLOD(view);
            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function apply(node:Object3D):void
        {
            if (node is IBlockerProvider)
            {
                (node as IBlockerProvider).blockers(consumer);
            }
        }

    }
}
