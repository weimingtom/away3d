package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.Graphics;

    public interface ITriangleMaterial extends IMaterial
    {
        function renderTriangle(tri:DrawTriangle, session:RenderSession):void;
    }
}
