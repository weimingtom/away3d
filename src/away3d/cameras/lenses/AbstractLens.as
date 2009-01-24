package away3d.cameras.lenses
{
	import away3d.cameras.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.geom.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	
	import flash.utils.*;
	
    /**
    * Abstract lens for resolving perspective using the <code>Camera3D</code> object's position and properties
    */
    public class AbstractLens
    {
    	protected const toRADIANS:Number = Math.PI/180;
		protected const toDEGREES:Number = 180/Math.PI;
		
		protected var _clipTop:Number;
        protected var _clipBottom:Number;
        protected var _clipLeft:Number;
        protected var _clipRight:Number;
        protected var _frustum:Frustum;
        protected var _near:Number;
        protected var _far:Number;
        protected var _plane:Plane3D;
        protected var _len:Number;
        
    	protected var _screenVertex:ScreenVertex;
    	protected var _sx:Number;
    	protected var _sy:Number;
    	protected var _sz:Number;
        protected var _sw:Number;
        protected var _vx:Number;
        protected var _vy:Number;
        protected var _vz:Number;
        protected var _scz:Number;
        
        protected var _projected:ScreenVertex;
        protected var _persp:Number;
        
    	protected var classification:int;
    	protected var viewTransform:Matrix3D;
    	protected var view:Matrix3D = new Matrix3D();
    	
		public static const OUT:int = -1;
		public static const INTERSECT:int = 0;
		public static const IN:int = 1;
		
		/**
		 * reference back to camera parent.
		 */
		public var camera:Camera3D;
		
		public var drawPrimitiveStore:DrawPrimitiveStore;
		
		public var cameraVarsStore:CameraVarsStore;
		/**
		 * store for visible scene nodes in the lens.
		 */
		public var nodeVisible:Dictionary;
		
		/**
		 * store for scene node's transform matrices.
		 */
		public var nodeTransform:Dictionary;
		
		public function setClipping(val:Clipping):void
		{
			_clipTop = val.maxY;
        	_clipBottom = val.minY;
        	_clipLeft = val.minX;
        	_clipRight = val.maxX;
        	
        	_far = val.maxZ;
        	
        	if (val.minZ == -Infinity)
        		_near = val.minZ = -camera.focus/2;
        	else
        		_near = val.minZ;
		}
		
		public function getFrustum(node:Object3D, viewTransform:Matrix3D):Frustum
		{
			throw new Error("Not implemented");
		}
		
		public function getFOV():Number
		{
			throw new Error("Not implemented");
		}
		
		public function getZoom():Number
		{
			throw new Error("Not implemented");
		}
		
		/**
		 * Returns the transformation matrix used to resolve the scene to the view.
		 * Used in the <code>ProjectionTraverser</code> class
		 * 
		 * @see	away3d.core.traverse.ProjectionTraverser
		 */
        public function updateView(clip:Clipping, sceneTransform:Matrix3D, flipY:Matrix3D):void
        {
        	throw new Error("Not implemented");
        }
        
    	/**
    	 * Used in <code>ProjectionTraverser</code> to determine whether the 3d object is visible in the lens.
    	 * 
    	 * @param	node	The 3d node being evaluated.
    	 * @return			Defines whether the 3d node is visible.
    	 * 
    	 * @see	away3d.core.traverse.ProjectionTraverser
    	 */
        public function preCheckNode(node:Object3D):Boolean
        {
        	throw new Error("Not implemented");
        }
        
        public function resolveTransform(node:Object3D):void
		{
			throw new Error("Not implemented");
		}
		
    	/**
    	 * Used in <code>ProjectionTraverser</code> to determine whether the 3d object is visible in the lens.
    	 * 
    	 * @param	node	The 3d node being evaluated.
    	 * @return			Defines whether the 3d node is visible.
    	 * 
    	 * @see	away3d.core.traverse.ProjectionTraverser
    	 */
        public function postCheckNode(node:Object3D):Boolean
        {
        	throw new Error("Not implemented");
        }
        
       /**
        * Projects the vertex to the screen space of the view.
        */
        public function project(viewTransform:Matrix3D, vertex:Vertex):ScreenVertex
        {
        	throw new Error("Not implemented");
        }
    }
}
