package away3d.core.draw;

    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.render.*;
    import away3d.materials.*;
    
    import flash.display.*;
    import flash.utils.*;

    /**
    * Interface for containers capable of drawing primitives
    */
    interface IPrimitiveConsumer
    {
    	/**
    	 * Adds a drawing primitive to the primitive consumer
    	 *
		 * @param	pri		The drawing primitive to add.
		 * @return			Whether the primitive was added.
		 */
        function primitive(pri:DrawPrimitive):Bool;
        
        function list():Array<Dynamic>;
        
        function clear(view:View3D):Void;
        
        function clone():IPrimitiveConsumer;
    }
