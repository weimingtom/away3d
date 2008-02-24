package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.mesh.Face;
    import away3d.core.mesh.Mesh;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;
    
    import flash.display.*;
    import flash.geom.*;

    /** Basic bitmap texture material */
    public class TransformBitmapMaterial extends BitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
    	use namespace arcane;
    	
        internal var _transform:Matrix = new Matrix();
        internal var _scaleX:Number = 1;
        internal var _scaleY:Number = 1;
        internal var _offsetX:Number = 0;
        internal var _offsetY:Number = 0;
        internal var _rotation:Number = 0;
        
        internal var _projectionVector:Number3D;
        
        internal var _N:Number3D = new Number3D();
        internal var _M:Number3D = new Number3D();
        
        internal var DOWN:Number3D = new Number3D(0, -1, 0);
        internal var RIGHT:Number3D = new Number3D(1, 0, 0);
        
        internal var transformDirty:Boolean;
        
        public var throughProjection:Boolean;
        
        public function get transform():Matrix
        {
        	return _transform;
        }
        
        public function set transform(val:Matrix):void
        {
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
        	
        	clearFaceDictionary();
        }
        
        public function get scaleX():Number
        {
        	return _scaleX;
        }
        
        public function set scaleX(val:Number):void
        {
        	if (isNaN(val))
                throw new Error("isNaN(scaleX)");
			
            if (val == Infinity)
                Debug.warning("scaleX == Infinity");
			
            if (val == -Infinity)
                Debug.warning("scaleX == -Infinity");
			
            if (val == 0)
                Debug.warning("scaleX == 0");
            
        	_scaleX = val;
        	clearFaceDictionary();
        	transformDirty = true;
        }
        
        public function get scaleY():Number
        {
        	return _scaleY;
        }
        
        public function set scaleY(val:Number):void
        {
        	if (isNaN(val))
                throw new Error("isNaN(scaleY)");
			
            if (val == Infinity)
                Debug.warning("scaleY == Infinity");
			
            if (val == -Infinity)
                Debug.warning("scaleY == -Infinity");
			
            if (val == 0)
                Debug.warning("scaleY == 0");
            
        	_scaleY = val;
        	
        	clearFaceDictionary();
        	transformDirty = true;
        }
		
        public function get offsetX():Number
        {
        	return _offsetX;
        }
        
        public function set offsetX(val:Number):void
        {
        	if (isNaN(val))
                throw new Error("isNaN(offsetX)");
			
            if (val == Infinity)
                Debug.warning("offsetX == Infinity");
			
            if (val == -Infinity)
                Debug.warning("offsetX == -Infinity");
            
        	_offsetX = val;
        	
        	clearFaceDictionary();
        	transformDirty = true;
        }
        
        public function get offsetY():Number
        {
        	return _offsetY;
        }
        
        public function set offsetY(val:Number):void
        {
        	if (isNaN(val))
                throw new Error("isNaN(offsetY)");
			
            if (val == Infinity)
                Debug.warning("offsetY == Infinity");
			
            if (val == -Infinity)
                Debug.warning("offsetY == -Infinity");
            
        	_offsetY = val;
        	
        	clearFaceDictionary();
        	transformDirty = true;
        }
        
        public function get rotation():Number
        {
        	return _rotation;
        }
        
        public function set rotation(val:Number):void
        {
        	if (isNaN(val))
                throw new Error("isNaN(rotation)");
			
            if (val == Infinity)
                Debug.warning("rotation == Infinity");
			
            if (val == -Infinity)
                Debug.warning("rotation == -Infinity");
            
        	_rotation = val;
        	
        	clearFaceDictionary();
        	transformDirty = true;
        }
                 
        public function get projectionVector():Number3D
        {
        	return _projectionVector;
        }
        
        public function set projectionVector(val:Number3D):void
        {
        	_projectionVector = val;
        	if (_projectionVector) {
        		_N.cross(_projectionVector, DOWN);
	            if (!_N.modulo) _N = RIGHT;
	            _M.cross(_N, _projectionVector);
	            _N.cross(_M, _projectionVector);
	            _N.normalize();
	            _M.normalize();
        	}
        	clearFaceDictionary();
        }
        
        public override function clearFaceDictionary():void
        {
        	if (!transformDirty)
        		super.clearFaceDictionary();
        }
        	
        
        public function updateTransform():void
        {
        	//check to see if no transformation exists
        	if (_scaleX == 1 && _scaleY == 1 && _offsetX == 0 && _offsetY == 0 && _rotation == 0) {
        		_transform = null;
        	} else {
	        	_transform = new Matrix();
	        	_transform.scale(_scaleX, _scaleY);
	        	_transform.rotate(_rotation);
	        	_transform.translate(_offsetX, _offsetY);
	        }
	        transformDirty = false;
        }
        
        public function TransformBitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            super(bitmap, init);
            
            init = Init.parse(init);
            transform = init.getObject("transform", Matrix);
            scaleX = init.getNumber("scaleX", _scaleX);
            scaleY = init.getNumber("scaleY", _scaleY);
            offsetX = init.getNumber("offsetX", _offsetX);
            offsetY = init.getNumber("offsetY", _offsetY);
            rotation = init.getNumber("rotation", _rotation);
            projectionVector = init.getObject("projectionVector", Number3D);
            throughProjection = init.getBoolean("throughProjection", false);
        }
        
        internal var face:Face;
        internal var w:Number;
        internal var h:Number;
        
        public override function renderMaterial(source:Mesh):void
        {
        }
        
        public override function renderTriangle(tri:DrawTriangle):void
        {
        	if (transformDirty)
        		updateTransform();
        	
			super.renderTriangle(tri);
        }
		
		public override function getMapping(tri:DrawTriangle):Matrix
		{
        	//check local transform or if texturemapping is null
        	face = tri.face;
        	faceDictionaryVO = _faceDictionary[face];
        	if (!faceDictionaryVO || faceDictionaryVO.dirty || !tri.texturemapping) {
        		if (!faceDictionaryVO)
        			_faceDictionary[face] = new FaceDictionaryVO();
        		else 
        			faceDictionaryVO.dirty = false;
        		
        		//use projectUV if projection vector detected
        		if (projectionVector)
        			tri.texturemapping = projectUV(tri);
        		else
        			tri.transformUV(this);
        		if (_transform) {
	        		mapping = _transform.clone();
	        		mapping.concat(tri.texturemapping);
	        		return tri.texturemapping = mapping;
	        	}
        	}
        	return tri.texturemapping;
		}
        
        internal var _u0:Number;
        internal var _u1:Number;
        internal var _u2:Number;
        internal var _v0:Number;
        internal var _v1:Number;
        internal var _v2:Number;
        
        internal var v0x:Number;
        internal var v0y:Number;
        internal var v0z:Number;
        internal var v1x:Number;
        internal var v1y:Number;
        internal var v1z:Number;
        internal var v2x:Number;
        internal var v2y:Number;
        internal var v2z:Number;
        
        internal var t:Matrix;
        
		public final function projectUV(tri:DrawTriangle):Matrix
        {
        	face = tri.face;
        	
    		if (tri.backface) {
	        	v0x = face.v0.x;
	        	v0y = face.v0.y;
	        	v0z = face.v0.z;
	        	v2x = face.v1.x;
	        	v2y = face.v1.y;
	        	v2z = face.v1.z;
	        	v1x = face.v2.x;
	        	v1y = face.v2.y;
	        	v1z = face.v2.z;
	    	} else {
	        	v0x = face.v0.x;
	        	v0y = face.v0.y;
	        	v0z = face.v0.z;
	        	v1x = face.v1.x;
	        	v1y = face.v1.y;
	        	v1z = face.v1.z;
	        	v2x = face.v2.x;
	        	v2y = face.v2.y;
	        	v2z = face.v2.z;
    		}
    		
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
        
		internal var _bitmapRect:Rectangle;
		
		public override function renderFace(face:Face, containerRect:Rectangle):void
		{
			if (transformDirty)
        		updateTransform();
        	
			//retrieve the transform
			if (_transform)
				mapping = _transform.clone();
			else
				mapping = new Matrix();
			
			faceDictionaryVO = _faceDictionary[face];
			
			//update the transform based on scaling or projection vector
			if (_projectionVector) {
				mapping.concat(projectUV(face._dt));
				mapping.concat(face._dt.invtexturemapping);
				_bitmapRect = face._bitmapRect;
				if (!faceDictionaryVO)
					faceDictionaryVO = _faceDictionary[face] = new FaceDictionaryVO();
				else
					faceDictionaryVO.dirty = false;
				
				//check to see if the bitmap (non repeating) lies inside the drawtriangle area
				if (!repeat && findSeparatingAxis(getFacePoints(face._dt.invtexturemapping), getMappingPoints(mapping)))
					return;
			} else {
				_bitmapRect = containerRect;
				mapping.scale(_bitmapRect.width/width, _bitmapRect.height/height);
				if (!faceDictionaryVO)
					faceDictionaryVO = _faceDictionary[face.parent] = new FaceDictionaryVO();
				else
					faceDictionaryVO.dirty = false;

				//check to see if the bitmap (non repeating) lies inside the containerRect area
				//if (!repeat && findSeparatingAxis(getContainerPoints(containerRect), getMappingPoints(mapping, containerRect)))
				//	return;
			}
			
			if (_projectionVector && !throughProjection && face.normal.dot(_projectionVector) < 0)
				return;
			
			//reset bitmap
			if (!faceDictionaryVO.bitmap)
				faceDictionaryVO.bitmap = new BitmapData(_bitmapRect.width, _bitmapRect.height, true, 0x00000000);
			
			//draw the bitmap
			if (mapping.a == 1 && mapping.d == 1 && mapping.b == 0 && mapping.c == 0 && mapping.tx == 0 && mapping.ty == 0) {
				//speedier version for non-transformed bitmap
				faceDictionaryVO.bitmap.copyPixels(_bitmap, _bitmapRect, _zeroPoint);
			}else {
				graphics = shape.graphics;
				graphics.clear();
				graphics.beginBitmapFill(_bitmap, mapping, repeat, smooth);
				graphics.drawRect(0, 0, _bitmapRect.width, _bitmapRect.height);
	            graphics.endFill();
				faceDictionaryVO.bitmap.draw(shape);
				
			}
		}
		
		public function getContainerPoints(rect:Rectangle):Array
		{
			return [rect.topLeft, new Point(rect.top, rect.right), rect.bottomRight, new Point(rect.bottom, rect.left)];
		}
		
		internal var fPoint1:Point = new Point();
        internal var fPoint2:Point = new Point();
        internal var fPoint3:Point = new Point();
        internal var fPoint4:Point = new Point();
        
		public function getFacePoints(map:Matrix):Array
		{
			fPoint1.x = _u0 = map.tx;
			fPoint2.x = map.a + _u0;
			fPoint3.x = map.c + _u0;
			fPoint1.y = _v0 = map.ty;
			fPoint2.y = map.b + _v0;
			fPoint3.y = map.d + _v0;
			return [fPoint1, fPoint2, fPoint3];
		}
        
        internal var mapa:Number;
        internal var mapb:Number;
        internal var mapc:Number;
        internal var mapd:Number;
        internal var maptx:Number;
        internal var mapty:Number;
        internal var mPoint1:Point = new Point();
        internal var mPoint2:Point = new Point();
        internal var mPoint3:Point = new Point();
        internal var mPoint4:Point = new Point();
        
        public function getMappingPoints(map:Matrix):Array
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
        
        internal var overlap:Boolean;
        
		public function findSeparatingAxis(points1:Array, points2:Array):Boolean
		{
			if (checkEdge(points1, points2))
				return true;
			if (checkEdge(points2, points1))
				return true;
			return false;
		}
		
        internal var i:String;
        internal var dot:Number;
		internal var line:Point = new Point();
        internal var zero:Number;
        internal var sign:Number;
        internal var point:Point;
		internal var point1:Point;
		internal var point2:Point;
		internal var point3:Point;
		internal var flag:Boolean;
		public function checkEdge(points1:Array, points2:Array):Boolean
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
            	for each (point in points2) {
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
 
    }
}
