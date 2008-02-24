package away3d.core.material
{
	import away3d.core.*;
	import away3d.core.draw.DrawTriangle;
	import away3d.core.mesh.Face;
	import away3d.core.mesh.Mesh;
	import away3d.core.utils.FaceDictionaryVO;
	import away3d.core.utils.Init;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class BitmapMaterialContainer extends BitmapMaterial implements ITriangleMaterial
	{
		use namespace arcane;
		
		public var materials:Array;
		
		internal var _width:Number;
		internal var _height:Number;
		internal var _zeroRect:Rectangle;
		internal var _bitmapRect:Rectangle;	
		
		public function BitmapMaterialContainer(width:int, height:int, init:Object = null)
		{
			super(new BitmapData(width, height, true, 0x00FFFFFF), init);
			
			_width = width;
			_height = height;
			_bitmapRect = new Rectangle(0, 0, _width, _height);
			
            init = Init.parse(init);
			
			materials = init.getArray("materials");
		}
		
		internal var _transformDirty:Boolean;
		internal var face:Face;
		internal var dt:DrawTriangle;
		internal var material:IUVMaterial;
		
        public override function renderMaterial(source:Mesh):void
        {
        }
        
        internal var bitmapDictionaryFace:FaceDictionaryVO;
        internal var bitmapDictionarySource:FaceDictionaryVO;
        
		public override function getMapping(tri:DrawTriangle):Matrix
        {
        	face = tri.face;
			dt = face._dt;
			
        	//check to see if face drawtriangle needs updating
        	if (!dt.texturemapping) {
        		_transformDirty = true;
        		
        		//update face bitmapRect
        		face._bitmapRect = new Rectangle(int(_width*face.minU), int(_height*(1 - face.maxV)), int(_width*(face.maxU-face.minU)+2), int(_height*(face.maxV-face.minV)+2));
        		
        		//update texturemapping
        		dt.transformUV(this);
        		
        		//reset bitmapData for container
        		faceDictionaryVO = _faceDictionary[face];
        		if (faceDictionaryVO != null)
        			faceDictionaryVO.reset(face._bitmapRect.width, face._bitmapRect.height);
        		else
        			_faceDictionary[face] = new FaceDictionaryVO(face._bitmapRect.width, face._bitmapRect.height);
        		
        		//reset bitmapData for container materials
        		for each(material in materials) {
        			faceDictionaryVO = material.faceDictionary[face];
	        		if (faceDictionaryVO != null)
	        			faceDictionaryVO.reset(face._bitmapRect.width, face._bitmapRect.height);
	        	}
        	} else {
        		//check to see if any materials require updating
        		for each(material in materials)
        			if (!material.faceDictionary[face] || material.faceDictionary[face].dirty)
        				_transformDirty = true;
        	}
        	
        	//check to see if tri texturemapping need updating
        	if (!tri.texturemapping)
        	    tri.transformUV(this);
        	
        	faceDictionaryVO = _faceDictionary[face];
        	
        	//check to see if materials need updating
        	if (_transformDirty) {
        		_transformDirty = false;
        		
        		//clear the bitmap VO
			    _zeroRect = new Rectangle(0, 0, face._bitmapRect.width, face._bitmapRect.height);
			    faceDictionaryVO.bitmap.lock();
        		faceDictionaryVO.clear();
        		
        		for each (material in materials) {
	        		//check if the material require updating
	        		bitmapDictionaryFace = material.faceDictionary[face];
	        		bitmapDictionarySource = material.faceDictionary[tri.source];
	        		if (bitmapDictionarySource && !bitmapDictionarySource.dirty)
	        			bitmapDictionaryFace = bitmapDictionarySource;
        			else if (!bitmapDictionaryFace || (bitmapDictionaryFace && bitmapDictionaryFace.dirty) || (bitmapDictionarySource && bitmapDictionarySource.dirty))
        				material.renderFace(face, _bitmapRect);
        			
        			//update the bitmap VO
        			bitmapDictionaryFace = material.faceDictionary[face];
	        		bitmapDictionarySource = material.faceDictionary[tri.source];
        			if (bitmapDictionarySource && bitmapDictionarySource.bitmap)
        				faceDictionaryVO.bitmap.copyPixels(bitmapDictionarySource.bitmap, face._bitmapRect, _zeroPoint, null, null, true);
        			else if (bitmapDictionaryFace.bitmap)
        				faceDictionaryVO.bitmap.copyPixels(bitmapDictionaryFace.bitmap, _zeroRect, _zeroPoint, null, null, true);
        		}
        		faceDictionaryVO.bitmap.unlock();
        	}
        	
        	_renderBitmap = faceDictionaryVO.bitmap;
        	
        	return tri.texturemapping;
        }     
	}
}