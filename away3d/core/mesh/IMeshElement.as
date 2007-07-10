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
        function get radius2():Number;
        function get visible():Boolean;
        function addOnVertexChange(listener:Function):void;
        function removeOnVertexChange(listener:Function):void;
        function addOnVertexValueChange(listener:Function):void;
        function removeOnVertexValueChange(listener:Function):void;
        function addOnVisibleChange(listener:Function):void;
        function removeOnVisibleChange(listener:Function):void;
    }
}
