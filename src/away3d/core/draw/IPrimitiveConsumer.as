package away3d.core.draw
{
    import away3d.containers.View3D;

    /**
    * Interface for containers capable of drawing primitives
    */
    public interface IPrimitiveConsumer
    {
    	function get view():View3D
    	function set view(val:View3D):void
    	
    	/**
    	 * Adds a drawing primitive to the primitive consumer
    	 *
		 * @param	pri		The drawing primitive to add.
		 */
        function primitive(pri:DrawPrimitive):void;
        
        function list():Array;
        
        function clear():void;
        
        function clone():IPrimitiveConsumer;
        
        function filter(filters:Array):void;
        
        function render():void;
    }
}
