package away3d.materials;

    import away3d.containers.*;
    import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;
    
    import flash.display.*;
    import flash.geom.*;

	use namespace arcane;
	
    /** Basic bitmap texture material */
    class TransformBitmapMaterial extends BitmapMaterial, implements ITriangleMaterial, implements IUVMaterial {
        public var globalProjection(getGlobalProjection, setGlobalProjection) : Bool;
        public var offsetX(getOffsetX, setOffsetX) : Float;
        public var offsetY(getOffsetY, setOffsetY) : Float;
        public var projectionVector(getProjectionVector, setProjectionVector) : Number3D;
        public var rotation(getRotation, setRotation) : Float;
        public var scaleX(getScaleX, setScaleX) : Float;
        public var scaleY(getScaleY, setScaleY) : Float;
        public var throughProjection(getThroughProjection, setThroughProjection) : Bool;
        public var transform(getTransform, setTransform) : Matrix;
        /** @private */
        
        /** @private */
        arcane var _transform:Matrix ;
        
        var _scaleX:Int ;
        var _scaleY:Int ;
        var _offsetX:Int ;
        var _offsetY:Int ;
        var _rotation:Int ;
        var _projectionVector:Number3D;
        var _projectionDirty:Bool;
        var _N:Number3D ;
        var _M:Number3D ;
        var DOWN:Number3D ;
        var RIGHT:Number3D ;
        var _transformDirty:Bool;
        var _throughProjection:Bool;
        var _globalProjection:Bool;
        var face:Face;
        var x:Float;
		var y:Float;
		var px:Float;
		var py:Float;
        var w:Float;
        var h:Float;
        var normalR:Number3D ;
        var _u0:Float;
        var _u1:Float;
        var _u2:Float;
        var _v0:Float;
        var _v1:Float;
        var _v2:Float;
        var v0x:Float;
        var v0y:Float;
        var v0z:Float;
        var v1x:Float;
        var v1y:Float;
        var v1z:Float;
        var v2x:Float;
        var v2y:Float;
        var v2z:Float;
        var v0:Number3D ;
        var v1:Number3D ;
        var v2:Number3D ;
        var t:Matrix;
		var _invtexturemapping:Matrix;
		var fPoint1:Point ;
        var fPoint2:Point ;
        var fPoint3:Point ;
        var fPoint4:Point ;
        var mapa:Float;
        var mapb:Float;
        var mapc:Float;
        var mapd:Float;
        var maptx:Float;
        var mapty:Float;
        var mPoint1:Point ;
        var mPoint2:Point ;
        var mPoint3:Point ;
        var mPoint4:Point ;
        var overlap:Bool;
        var i:String;
        var dot:Float;
		var line:Point ;
        var zero:Float;
        var sign:Float;
        var point:Point;
		var point1:Point;
		var point2:Point;
		var point3:Point;
		var flag:Bool;
		
        function updateTransform():Void
        {
	        _transformDirty = false;
	        
        	//check to see if no transformation exists
        	if (_scaleX == 1 && _scaleY == 1 && _offsetX == 0 && _offsetY == 0 && _rotation == 0) {
        		_transform = null;
        	} else {
	        	_transform = new Matrix();
	        	_transform.scale(_scaleX, _scaleY);
	        	_transform.rotate(_rotation);
	        	_transform.translate(_offsetX, _offsetY);
	        }
	        
	        _faceDirty = true;
        }
        
		function projectUV(tri:DrawTriangle):Matrix
        {
        	face = tri.face;
        	
        	if (globalProjection) {
	    		if (tri.backface) {
		    		v0.transform(face.v0.position, tri.source.sceneTransform);
		    		v2.transform(face.v1.position, tri.source.sceneTransform);
		    		v1.transform(face.v2.position, tri.source.sceneTransform);
		    	} else {
		    		v0.transform(face.v0.position, tri.source.sceneTransform);
		    		v1.transform(face.v1.position, tri.source.sceneTransform);
		    		v2.transform(face.v2.position, tri.source.sceneTransform);
	    		}
        	} else {
	    		if (tri.backface) {
		    		v0 = face.v0.position;
		    		v2 = face.v1.position;
		    		v1 = face.v2.position;
		    	} else {
		    		v0 = face.v0.position;
		    		v1 = face.v1.position;
		    		v2 = face.v2.position;
	    		}
        	}
        	
        	v0x = v0.x;
        	v0y = v0.y;
        	v0z = v0.z;
        	v1x = v1.x;
        	v1y = v1.y;
        	v1z = v1.z;
        	v2x = v2.x;
        	v2y = v2.y;
        	v2z = v2.z;
    		
    		_u0 = v0x*_N.x + v0y*_N.y + v0z*_N.z;
    		_u1 = v1x*_N.x + v1y*_N.y + v1z*_N.z;
    		_u2 = v2x*_N.x + v2y*_N.y + v2z*_N.z;
    		_v0 = v0x*_M.x + v0y*_M.y + v0z*_M.z;
    		_v1 = v1x*_M.x + v1y*_M.y + v1z*_M.z;
    		_v2 = v2x*_M.x + v2y*_M.y + v2z*_M.z;
      
            // Fix perpendicular projections
            if ((_u0 == _u1 && _v0 == _v1) || (_u0 == _u2 && _v0 == _v2))
            {
            	if (_u0 > 0.05)
                	_u0 -= 0.05;
                else
                	_u0 += 0.05;
                	
                if (_v0 > 0.07)           
                	_v0 -= 0.07;
                else
                	_v0 += 0.07;
            }
    
            if (_u2 == _u1 && _v2 == _v1)
            {
            	if (_u2 > 0.04)
                	_u2 -= 0.04;
                else
                	_u2 += 0.04;
                	
                if (_v2 > 0.06)           
                	_v2 -= 0.06;
                else
                	_v2 += 0.06;
            }
            
            t = new Matrix(_u1 - _u0, _v1 - _v0, _u2 - _u0, _v2 - _v0, _u0, _v0);
            t.invert();
            return t;
        }
		
		function getContainerPoints(rect:Rectangle):Array<Dynamic>
		{
			return [rect.topLeft, new Point(rect.top, rect.right), rect.bottomRight, new Point(rect.bottom, rect.left)];
		}
		
		function getFacePoints(map:Matrix):Array<Dynamic>
		{
			fPoint1.x = _u0 = map.tx;
			fPoint2.x = map.a + _u0;
			fPoint3.x = map.c + _u0;
			fPoint1.y = _v0 = map.ty;
			fPoint2.y = map.b + _v0;
			fPoint3.y = map.d + _v0;
			return [fPoint1, fPoint2, fPoint3];
		}
		
        function getMappingPoints(map:Matrix):Array<Dynamic>
        {
        	mapa = map.a*width;
        	mapb = map.b*height;
        	mapc = map.c*width;
        	mapd = map.d*height;
        	maptx = map.tx;
        	mapty = map.ty;
        	mPoint1.x = maptx;
        	mPoint1.y = mapty;
        	mPoint2.x = maptx + mapc;
        	mPoint2.y = mapty + mapd;
        	mPoint3.x = maptx + mapa + mapc;
        	mPoint3.y = mapty + mapb + mapd;
        	mPoint4.x = maptx + mapa;
        	mPoint4.y = mapty + mapb;
        	return [mPoint1, mPoint2, mPoint3, mPoint4]; 
        }
        
		function findSeparatingAxis(points1:Array<Dynamic>, points2:Array<Dynamic>):Bool
		{
			if (checkEdge(points1, points2))
				return true;
			if (checkEdge(points2, points1))
				return true;
			return false;
		}
		
		function checkEdge(points1:Array<Dynamic>, points2:Array<Dynamic>):Bool
		{
            for (i in points1) {
            	//get point 1
            	point2 = points1[i];
            	
            	//get point 2
            	if (int(i) == 0) {
            		point1 = points1[points1.length-1];
            		point3 = points1[points1.length-2];
            	} else {
            		point1 = points1[int(i)-1];
            		if (int(i) == 1)
            			point3 = points1[points1.length-1];
            		else
            			point3 = points1[int(i)-2];
            	}
            	
            	//calulate perpendicular line
            	line.x = point2.y - point1.y;
            	line.y = point1.x - point2.x;
            	zero = point1.x*line.x + point1.y*line.y;
            	sign = zero - point3.x*line.x - point3.y*line.y;
            	
            	//calculate each projected value for points2
				flag = true;
            	for (point in points2) {
            		dot = point.x*line.x + point.y*line.y;
            		//return if zero is greater than dot
            		if (zero*sign > dot*sign) {
            			flag = false;
            			break;
            		}
            	}
            	if (flag)
            		return true;
            }
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		override function getMapping(tri:DrawTriangle):Matrix
		{
			if (tri.generated) {
				_texturemapping = tri.transformUV(this).clone();
	        	_texturemapping.invert();
	        	
	        	//apply transform matrix if one exists
        		if (_transform) {
        			_mapping = _transform.clone();
	        		_mapping.concat(_texturemapping);
	        	} else {
	        		_mapping = _texturemapping;
	        	}
	        	
	        	return _mapping;
			}
			
        	_faceVO = getFaceVO(tri.face, tri.source);
        	
        	//check to see if rendering can be skipped
        	if (_faceVO.invalidated || !_faceVO.texturemapping || _faceVO.backface != tri.backface) {
        		_faceVO.invalidated = false;
        		_faceVO.backface = tri.backface;
        		
        		//use projectUV if projection vector detected
        		if (projectionVector) {
        			_faceVO.texturemapping = projectUV(tri);
        		} else if (!_faceVO.texturemapping) {
        			_faceVO.texturemapping = tri.transformUV(this).clone();
	        		_faceVO.texturemapping.invert();
        		}
        		
        		//apply transform matrix if one exists
        		if (_transform) {
        			_faceVO.mapping = _transform.clone();
	        		_faceVO.mapping.concat(_faceVO.texturemapping);
	        	} else {
	        		_faceVO.mapping = _faceVO.texturemapping;
	        	}
        	}
        	return _faceVO.mapping;
		}
		
		/**
		 * Determines whether a projected texture is visble on the faces pointing away from the projection.
		 * 
		 * @see projectionVector
		 */
        public function getThroughProjection():Bool{
        	return _throughProjection;
        }
        
        public function setThroughProjection(val:Bool):Bool{
        	_throughProjection = val;
        	_projectionDirty = true;
        	return val;
        }
        
        /**
        * Determines whether a projected texture uses offsetX, offsetY and projectionVector values relative to scene cordinates.
        * 
        * @see projectionVector
        * @see offsetX
        * @see offsetY
        */
        public function getGlobalProjection():Bool{
        	return _globalProjection;
        }
        
        public function setGlobalProjection(val:Bool):Bool{
        	_globalProjection = val;
        	_projectionDirty = true;
        	return val;
        }
        
        /**
        * Transforms the texture in uv-space
        */
        public function getTransform():Matrix{
        	return _transform;
        }
        
        public function setTransform(val:Matrix):Matrix{
        	_transform = val;
        	
        	if (_transform) {
	        	
	        	//recalculate rotation
	        	_rotation = Math.atan2(_transform.b, _transform.a);

	        	//recalculate scale
	        	_scaleX = _transform.a/Math.cos(_rotation);
	        	_scaleY = _transform.d/Math.cos(_rotation);
	        	
	        	//recalculate offset
	        	_offsetX = _transform.tx;
	        	_offsetY = _transform.ty;
	        } else {
	        	_scaleX = _scaleY = 1;
	        	_offsetX = _offsetY = _rotation = 0;
	        }
        	
	        //_faceDirty = true;
        	return val;
        }
        
        /**
        * Scales the x coordinates of the texture in uv-space
        */
        public function getScaleX():Float{
        	return _scaleX;
        }
        
        public function setScaleX(val:Float):Float{
        	if (isNaN(val))
                throw new Error("isNaN(scaleX)");
			
            if (val == Infinity)
                Debug.warning("scaleX == Infinity");
			
            if (val == -Infinity)
                Debug.warning("scaleX == -Infinity");
			
            if (val == 0)
                Debug.warning("scaleX == 0");
            
        	_scaleX = val;
        	
        	_transformDirty = true;
        	return val;
        }
        
        /**
        * Scales the y coordinates of the texture in uv-space
        */
        public function getScaleY():Float{
        	return _scaleY;
        }
        
        public function setScaleY(val:Float):Float{
        	if (isNaN(val))
                throw new Error("isNaN(scaleY)");
			
            if (val == Infinity)
                Debug.warning("scaleY == Infinity");
			
            if (val == -Infinity)
                Debug.warning("scaleY == -Infinity");
			
            if (val == 0)
                Debug.warning("scaleY == 0");
            
        	_scaleY = val;
        	
        	_transformDirty = true;
        	return val;
        }
        
        /**
        * Offsets the x coordinates of the texture in uv-space
        */
        public function getOffsetX():Float{
        	return _offsetX;
        }
        
        public function setOffsetX(val:Float):Float{
        	if (isNaN(val))
                throw new Error("isNaN(offsetX)");
			
            if (val == Infinity)
                Debug.warning("offsetX == Infinity");
			
            if (val == -Infinity)
                Debug.warning("offsetX == -Infinity");
            
        	_offsetX = val;
        	
        	_transformDirty = true;
        	return val;
        }
        
        /**
        * Offsets the y coordinates of the texture in uv-space
        */
        public function getOffsetY():Float{
        	return _offsetY;
        }
        
        public function setOffsetY(val:Float):Float{
        	if (isNaN(val))
                throw new Error("isNaN(offsetY)");
			
            if (val == Infinity)
                Debug.warning("offsetY == Infinity");
			
            if (val == -Infinity)
                Debug.warning("offsetY == -Infinity");
            
        	_offsetY = val;
        	
        	_transformDirty = true;
        	return val;
        }
        
        /**
        * Rotates the texture in uv-space
        */
        public function getRotation():Float{
        	return _rotation;
        }
        
        public function setRotation(val:Float):Float{
        	if (isNaN(val))
                throw new Error("isNaN(rotation)");
			
            if (val == Infinity)
                Debug.warning("rotation == Infinity");
			
            if (val == -Infinity)
                Debug.warning("rotation == -Infinity");
            
        	_rotation = val;
        	
        	_transformDirty = true;
        	return val;
        }
        
        /**
        * Projects the texture in object space, ignoring the uv coordinates of the vertex objects.
        * Texture renders normally when set to <code>null</code>.
        */
        public function getProjectionVector():Number3D{
        	return _projectionVector;
        }
        
        public function setProjectionVector(val:Number3D):Number3D{
        	_projectionVector = val;
        	if (_projectionVector) {
        		_N.cross(_projectionVector, DOWN);
	            if (!_N.modulo) _N = RIGHT;
	            _M.cross(_N, _projectionVector);
	            _N.cross(_M, _projectionVector);
	            _N.normalize();
	            _M.normalize();
        	}
        	_projectionDirty = true;
        	return val;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function getPixel32(u:Float, v:Float):UInt
        {
			if (_transform) {
	        	x = u*_bitmap.width;
				y = (1 - v)*_bitmap.height;
				
				t = _transform.clone();
				t.invert();
				if (repeat) {
					px = (x*t.a + y*t.c + t.tx)%_bitmap.width;
					py = (x*t.b + y*t.d + t.ty)%_bitmap.height;
					if (px < 0)
						px += _bitmap.width;
					if (py < 0)
						py += _bitmap.height;
        			return _bitmap.getPixel32(px, py);
    			} else
        			return _bitmap.getPixel32(x*t.a + y*t.c + t.tx, x*t.b + y*t.d + t.ty);
   			}
        	return super.getPixel32(u, v);
        }
        
		/**
		 * Creates a new <code>TransformBitmapMaterial</code> object.
		 * 
		 * @param	bitmap				The bitmapData object to be used as the material's texture.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(bitmap:BitmapData, ?init:Dynamic = null)
        {
            
            _transform = new Matrix();
            _scaleX = 1;
            _scaleY = 1;
            _offsetX = 0;
            _offsetY = 0;
            _rotation = 0;
            _N = new Number3D();
            _M = new Number3D();
            DOWN = new Number3D(0, -1, 0);
            RIGHT = new Number3D(1, 0, 0);
            normalR = new Number3D();
            v0 = new Number3D();
            v1 = new Number3D();
            v2 = new Number3D();
            fPoint1 = new Point();
            fPoint2 = new Point();
            fPoint3 = new Point();
            fPoint4 = new Point();
            mPoint1 = new Point();
            mPoint2 = new Point();
            mPoint3 = new Point();
            mPoint4 = new Point();
            line = new Point();
            super(bitmap, init);
            
            transform = cast( ini.getObject("transform", Matrix), Matrix);
            scaleX = ini.getNumber("scaleX", _scaleX);
            scaleY = ini.getNumber("scaleY", _scaleY);
            offsetX = ini.getNumber("offsetX", _offsetX);
            offsetY = ini.getNumber("offsetY", _offsetY);
            rotation = ini.getNumber("rotation", _rotation);
            projectionVector = cast( ini.getObject("projectionVector", Number3D), Number3D);
            throughProjection = ini.getBoolean("throughProjection", true);
            globalProjection = ini.getBoolean("globalProjection", false);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function updateMaterial(source:Object3D, view:View3D):Void
        {
        	_graphics = null;
        	clearShapeDictionary();
        	
        	if (_colorTransformDirty)
        		updateColorTransform();
        	
        	if (_bitmapDirty)
        		updateRenderBitmap();
        	
        	if (_transformDirty)
        		updateTransform();
        	
        	if (_faceDirty || _projectionDirty || _blendModeDirty)
        		clearFaceDictionary();
        	
        	_projectionDirty = false;
        	_blendModeDirty = false;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function renderTriangle(tri:DrawTriangle):Void
        {
        	if (_projectionVector && !throughProjection) {
        		
        		if (globalProjection) {
        			normalR.rotate(tri.face.normal, tri.source.sceneTransform);
        			if (normalR.dot(_projectionVector) < 0)
        				return;
        		} else if (tri.face.normal.dot(_projectionVector) < 0)
        			return;
        	}
        	
			super.renderTriangle(tri);
        }
        
		/**
		 * @inheritDoc
		 */
		public override function renderBitmapLayer(tri:DrawTriangle, containerRect:Rectangle, parentFaceVO:FaceVO):FaceVO
		{	
			//retrieve the transform
			if (_transform)
				_mapping = _transform.clone();
			else
				_mapping = new Matrix();
			
			//if not projected, draw the source bitmap once
			if (!_projectionVector)
				renderSource(tri.source, containerRect, _mapping);
			
			//check to see if faceDictionary exists
			if (!(_faceVO = _faceDictionary[tri]))
				_faceVO = _faceDictionary[tri] = new FaceVO();
			
			//pass on resize value
			if (parentFaceVO.resized) {
				parentFaceVO.resized = false;
				_faceVO.resized = true;
			}
			
			//pass on invtexturemapping value
			_faceVO.invtexturemapping = parentFaceVO.invtexturemapping;
			
			//check to see if rendering can be skipped
			if (parentFaceVO.updated || _faceVO.invalidated) {
				parentFaceVO.updated = false;
				
				//retrieve the bitmapRect
				_bitmapRect = tri.face.bitmapRect;
				
				//reset booleans
				if (_faceVO.invalidated)
					_faceVO.invalidated = false;
				else 
					_faceVO.updated = true;
				
				//store a clone
				_faceVO.bitmap = parentFaceVO.bitmap;
				
				//update the transform based on scaling or projection vector
				if (_projectionVector) {
					
					//calulate mapping
					_invtexturemapping = _faceVO.invtexturemapping;
					_mapping.concat(projectUV(tri));
					_mapping.concat(_invtexturemapping);
					
					//check to see if the bitmap (non repeating) lies inside the drawtriangle area
					if ((throughProjection || tri.face.normal.dot(_projectionVector) >= 0) && (repeat || !findSeparatingAxis(getFacePoints(_invtexturemapping), getMappingPoints(_mapping)))) {
						
						//store a clone
						if (_faceVO.cleared)
							_faceVO.bitmap = parentFaceVO.bitmap.clone();
						
						_faceVO.cleared = false;
						_faceVO.updated = true;
							
						//draw into faceBitmap
						_graphics = _s.graphics;
						_graphics.clear();
						_graphics.beginBitmapFill(_bitmap, _mapping, repeat, smooth);
						_graphics.drawRect(0, 0, _bitmapRect.width, _bitmapRect.height);
			            _graphics.endFill();
						_faceVO.bitmap.draw(_s, null, _colorTransform, _blendMode, _faceVO.bitmap.rect);
					}
				} else {
					
					//check to see if the bitmap (non repeating) lies inside the containerRect area
					if (repeat && !findSeparatingAxis(getContainerPoints(containerRect), getMappingPoints(_mapping))) {
						_faceVO.cleared = false;
						_faceVO.updated = true;
						
						//draw into faceBitmap
						_faceVO.bitmap.copyPixels(_sourceVO.bitmap, _bitmapRect, _zeroPoint, null, null, true);
					}
				}
			}
			
			return _faceVO;
		}
    }
