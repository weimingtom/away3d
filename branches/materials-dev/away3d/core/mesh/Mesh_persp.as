package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.render.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;
    
    import away3d.objects.*;

    import flash.utils.Dictionary;
    import flash.display.BitmapData;
    import flash.display.*;
    import flash.utils.ByteArray;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.geom.ColorTransform;
    import flash.filters.DisplacementMapFilter;
    
    /** Mesh constisting of faces and segments */
    public class Mesh extends BaseMesh implements IPrimitiveProvider
    {
        use namespace arcane;

        private var _faces:Array = [];

        public function get faces():Array
        {
            return _faces;
        }

        public override function get elements():Array
        {
            return _faces;
        }

        private var _neighboursDirty:Boolean = true;
        private var _neighbour01:Dictionary; 
        private var _neighbour12:Dictionary; 
        private var _neighbour20:Dictionary; 

        private var _vertfacesDirty:Boolean = true;
        private var _vertfaces:Dictionary;

        private function findVertFaces():void
        {
            if (!_vertfacesDirty)
                return;
            
            _vertfaces = new Dictionary();
            for each (var face:Face in faces)
            {
                var v0:Vertex = face.v0;
                if (_vertfaces[face.v0] == null)
                    _vertfaces[face.v0] = [face];
                else
                    _vertfaces[face.v0].push(face);
                var v1:Vertex = face.v1;
                if (_vertfaces[face.v1] == null)
                    _vertfaces[face.v1] = [face];
                else
                    _vertfaces[face.v1].push(face);
                var v2:Vertex = face.v2;
                if (_vertfaces[face.v2] == null)
                    _vertfaces[face.v2] = [face];
                else
                    _vertfaces[face.v2].push(face);
            }
            _vertfacesDirty = false;    
        }

        arcane function getFacesByVertex(vertex:Vertex):Array
        {
            if (_vertfacesDirty)
                findVertFaces();

            return _vertfaces[vertex];
        }

        arcane function neighbour01(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            return _neighbour01[face];
        }

        arcane function neighbour12(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            return _neighbour12[face];
        }

        arcane function neighbour20(face:Face):Face
        {
            if (_neighboursDirty)
                findNeighbours();
            return _neighbour20[face];
        }

        private function findNeighbours():void
        {
            if (!_neighboursDirty)
                return;

            _neighbour01 = new Dictionary();
            _neighbour12 = new Dictionary();
            _neighbour20 = new Dictionary();
            for each (var face:Face in _faces)
            {
                var skip:Boolean = true;
                for each (var another:Face in _faces)
                {
                    if (skip)
                    {
                        if (face == another)
                            skip = false;
                        continue;
                    }

                    if ((face._v0 == another._v2) && (face._v1 == another._v1))
                    {
                        _neighbour01[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v0 == another._v0) && (face._v1 == another._v2))
                    {
                        _neighbour01[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v0 == another._v1) && (face._v1 == another._v0))
                    {
                        _neighbour01[face] = another;
                        _neighbour01[another] = face;
                    }
                
                    if ((face._v1 == another._v2) && (face._v2 == another._v1))
                    {
                        _neighbour12[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v1 == another._v0) && (face._v2 == another._v2))
                    {
                        _neighbour12[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v1 == another._v1) && (face._v2 == another._v0))
                    {
                        _neighbour12[face] = another;
                        _neighbour01[another] = face;
                    }
                
                    if ((face._v2 == another._v2) && (face._v0 == another._v1))
                    {
                        _neighbour20[face] = another;
                        _neighbour12[another] = face;
                    }

                    if ((face._v2 == another._v0) && (face._v0 == another._v2))
                    {
                        _neighbour20[face] = another;
                        _neighbour20[another] = face;
                    }

                    if ((face._v2 == another._v1) && (face._v0 == another._v0))
                    {
                        _neighbour20[face] = another;
                        _neighbour01[another] = face;
                    }
                }
            }

            _neighboursDirty = false;
        }
         
        public var material:ITriangleMaterial;
        public var outline:ISegmentMaterial;
        public var back:ITriangleMaterial;

        public var bothsides:Boolean;
        public var debugbb:Boolean;

        public function Mesh(init:Object = null)
        {
            super(init);

            init = Init.parse(init);
            
            material = init.getMaterial("material");
            outline = init.getSegmentMaterial("outline");
            back = init.getMaterial("back");
            bothsides = init.getBoolean("bothsides", false);
            debugbb = init.getBoolean("debugbb", false);

            if ((material == null) && (outline == null))
                material = new WireColorMaterial();
        }
		
		public var perspBitmapX:BitmapData;
		internal var perspByteX:ByteArray;
		public var colTransformX:ColorTransform = new ColorTransform();
		
		public var perspBitmapY:BitmapData;
		internal var perspByteY:ByteArray;
		public var colTransformY:ColorTransform = new ColorTransform();
		
		public var perspBitmapZ:BitmapData;
		internal var perspByteZ:ByteArray;
		public var colTransformZ:ColorTransform = new ColorTransform();
		
		public var perspBitmapDX:BitmapData;
		public var perspBitmapDY:BitmapData;	
		public var perspBitmapDZ:BitmapData;
		public var colTransform:ColorTransform = new ColorTransform();
		
		public var materialBitmap:BitmapData;
		public var materialFilter:DisplacementMapFilter = new DisplacementMapFilter(null, new Point(0,0), BitmapDataChannel.RED, BitmapDataChannel.GREEN, 127, 127);
		public var perspBitmap:BitmapData;
		public var perspBitmapD:BitmapData;
		internal var perspByteD:ByteArray;
		
		internal var uv0:UV;
        internal var uv1:UV;
        internal var uv2:UV;
        
        internal var x0:int;
        internal var x1:int;
        internal var y0:int;
        internal var y1:int;
        internal var o:Object;
		internal var width:Number;
		internal var height:Number;
		internal var focus:Number = 200;
		
		internal var bx:Number;
		internal var by:Number;
		internal var bz:Number;
		
		internal var rect:Rectangle;
		internal var pt:Point = new Point();
		
		public function buildMaterial(mat:IUVMaterial):void
		{
			//create containers for transformations
			width = mat.width;
			height = mat.height;
			rect = new Rectangle(0,0,width,height);
			
			perspBitmapX = new BitmapData(width, height, true, 0xFF000000);
			perspByteX = perspBitmapX.getPixels(rect);
			perspBitmapY = new BitmapData(width, height, true, 0xFF000000);
			perspByteY = perspBitmapY.getPixels(rect);
			perspBitmapZ = new BitmapData(width, height, true, 0xFF000000);
			perspByteZ = perspBitmapZ.getPixels(rect);
			
			perspBitmapDX = new BitmapData(width, height, true, 0xFF000000);
			perspBitmapDY = new BitmapData(width, height, true, 0xFF000000);
			perspBitmapDZ = new BitmapData(width, height, true, 0xFF000000);
			perspByteD = perspBitmapDX.getPixels(rect);
			
			materialBitmap = new BitmapData(width, height);
			perspBitmap = new BitmapData(width, height);
			perspBitmapD = new BitmapData(width, height, true, 0XFF808080);
			
			//calulate offset viewed from each axis
        	
			for each (var face:Face in _faces)
            {
            	uv0 = face._uv0;
            	uv1 = face._uv1;
            	uv2 = face._uv2;
            	
            	var p0:Number3D = face._v0.position;
            	var p1:Number3D = face._v1.position;
            	var p2:Number3D = face._v2.position;
            	
            	o = {};
            	
            	// texture
            	lineTri(uv0,uv1,p0,p1);
				lineTri(uv1,uv2,p1,p2);
				lineTri(uv2,uv0,p2,p0);
            	
            }
            perspByteX.position = 0;
            perspByteY.position = 0;
            perspByteZ.position = 0;
            perspByteD.position = 0;
            
            perspBitmapX.setPixels(rect, perspByteX);
            perspBitmapY.setPixels(rect, perspByteY);
            perspBitmapZ.setPixels(rect, perspByteZ);
            
            //perspBitmapD.setPixels(rect, perspByteD);
            //perspBitmapDX.copyChannel(perspBitmapD, rect, pt, BitmapDataChannel.RED, 1);
            //perspBitmapDY.copyChannel(perspBitmapD, rect, pt, BitmapDataChannel.GREEN, 1);
            //perspBitmapDZ.copyChannel(perspBitmapD, rect, pt, BitmapDataChannel.BLUE, 1);
            
			materialBitmap.draw(mat.bitmap);
		}
		
		private function lineTri(uv0:UV,uv1:UV,p0:Number3D,p1:Number3D):void{
			
        	x0 = int(uv0._u*width);
        	y0 = int((1-uv0._v)*height);
        	x1 = int(uv1._u*width);
        	y1 = int((1-uv1._v)*height);
        	
			var steep:Boolean = (y1-y0)*(y1-y0) > (x1-x0)*(x1-x0);
			var swap:int;
			var swapP:Number3D;
			var swapUV:UV;
			
			if (steep){
				swap=x0; x0=y0; y0=swap;
				swap=x1; x1=y1; y1=swap;
			}
			if (x0>x1){
				swapP=p0; p0=p1; p1=swapP;
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
						
			while (x++<=xend){
				if (steep){
					checkLine(o,y,x, uv0, uv1, p0, p1, (x-x0)/xtotal);
					if (fx!=x1 && fx!=xend)checkLine(o,fy,fx+1, uv0, uv1 ,p0, p1, (fx+1-x0)/xtotal);
				}
					
				error += deltay;
				if ((error<<1) >= deltax){
					if (!steep){
						checkLine(o,x-px+1,y, uv0, uv1, p0, p1, (x-px+1-x0)/xtotal);
						if (fx!=xend)checkLine(o,fx+1,fy, uv0, uv1, p0, p1, (fx+1-x0)/xtotal);
				
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
				checkLine(o,x-px+1,y, uv0, uv1, p0, p1, (x-px+1-x0)/xtotal);
			}
			
		}
		
		internal var ox:int;
		internal var ouv0:UV;
		internal var ouv1:UV;
		internal var op0:Number3D;
		internal var op1:Number3D;
		internal var ratio:Number;
		internal var oratio:Number;
		
		private function checkLine(o:Object,x:int,y:int, uv0:UV, uv1:UV, p0:Number3D, p1:Number3D, ratio:Number):void{
			if (o[y]){
				if (o[y].x > x){
					ox = x;
					ouv0 = uv0;
					ouv1 = uv1;
					op0 = p0;
					op1 = p1;
					oratio = ratio
					x = o[y].x;
					uv0 = o[y].uv0;
					uv1 = o[y].uv1;
					p0 = o[y].p0;
					p1 = o[y].p1;
					ratio = o[y].ratio;
				} else {
					ox = o[y].x;
					ouv0 = o[y].uv0;
					ouv1 = o[y].uv1;
					op0 = o[y].p0;
					op1 = o[y].p1;
					oratio = o[y].ratio;
				}
				
				//setup default distances
				var x0:Number = p0.x;
				var y0:Number = p0.y;
				var z0:Number = p0.z;
				
				var x1:Number = p1.x;
				var y1:Number = p1.y;
				var z1:Number = p1.z;

				var uratio:Number = (uv1._u - uv0._u)? (x/width - uv0._u)/(uv1._u - uv0._u) : ratio;
				var uratio1:Number = (1 - uratio);
				
				var vratio:Number = (uv0._v - uv1._v)? (y/height - 1 + uv0._v)/(uv0._v - uv1._v) : ratio;
				var vratio1:Number = (1 - vratio);
				
				//calculate offsets
				var ux0ratio:Number = uratio1*x0;
				var uy0ratio:Number = uratio1*y0;
				var uz0ratio:Number = uratio1*z0;
				
				var ux1ratio:Number = uratio*x1;
				var uy1ratio:Number = uratio*y1;
				var uz1ratio:Number = uratio*z1;
				
				var vx0ratio:Number = vratio1*x0;
				var vy0ratio:Number = vratio1*y0;
				var vz0ratio:Number = vratio1*z0;
				
				var vx1ratio:Number = vratio*x1;
				var vy1ratio:Number = vratio*y1;
				var vz1ratio:Number = vratio*z1;
				
				var uxX:Number = uratio1*x0 + uratio*x1;
				var uyY:Number = uratio1*y0 + uratio*y1;
				var uzZ:Number = uratio1*z0 + uratio*z1;
				
				var vxX:Number = vratio1*x0 + vratio*x1;
				var vyY:Number = vratio1*y0 + vratio*y1;
				var vzZ:Number = vratio1*z0 + vratio*z1;
				
				var u0:Number = int(uv0._u*width);
				var u1:Number = int(uv1._u*width);
				var uX:Number = u0*ux0ratio + u1*ux1ratio;
				var uY:Number = u0*uy0ratio + u1*uy1ratio;
				var uZ:Number = u0*uz0ratio + u1*uz1ratio;
				
				var v0:Number = int((1-uv0._v)*height);
				var v1:Number = int((1-uv1._v)*height);
				var vX:Number = v0*vx0ratio + v1*vx1ratio;
				var vY:Number = v0*vy0ratio + v1*vy1ratio;
				var vZ:Number = v0*vz0ratio + v1*vz1ratio;
				
				
				
				var ouratio:Number = (ouv1._u - ouv0._u)? (ox/width - ouv0._u)/(ouv1._u - ouv0._u) : ratio;
				var ouratio1:Number = (1 - ouratio);
				
				var ovratio:Number = (ouv0._v - ouv1._v)? (y/height - 1 + ouv0._v)/(ouv0._v - ouv1._v) : ratio;
				var ovratio1:Number = (1 - ovratio);
				
				
				var ox0:Number = op0.x;
				var oy0:Number = op0.y;
				var oz0:Number = op0.z;
				
				var ox1:Number = op1.x;
				var oy1:Number = op1.y;
				var oz1:Number = op1.z;
				
				var oux0ratio:Number = ouratio1*ox0;
				var ouy0ratio:Number = ouratio1*oy0;
				var ouz0ratio:Number = ouratio1*oz0;
				
				var oux1ratio:Number = ouratio*ox1;
				var ouy1ratio:Number = ouratio*oy1;
				var ouz1ratio:Number = ouratio*oz1;
				
				var ovx0ratio:Number = ovratio1*ox0;
				var ovy0ratio:Number = ovratio1*oy0;
				var ovz0ratio:Number = ovratio1*oz0;
				
				var ovx1ratio:Number = ovratio*ox1;
				var ovy1ratio:Number = ovratio*oy1;
				var ovz1ratio:Number = ovratio*oz1;
				
				var ouxX:Number = ouratio1*ox0 + ouratio*ox1;
				var ouyY:Number = ouratio1*oy0 + ouratio*oy1;
				var ouzZ:Number = ouratio1*oz0 + ouratio*oz1;
				
				var ovxX:Number = ovratio1*ox0 + ovratio*ox1;
				var ovyY:Number = ovratio1*oy0 + ovratio*oy1;
				var ovzZ:Number = ovratio1*oz0 + ovratio*oz1;
				
				var ou0:Number = int(ouv0._u*width);
				var ou1:Number = int(ouv1._u*width);
				var ouX:Number = ou0*oux0ratio + ou1*oux1ratio;
				var ouY:Number = ou0*ouy0ratio + ou1*ouy1ratio;
				var ouZ:Number = ou0*ouz0ratio + ou1*ouz1ratio;
				
				var ov0:Number = int((1-ouv0._v)*height);
				var ov1:Number = int((1-ouv1._v)*height);
				var ovX:Number = ov0*ovx0ratio + ov1*ovx1ratio;
				var ovY:Number = ov0*ovy0ratio + ov1*ovy1ratio;
				var ovZ:Number = ov0*ovz0ratio + ov1*ovz1ratio;
				
				var i:int = x+1;
				var bi:int;
				var xtotal:int = x - ox;
				var iratio:Number;
				var iratio1:Number;
				
				var xiratio:Number;
				var yiratio:Number;
				var ziratio:Number;
				var oxiratio:Number;
				var oyiratio:Number;
				var oziratio:Number;
				
				var ixX:Number;
				var iyY:Number;
				var izZ:Number;
				
				var disp:int;
				
				while(i-->=ox)
				{
					bi = 4*(y*width+i);
					iratio = (i-ox)/xtotal;
					iratio1 = (1 - iratio);
					
					xiratio = iratio*uxX;
					yiratio = iratio*uyY;
					ziratio = iratio*uzZ;
					
					oxiratio = iratio1*ouxX;
					oyiratio = iratio1*ouyY;
					oziratio = iratio1*ouzZ;
					
					ixX = oxiratio + xiratio;
					iyY = oyiratio + yiratio;
					izZ = oziratio + ziratio;
					
					
					disp = int(127 + (ouX*iratio1 + uX*iratio - ixX*i)/100);
					if (disp > 255) disp = 255;
					else if (disp < 0) disp = 0;
					perspByteX[bi+1] = disp;
					
					disp =  int(127 + (ouY*iratio1 + uY*iratio - iyY*i)/100);
					if (disp > 255) disp = 255;
					else if (disp < 0) disp = 0;
					perspByteY[bi+1] = disp;
					
					disp =  int(127 + (ouZ*iratio1 + uZ*iratio - izZ*i)/100);
					if (disp > 255) disp = 255;
					else if (disp < 0) disp = 0;
					perspByteZ[bi+1] = disp;
					
					
					disp = int(127 - ixX/5);
					if (disp > 255) disp = 255;
					else if (disp < 0) disp = 0;
					perspByteX[bi+3] = disp;
					
					disp = int(127 - iyY/5);
					if (disp > 255) disp = 255;
					else if (disp < 0) disp = 0;
					perspByteY[bi+3] = disp;
					
					disp = int(127 - izZ/5);
					if (disp > 255) disp = 255;
					else if (disp < 0) disp = 0;
					perspByteZ[bi+3] = disp;
					
					xiratio = iratio*vxX;
					yiratio = iratio*vyY;
					ziratio = iratio*vzZ;
					
					oxiratio = iratio1*ovxX;
					oyiratio = iratio1*ovyY;
					oziratio = iratio1*ovzZ;
					
					ixX = oxiratio + xiratio;
					iyY = oyiratio + yiratio;
					izZ = oziratio + ziratio;
					
					disp = int(127 + (ovX*iratio1 + vX*iratio - ixX*y)/100);
					if (disp > 255) disp = 255;
					else if (disp < 0) disp = 0;
					perspByteX[bi+2] = disp;
					
					disp = int(127 + (ovY*iratio1 + vY*iratio - iyY*y)/100);
					if (disp > 255) disp = 255;
					else if (disp < 0) disp = 0;
					perspByteY[bi+2] = disp;
					
					disp = int(127 + (ovZ*iratio1 + vZ*iratio - izZ*y)/100);
					if (disp > 255) disp = 255;
					else if (disp < 0) disp = 0;
					perspByteZ[bi+2] = disp;
					/*
					disp = int(127 + ixX/10);
					if (disp > 255) disp = 255;
					else if (disp < 0) disp = 0;
					perspByteD[bi+1] = disp;
					
					disp = int(127 + iyY/10);
					if (disp > 255) disp = 255;
					else if (disp < 0) disp = 0;
					perspByteD[bi+2] = disp;
					
					disp = int(127 + izZ/10);
					if (disp > 255) disp = 255;
					else if (disp < 0) disp = 0;
					perspByteD[bi+3] = disp;
					*/
				}
				
			}else{
				o[y]={x:x, uv0:uv0, uv1:uv1, p0:p0, p1:p1, ratio:ratio};
			}
		}
		
        public function addFace(face:Face):void
        {
            addElement(face);

            _faces.push(face);

            face.addOnVertexChange(onFaceVertexChange);
            rememberFaceNeighbours(face);
            _vertfacesDirty = true;
        }

        public function removeFace(face:Face):void
        {
            var index:int = _faces.indexOf(face);
            if (index == -1)
                return;

            removeElement(face);

            _vertfacesDirty = true;
            forgetFaceNeighbours(face);
            face.removeOnVertexChange(onFaceVertexChange);

            _faces.splice(index, 1);
        }

        private function rememberFaceNeighbours(face:Face):void
        {
            if (_neighboursDirty)
                return;
            
            for each (var another:Face in _faces)
            {
                if (face == another)
                    continue;

                if ((face._v0 == another._v2) && (face._v1 == another._v1))
                {
                    _neighbour01[face] = another;
                    _neighbour12[another] = face;
                }

                if ((face._v0 == another._v0) && (face._v1 == another._v2))
                {
                    _neighbour01[face] = another;
                    _neighbour20[another] = face;
                }

                if ((face._v0 == another._v1) && (face._v1 == another._v0))
                {
                    _neighbour01[face] = another;
                    _neighbour01[another] = face;
                }
            
                if ((face._v1 == another._v2) && (face._v2 == another._v1))
                {
                    _neighbour12[face] = another;
                    _neighbour12[another] = face;
                }

                if ((face._v1 == another._v0) && (face._v2 == another._v2))
                {
                    _neighbour12[face] = another;
                    _neighbour20[another] = face;
                }

                if ((face._v1 == another._v1) && (face._v2 == another._v0))
                {
                    _neighbour12[face] = another;
                    _neighbour01[another] = face;
                }
            
                if ((face._v2 == another._v2) && (face._v0 == another._v1))
                {
                    _neighbour20[face] = another;
                    _neighbour12[another] = face;
                }

                if ((face._v2 == another._v0) && (face._v0 == another._v2))
                {
                    _neighbour20[face] = another;
                    _neighbour20[another] = face;
                }

                if ((face._v2 == another._v1) && (face._v0 == another._v0))
                {
                    _neighbour20[face] = another;
                    _neighbour01[another] = face;
                }
            }
        }

        private function forgetFaceNeighbours(face:Face):void
        {
            if (_neighboursDirty)
                return;
            
            var n01:Face = _neighbour01[face];
            if (n01 != null)
            {
                delete _neighbour01[face];
                if (_neighbour01[n01] == face)
                    delete _neighbour01[n01];
                if (_neighbour12[n01] == face)
                    delete _neighbour12[n01];
                if (_neighbour20[n01] == face)
                    delete _neighbour20[n01];
            }
            var n12:Face = _neighbour12[face];
            if (n12 != null)
            {
                delete _neighbour12[face];
                if (_neighbour01[n12] == face)
                    delete _neighbour01[n12];
                if (_neighbour12[n12] == face)
                    delete _neighbour12[n12];
                if (_neighbour20[n12] == face)
                    delete _neighbour20[n12];
            }
            var n20:Face = _neighbour20[face];
            if (n20 != null)
            {
                delete _neighbour20[face];
                if (_neighbour01[n20] == face)
                    delete _neighbour01[n20];
                if (_neighbour12[n20] == face)
                    delete _neighbour12[n20];
                if (_neighbour20[n20] == face)
                    delete _neighbour20[n20];
            }
        }

        private function onFaceVertexChange(event:MeshElementEvent):void
        {
            if (!_neighboursDirty)
            {
                var face:Face = event.element as Face;
                forgetFaceNeighbours(face);
                rememberFaceNeighbours(face);
            }

            _vertfacesDirty = true;
        }

        private function clear():void
        {
            for each (var face:Face in _faces.concat([]))
                removeFace(face);
        }

        public function invertFaces():void
        {
            for each (var face:Face in _faces)
                face.invert();
        }

        public function quarterFaces():void
        {
            var medians:Dictionary = new Dictionary();
            for each (var face:Face in _faces.concat([]))
            {
                var v0:Vertex = face.v0;
                var v1:Vertex = face.v1;
                var v2:Vertex = face.v2;

                if (medians[v0] == null)
                    medians[v0] = new Dictionary();
                if (medians[v1] == null)
                    medians[v1] = new Dictionary();
                if (medians[v2] == null)
                    medians[v2] = new Dictionary();

                var v01:Vertex = medians[v0][v1];
                if (v01 == null)
                {
                   v01 = Vertex.median(v0, v1);
                   medians[v0][v1] = v01;
                   medians[v1][v0] = v01;
                }
                var v12:Vertex = medians[v1][v2];
                if (v12 == null)
                {
                   v12 = Vertex.median(v1, v2);
                   medians[v1][v2] = v12;
                   medians[v2][v1] = v12;
                }
                var v20:Vertex = medians[v2][v0];
                if (v20 == null)
                {
                   v20 = Vertex.median(v2, v0);
                   medians[v2][v0] = v20;
                   medians[v0][v2] = v20;
                }
                var uv0:UV = face.uv0;
                var uv1:UV = face.uv1;
                var uv2:UV = face.uv2;
                var uv01:UV = UV.median(uv0, uv1);
                var uv12:UV = UV.median(uv1, uv2);
                var uv20:UV = UV.median(uv2, uv0);
                var material:ITriangleMaterial = face.material;
                removeFace(face);
                addFace(new Face(v0, v01, v20, material, uv0, uv01, uv20));
                addFace(new Face(v01, v1, v12, material, uv01, uv1, uv12));
                addFace(new Face(v20, v12, v2, material, uv20, uv12, uv2));
                addFace(new Face(v12, v20, v01, material, uv12, uv20, uv01));
            }
        }

        public function movePivot(dx:Number, dy:Number, dz:Number):void
        {
            _neighboursDirty = true;
            for each (var vertex:Vertex in vertices)
            {
                vertex.x += dx;
                vertex.y += dy;
                vertex.z += dz;
            }
            x -= dx;
            y -= dy;
            z -= dz;
        }

        private var _debugboundingbox:WireCube;

        public function primitives(projection:Projection, consumer:IPrimitiveConsumer):void
        {
            if (outline != null)
                if (_neighboursDirty)
                    findNeighbours();

            if (debugbb)
            {
                if (_debugboundingbox == null)
                    _debugboundingbox = new WireCube({material:"#white"});
                _debugboundingbox.v000.x = minX;
                _debugboundingbox.v001.x = minX;
                _debugboundingbox.v010.x = minX;
                _debugboundingbox.v011.x = minX;
                _debugboundingbox.v100.x = maxX;
                _debugboundingbox.v101.x = maxX;
                _debugboundingbox.v110.x = maxX;
                _debugboundingbox.v111.x = maxX;
                _debugboundingbox.v000.y = minY;
                _debugboundingbox.v001.y = minY;
                _debugboundingbox.v010.y = maxY;
                _debugboundingbox.v011.y = maxY;
                _debugboundingbox.v100.y = minY;
                _debugboundingbox.v101.y = minY;
                _debugboundingbox.v110.y = maxY;
                _debugboundingbox.v111.y = maxY;
                _debugboundingbox.v000.z = minZ;
                _debugboundingbox.v001.z = maxZ;
                _debugboundingbox.v010.z = minZ;
                _debugboundingbox.v011.z = maxZ;
                _debugboundingbox.v100.z = minZ;
                _debugboundingbox.v101.z = maxZ;
                _debugboundingbox.v110.z = minZ;
                _debugboundingbox.v111.z = maxZ;
                if (_faces.length > 0)
                    _debugboundingbox.primitives(projection, consumer);
            }
			
			
			//added code for material
			//projection.view.sxx
			//perspBitmap.merge(perspBitmapX, rect, pt, projection.view.sxx*255, 255, 0, 0);
			//perspBitmap.merge(perspBitmapY, rect, pt, 127, 127, 0, 0);
			//perspBitmap.merge(perspBitmapZ, rect, pt, 127, 127, 0, 0);
			var szx:Number = -projection.view.szx;
			var szy:Number = -projection.view.szy;
			var szz:Number = -projection.view.szz;
			
			var mod:Number = Math.abs(szx) + Math.abs(szy) + Math.abs(szz);
			szx /= mod;
			szy /= mod;
			szz /= mod;
			
			colTransformX.redMultiplier = colTransformX.greenMultiplier = colTransformX.blueMultiplier = szx;
			colTransformX.redOffset = colTransformX.greenOffset = colTransformX.blueOffset = (szx > 0)? 0 : -szx*255;
			colTransformY.redMultiplier = colTransformY.greenMultiplier = colTransformY.blueMultiplier = szy;
			colTransformY.redOffset = colTransformY.greenOffset = colTransformY.blueOffset = (szy > 0)? 0 : -szy*255;
			colTransformZ.redMultiplier = colTransformZ.greenMultiplier = colTransformZ.blueMultiplier = szz;
			colTransformZ.redOffset = colTransformZ.greenOffset = colTransformZ.blueOffset = (szz > 0)? 0 : -szz*255;
			perspBitmap.fillRect(rect, 0x00000000);
			perspBitmap.draw(perspBitmapX, null, colTransformX, BlendMode.ADD);
			perspBitmap.draw(perspBitmapY, null, colTransformY, BlendMode.ADD);
			perspBitmap.draw(perspBitmapZ, null, colTransformZ, BlendMode.ADD);
			
			//scale perspbitmap
			
			var posZ:Number = projection.view.tz + focus;
			colTransform.alphaMultiplier = 100000/(posZ*posZ);
			//colTransform.alphaOffset = 220 - 25500/posZ;
			colTransform.alphaOffset = 100-127*100000/(posZ*posZ) - 25500/posZ;
			perspBitmapD.fillRect(rect, 0xFF808080);
			perspBitmapD.copyChannel(perspBitmap, rect, pt, BitmapDataChannel.BLUE, BitmapDataChannel.ALPHA);
			
			perspBitmap.draw(perspBitmapD, null, colTransform, BlendMode.NORMAL);
			materialFilter.mapBitmap = perspBitmap;
			materialBitmap.applyFilter((material as IUVMaterial).bitmap, rect, pt, materialFilter);
			//finished add
			//trace(50000/(posZ*posZ));
			
            var tri:DrawTriangle;
            var ntri:DrawTriangle;
            var transparent:ITriangleMaterial = TransparentMaterial.INSTANCE;
            var backmat:ITriangleMaterial = back || material;
            for each (var face:Face in _faces)
            {
                if (!face._visible)
                    continue;

                if (tri == null)
                    if (outline == null)
                        tri = face._dt; //new DrawTriangle();
                    else
                        tri = new DrawBorderTriangle();

                tri.v0 = face._v0.project(projection);
                tri.v1 = face._v1.project(projection);
                tri.v2 = face._v2.project(projection);

                if (!tri.v0.visible)
                    continue;

                if (!tri.v1.visible)
                    continue;

                if (!tri.v2.visible)
                    continue;

                tri.calc();

                if (tri.maxZ < 0)
                    continue;

                var backface:Boolean = tri.area <= 0;

                if (backface)
                    if (!bothsides)
                        continue;

                tri.material = face._material;
				tri.object = this;
				
                if (tri.material == null)
                    if (backface)
                        tri.material = backmat;
                    else
                        tri.material = material;

                if (tri.material != null)
                    if (!tri.material.visible)
                        tri.material = null;

                if (outline == null)
                    if (tri.material == null)
                        continue;

                if (pushback)
                    tri.screenZ = tri.maxZ;

                if (pushfront)
                    tri.screenZ = tri.minZ;

                tri.uv0 = face._uv0;
                tri.uv1 = face._uv1;
                tri.uv2 = face._uv2;

                tri.texturemapping = null;

                if (backface)
                {
                    // Make cleaner
                    var vt:ScreenVertex = tri.v1;
                    tri.v1 = tri.v2;
                    tri.v2 = vt;

                    var uvt:UV = tri.uv1;
                    tri.uv1 = tri.uv2;
                    tri.uv2 = uvt;

                    tri.area = -tri.area;
                }
                else
                {
                    var uvm:IUVMaterial = tri.material as IUVMaterial;
                    if (uvm != null)
                    {
                        if (tri.material == face._mappingmaterial) {
                            tri.texturemapping = face._texturemapping;
                        } else {
                            tri.texturemapping = face.mapping(uvm);
                        }
                    }
                }

                if ((outline != null) && (!backface))
                {
                    var btri:DrawBorderTriangle = tri as DrawBorderTriangle;
                        
                    if (ntri == null)
                        ntri = new DrawTriangle();

                    var n01:Face = _neighbour01[face];
                    if (n01 != null)
                    {
                        if (n01.front(projection) <= 0)
                            btri.s01material = outline;
                    }
                    else
                        btri.s01material = outline;

                    var n12:Face = _neighbour12[face];
                    if (n12 != null)
                    {
                        if (n12.front(projection) <= 0)
                            btri.s12material = outline;
                    }
                    else
                        btri.s12material = outline;

                    var n20:Face = _neighbour20[face];
                    if (n20 != null)
                    {
                        if (n20.front(projection) <= 0)
                            btri.s20material = outline;
                    }
                    else
                        btri.s20material = outline;

                    if (btri.material == null)
                    {
                        if ((btri.s01material == null) && (btri.s12material == null) && (btri.s20material == null))
                            continue;
                        else
                            btri.material = transparent;
                    }
                }

                tri.source = this;
                tri.face = face;
                tri.projection = projection;
                consumer.primitive(tri);
                tri = null;
            }
        }

        public override function clone(object:* = null):*
        {
            var mesh:Mesh = object || new Mesh();
            super.clone(mesh);
            mesh.material = material;
            mesh.outline = outline;
            mesh.back = back;
            mesh.bothsides = bothsides;
            mesh.debugbb = debugbb;

            var clonedvertices:Dictionary = new Dictionary();
            var clonevertex:Function = function(vertex:Vertex):Vertex
            {
                var result:Vertex = clonedvertices[vertex];
                if (result == null)
                {
                    result = new Vertex(vertex._x, vertex._y, vertex._z);
                    result.extra = (vertex.extra is IClonable) ? (vertex.extra as IClonable).clone() : vertex.extra;
                    clonedvertices[vertex] = result;
                }
                return result;
            }

            var cloneduvs:Dictionary = new Dictionary();
            var cloneuv:Function = function(uv:UV):UV
            {
                if (uv == null)
                    return null;

                var result:UV = cloneduvs[uv];
                if (result == null)
                {
                    result = new UV(uv._u, uv._v);
                    cloneduvs[uv] = result;
                }
                return result;
            }
            
            for each (var face:Face in _faces)
                mesh.addFace(new Face(clonevertex(face._v0), clonevertex(face._v1), clonevertex(face._v2), face.material, cloneuv(face._uv0), cloneuv(face._uv1), cloneuv(face._uv2)));

            return mesh;
        }

        public function asAS3Class(classname:String = null, packagename:String = ""):String
        {
            classname = classname || name || "MyAway3DObject";
            var source:String = "package "+packagename+"\n{\n\timport away3d.core.mesh.*;\n\n\tpublic class "+classname+" extends Mesh\n\t{\n";
            source += "\t\tprivate var varr:Array = [];\n";
            source += "\t\tprivate var uvarr:Array = [];\n\n";
            source += "\t\tprivate function v(x:Number,y:Number,z:Number):void\n\t\t{\n";
            source += "\t\t\tvarr.push(new Vertex(x,y,z));\n\t\t}\n\n";
            source += "\t\tprivate function uv(u:Number,v:Number):void\n\t\t{\n";
            source += "\t\t\tuvarr.push(new UV(u,v));\n\t\t}\n\n";
            source += "\t\tprivate function f(vn0:int, vn1:int, vn2:int, uvn0:int, uvn1:int, uvn2:int):void\n\t\t{\n";
            source += "\t\t\taddFace(new Face(varr[vn0],varr[vn1],varr[vn2], null, uvarr[uvn0],uvarr[uvn1],uvarr[uvn2]));\n\t\t}\n\n";
            source += "\t\tpublic function "+classname+"(init:Object = null)\n\t\t{\n\t\t\tsuper(init);\n\t\t\tbuild();\n\t\t}\n\n";
            source += "\t\tprivate function build():void\n\t\t{\n";
            
            var refvertices:Dictionary = new Dictionary();
            var verticeslist:Array = [];
            var remembervertex:Function = function(vertex:Vertex):void
            {
                if (refvertices[vertex] == null)
                {
                    refvertices[vertex] = verticeslist.length;
                    verticeslist.push(vertex);
                }
            }

            var refuvs:Dictionary = new Dictionary();
            var uvslist:Array = [];
            var rememberuv:Function = function(uv:UV):void
            {
                if (uv == null)
                    return;

                if (refuvs[uv] == null)
                {
                    refuvs[uv] = uvslist.length;
                    uvslist.push(uv);
                }
            }

            for each (var face:Face in _faces)
            {
                remembervertex(face._v0);
                remembervertex(face._v1);
                remembervertex(face._v2);
                rememberuv(face._uv0);
                rememberuv(face._uv1);
                rememberuv(face._uv2);
            }

            for each (var v:Vertex in verticeslist)
                source += "\t\t\tv("+v._x+","+v._y+","+v._z+");\n";

            for each (var uv:UV in uvslist)
                source += "\t\t\tuv("+uv._u+","+uv._v+");\n";

            for each (var f:Face in _faces)
                source += "\t\t\tf("+refvertices[f._v0]+","+refvertices[f._v1]+","+refvertices[f._v2]+","+refuvs[f._uv0]+","+refuvs[f._uv1]+","+refuvs[f._uv2]+");\n"

            source += "\t\t}\n\t}\n}";
            return source;
        }
    }
}
