package away3d.core.draw;

    import away3d.core.base.*;

    /**
    * representation of a 3d vertex resolved to the view.
    */
    public final class ScreenVertex
     {
		
		var persp:Float;
		var faz:Float;
		var fbz:Float;
		var ifmz2:Float;
		var mx2:Float;
		var my2:Float;
		var dx:Float;
		var dy:Float;
		
    	/**
    	 * The x position of the vertex in the view.
    	 */
        public var x:Float;
        
    	/**
    	 * The y position of the vertex in the view.
    	 */
        public var y:Float;
        
    	/**
    	 * The z position of the vertex in the view.
    	 */
        public var z:Float;
        
        
        /**
        * The x position of the vertex in clip space
        */
        public var clipX:Float;
        
        /**
        * The y position of the vertex in clip space
        */
        public var clipY:Float;
        
        /**
        * The z position of the vertex in clip space
        */
        public var clipZ:Float;
        
        /**
        * A number containing user defined properties.
        */
        public var num:Float;
        
        /**
        * Indicates whether the vertex is visible after projection.
        */
        public var visible:Bool;
    	
		/**
		 * Creates a new <code>PrimitiveQuadrantTreeNode</code> object.
		 *
		 * @param	x	[optional]		The x position of the vertex in the view. Defaults to 0.
		 * @param	y	[optional]		The y position of the vertex in the view. Defaults to 0.
		 * @param	z	[optional]		The z position of the vertex in the view. Defaults to 0.
		 */
        public function new(?x:Int = 0, ?y:Int = 0, ?z:Int = 0)
        {
            this.x = x;
            this.y = y;
            this.z = z;
    
            this.visible = false;
        }
		
		/**
		 * Used to trace the values of a vertex.
		 * 
		 * @return A string representation of the vertex object.
		 */
        public function toString(): String
        {
            return "new ScreenVertex("+x+', '+y+', '+z+")";
        }
		
		/**
		 * Converts a screen vertex back to a vertex object.
		 * 
		 * @param	focus	The focus value to use for deperspective calulations.
		 * @return			The deperspectived vertex object.
		 */
        public function deperspective(focus:Float):Vertex
        {
            persp = 1 + z / focus;

            return new Vertex(x * persp, y * persp, z);
        }
		
		/**
		 * Calculates the squared distance between two screen vertex objects.
		 * 
		 * @param	b	The screen vertex object to use for the calcation.
		 * @return		The squared scalar value of the vector between this and the given scren vertex.
		 */
        public function distanceSqr(b:ScreenVertex):Float
        {
            return (x - b.x)*(x - b.x) + (y - b.y)*(y - b.y);
        }
		
		/**
		 * Calculates the distance between two screen vertex objects.
		 * 
		 * @param	b	The second screen vertex object to use for the calcation.
		 * @return		The scalar value of the vector between this and the given screen vertex.
		 */
        public function distance(b:ScreenVertex):Float
        {
            return Math.sqrt((x - b.x)*(x - b.x) + (y - b.y)*(y - b.y));
        }
		
		/**
		 * Calculates affine distortion present at the midpoint between two screen vertex objects.
		 * 
		 * @param	b		The second screen vertex object to use for the calcation.
		 * @param	focus	The focus value used for the distortion calulations. 
		 * @return			The scalar value of the vector between this and the given screen vertex.
		 */
        public function distortSqr(b:ScreenVertex, focus:Float):Float
        {
            faz = focus + z;
            fbz = focus + z;
            ifmz2 = 2 / (faz + fbz);
            mx2 = (x*faz + b.x*fbz)*ifmz2;
            my2 = (y*faz + b.y*fbz)*ifmz2;

            dx = x + b.x - mx2;
            dy = y + b.y - my2;

            return 50*(dx*dx + dy+dy); // (distort*10)^2
        }
		
		/**
		 * Returns a screen vertex with values given by a weighted mean calculation.
		 * 
		 * @param	a		The first screen vertex to use for the calculation.
		 * @param	b		The second screen vertex to use for the calculation.
		 * @param	aw		The first screen vertex weighting.
		 * @param	bw		The second screen vertex weighting.
		 * @param	focus	The focus value used for the weighting calulations.
		 * @return			The resulting screen vertex.
		 */
        public static function weighted(a:ScreenVertex, b:ScreenVertex, aw:Float, bw:Float, focus:Float):ScreenVertex
        {
            if ((bw == 0) && (aw == 0))
                throw new Error("Zero weights");

            if (bw == 0)
                return new ScreenVertex(a.x, a.y, a.z);
            else
            if (aw == 0)
                return new ScreenVertex(b.x, b.y, b.z);

            var d:Int = aw + bw;
            var ak:Int = aw / d;
            var bk:Int = bw / d;

            var x:Int = a.x*ak + b.x*bk;
            var y:Int = a.y*ak + b.y*bk;

            var azf:Int = a.z / focus;
            var bzf:Int = b.z / focus;

            var faz:Int = 1 + azf;
            var fbz:Int = 1 + bzf;

            var axf:Int = a.x*faz - x*azf;
            var bxf:Int = b.x*fbz - x*bzf;
            var ayf:Int = a.y*faz - y*azf;
            var byf:Int = b.y*fbz - y*bzf;

            var det:Int = axf*byf - bxf*ayf;
            var da:Int = x*byf - bxf*y;
            var db:Int = axf*y - x*ayf;

            return new ScreenVertex(x, y, (da*a.z + db*b.z) / det);
        }
		
		/**
		 * Returns the median screen vertex between the two given screen vertex objects.
		 * 
		 * @param	a		The first screen vertex to use for the calculation.
		 * @param	b		The second screen vertex to use for the calculation.
		 * @param	focus	The focus value used for the median calulations.
		 * @return			The resulting screen vertex.
		 */
        public static function median(a:ScreenVertex, b:ScreenVertex, focus:Float):ScreenVertex
        {
            var mz:Int = (a.z + b.z) / 2;

            var faz:Int = focus + a.z;
            var fbz:Int = focus + b.z;
            var ifmz:Int = 1 / (focus + mz) / 2;

            return new ScreenVertex((a.x*faz + b.x*fbz)*ifmz, (a.y*faz + b.y*fbz)*ifmz, mz);

            // ap = focus / (focus + saz) * zoom
            // bp = focus / (focus + sbz) * zoom
            // 
            // ax = sax / ap
            // bx = sbx / bp
            //
            // ay = say / ap
            // by = sby / bp
            //
            // az = saz
            // bz = sbz
            //
            // mx = (ax + bx) / 2
            // my = (ay + by) / 2
            // mz = (az + bz) / 2
            //
            // mp = focus / (focus + mz) * zoom
            // smx = mx * mp
            // smy = my * mp
            // smz = mz
            //
            // smz = (saz + sbz) / 2
            // smx = (ax + bx) * focus / (focus + smz) * zoom 
            //     = (sax / ap + sbx / bp) * focus / (focus + smz) * zoom
            //     = (sax / focus / zoom * (focus + saz) + sbx / focus / zoom * (focus + sbz)) * focus / (focus + smz) * zoom
            //     = (sax * (focus + saz) + sbx * (focus + sbz)) / (focus + smz)
            // smy = (say * (focus + saz) + sby * (focus + sbz)) / (focus + smz)

        }
    }
