package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    import away3d.core.draw.*;
    import away3d.core.utils.*;
    import away3d.core.render.*;
    
    import flash.events.Event;
    import flash.display.BitmapData;
    import flash.geom.*;
    import flash.utils.*;
    import flash.filters.ColorMatrixFilter;

    /** Mesh's triangle face */
    public class Face extends BaseMeshElement
    {
        use namespace arcane;

        public var extra:Object;

        arcane var _v0:Vertex;
        arcane var _v1:Vertex;
        arcane var _v2:Vertex;
        arcane var _uv0:UV;
        arcane var _uv1:UV;
        arcane var _uv2:UV;
        arcane var _material:ITriangleMaterial;
        arcane var _dt:DrawTriangle = new DrawTriangle();
        private var _normal:Number3D;
		private var _bitmapMaterial:BitmapData;
		public var _bitmapPhong:BitmapData;
		public var _bitmapNormal:BitmapData;
		private var _byteNormal:ByteArray;
		private var _bitmapRect:Rectangle;
		private var _normalRect:Rectangle;
		private var _normalPoint:Point = new Point(0,0);
		public var parent:Mesh;
		
        public override function get vertices():Array
        {
            return [_v0, _v1, _v2];
        }
		
		public function get uvs():Array
        {
            return [_uv0, _uv1, _uv2];
        }
        
        public function get v0():Vertex
        {
            return _v0;
        }

        public function set v0(value:Vertex):void
        {
            if (value == _v0)
                return;

            if (_v0 != null)
                if ((_v0 != _v1) && (_v0 != _v2))
                    _v0.removeOnChange(onVertexValueChange);

            _v0 = value;

            if (_v0 != null)
                if ((_v0 != _v1) && (_v0 != _v2))
                    _v0.addOnChange(onVertexValueChange);

            notifyVertexChange();
        }

        public function get v1():Vertex
        {
            return _v1;
        }

        public function set v1(value:Vertex):void
        {
            if (value == _v1)
                return;

            if (_v1 != null)
                if ((_v1 != _v0) && (_v1 != _v2))
                    _v1.removeOnChange(onVertexValueChange);

            _v1 = value;

            if (_v1 != null)
                if ((_v1 != _v0) && (_v1 != _v2))
                    _v1.addOnChange(onVertexValueChange);

            notifyVertexChange();
        }

        public function get v2():Vertex
        {
            return _v2;
        }

        public function set v2(value:Vertex):void
        {
            if (value == _v2)
                return;

            if (_v2 != null)
                if ((_v2 != _v1) && (_v2 != _v0))
                    _v2.removeOnChange(onVertexValueChange);

            _v2 = value;

            if (_v2 != null)
                if ((_v2 != _v1) && (_v2 != _v0))
                    _v2.addOnChange(onVertexValueChange);

            notifyVertexChange();
        }

        public function get material():ITriangleMaterial
        {
            return _material;
        }

        public function set material(value:ITriangleMaterial):void
        {
            if (value == _material)
                return;

            _material = value;

            _texturemapping = null;
			_bitmapMaterial = null;
			
            notifyMaterialChange();
        }

        public function get uv0():UV
        {
            _texturemapping = null;

            return _uv0;
        }

        public function set uv0(value:UV):void
        {
            if (value == _uv0)
                return;

            if (_uv0 != null)
                if ((_uv0 != _uv1) && (_uv0 != _uv2))
                    _uv0.removeOnChange(onUVChange);

            _uv0 = value;

            if (_uv0 != null)
                if ((_uv0 != _uv1) && (_uv0 != _uv2))
                    _uv0.addOnChange(onUVChange);

            _texturemapping = null;

            notifyMappingChange();
        }

        public function get uv1():UV
        {
            return _uv1;
        }

        public function set uv1(value:UV):void
        {
            if (value == _uv1)
                return;

            if (_uv1 != null)
                if ((_uv1 != _uv0) && (_uv1 != _uv2))
                    _uv1.removeOnChange(onUVChange);

            _uv1 = value;

            if (_uv1 != null)
                if ((_uv1 != _uv0) && (_uv1 != _uv2))
                    _uv1.addOnChange(onUVChange);

            _texturemapping = null;

            notifyMappingChange();
        }

        public function get uv2():UV
        {
            return _uv2;
        }

        public function set uv2(value:UV):void
        {
            if (value == _uv2)
                return;

            if (_uv2 != null)
                if ((_uv2 != _uv1) && (_uv2 != _uv0))
                    _uv2.removeOnChange(onUVChange);

            _uv2 = value;

            if (_uv2 != null)
                if ((_uv2 != _uv1) && (_uv2 != _uv0))
                    _uv2.addOnChange(onUVChange);

            _texturemapping = null;

            notifyMappingChange();
        }

        public function get area():Number
        {
            // not quick enough
            var a:Number = Number3D.distance(v0.position, v1.position);
            var b:Number = Number3D.distance(v1.position, v2.position);
            var c:Number = Number3D.distance(v2.position, v0.position);
            var s:Number = (a + b + c) / 2;
            return Math.sqrt(s*(s - a)*(s - b)*(s - c));
        }

        public function get normal():Number3D
        {
            if (_normal == null)
            {
                var d1x:Number = _v1.x - _v0.x;
                var d1y:Number = _v1.y - _v0.y;
                var d1z:Number = _v1.z - _v0.z;
            
                var d2x:Number = _v2.x - _v0.x;
                var d2y:Number = _v2.y - _v0.y;
                var d2z:Number = _v2.z - _v0.z;
            
                var pa:Number = d1y*d2z - d1z*d2y;
                var pb:Number = d1z*d2x - d1x*d2z;
                var pc:Number = d1x*d2y - d1y*d2x;

                var pdd:Number = Math.sqrt(pa*pa + pb*pb + pc*pc);

                _normal = new Number3D(pa / pdd, pb / pdd, pc / pdd);
            }
            return _normal;
        }
        
        public function getBitmapMaterial(uvm:PhongBitmapMaterial):BitmapData
        {
            if (_bitmapMaterial == null)
            {
            	//sample bitmap rectangle required for this face
            	_bitmapMaterial = new BitmapData(_bitmapRect.width, _bitmapRect.height, true, 0x00000000);
            }
            _bitmapMaterial.copyPixels(uvm.bitmap, _bitmapRect, new Point(0,0));
            return _bitmapMaterial;
        }
        
        internal var colorTransform:ColorMatrixFilter = new ColorMatrixFilter();
        
        public function setBitmapPhongProjection(view:Matrix3D):void
        {
        	if (_bitmapPhong == null)
        		getBitmapPhong();
        	
        	//conbine normal map
        	var szx:Number = view.szz;
			var szy:Number = view.szy;
			var szz:Number = -view.szx;
			/*
        	var matrix:Array = new Array();
			matrix = matrix.concat([szx, 0, 0, 0, 127-szx*127]); // red
            matrix = matrix.concat([0, szy, 0, 0, 127-szy*127]); // green
            matrix = matrix.concat([0, 0, szz, 0, 127-szz*127]); // blue
            matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
            */
			colorTransform.matrix = [szx, 0, 0, 0, 127-szx*127, 0, szy, 0, 0, 127-szy*127, 0, 0, szz, 0, 127-szz*127, 0, 0, 0, 1, 0];
            _bitmapPhong.applyFilter(_bitmapNormal, _normalRect, _normalPoint, colorTransform);
            var s:Number = 2;
            var o:Number = -127;
            var ambientR:Number = 0x00;
            var ambientG:Number = 0x22;
            var ambientB:Number = 0x44;
            /*
            matrix = new Array();
			matrix = matrix.concat([s, s, s, 0, (o-255)*s]); // red
            matrix = matrix.concat([s, s, s, 0, (o-255)*s]); // green
            matrix = matrix.concat([s, s, s, 0, (o-255)*s]); // blue
            matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
            */
			colorTransform.matrix = [s, s, s, 0, (o-255)*s+ambientR, s, s, s, 0, (o-255)*s+ambientG, s, s, s, 0, (o-255)*s+ambientB, 0, 0, 0, 1, 0];
			_bitmapPhong.applyFilter(_bitmapPhong, _normalRect, _normalPoint, colorTransform);
        	      	
        }
        
        internal var nUV:UV;
        internal var oFace:Object;
        internal var contains:Boolean;
        
        public function getBitmapPhong():BitmapData
        {
            if (_bitmapPhong == null)
            {
            	//setup bitmapdata objects
            	_bitmapPhong = new BitmapData(_bitmapRect.width, _bitmapRect.height, true, 0x00000000);
            	_bitmapNormal = new BitmapData(_bitmapRect.width, _bitmapRect.height, true, 0x00000000);
            	
            	//create normal map
            	_normalRect = new Rectangle(0,0,_bitmapRect.width, _bitmapRect.height);
            	_byteNormal = _bitmapNormal.getPixels(_normalRect);
            	o = {};
            	lineTri(_uv0,_uv1,_v0,_v1);
				lineTri(_uv1,_uv2,_v1,_v2);
				lineTri(_uv2,_uv0,_v2,_v0);
				contains = _uv0._u*(_uv2._v - _uv1._v) + _uv1._u*(_uv0._v - _uv2._v) + _uv2._u*(_uv1._v - _uv0._v) > 0;
				
				oFace = getReflectedUV(parent.neighbour01(this), _v0, _v1, _uv0, _uv1);
				
				o = {};
            	lineTri(_uv1,      _uv0,      _v1,      _v0);
				lineTri(_uv0,      oFace.uv,  _v0,      oFace.v);
				lineTri(oFace.uv,  _uv1,      oFace.v,  _v1);
				
				oFace = getReflectedUV(parent.neighbour12(this), _v1, _v2, _uv1, _uv2);
				
				o = {};
            	lineTri(oFace.uv,   _uv2,       oFace.v,   _v2);
				lineTri(_uv2,       _uv1,       _v2,       _v1);
				lineTri(_uv1,       oFace.uv,   _v1,       oFace.v);
				
				oFace = getReflectedUV(parent.neighbour20(this), _v2, _v0, _uv2, _uv0);
				
				o = {};
            	lineTri(_uv2,       oFace.uv,   _v2,       oFace.v);
				lineTri(oFace.uv,   _uv0,       oFace.v,   _v0);
				lineTri(_uv0,       _uv2,       _v0,       _v2);
				
            	_byteNormal.position = 0;
				_bitmapNormal.setPixels(_normalRect, _byteNormal);
            }
            return _bitmapPhong;
        }
        
        internal var udiff:Number;
        internal var vdiff:Number;
        internal var ncontains:Boolean;
        internal var grad:Number;
        internal var grad2:Number;
        
        public function getReflectedUV(neighbour:Face, point0:Vertex, point1:Vertex, line0:UV, line1:UV):Object
        {
        	var i:Number = 2;
        	while (neighbour.vertices[i] == point0 || neighbour.vertices[i] == point1) i--;
        	
        	var neighbourV:Vertex = neighbour.vertices[i];
        	var neighbourUV:UV = neighbour.uvs[i].clone();
        	
			ncontains = line0._u*(neighbourUV._v - line1._v) + line1._u*(line0._v - neighbourUV._v) + neighbourUV._u*(line1._v - line0._v) > 0;			
			if (ncontains == contains) {
				//reflect
				grad = (line1._v - line0._v)/(line1._u - line0._u);
				grad2 = grad*grad;
				udiff = (neighbourUV._u - line0._u);
				vdiff = (neighbourUV._v - line0._v);
				neighbourUV._u = line0._u + (udiff*(1 - grad2) + vdiff*2*grad)/(1 + grad2);
				neighbourUV._v = line0._v + (udiff*2*grad + vdiff*(grad2 - 1))/(1 + grad2);
			}
			return {uv:neighbourUV, v:neighbourV, ncontains:ncontains};
        }
        
        internal var x0:int;
        internal var x1:int;
        internal var y0:int;
        internal var y1:int;
        internal var bwidth:int;
        internal var bheight:int;
        internal var o:Object;
        
        private function lineTri(uv0:UV,uv1:UV,v0:Vertex,v1:Vertex):void{
			
        	x0 = int(uv0._u*width-_bitmapRect.x);
        	y0 = int((1-uv0._v)*height-_bitmapRect.y);
        	x1 = int(uv1._u*width-_bitmapRect.x);
        	y1 = int((1-uv1._v)*height-_bitmapRect.y);
        	bwidth = _bitmapRect.width;
        	bheight = _bitmapRect.height;
        	
			var steep:Boolean = (y1-y0)*(y1-y0) > (x1-x0)*(x1-x0);
			var grad:Number = (y1-y0)/(x1-x0);
			var swap:int;
			var swapP:Vertex;
			var swapUV:UV;
			
			if (steep){
				swap=x0; x0=y0; y0=swap;
				swap=x1; x1=y1; y1=swap;
				swap = bwidth; bwidth = bheight; bheight = swap;
			}
			if (x0>x1){
				swapP=v0; v0=v1; v1=swapP;
				swapUV=uv0; uv0=uv1; uv1=swapUV;
				x0^=x1; x1^=x0; x0^=x1;
				y0^=y1; y1^=y0; y0^=y1;
			}
			
			var deltax:int = x1 - x0
			var deltay:int = Math.abs(y1 - y0);
			
			var error:int = 0;
			
			var y:int = y0;
			var ystep:int = y0<y1 ? 1 : -1;
			var x:int = x0;
			var xend:int = x1-(deltax>>1);
			var fx:int = x1;
			var fy:int = y1;
			var px:int = 0;
			var xtotal:int = x1-x0;
			
			var xc:int;
			
			while (x++<=xend){
				if (steep){
					checkLine(o,y,x, uv0, uv1, v0, v1, (x-x0)/xtotal, grad);
					if (fx!=x1 && fx!=xend) checkLine(o,fy,fx+1, uv0, uv1 ,v0, v1, (fx+1-x0)/xtotal, grad);
				}
					
				error += deltay;
				if ((error<<1) >= deltax){
					if (!steep){
						
						checkLine(o,x-px+1,y, uv0, uv1, v0, v1, (x-px+1-x0)/xtotal, grad);
						if (fx!=xend) checkLine(o,fx+1,fy, uv0, uv1, v0, v1, (fx+1-x0)/xtotal, grad);
				
					}
					px = 0;
					y += ystep;
					fy -= ystep;
					error -= deltax; 
				}
				px++;
				fx--;
			}
			
			if (!steep){
				checkLine(o,x-px+1,y, uv0, uv1, v0, v1, (x-px+1-x0)/xtotal, grad);
			}
			
		}
		
		internal var ox:int;
		internal var ouv0:UV;
		internal var ouv1:UV;
		internal var ov0:Vertex;
		internal var ov1:Vertex;
		internal var oratio:Number;
		internal var ograd:Number;
		
		private function checkLine(o:Object,x:int,y:int, uv0:UV, uv1:UV, v0:Vertex, v1:Vertex, ratio:Number, grad:Number):void{
			if (y >=0 && y<=_bitmapRect.height) {
				if (o[y]){
					if (o[y].x > x){
						ox = x;
						ouv0 = uv0;
						ouv1 = uv1;
						ov0 = v0;
						ov1 = v1;
						oratio = ratio;
						ograd = grad;
						x = o[y].x;
						uv0 = o[y].uv0;
						uv1 = o[y].uv1;
						v0 = o[y].v0;
						v1 = o[y].v1;
						ratio = o[y].ratio;
						grad = o[y].grad;
					} else {
						ox = o[y].x;
						ouv0 = o[y].uv0;
						ouv1 = o[y].uv1;
						ov0 = o[y].v0;
						ov1 = o[y].v1;
						oratio = o[y].ratio;
						ograd = o[y].grad;
					}
					
					var ratio1:Number = 1 - ratio;
					var oratio1:Number = 1 - oratio;
					var n0:Number3D = parent.getVertexNormal(v0);
					var n1:Number3D = parent.getVertexNormal(v1);
					
					var n:Number3D = new Number3D(ratio1*n0.x + ratio*n1.x, ratio1*n0.y + ratio*n1.y, ratio1*n0.z + ratio*n1.z);
					
					var on0:Number3D = parent.getVertexNormal(ov0);
					var on1:Number3D = parent.getVertexNormal(ov1);
					
					var on:Number3D = new Number3D(oratio1*on0.x + oratio*on1.x, oratio1*on0.y + oratio*on1.y, oratio1*on0.z + oratio*on1.z);
					
					//if (ograd > grad && y < _bitmapRect.height) y += 1;
					//else if (ograd < grad && y > 0) y -= 1;
					
					//ox -= 1;
					//if (ox < 0) ox = 0;
					//x += 1;
					//if (x > _bitmapRect.width) x = _bitmapRect.width;
					var i:int = x+1;
					var bi:int;
					var xtotal:int = x - ox;
					var iratio:Number;
					var iratio1:Number;
					
					var ni:Number3D;
					var disp:int;
					
					while(i-->ox)
					{
						if (i >= 0 && i <= _bitmapRect.width) {
							bi = 4*(y*_bitmapRect.width+i);
							//if (_byteNormal[bi] == 0) {
								iratio = (i-ox)/xtotal;
								iratio1 = (1 - iratio);
								_byteNormal[bi] = 255;
								
								ni = new Number3D(iratio1*on.x + iratio*n.x, iratio1*on.y + iratio*n.y, iratio1*on.z + iratio*n.z);
								ni.normalize();
								
								disp = int((ni.x+1)*127);
								if (disp > 255) disp = 255;
								else if (disp < 0) disp = 0;
								_byteNormal[bi+1] = disp;
								
								disp = int((ni.y+1)*127);
								if (disp > 255) disp = 255;
								else if (disp < 0) disp = 0;
								_byteNormal[bi+2] = disp;
								
								disp = int((ni.z+1)*127);
								if (disp > 255) disp = 255;
								else if (disp < 0) disp = 0;
								_byteNormal[bi+3] = disp;
							//}
						}				
					}
					
				}else{
					o[y]={x:x, uv0:uv0, uv1:uv1, v0:v0, v1:v1, ratio:ratio, grad:grad};
				}
			}
		}
		
        public override function get radius2():Number
        {
            var rv0:Number = _v0._x*_v0._x + _v0._y*_v0._y + _v0._z*_v0._z;
            var rv1:Number = _v1._x*_v1._x + _v1._y*_v1._y + _v1._z*_v1._z;
            var rv2:Number = _v2._x*_v2._x + _v2._y*_v2._y + _v2._z*_v2._z;

            if (rv0 > rv1)
            {
                if (rv0 > rv2)
                    return rv0;
                else
                    return rv2;
            }
            else
            {
                if (rv1 > rv2)
                    return rv1;
                else        
                    return rv2;
            }
        }

        public function get maxU():Number
        {
            if (_uv0._u > _uv1._u)
            {
                if (_uv0.u > _uv2._u)
                    return _uv0._u;
                else
                    return _uv2._u;
            }
            else
            {
                if (_uv1._u > _uv2._u)
                    return _uv1._u;
                else
                    return _uv2._u;
            }
        }
        
        public function get minU():Number
        {
            if (_uv0._u < _uv1._u)
            {
                if (_uv0._u < _uv2._u)
                    return _uv0._u;
                else
                    return _uv2._u;
            }
            else
            {
                if (_uv1._u < _uv2._u)
                    return _uv1._u;
                else
                    return _uv2._u;
            }
        }
        
        public function get maxV():Number
        {
            if (_uv0._v > _uv1._v)
            {
                if (_uv0._v > _uv2._v)
                    return _uv0._v;
                else
                    return _uv2._v;
            }
            else
            {
                if (_uv1._v > _uv2._v)
                    return _uv1._v;
                else
                    return _uv2._v;
            }
        }
        
        public function get minV():Number
        {
            if (_uv0._v < _uv1._v)
            {
                if (_uv0._v < _uv2._v)
                    return _uv0._v;
                else
                    return _uv2._v;
            }
            else
            {
                if (_uv1._v < _uv2._v)
                    return _uv1._v;
                else
                    return _uv2._v;
            }
        }
        
        public override function get minX():Number
        {
            if (_v0._x < _v1._x)
            {
                if (_v0._x < _v2._x)
                    return _v0._x;
                else
                    return _v2._x;
            }
            else
            {
                if (_v1._x < _v2._x)
                    return _v1._x;
                else
                    return _v2._x;
            }
        }
        
        public override function get maxY():Number
        {
            if (_v0._y > _v1._y)
            {
                if (_v0._y > _v2._y)
                    return _v0._y;
                else
                    return _v2._y;
            }
            else
            {
                if (_v1._y > _v2._y)
                    return _v1._y;
                else
                    return _v2._y;
            }
        }
        
        public override function get minY():Number
        {
            if (_v0._y < _v1._y)
            {
                if (_v0._y < _v2._y)
                    return _v0._y;
                else
                    return _v2._y;
            }
            else
            {
                if (_v1._y < _v2._y)
                    return _v1._y;
                else
                    return _v2._y;
            }
        }
        
        public override function get maxZ():Number
        {
            if (_v0._z > _v1._z)
            {
                if (_v0._z > _v2._z)
                    return _v0._z;
                else
                    return _v2._z;
            }
            else
            {
                if (_v1._z > _v2._z)
                    return _v1._z;
                else
                    return _v2._z;
            }
        }
        
        public override function get minZ():Number
        {
            if (_v0._z < _v1._z)
            {
                if (_v0._z < _v2._z)
                    return _v0._z;
                else
                    return _v2._z;
            }
            else
            {
                if (_v1._z < _v2._z)
                    return _v1._z;
                else
                    return _v2._z;
            }
        }

        public function invert():void
        {
            var v1:Vertex = this._v1;
            var v2:Vertex = this._v2;
            var uv1:UV = this._uv1;
            var uv2:UV = this._uv2;

            this._v1 = v2;
            this._v2 = v1;
            this._uv1 = uv2;
            this._uv2 = uv1;

            _texturemapping = null;

            notifyVertexChange();
            notifyMappingChange();
        }

        arcane var _texturemapping:Matrix;
        arcane var _mappingmaterial:IUVMaterial;
		
		internal var uv_u0:Number;
        internal var uv_u1:Number;
        internal var uv_u2:Number;
        internal var uv_v0:Number;
        internal var uv_v1:Number;
        internal var uv_v2:Number;
        internal var width:Number;
        internal var height:Number;
            
        arcane function mapping(uvm:IUVMaterial):Matrix
        {
            if (uvm == null)
                return null;

            if (_texturemapping != null)
                if (_mappingmaterial == uvm)
                    return _texturemapping;

            _mappingmaterial = uvm;

            width = uvm.width;
            height = uvm.height;

            if (uv0 == null)
            {
                _texturemapping = new Matrix();
                return _texturemapping;
            }
            if (uv1 == null)
            {
                _texturemapping = new Matrix();
                return _texturemapping;
            }
            if (uv2 == null)
            {
                _texturemapping = new Matrix();
                return _texturemapping;
            }

            uv_u0 = width * uv0._u;
            uv_u1 = width * uv1._u;
            uv_u2 = width * uv2._u;
            uv_v0 = height * (1 - uv0._v);
            uv_v1 = height * (1 - uv1._v);
            uv_v2 = height * (1 - uv2._v);
      
            // Fix perpendicular projections
            if ((uv_u0 == uv_u1 && uv_v0 == uv_v1) || (uv_u0 == uv_u2 && uv_v0 == uv_v2))
            {
                uv_u0 -= (uv_u0 > 0.05) ? 0.05 : -0.05;
                uv_v0 -= (uv_v0 > 0.07) ? 0.07 : -0.07;
            }
    
            if (uv_u2 == uv_u1 && uv_v2 == uv_v1)
            {
                uv_u2 -= (uv_u2 > 0.05) ? 0.04 : -0.04;
                uv_v2 -= (uv_v2 > 0.06) ? 0.06 : -0.06;
            }
			if (uvm is PhongBitmapMaterial)
			{
				_bitmapRect = new Rectangle(int(width*minU)-1, int(height*(1 - maxV))-1, int(width*(maxU-minU))+1, int(height*(maxV-minV))+1);
            	if (_bitmapRect.width == 0)
            		_bitmapRect.width = 1;
            	if (_bitmapRect.height == 0)
            		_bitmapRect.height = 1;
            	_texturemapping = new Matrix(uv_u1 - uv_u0, uv_v1 - uv_v0, uv_u2 - uv_u0, uv_v2 - uv_v0, uv_u0 - _bitmapRect.x, uv_v0 - _bitmapRect.y);			
			} else {
            	_texturemapping = new Matrix(uv_u1 - uv_u0, uv_v1 - uv_v0, uv_u2 - uv_u0, uv_v2 - uv_v0, uv_u0, uv_v0);
			}
            _texturemapping.invert();
            return _texturemapping;
        }

        arcane function front(projection:Projection):Number
        {
            var sv0:ScreenVertex = _v0.project(projection);
            var sv1:ScreenVertex = _v1.project(projection);
            var sv2:ScreenVertex = _v2.project(projection);
                
            return (sv0.x*(sv2.y - sv1.y) + sv1.x*(sv0.y - sv2.y) + sv2.x*(sv1.y - sv0.y));
        }

        public function Face(v0:Vertex, v1:Vertex, v2:Vertex, material:ITriangleMaterial = null, uv0:UV = null, uv1:UV = null, uv2:UV = null)
        {
            this.v0 = v0;
            this.v1 = v1;
            this.v2 = v2;
            this.material = material;
            this.uv0 = uv0;
            this.uv1 = uv1;
            this.uv2 = uv2;
        }

        private function onVertexChange(event:Event):void
        {
            _normal = null;
            notifyVertexChange();
        }

        private function onVertexValueChange(event:Event):void
        {
            _normal = null;
            notifyVertexValueChange();
        }

        private function onUVChange(event:Event):void
        {
            _texturemapping = null;
            notifyMappingChange();
        }

        public function addOnMappingChange(listener:Function):void
        {
            addEventListener("mappingchanged", listener, false, 0, true);
        }
        public function removeOnMappingChange(listener:Function):void
        {
            removeEventListener("mappingchanged", listener, false);
        }
        private var mappingchanged:FaceEvent;
        protected function notifyMappingChange():void
        {
            if (!hasEventListener("mappingchanged"))
                return;

            if (mappingchanged == null)
                mappingchanged = new FaceEvent("mappingchanged", this);
                
            dispatchEvent(mappingchanged);
        }

        public function addOnMaterialChange(listener:Function):void
        {
            addEventListener("materialchanged", listener, false, 0, true);
        }
        public function removeOnMaterialChange(listener:Function):void
        {
            removeEventListener("materialchanged", listener, false);
        }
        private var materialchanged:FaceEvent;
        protected function notifyMaterialChange():void
        {
            if (!hasEventListener("materialchanged"))
                return;

            if (materialchanged == null)
                materialchanged = new FaceEvent("materialchanged", this);
                
            dispatchEvent(materialchanged);
        }

    }
}
