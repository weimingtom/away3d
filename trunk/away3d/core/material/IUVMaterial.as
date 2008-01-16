package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    
    import flash.display.BitmapData;
    import flash.geom.*;
	
    /** Interface for all materials that take in account texture coordinates */
    public interface IUVMaterial extends IMaterial
    {
        function get width():Number;
        function get height():Number;
        function get bitmap():BitmapData;
    }
}
