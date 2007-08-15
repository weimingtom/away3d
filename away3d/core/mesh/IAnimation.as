package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;

    public interface IAnimation
    {
        function get frame():Number;
        function set frame(value:Number):void
        function get fps():Number;
        function set fps(value:Number):void
        function start(frame:Number = -1, endframe:Number = -1):void
        function stop():void
        function get loop():Boolean;
        function set loop(value:Boolean):void;
        function get smooth():Boolean;
        function set smooth(value:Boolean):void;
        function update():void;
    }
}
