package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.geom.*;
    import away3d.core.proto.*;
    
    // The Vertices3D class lets you create and manipulate groups of vertices.
    public class Vertices3D extends Object3D
    {
        public var maxradius:Number = -1;
        public var minradius:Number = 0;
        
		public var vertices:Array = new Array();
		
	    protected var _boundingSphere2     :Number;
		protected var _boundingSphereDirty :Boolean = true;
		
	    /**
		* Radius square of the mesh bounding sphere
		*/
		public function get boundingSphere2():Number
		{
			if( _boundingSphereDirty )
				return getBoundingSphere2();
			else
				return _boundingSphere2;
		}
		
        protected function calcMaxRadius():void
        {
            var mrs:Number = 0;
            for each (var v:Vertex3D in vertices)
            {
                var sd:Number = v.x*v.x + v.y*v.y + v.z*v.z;
                if (sd > mrs)
                    mrs = sd;
            }
            maxradius = Math.sqrt(mrs);
        }

        public function Vertices3D(name:String = null, init:Object = null)
        {
            super(name, init);
        }
        
        public function getBoundingSphere2():Number
		{
			var max :Number = 0;
			var d   :Number;
			for each( var v:Vertex3D in vertices )
			{
				d = v.x*v.x + v.y*v.y + v.z*v.z;
	
				max = (d > max)? d : max;
			}
	
			this._boundingSphereDirty = false;
	
			return _boundingSphere2 = max;
		}
		
    	public function hitTestPoint( x:Number, y:Number, z:Number ):Boolean
		{
			var dx :Number = this.x - x;
			var dy :Number = this.y - y;
			var dz :Number = this.z - z;
	
			var d2 :Number = x*x + y*y + z*z;
	
			var sA :Number = boundingSphere2;
	
			return sA > d2;
		}
    	
    	public function hitTestObject( obj:Vertices3D, multiplier:Number=1 ):Boolean
		{
			var dx :Number = this.x - obj.x;
			var dy :Number = this.y - obj.y;
			var dz :Number = this.z - obj.z;
	
			var d2 :Number = dx*dx + dy*dy + dz*dz;
	
			var sA :Number = boundingSphere2;
			var sB :Number = obj.boundingSphere2;
			
			sA = sA * multiplier;
	
			return sA + sB > d2;
		}

    }
}
