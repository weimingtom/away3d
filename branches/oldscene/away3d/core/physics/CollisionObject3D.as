package away3d.core.physics
{
	import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.physics.*;
    
	public class CollisionObject3D
	{
		protected var _mass:Number = 1;		
		protected var _fixed:Boolean = false;
		protected var _immovable:Boolean = false;
        public var _parent:Object3D = null;
		
				
		//configuration properties
		public var inheritAttributes:Boolean = true;
		public var useRaycasting:Boolean = false;
		public var detectionMode:int = 0;
		public var reactionMode:int = 1;
		public var iterations:int = 3;
		public var lastCollision:Collision;
		
		//physical properties
		public var active:Boolean = true;
		public var collidable:Boolean = true;
    	public var magnetic:Boolean = true;
		public var drag:Number = 0;
		public var bounce:Number = 1;
		public var traction:Number = 1;
		public var friction:Number = 1;
		
		//temp variable fields set per frame
		public var minX:Number;
		public var maxX:Number;
		public var minY:Number;
		public var maxY:Number;
		public var minZ:Number;
		public var maxZ:Number;
		public var oldPosition:Number3D;
		public var oldScenePosition:Number3D;
		public var scenePosition:Number3D = new Number3D();
		public var acceleration:Number3D = new Number3D();
		public var invMass:Number = 10000;
		public var velocity2:Number;
		public var maxVelocity:Number;
		public var maxVelocity2:Number;
		public var dt2:Number;
        
        public function get parent():Object3D
        {
            return _parent;
        }

        public function set parent(p:Object3D):void
        {
        	_parent = p;
        }
        
		public function set immovable(val:Boolean):void
		{
			_immovable = val;
		}
		
		public function get immovable():Boolean
		{
			return _immovable;
		}
		
		public function set fixed(val:Boolean):void
		{
			_fixed = val;
		}
		
		public function get fixed():Boolean
		{
			return _fixed || _immovable;
		}
		
		public function CollisionObject3D(init:Object = null):void
        {
            init = Init.parse(init);
            mass = init.getNumber("mass", mass);
            fixed = init.getBoolean("fixed", fixed);
            immovable = init.getBoolean("immovable", immovable);
            collidable = init.getBoolean("collidable", collidable);
            magnetic = init.getBoolean("magnetic", magnetic);
            parent = init.getObject("parent") as Object3D;
            drag = init.getNumber("drag", drag);
            bounce = init.getNumber("bounce", bounce);
            traction = init.getNumber("traction", traction);
            friction = init.getNumber("friction", friction);
            
            lastCollision = new Collision();
        }
				
		public function get mass():Number
		{
			return _mass;
		}
        
        public function set mass(val:Number):void
		{
			
		}
 		        
        public function get position():Number3D
        {
            return new Number3D();
        }
    
        public function set position(val:Number3D):void
        {

        }
        
        public function get velocity():Number3D
        {
        	return Number3D.sub(position, oldPosition);
        }
        
        public function set velocity(val:Number3D):void
        {
        	oldPosition = Number3D.sub(position, val);
        }
        
		public function thrust(val:Number3D):void
		{
			//if (val.x == 0 && val.y == 0 && val.z == 0)
			//	return;
			position = Number3D.add(position, val);
		}
		
		public function updateBoundingBox():void
		{
			
		}
	}
}