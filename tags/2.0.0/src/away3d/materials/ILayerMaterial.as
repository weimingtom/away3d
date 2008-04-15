package away3d.materials
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;
    
    import flash.display.*;
    import flash.geom.*;
	
    /** Interface for all materials that take in account texture coordinates */
    public interface ILayerMaterial extends IMaterial
    {
        function renderFace(face:Face, containerRect:Rectangle, parentFaceVO:FaceVO):FaceVO;
        function renderLayer(tri:DrawTriangle, layer:Sprite):void;
    }
}
