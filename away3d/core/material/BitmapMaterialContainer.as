package away3d.core.material
{
	import away3d.core.*;
	import away3d.core.draw.DrawTriangle;
	import away3d.core.mesh.Face;
	import away3d.core.mesh.Mesh;
	import away3d.core.utils.BitmapDictionaryVO;
	import away3d.core.utils.Init;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class BitmapMaterialContainer implements ITriangleMaterial, IUVMaterialContainer
	{
		use namespace arcane;
        
        public var smooth:Boolean;
        public var debug:Boolean;
        public var repeat:Boolean;
		public var materials:Array;
		
        internal var _width:Number;
        internal var _height:Number;
        internal var _bitmap:BitmapData;
		internal var _zeroPoint:Point = new Point(0, 0);
		internal var _zeroRect:Rectangle;
		internal var _bitmapRect:Rectangle;
		
		public function get width():Number
        {
            return _width;
        }

        public function get height():Number
        {
            return _height;
        }
        
        public function get bitmap():BitmapData
        {
        	return _bitmap;
        }	
		
		public function addMaterial(material:IUVTransformMaterial):void
		{
			
		}
		
		public function BitmapMaterialContainer(width:int, height:int, init:Object = null)
		{
			_width = width;
			_height = height;
			_bitmap = new BitmapData(width, height, true, 0x00FFFFFF);
			_bitmapRect = new Rectangle(0, 0, _width, _height);
            init = Init.parse(init);
			
			materials = init.getArray("materials");
		}
		
		internal var _transformDirty:Boolean;
		internal var _transform:Matrix;
		internal var face:Face;
		internal var dt:DrawTriangle;
		internal var material:IUVTransformMaterial;
		internal var bitmapDictionary:Dictionary = new Dictionary(true);
		
        public function renderMaterial(source:Mesh):void
        {
        	//resolve material rendering if no uv's overlap
        	/*
        	if (!overlappingUVs) {
	        	if (!bitmapDictionary[source])
	        		bitmapDictionary[source] = _bitmap.clone();
	        	
	        	for each(material in materials) {
	    			if (!material.bitmapDictionary[source])
	    				_transformDirty = true;
	    		}
	    		for each (face in source.faces) {
		    		dt = face._dt;
	    			if (dt.material == this) {
		    			if (!dt.texturemapping) {
		    				_transformDirty = true;
			    			face._bitmapRect = _bitmapRect;
			        		dt.transformUV(this);
			      		}
			     	}
	    		}
	    		if (_transformDirty) {
        			//update all materials
        			_transformDirty = false;
	        		bitmapDictionary[source].lock();
	        		bitmapDictionary[source].fillRect(_bitmapRect, 0x00FFFFFF);
		        	for each(material in materials) {
		        		if (!material.bitmapDictionary[source] || material.projectionVector)
		        			material.renderObject(source, _bitmapRect, _bitmap);
		        		bitmapDictionary[source].copyPixels(material.bitmapDictionary[source], _bitmapRect, _zeroPoint, null, null, true);
		        	}
		        	bitmapDictionary[source].unlock();
		    	}
        	}*/
        }
        public function resetMaterial(source:Mesh):void
        {
        	
        }
        
        internal var bitmapDictionaryVO:BitmapDictionaryVO;
        internal var bitmapDictionaryFace:BitmapDictionaryVO;
        internal var bitmapDictionarySource:BitmapDictionaryVO;
        
		public function renderTriangle(tri:DrawTriangle):void
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
        		bitmapDictionaryVO = bitmapDictionary[face];
        		if (bitmapDictionaryVO != null)
        			bitmapDictionaryVO.reset(face._bitmapRect.width, face._bitmapRect.height);
        		else
        			bitmapDictionary[face] = new BitmapDictionaryVO(face._bitmapRect.width, face._bitmapRect.height);
        		
        		//reset bitmapData for container materials
        		for each(material in materials) {
        			bitmapDictionaryVO = material.bitmapDictionary[face];
	        		if (bitmapDictionaryVO != null)
	        			bitmapDictionaryVO.reset(face._bitmapRect.width, face._bitmapRect.height);
	        	}
        	} else {
        		//check to see if any materials require updating
        		for each(material in materials)
        			if (!material.bitmapDictionary[face] || material.bitmapDictionary[face].dirty)
        				_transformDirty = true;
        	}
        	
        	//check to see if tri texturemapping need updating
        	if (!tri.texturemapping)
        	    tri.transformUV(this);
        	
        	if (_transformDirty) {
        		_transformDirty = false;
        		
        		//clear the bitmap VO
        		bitmapDictionaryVO = bitmapDictionary[face];
			    _zeroRect = new Rectangle(0, 0, face._bitmapRect.width, face._bitmapRect.height);
			    bitmapDictionaryVO.bitmap.lock();
        		bitmapDictionaryVO.clear();
        		
        		for each (material in materials) {
	        		//check if the material require updating
	        		bitmapDictionaryFace = material.bitmapDictionary[face];
	        		bitmapDictionarySource = material.bitmapDictionary[tri.source]
        			if ((!bitmapDictionaryFace && !bitmapDictionarySource) || (bitmapDictionaryFace && bitmapDictionaryFace.dirty) || (bitmapDictionarySource && bitmapDictionarySource.dirty))
        				material.renderFace(face, _bitmapRect);
        			
        			//update the bitmap VO
        			if (material.bitmapDictionary[tri.source])
        				bitmapDictionaryVO.bitmap.copyPixels(material.bitmapDictionary[tri.source].bitmap, face._bitmapRect, _zeroPoint, null, null, true);
        			else
        				bitmapDictionaryVO.bitmap.copyPixels(material.bitmapDictionary[face].bitmap, _zeroRect, _zeroPoint, null, null, true);
        		}
        		bitmapDictionaryVO.bitmap.unlock();
        	}
        	
        	//send triangle data to rendersession
        	tri.source.session.renderTriangleBitmap(bitmapDictionaryVO.bitmap, tri.texturemapping, tri.v0, tri.v1, tri.v2, smooth, repeat);
			
            if (debug)
                tri.source.session.renderTriangleLine(2, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }
        	
		public function shadeTriangle(tri:DrawTriangle):void
        {
        	//tri.bitmapMaterial = getBitmapReflection(tri, source);
        }
        
        public function get visible():Boolean
        {
            return true;
        }        
	}
}