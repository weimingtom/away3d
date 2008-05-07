package away3d.materials
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    
    import flash.display.BitmapData;
    import flash.geom.*;
	
    /** Interface for all materials that take in account texture coordinates */
    public interface IUVMaterial extends IMaterial
    {
        function get width():Number;
        function get height():Number;
        function get bitmap():BitmapData;
        function getPixel32(u:Number, v:Number):uint;
        function addOnResize(listener:Function):void;
        function removeOnResize(listener:Function):void;
    }
}
