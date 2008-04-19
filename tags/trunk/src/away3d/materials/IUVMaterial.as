package away3d.materials
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.base.*;
    import away3d.core.base.*;
    import away3d.core.base.*
    
    import flash.display.BitmapData;
    import flash.geom.*;
    import flash.utils.Dictionary;
	
    /** Interface for all materials that take in account texture coordinates */
    public interface IUVMaterial extends IMaterial
    {
        function get width():Number;
        function get height():Number;
        function get bitmap():BitmapData;
    }
}
