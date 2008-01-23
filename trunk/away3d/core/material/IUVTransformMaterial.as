package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.mesh.Face;
    import away3d.core.mesh.Mesh;
    import away3d.core.scene.*;
    
    import flash.display.BitmapData;
    import flash.geom.*;
    import flash.utils.Dictionary;
	
    /** Interface for all materials that take in account texture coordinates */
    public interface IUVTransformMaterial extends IUVMaterial
    {
    	function get transform():Matrix;
    	function get bitmapDictionary():Dictionary;
        function get projectionVector():Number3D;
        function clearBitmapDictionary():void;
        function renderMaterial(source:Mesh, bitmapRect:Rectangle, bitmap:BitmapData):void;
        function renderFace(face:Face, _bitmapRect:Rectangle):void;
    }
}
