package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;

    import flash.geom.*;

    public interface IUVMaterial extends IMaterial
    {
        function get width():Number;
        function get height():Number;
        function get transform():Matrix;
        function get normal():Number3D;
        function get repeat():Boolean;
        function get scalex():Boolean;
        function get scaley():Boolean;
    }
}
