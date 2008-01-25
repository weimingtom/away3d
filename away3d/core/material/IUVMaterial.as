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
    public interface IUVMaterial extends IMaterial
    {
        function get width():Number;
        function get height():Number;
        function get bitmap():BitmapData;
        function get faceDictionary():Dictionary;
        function clearFaceDictionary():void;
        function renderMaterial(source:Mesh):void;
        function renderFace(face:Face, bitmapRect:Rectangle):void;
    }
}
