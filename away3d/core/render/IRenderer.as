package away3d.core.render
{
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import flash.geom.*;
    import flash.display.*;

    /** Interface for renderers capable of rendering scene to the view */
    public interface IRenderer
    {
        function render(view:View3D/*scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping*/):void;
        function desc():String;
        function stats():String;
    }
}
