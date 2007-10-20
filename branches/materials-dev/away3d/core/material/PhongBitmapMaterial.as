package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
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
    	use namespace arcane;
    	
        private var _byteMaterial:ByteArray;
        private var _bitmapBump:BitmapData;
        private var _bitmapMaterial:BitmapData;
        private var _bitmapRect:Rectangle;
        private var _normalPoint:Point = new Point(0,0);
        
        public function PhongBitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            super(bitmap, init);
			
            init = Init.parse(init);
            
            _bitmapBump = init.getBitmap("bitmapBump");
        }
        
        public override function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
        	mapping = tri.texturemapping || tri.transformUV(this);
        	
        	_bitmapMaterial = getBitmapMaterial(tri)
        	_bitmapMaterial.copyPixels(_bitmap, tri.bitmapRect, _normalPoint);
        	_bitmapMaterial.draw(getBitmapPhong(tri), null, null, BlendMode.MULTIPLY);
            session.renderTriangleBitmap(_bitmapMaterial, mapping, tri.v0, tri.v1, tri.v2, smooth, repeat);
			
            if (debug)
                session.renderTriangleLine(2, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }
        
        public function getByteArray():ByteArray
        {
        	if (_byteMaterial == null)
        	{
        		var _bumpRect:Rectangle = new Rectangle(0, 0, width, height);
        		if (_bitmapBump == null) {
	            	_bitmapBump = new BitmapData(_bumpRect.width, _bumpRect.height, true, 0x00000000);
	            	_bitmapBump.copyPixels(_bitmap, _bumpRect, new Point(0,0));
	            	var colorTransform:ColorMatrixFilter = new ColorMatrixFilter([0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0,0,1,0,0]);
	            	_bitmapBump.applyFilter(_bitmapBump, _bumpRect, new Point(0,0), colorTransform);
	         	}
            	
            	var cf:ConvolutionFilter = new ConvolutionFilter(3, 3, null, 1, 127);
            	
            	var _dummyX:BitmapData = new BitmapData(_bumpRect.width, _bumpRect.height, true, 0x00000000);
            	cf.matrix = new Array(0,0,0,-1,0,1,0,0,0);
            	_dummyX.applyFilter(_bitmapBump, _bumpRect, new Point(0,0), cf);
            	_bitmapBump.copyChannel(_dummyX, _bumpRect, new Point(0,0), BitmapDataChannel.RED, BitmapDataChannel.RED);
            	
            	var _dummyY:BitmapData = new BitmapData(_bumpRect.width, _bumpRect.height, true, 0x00000000);
            	cf.matrix = new Array(0,-1,0,0,0,0,0,1,0);
            	_dummyY.applyFilter(_bitmapBump, _bumpRect, new Point(0,0), cf);
            	_bitmapBump.copyChannel(_dummyY, _bumpRect, new Point(0,0), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
            	
            	_byteMaterial = _bitmapBump.getPixels(_bumpRect);
        	}
        	return _byteMaterial;
        }
 
 
        public function getBitmapMaterial(tri:DrawTriangle):BitmapData
        {
            if (tri.bitmapMaterial == null)
            {
            	//sample bitmap rectangle required for this face
				_bitmapRect = tri.bitmapRect = tri.face.bitmapRect;
            	tri.bitmapMaterial = new BitmapData(_bitmapRect.width, _bitmapRect.height, true, 0x00000000);
            }
            return tri.bitmapMaterial;
        }
        
        internal var _byteNormal:ByteArray;
        internal var _byteBump:ByteArray;
        
        internal var vF:Vertex;
        internal var xF:int;
        internal var yF:int;
        internal var contains:Boolean;
        internal var insideTri:Boolean;
        
        internal var x0:int;
        internal var x1:int;
        internal var x2:int;
        internal var y0:int;
        internal var y1:int;
        internal var y2:int;
        
        internal var o:Object;
        
        internal var v0:Vertex;
        internal var v1:Vertex;
        internal var v2:Vertex;
        
        internal var v0z:Number;
       	internal var v0x:Number;
        internal var v0y:Number;
        internal var v1x:Number;
        internal var v1y:Number;
    	internal var v1z:Number;
        internal var v2x:Number;
        internal var v2y:Number;
    	internal var v2z:Number;
        
        internal var a:Number;
        internal var b:Number;
        internal var c:Number;
        internal var d:Number;
        
		internal var a2:Number;
        internal var b2:Number;
        internal var c2:Number;
        internal var d2:Number;
        internal var e2:Number;
        internal var f2:Number;
        
        internal var M:Number3D = new Number3D();
        internal var N:Number3D = new Number3D();
        
        internal var mesh:Mesh;
        
        internal var edge0x:Number;
        internal var edge0y:Number;
        internal var edge1x:Number;
        internal var edge1y:Number;
        internal var edge2x:Number;
        internal var edge2y:Number;
        
        internal var colorTransform:ColorMatrixFilter = new ColorMatrixFilter();
        
        public function getBitmapPhong(tri:DrawTriangle):BitmapData
        {
        	if (tri.bitmapPhong == null) {
        		//setup bitmapdata objects
            	tri.bitmapPhong = new BitmapData(_bitmapRect.width, _bitmapRect.height, true, 0x00000000);
            	tri.bitmapNormal = new BitmapData(_bitmapRect.width, _bitmapRect.height, true, 0x00000000);
            	
            	//create normal map
            	tri.normalRect = new Rectangle(0,0,_bitmapRect.width, _bitmapRect.height);
            	_byteNormal = tri.bitmapNormal.getPixels(tri.normalRect);
            	_byteBump = getByteArray();
            	
            	v0 = tri.face.v0;
            	v1 = tri.face.v1;
            	v2 = tri.face.v2;
            	
            	v0z = v0.z;
				v1z = v1.z;
				v2z = v2.z;
			
            	// calc u and v 3d vectors
            	a2 = (v1x = v1.x) - (v0x = v0.x);
	        	b2 = (v1y = v1.y) - (v0y = v0.y);
	        	c2 = v1z - v0z;
	        	d2 = (v2x = v2.x) - v0x;
	        	e2 = (v2y = v2.y) - v0y;
	        	f2 = v2z - v0z;
	        	
				M.x = (a = tri.texturemapping.a)*a2 + (b = tri.texturemapping.b)*d2;
				M.y = a*b2 + b*e2;
				M.z = a*c2 + b*f2;
				M.normalize();
				N.x = (c = tri.texturemapping.c)*a2 + (d = tri.texturemapping.d)*d2;
				N.y = c*b2 + d*e2;
				N.z = c*c2 + d*f2;
				N.normalize();
				
				mesh = tri.object;
				
            	o = {};
            	
            	x0 = int(tri.uv0._u*width-_bitmapRect.x);
	        	y0 = int((1-tri.uv0._v)*height-_bitmapRect.y);
	        	x1 = int(tri.uv1._u*width-_bitmapRect.x);
	        	y1 = int((1-tri.uv1._v)*height-_bitmapRect.y);
        		x2 = int(tri.uv2._u*width-_bitmapRect.x);
	        	y2 = int((1-tri.uv2._v)*height-_bitmapRect.y);
	        	
            	edge0x = x1 - x0;
            	edge0y = y1 - y0;
            	edge1x = x2 - x1;
            	edge1y = y2 - y1;
            	edge2x = x0 - x2;
            	edge2y = y0 - y2;
	        	
	        	insideTri = true;
	        	
            	lineTri(x0,y0,x1,y1,v0,v1);
				lineTri(x1,y1,x2,y2,v1,v2);
				lineTri(x2,y2,x0,y0,v2,v0);
				
				insideTri = false;
				contains = tri.uv0._u*(tri.uv2._v - tri.uv1._v) + tri.uv1._u*(tri.uv0._v - tri.uv2._v) + tri.uv2._u*(tri.uv1._v - tri.uv0._v) > 0;
				getReflectedUV(mesh.neighbour01(tri.face), v0, v1, tri.uv0, tri.uv1);
				
				o = {};
            	lineTri(x1, y1, x0, y0, v1, v0);
				lineTri(x0, y0, xF, yF, v0, vF);
				lineTri(xF, yF, x1, y1, vF, v1);
				
				getReflectedUV(mesh.neighbour12(tri.face), v1, v2, tri.uv1, tri.uv2);
				
				o = {};
            	lineTri(xF, yF, x2, y2, vF, v2);
				lineTri(x2, y2, x1, y1, v2, v1);
				lineTri(x1, y1, xF, yF, v1, vF);
				
				getReflectedUV(mesh.neighbour20(tri.face), v2, v0, tri.uv2, tri.uv0);
				
				o = {};
            	lineTri(x2, y2, xF, yF, v2, vF);
				lineTri(xF, yF, x0, y0, vF, v0);
				lineTri(x0, y0, x2, y2, v0, v2);
				
            	_byteNormal.position = 0;
				tri.bitmapNormal.setPixels(tri.normalRect, _byteNormal);
        	}
        	
        	//combine normal map
        	var view:Matrix3D = tri.projection.view;
        	var szx:Number = view.szz;
			var szy:Number = view.szy;
			var szz:Number = -view.szx;
			
			colorTransform.matrix = [szx, 0, 0, 0, 127-szx*127, 0, szy, 0, 0, 127-szy*127, 0, 0, szz, 0, 127-szz*127, 0, 0, 0, 1, 0];
            tri.bitmapPhong.applyFilter(tri.bitmapNormal, tri.normalRect, _normalPoint, colorTransform);
            
            var ambientR:Number = 0x00;
            var ambientG:Number = 0x22;
            var ambientB:Number = 0x88;
            
			colorTransform.matrix = [2, 2, 2, 0, -764, 2, 2, 2, 0, -764, 2, 2, 2, 0, -764, 0, 0, 0, 1, 0];
			tri.bitmapPhong.applyFilter(tri.bitmapPhong, tri.normalRect, _normalPoint, colorTransform);
			colorTransform.matrix = [1, 0, 0, 0, ambientR, 0, 1, 0, 0, ambientG, 0, 0, 1, 0, ambientB, 0, 0, 0, 1, 0];
			tri.bitmapPhong.applyFilter(tri.bitmapPhong, tri.normalRect, _normalPoint, colorTransform);        	
        	return tri.bitmapPhong;
        }
        
        
        internal var udiff:Number;
        internal var vdiff:Number;
        internal var ncontains:Boolean;
        internal var grad:Number;
        internal var grad2:Number;
        
        public function getReflectedUV(neighbour:Face, point0:Vertex, point1:Vertex, line0:UV, line1:UV):void
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
			xF = int(neighbourUV._u*width-_bitmapRect.x);
			yF = int((1-neighbourUV._v)*height-_bitmapRect.y);
			vF = neighbourV;
        }
        
        internal var steep:Boolean;
        internal var swap:Vertex;
		internal var deltax:int;
		internal var deltay:int;
		internal var x:int;
		internal var y:int;
		internal var ystep:int;
		internal var error:int;
		
        private function lineTri(x0:int,y0:int,x1:int, y1:int,v0:Vertex,v1:Vertex):void
        {	
			steep = (y1-y0)*(y1-y0) > (x1-x0)*(x1-x0);
			if (steep){
				x0^=y0; y0^=x0; x0^=y0;
				x1^=y1; y1^=x1; x1^=y1;
			}
			if (x0>x1){
				swap=v0; v0=v1; v1=swap;
				x0^=x1; x1^=x0; x0^=x1;
				y0^=y1; y1^=y0; y0^=y1;
			}
			
			deltax = y0 - y1;
			deltay = (deltax ^ (deltax >> 31)) - (deltax >> 31);
			deltax = x1 - x0;
			
			
			x = x0-1;
			y = y0;
			ystep = y0<y1 ? 1 : -1;
			error = -(deltax>>1);
			
			while (x++<x1){
				if (steep && x > -1 && x <= _bitmapRect.height){
					checkLine(o,y,x, v0, v1, (x-x0)/deltax, grad);
				}
				error += deltay;
				if (error > 0){
					if (!steep && y > -1 && y <= _bitmapRect.height){
						checkLine(o,x,y, v0, v1, (x-x0)/deltax, grad);
					}
					y += ystep;
					error -= deltax;
				}
			}
			if (!steep && y > -1 && y <= _bitmapRect.height){
				checkLine(o,x-1,y, v0, v1, (x-1-x0)/deltax, grad);
			}
			
		}
		
		internal var ox:int;
		internal var ov0:Vertex;
		internal var ov1:Vertex;
		internal var oratio:Number;
		internal var ratio1:Number;
		internal var oratio1:Number;
        internal var n0:Number3D;
        internal var n1:Number3D;
        internal var n:Number3D;
        internal var on0:Number3D;
        internal var on1:Number3D;
        internal var on:Number3D;
        
        internal var xi:int;
		internal var bi:int;
		internal var xtotal:int;
		internal var iratio:Number;
		internal var iratio1:Number;
		
		internal var ni:Number3D;
		internal var bm:int;
		internal var bn:int;
		internal var rotV:Number3D;
		internal var rotA:Number;
		internal const rotConst:Number = (90/127)*(Math.PI/180);
		internal var disp:int;
		internal var offsetRect:int;
		internal var bumpByte:int;
		
		private function checkLine(o:Object,x:int,y:int, v0:Vertex, v1:Vertex, ratio:Number, grad:Number):void{
			if (o[y]){
				if (o[y].x > x){
					ox = x;
					ov0 = v0;
					ov1 = v1;
					oratio = ratio;
					x = o[y].x;
					v0 = o[y].v0;
					v1 = o[y].v1;
					ratio = o[y].ratio;
				} else {
					ox = o[y].x;
					ov0 = o[y].v0;
					ov1 = o[y].v1;
					oratio = o[y].ratio;
				}
				
				ratio1 = 1 - ratio;
				oratio1 = 1 - oratio;
				n0 = mesh.getVertexNormal(v0);
				n1 = mesh.getVertexNormal(v1);
				
				n = new Number3D(ratio1*n0.x + ratio*n1.x, ratio1*n0.y + ratio*n1.y, ratio1*n0.z + ratio*n1.z);
				n.normalize();
				
				on0 = mesh.getVertexNormal(ov0);
				on1 = mesh.getVertexNormal(ov1);
				
				on = new Number3D(oratio1*on0.x + oratio*on1.x, oratio1*on0.y + oratio*on1.y, oratio1*on0.z + oratio*on1.z);
				on.normalize();
				
				xi = x + 1;
				xtotal = x - ox;
				offsetRect = 4*(_bitmapRect.y*width + y*(width - _bitmapRect.width) + _bitmapRect.x);
				
				while(xi-->ox)
				{
					if (xi >= 0 && xi < _bitmapRect.width && (insideTri || triProximity(xi, y))) {
						bi = 4*(y*_bitmapRect.width+xi);
					
						iratio = xtotal? (xi-ox)/xtotal : 0.5;
						iratio1 = (1 - iratio);
						_byteNormal[bi] = 255;
						
						ni = new Number3D(iratio1*on.x + iratio*n.x, iratio1*on.y + iratio*n.y, iratio1*on.z + iratio*n.z);
						
						bumpByte = offsetRect + bi;
						bm = _byteBump[int(bumpByte+1)]-127;
						bn = _byteBump[int(bumpByte+2)]-127;
						ni.normalize();
						rotV = Number3D.cross(Number3D.add(Number3D.scale(M, bm), Number3D.scale(N, bn)), ni);
						rotV.normalize();
						rotA = Math.sqrt(bm*bm + bn*bn);
						ni = ni.rotate(Matrix3D.rotationMatrix(rotV.x, rotV.y, rotV.z, rotA*rotConst));
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
						
					}
				}
				
			}else{
				o[y]={x:x, v0:v0, v1:v1, ratio:ratio};
			}
		}
		
		public function triProximity(x:int, y:int):Boolean
		{
			if (Math.abs(edge0y*(x-x0) - edge0x*(y-y0))/Math.sqrt(edge0x*edge0x + edge0y*edge0y) < 2)
				return true;
			if (Math.abs(edge1y*(x-x1) - edge1x*(y-y1))/Math.sqrt(edge1x*edge1x + edge1y*edge1y) < 2)
				return true;
			if (Math.abs(edge2y*(x-x2) - edge2x*(y-y2))/Math.sqrt(edge2x*edge2x + edge2y*edge2y) < 2)
				return true;
			return false;
		}
    }
}
