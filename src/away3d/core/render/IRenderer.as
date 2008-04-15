package away3d.core.render
{
	import away3d.containers.*;
    import away3d.core.base.*
    import away3d.core.draw.*;
    
    import flash.display.*;
    import flash.geom.*;
    

    /** Interface for renderers capable of rendering scene to the view */
    public interface IRenderer
    {
        function render(view:View3D):Array;
        function desc():String;
        function stats():String;
        function set renderSession(value:AbstractRenderSession):void;
        function get renderSession():AbstractRenderSession;
    }
}
