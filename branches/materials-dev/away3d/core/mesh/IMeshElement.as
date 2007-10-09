package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;

    public interface IMeshElement
    {
        function get vertices():Array;
        function get visible():Boolean;
        function get radius2():Number;
        function get maxX():Number;
        function get minX():Number;
        function get maxY():Number;
        function get minY():Number;
        function get maxZ():Number;
        function get minZ():Number;
        function addOnVertexChange(listener:Function):void;
        function removeOnVertexChange(listener:Function):void;
        function addOnVertexValueChange(listener:Function):void;
        function removeOnVertexValueChange(listener:Function):void;
        function addOnVisibleChange(listener:Function):void;
        function removeOnVisibleChange(listener:Function):void;
    }
}
