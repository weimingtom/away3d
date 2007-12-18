package away3d.core.render
{
    import away3d.core.draw.*;
    import away3d.core.scene.*;
    
    import flash.display.*;
    import flash.geom.*;

    /** Interface for renderers capable of rendering scene to the view */
    public interface IRenderer
    {
        function render(view:View3D):Array;
        function desc():String;
        function stats():String;
    }
}
