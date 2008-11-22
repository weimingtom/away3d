package away3d.materials;

	import away3d.containers.*;
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	
	import flash.display.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.utils.*;

    use namespace arcane;
    
    /**
    * Bitmap material with flat white lighting
    */
    class WhiteShadingBitmapMaterial extends CenterLightingMaterial, implements IUVMaterial {
        public var bitmap(getBitmap, null) : BitmapData
        ;
        public var height(getHeight, null) : Float
        ;
        public var visible(getVisible, null) : Bool
        ;
        public var width(getWidth, null) : Float
        ;
        
        var _bitmap:BitmapData;
        var _texturemapping:Matrix;
        var _faceVO:FaceVO;
        var _faceDictionary:Dictionary ;
        var blackrender:Bool;
        var whiterender:Bool;
        var whitek:Float ;
		var bitmapPoint:Point ;
		var colorTransform:ColorMatrixFilter ;
        var cache:Dictionary;
        var step:Int ;
		var mapping:Matrix;
		var br:Float;
         
        function ladder(v:Float):Float
        {
            if (v < 1/0xFF)
                return 0;
            if (v > 0xFF)
                v = 0xFF;
            return Math.exp(Math.round(Math.log(v)*step)/step);
        }
        
        /**
        * Calculates the mapping matrix required to draw the triangle texture to screen.
        * 
        * @param	tri		The data object holding all information about the triangle to be drawn.
        * @return			The required matrix object.
        */
		function getMapping(tri:DrawTriangle):Matrix
		{
			_faceVO = getFaceVO(tri.face, tri.source, tri.view);
			if (_faceVO.texturemapping)
				return _faceVO.texturemapping;
			
			_texturemapping = tri.transformUV(this).clone();
			_texturemapping.invert();
			
			return _faceVO.texturemapping = _texturemapping;
		}
		
        /** @private */
        override function renderTri(tri:DrawTriangle, session:AbstractRenderSession, kar:Float, kag:Float, kab:Float, kdr:Float, kdg:Float, kdb:Float, ksr:Float, ksg:Float, ksb:Float):Void
        {
            br = (kar + kag + kab + kdr + kdg + kdb + ksr + ksg + ksb) / (255*3);
			
            mapping = getMapping(tri);
            	
            v0 = tri.v0;
            v1 = tri.v1;
            v2 = tri.v2;
            
                //trace(br);
            if ((br < 1) && (blackrender || ((step < 16) && (!_bitmap.transparent))))
            {
                session.renderTriangleBitmap(_bitmap, mapping, v0, v1, v2, smooth, repeat);
                session.renderTriangleColor(0x000000, 1 - br, v0, v1, v2);
            }
            else
            if ((br > 1) && (whiterender))
            {
                session.renderTriangleBitmap(_bitmap, mapping, v0, v1, v2, smooth, repeat);
                session.renderTriangleColor(0xFFFFFF, (br - 1)*whitek, v0, v1, v2);
            }
            else
            {
                if (step < 64)
                    if (Math.random() < 0.01)
                        doubleStepTo(64);
                var brightness:Int = ladder(br);
                var bitmap:BitmapData = cache[brightness];
                if (bitmap == null)
                {
                	bitmap = new BitmapData(_bitmap.width, _bitmap.height, true, 0x00000000);
                	colorTransform.matrix = [brightness, 0, 0, 0, 0, 0, brightness, 0, 0, 0, 0, 0, brightness, 0, 0, 0, 0, 0, 1, 0];
                	bitmap.applyFilter(_bitmap, bitmap.rect, bitmapPoint, colorTransform);
                    cache[brightness] = bitmap;
                }
                session.renderTriangleBitmap(bitmap, mapping, v0, v1, v2, smooth, repeat);
            }
        }
        
    	/**
    	 * Determines if texture bitmap is smoothed (bilinearly filtered) when drawn to screen
    	 */
        public var smooth:Bool;
        
        /**
        * Determines if texture bitmap will tile in uv-space
        */
        public var repeat:Bool;
        
		/**
		 * @inheritDoc
		 */
        public function getWidth():Float
        {
            return _bitmap.width;
        }
        
		/**
		 * @inheritDoc
		 */
        public function getHeight():Float
        {
            return _bitmap.height;
        }
        
		/**
		 * @inheritDoc
		 */
        public function getBitmap():BitmapData
        {
        	return _bitmap;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function getVisible():Bool
        {
            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public function getPixel32(u:Float, v:Float):UInt
        {
        	return _bitmap.getPixel32(u*_bitmap.width, (1 - v)*_bitmap.height);
        }
    	
		/**
		 * Creates a new <code>WhiteShadingBitmapMaterial</code> object.
		 * 
		 * @param	bitmap				The bitmapData object to be used as the material's texture.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(bitmap:BitmapData, ?init:Dynamic = null)
        {
            
            _faceDictionary = new Dictionary(true);
            whitek = 0.2;
            bitmapPoint = new Point(0, 0);
            colorTransform = new ColorMatrixFilter();
            step = 1;
            _bitmap = bitmap;
            
            super(init);

			
            smooth = ini.getBoolean("smooth", false);
            repeat = ini.getBoolean("repeat", false);
            
            if (!CacheStore.whiteShadingCache[_bitmap])
            	CacheStore.whiteShadingCache[_bitmap] = new Dictionary(true);
            	
            cache = CacheStore.whiteShadingCache[_bitmap];
        }
		
        public function doubleStepTo(limit:Int):Void
        {
            if (step < limit)
                step *= 2;
        }
        
        public function getFaceVO(face:Face, source:Object3D, ?view:View3D = null):FaceVO
        {
        	if ((_faceVO = _faceDictionary[face]))
        		return _faceVO;
        	
        	return _faceDictionary[face] = new FaceVO();
        }
        
        public function removeFaceDictionary():Void
        {
			_faceDictionary = new Dictionary(true);
        }
        
		/**
		 * @inheritDoc
		 */
        public function addOnMaterialResize(listener:Dynamic):Void
        {
        	addEventListener(MaterialEvent.MATERIAL_RESIZED, listener, false, 0, true);
        }
        
		/**
		 * @inheritDoc
		 */
        public function removeOnMaterialResize(listener:Dynamic):Void
        {
        	removeEventListener(MaterialEvent.MATERIAL_RESIZED, listener, false);
        }
    }
