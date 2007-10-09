package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import flash.utils.*;
    import flash.geom.*;
    import flash.display.*;
    import away3d.core.mesh.Vertex;
    import away3d.core.math.Number3D;
    import away3d.core.math.Matrix3D;

    /** Object holding information for one rendering frame */
    public final class BitmapSession extends RenderSession
    {
    	internal var v0z:Number;
    	internal var v1z:Number;
    	internal var v2z:Number;
    	
    	internal var v0Persp:Number;
    	internal var v1Persp:Number;
    	internal var v2Persp:Number;
    	internal var focus:Number;
    	
		internal var e2:Number;
        internal var f2:Number;
		
		internal var DIST:Number;
		internal var TWIDTH:int;
		internal var THEIGHT:int;
		
		internal var P:Number3D;
		internal var M:Number3D;
		internal var N:Number3D;
		
		internal var A:Number3D;
		internal var B:Number3D;
		internal var C:Number3D;
		
		internal var o:Object;
		
        public override function renderTriangleBitmap(bitmap:BitmapData, map:Matrix, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex, smooth:Boolean, repeat:Boolean):void
        {
        	super.renderTriangleBitmap(bitmap, map, v0, v1, v2, smooth, repeat)
			
			//calc P, N and M
			/*
			focus = camera.focus;
			
			DIST = camera.zoom*focus;
			TWIDTH = bitmap.width;
			THEIGHT = bitmap.height;
			
			v0z = focus + v0.z;
			v1z = focus + v1.z;
			v2z = focus + v2.z;
			
			a2 = (v1x = v1.x*v1z) - (v0x = v0.x*v0z);
        	b2 = (v1y = v1.y*v1z) - (v0y = v0.y*v0z);
        	c2 = v1z - v0z;
        	d2 = (v2x = v2.x*v2z) - v0x;
        	e2 = (v2y = v2.y*v2z) - v0y;
        	f2 = v2z - v0z;
        	
			M.x = (a = map.a)*a2 + (b = map.b)*d2;
			M.y = a*b2 + b*e2;
			M.z = a*c2 + b*f2;
			N.x = (c = map.c)*a2 + (d = map.d)*d2;
			N.y = c*b2 + d*e2;
			N.z = c*c2 + d*f2;
			P.x = (tx = map.tx)*a2 + (ty = map.ty)*d2 + v0x;
			P.y = tx*b2 + ty*e2 + v0y;
			P.z = tx*c2 + ty*f2 + v0z;
			
			A = Number3D.cross(P, N);
			B = Number3D.cross(M, P);
			C = Number3D.cross(N, M);
			
			o = {};
			
			lineTri(v0,v1);
			lineTri(v1,v2);
			lineTri(v2,v0);
			
			//var p:Number3D = v0;
			*/
        }
		
		internal var x0:Number;
		internal var y0:Number;
		internal var x1:Number;
		internal var y1:Number;
		
		internal var steep:Boolean;
		internal var swap:int;
			
		internal var deltax:int;
		internal var deltay:int;
			
		internal var error:int = 0;
			
		internal var y:int;			
		internal var ystep:int;
		internal var x:int;
		internal var xend:int;
		internal var fx:int;
		internal var fy:int;
		internal var px:int;
		internal var xtotal:int;
			
		private function lineTri(v0:ScreenVertex,v1:ScreenVertex):void{
			
        	x0 = v0.x;
        	y0 = v0.y;
        	x1 = v1.x;
        	y1 = v1.y;
        	
			steep = (y1-y0)*(y1-y0) > (x1-x0)*(x1-x0);
			
			if (steep){
				swap=x0; x0=y0; y0=swap;
				swap=x1; x1=y1; y1=swap;
			}
			if (x0>x1){
				x0^=x1; x1^=x0; x0^=x1;
				y0^=y1; y1^=y0; y0^=y1;
			}
			
			deltax = x1 - x0
			deltay = Math.abs(y1 - y0);
			
			error = 0;
			
			y = y0;			
			ystep = y0<y1 ? 1 : -1;
			x = x0;
			xend = x1-(deltax>>1);
			fx = x1;
			fy = y1;
			px = 0;
			xtotal = x1-x0;
						
			while (x++<=xend){
				if (steep){
					checkLine(o,y,x);
					if (fx!=x1 && fx!=xend)checkLine(o,fy,fx+1);
				}
					
				error += deltay;
				if ((error<<1) >= deltax){
					if (!steep){
						checkLine(o,x-px+1,y);
						if (fx!=xend)checkLine(o,fx+1,fy);
				
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
				checkLine(o,x-px+1,y);
			}
			
		}
		
		internal var ox:int;
		internal var i:int;
		internal var div:Number;
		
		private function checkLine(o:Object,x:int,y:int):void{
			if (o[y]){
				if (o[y] > x){
					ox = x;
					x = o[y];
				} else {
					ox = o[y];
				}
				i = x + 1;
				while(i-->=ox)
				{
					div = i*C.x + y*C.y + DIST*C.z;
					TWIDTH*(i*A.x + y*A.y + DIST*A.z)/div;
					THEIGHT*(i*B.x + y*B.y + DIST*B.z)/div;
				}
			}else{
				o[y] = x;
			}
		}
		
        public override function renderTriangleColor(color:int, alpha:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
            super.renderTriangleColor(color, alpha, v0, v1, v2)
        }

        public override function renderTriangleLine(color:int, alpha:Number, width:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
            super.renderTriangleLine(color, alpha, width, v0, v1, v2)
        }

        public function BitmapSession(scene:Scene3D, camera:Camera3D, container:Sprite, clip:Clipping, lightarray:LightArray)
        {
            super(scene, camera, container, clip, lightarray);
        }
    }
}

