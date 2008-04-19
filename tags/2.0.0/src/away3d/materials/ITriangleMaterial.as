package away3d.materials
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.base.*
    import away3d.core.draw.*;
    import away3d.core.render.*;

    /** Interface for all material that are capable of triangle faces */
    public interface ITriangleMaterial extends IMaterial
    {
        function renderTriangle(tri:DrawTriangle):void;
    }
}
