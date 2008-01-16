package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    
    import flash.geom.*;
    import flash.utils.Dictionary;
	
    /** Interface for all materials that take in account texture coordinates */
    public interface IUVTransformMaterial extends IUVMaterial
    {
    	function get bitmapDictionary():Dictionary;
        function get projectionVector():Number3D;
        function get N():Number3D;
        function get M():Number3D;
        function get transform():Matrix;
        function clearBitmapDictionary():void;
    }
}
