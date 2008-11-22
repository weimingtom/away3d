package away3d.core.draw;

    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.math.*;
    import away3d.core.project.*;
    import away3d.core.render.*;

    /**
    * Interface for objects that provide drawing primitives to the rendering process
    */
    interface IPrimitiveProvider
    {
    	function source():Object3D;
    	
    	function source(val:Object3D):Void;
    	
    	/**
    	 * Called from the <code>PrimitiveTraverser</code> when passing <code>DrawPrimitive</code> objects to the primitive consumer object
    	 * 
    	 * @see	away3d.core.traverse.PrimitiveTraverser
    	 * @see	away3d.core.draw.DrawPrimitive
    	 */
        function primitives(view:View3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):Void;
        
        function clone():IPrimitiveProvider;
    }
