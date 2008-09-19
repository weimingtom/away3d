package away3d.core.draw
{
    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.render.*;
    import away3d.materials.*;
    
    import flash.display.*;
    import flash.utils.*;

    /**
    * Interface for containers capable of drawing primitives
    */
    public interface IPrimitiveConsumer
    {
    	/**
    	 * Adds a drawing primitive to the primitive consumer
    	 *
		 * @param	pri		The drawing primitive to add.
		 */
        function primitive(pri:DrawPrimitive):void;
        
        function list():Array;
        
        function clear(view:View3D):void;
        
        function clone():IPrimitiveConsumer;
        
    	function createScreenVertex(source:Object3D, vertex:Vertex = null):ScreenVertex;
        
        function getScreenVertex(source:Object3D, vertex:Vertex = null):ScreenVertex;
        
        function createDrawTriangle(view:View3D, source:Object3D, face:Face, material:ITriangleMaterial = null, v0:ScreenVertex = null, v1:ScreenVertex = null, v2:ScreenVertex = null, uv0:UV = null, uv1:UV = null, uv2:UV = null):DrawTriangle;
        
        function createDrawSegment(view:View3D, source:Object3D, material:ISegmentMaterial = null, v0:ScreenVertex = null, v1:ScreenVertex = null):DrawSegment;
        
        function createDrawDisplayObject(view:View3D, session:AbstractRenderSession, displayobject:DisplayObject, screenvertex:ScreenVertex):DrawDisplayObject;
    }
}
