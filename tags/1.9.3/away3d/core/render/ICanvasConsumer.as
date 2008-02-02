package away3d.core.render
{
    import away3d.core.draw.*;
    import away3d.core.scene.*;

    public interface ICanvasConsumer
    {
        function canvas(object:Object3D):void;
    }
}
