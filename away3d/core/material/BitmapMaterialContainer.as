package away3d.core.material
{
	import away3d.core.draw.DrawTriangle;
	import away3d.core.utils.Init;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class BitmapMaterialContainer implements ITriangleMaterial, IUVMaterialContainer
	{
        
        public var smooth:Boolean;
        public var debug:Boolean;
        public var repeat:Boolean;
		public var materials:Array;
        internal var _width:Number;
        internal var _height:Number;
        internal var _bitmap:BitmapData;
		internal var _zeroPoint:Point = new Point(0, 0);
		internal var _zeroRect:Rectangle;
		
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
			_bitmap = new BitmapData(width, height, true);
            init = Init.parse(init);
			
			materials = init.getArray("materials");			
		}
		
		internal var _transformDirty:Boolean;
		internal var _transform:Matrix;
		internal var material:IUVTransformMaterial;
		internal var bitmapDictionary:Dictionary = new Dictionary();
		internal var transformDictionary:Dictionary = new Dictionary();
		
		public function renderTriangle(tri:DrawTriangle):void
        {
        	//check to see if bitmapData needs updating
        	if (!tri.texturemapping) {
        		tri.texturemapping = (tri.invtexturemapping = tri.transformUV(this)).clone();
        		tri.texturemapping.invert();
        		if (bitmapDictionary[tri] != null)
        			bitmapDictionary[tri].dispose();
        		bitmapDictionary[tri] = new BitmapData(tri.bitmapRect.width, tri.bitmapRect.height, true);
        		_transformDirty = true;
        		for each(material in materials)
        			material.clearBitmapDictionary();
        	} else {
        		for each(material in materials) {
        			if (!material.bitmapDictionary[tri])
        				_transformDirty = true;
        		}
        	}
        	if (_transformDirty) {
        		//update all materials
        		_transformDirty = false;
			    _zeroRect = new Rectangle(0, 0, tri.bitmapRect.width, tri.bitmapRect.height);
        		bitmapDictionary[tri].fillRect(tri.bitmapRect, 0x00000000);
        		for each (material in materials) {
        			if (!material.bitmapDictionary[tri]) {
        				
        				if (material.transform) {
        					_transform = material.transform.clone();
        				} else {
        					_transform = new Matrix();
        				}
        				if (material.projectionVector) {
        					_transform.concat(tri.transformUV(material));
        					_transform.concat(tri.invtexturemapping);
        				} else {
	        				_transform.scale(_width/material.width, _height/material.height)
	        				_transform.translate(-tri.bitmapRect.x, -tri.bitmapRect.y);
        				}
        				
        				material.bitmapDictionary[tri] = new BitmapData(_zeroRect.width, _zeroRect.height, true, 0x00000000);
        				if (_transform.a == _transform.d == 1 && _transform.b == 0 && _transform.c == 0) {
        					material.bitmapDictionary[tri].copyPixels(material.bitmap, tri.bitmapRect, _zeroPoint);
        				}else
        					material.bitmapDictionary[tri].draw(material.bitmap, _transform);
        			}
        			
        			bitmapDictionary[tri].copyPixels(material.bitmapDictionary[tri], _zeroRect, _zeroPoint);  	
        		}
        		
        	}
        	tri.source.session.renderTriangleBitmap(bitmapDictionary[tri], tri.texturemapping, tri.v0, tri.v1, tri.v2, smooth, repeat);
			
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