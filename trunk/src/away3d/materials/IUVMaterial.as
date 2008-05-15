package away3d.materials
{
    
    import flash.display.BitmapData;
	
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
