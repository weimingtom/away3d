package away3d.materials
{
    import away3d.core.draw.*;

    /** Interface for all material that are capable of triangle faces */
    public interface ITriangleMaterial extends IMaterial
    {
        function renderTriangle(tri:DrawTriangle):void;
    }
}
