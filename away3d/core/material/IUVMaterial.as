package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;

    import flash.display.Graphics;

    public interface IUVMaterial extends IMaterial
    {
        function get width():Number;
        function get height():Number;
    }
}
