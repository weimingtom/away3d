package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;
    
    import flash.display.*;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.ConvolutionFilter;
    import flash.geom.*;
    import flash.utils.*;
	
    /** Basic phong texture material */
    public class PhongBitmapMaterial extends BitmapMaterial
    {
        public var _byteMaterial:ByteArray;
        public var _bitmapBump:BitmapData;
        
        public function PhongBitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            super(bitmap, init);

            init = Init.parse(init);
        }
        
        public override function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
        	mapping = tri.texturemapping || tri.transformUV(this);
        	
        	tri.bitmapMaterial = tri.face.getBitmapMaterial(tri.material as PhongBitmapMaterial);
        	tri.bitmapMaterial.draw(tri.face.getBitmapPhong(), null, null, BlendMode.MULTIPLY);
            session.renderTriangleBitmap(tri.bitmapMaterial, mapping, tri.v0, tri.v1, tri.v2, smooth, repeat);
			
            if (debug)
                session.renderTriangleLine(2, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }
        
        public function shadeTriangle(tri:DrawTriangle, session:RenderSession):void
        {
			tri.bitmapMaterial.copyPixels(tri.face.getBitmapPhong(), tri.face._normalRect, tri.face._normalPoint);        	
        }
        
        public function getByteArray():ByteArray
        {
        	if (_byteMaterial == null)
        	{
        		var _bumpRect:Rectangle = new Rectangle(0, 0, width, height);
            	_bitmapBump = new BitmapData(_bumpRect.width, _bumpRect.height, true, 0x00000000);
            	_bitmapBump.copyPixels(bitmap, _bumpRect, new Point(0,0));
            	var colorTransform:ColorMatrixFilter = new ColorMatrixFilter([0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0]);
            	_bitmapBump.applyFilter(_bitmapBump, _bumpRect, new Point(0,0), colorTransform);
            	//var cf:ConvolutionFilter = new ConvolutionFilter(3, 3, null, 1, 127);
            	//cf.matrix = new Array(0,0,0,-1,0,1,0,0,0);
            	//_bitmapBump.applyFilter(_bitmapBump, _bumpRect, new Point(0,0), cf);
            	_byteMaterial = _bitmapBump.getPixels(_bumpRect);
        	}
        	return _byteMaterial;
        }
 
    }
}
