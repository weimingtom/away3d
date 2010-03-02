package away3dlite.core.base
{
	import away3dlite.arcane;
	import away3dlite.cameras.*;
	import away3dlite.containers.*;
	import away3dlite.core.*;
	import away3dlite.loaders.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	use namespace arcane;
    
	/**
	 * Dispatched when a user moves the cursor while it is over the 3d object.
	 * 
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name="mouseMove",type="away3dlite.events.MouseEvent3D")]
    
	/**
	 * Dispatched when a user presses the left hand mouse button while the cursor is over the 3d object.
	 * 
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name="mouseDown",type="away3dlite.events.MouseEvent3D")]
    
	/**
	 * Dispatched when a user releases the left hand mouse button while the cursor is over the 3d object.
	 * 
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name="mouseUp",type="away3dlite.events.MouseEvent3D")]
    
	/**
	 * Dispatched when a user moves the cursor over the 3d object.
	 * 
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name="mouseOver",type="away3dlite.events.MouseEvent3D")]
    
	/**
	 * Dispatched when a user moves the cursor away from the 3d object.
	 * 
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name="mouseOut",type="away3dlite.events.MouseEvent3D")]
	
	/**
	 * Dispatched when a user rolls over the 3d object.
	 * 
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name="rollOver",type="away3dlite.events.MouseEvent3D")]
    
	/**
	 * Dispatched when a user rolls out of the 3d object.
	 * 
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name="rollOut",type="away3dlite.events.MouseEvent3D")]
	
	/**
	 * The base class for all 3d objects.
	 */
	public class Object3D extends Sprite implements IDestroyable
	{
		/** @private */
		protected var _isDestroyed:Boolean;
		/** @private */
		arcane var _frustumCulling:Boolean;
		/** @private */
		arcane var _perspCulling:Boolean;
		/** @private */
		arcane var _screenZ:Number = 0;
		/** @private */
		arcane var _scene:Scene3D;
		/** @private */
		arcane var _viewMatrix3D:Matrix3D = new Matrix3D();
		/** @private */
		arcane var _sceneMatrix3D:Matrix3D = new Matrix3D();
		/** @private */
		arcane var _mouseEnabled:Boolean;
		/** @private */
		arcane function updateScene(val:Scene3D):void
		{
		}
        /** @private */
        arcane function project(camera:Camera3D, parentSceneMatrix3D:Matrix3D = null):void
		{
			_sceneMatrix3D.rawData = transform.matrix3D.rawData;
			
			if (parentSceneMatrix3D)
				_sceneMatrix3D.append(parentSceneMatrix3D);
				
			_viewMatrix3D.rawData = _sceneMatrix3D.rawData;
			_viewMatrix3D.append(camera._screenMatrix3D);
			
			_screenZ = _viewMatrix3D.position.z;
			
			//perspective culling
			var persp:Number = camera.zoom / (1 + _screenZ / camera.focus);
			
			if (minPersp != maxPersp && (persp < minPersp || persp >= maxPersp))
				_perspCulling = true;
			else
				_perspCulling = false;
			
			// dirty
			updateDirty(_viewMatrix3D);
		}
		
		private function checkDirty(a:Vector.<Number>, b:Vector.<Number>):Boolean
		{
			var i:int = 16;
			while(--i>-1 && a[int(i)]==b[int(i)]){}
			if(i>=0)
				return true;
			else
				return false;
		}
		
		private var _cachedViewMatrix3D:Matrix3D;
		
		protected function updateDirty(matrix3D:Matrix3D):void
		{
			if(!_cachedViewMatrix3D || transfromDirty)
			{
				_cachedViewMatrix3D = matrix3D.clone();
				
				//mark as dirty
				transfromDirty = true;
				
				//mark parent is dirty
				if(_scene)
					_scene.transfromDirty = true;
			}
			
			//transform dirty
			if(checkDirty(matrix3D.rawData, _cachedViewMatrix3D.rawData))
			{
				//mark as dirty
				transfromDirty = true;
				
				//mark parent is dirty
				if(_scene)
					_scene.transfromDirty = true;
					
				//store
				_cachedViewMatrix3D = matrix3D.clone();
			}else{
				//clean
				transfromDirty = false || _scene?_scene.transfromDirty:false;
			}
		}
		
		protected function copyMatrix3D(m1:Matrix3D, m2:Matrix3D):void
		{
			var rawData:Vector.<Number> = m1.rawData.concat();
			m2.rawData = rawData;
		}
		
		/**
		 * Returns the maxinum length of 3d object to local center aka radius
		 */
		public var maxRadius:Number = 0;
		
		/**
		 * Global position in space, use for Frustum object culler 
		 */		
		public var projectedPosition:Vector3D;
		
		/**
		 * Transfrom status
		 */	
		public var transfromDirty:Boolean = true;
		
		/**
		 * An optional layer sprite used to draw into inseatd of the default view.
		 */
		protected var _layer:Sprite;
		public function set layer(value:Sprite):void
		{
			_layer = value;
		}
		
		public function get layer():Sprite
		{
			return _layer;
		}
		
		/**
		 * An optional canvas sprite used to draw into inseatd of the default view.
		 */
		public var _canvas:Sprite;
		public function set canvas(value:Sprite):void
		{
			_canvas = value;
		}
		
		public function get canvas():Sprite
		{
			return _canvas;
		}
		
		/**
		 * Used in loaders to store all parsed materials contained in the model.
		 */
		public var materialLibrary:MaterialLibrary;
		
		/**
		 * Used in loaders to store all parsed geometry data contained in the model.
		 */
		public var geometryLibrary:GeometryLibrary;
		
		/**
		 * Used in the loaders to store all parsed animation data contained in the model.
		 */
		public var animationLibrary:AnimationLibrary;
		
		/**
		 * Returns the type of 3d object.
		 */
		public var type:String;
		
		/**
		 * Returns the source url of the 3d object, or the name of the family of generative geometry objects if not loaded from an external source.
		 */
		public var url:String;
			
    	/**
    	 * The maximum perspective value from which the 3d object can be viewed.
    	 */
        public var maxPersp:Number = 0;
        
    	/**
    	 * The minimum perspective value from which the 3d object can be viewed.
    	 */
        public var minPersp:Number = 0;
        
		/**
		 * Returns the scene to which the 3d object belongs
		 */
		public function get scene():Scene3D
		{
			return _scene;
		}
		
		/**
		 * Returns the z-sorting position of the 3d object.
		 */
		public function get screenZ():Number
		{
			return _screenZ;
		}
		
		/**
		 * Returns a 3d matrix representing the absolute transformation of the 3d object in the view.
		 */
		public function get viewMatrix3D():Matrix3D
		{
			return _viewMatrix3D;
		}
		
		/**
		 * Returns a 3d matrix representing the absolute transformation of the 3d object in the scene.
		 */
		public function get sceneMatrix3D():Matrix3D
		{
			return _sceneMatrix3D;
		}
				
		/**
		 * Returns a 3d vector representing the local position of the 3d object.
		 */
		public function get position():Vector3D
		{
			return transform.matrix3D.position;
		}
		
		override public function set alpha(value:Number):void
		{
			super.alpha = value;
			if(canvas && canvas.alpha != value)
				canvas.alpha = value;
		}
		
		override public function set blendMode(value:String):void
		{
			super.blendMode = value;
			if(canvas && canvas.blendMode != value)
				canvas.blendMode = value;
		}
		
		override public function set filters(value:Array):void
		{
			super.filters = value;
			if(canvas && canvas.filters != value)
				canvas.filters = value;
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if(canvas && canvas.visible != value)
				canvas.visible = value;
		}
		
		/**
		 * Creates a new <code>Object3D</code> object.
		 */
		public function Object3D()
		{
			super();
			
			//enable for 3d calculations
			transform.matrix3D = new Matrix3D();
		}
		
		/**
		 * Rotates the 3d object around to face a point defined relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 * 
		 * @param	target		The vector defining the point to be looked at
		 * @param	upAxis		An optional vector used to define the desired up orientation of the 3d object after rotation has occurred
		 */
        public function lookAt(target:Vector3D, upAxis:Vector3D = null):void
        {
        	transform.matrix3D.pointAt(target, Vector3D.Z_AXIS, upAxis || new Vector3D(0,-1,0));
        }
		
		/**
		 * Duplicates the 3d object's properties to another <code>Object3D</code> object
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
		 public function clone(object:Object3D = null):Object3D
		 {
            var object3D:Object3D = object || new Object3D();
            
            object3D.transform.matrix3D = transform.matrix3D.clone();
            object3D.name = name;
            object3D.filters = filters.concat();
            object3D.blendMode = blendMode;
            object3D.alpha = alpha;
            object3D.visible = visible;
            object3D.mouseEnabled = mouseEnabled;
            object3D.useHandCursor = useHandCursor;
            
            return object3D;
        }
        
        public function get destroyed():Boolean
		{
			return _isDestroyed;
		}

		public function destroy():void
		{
			_isDestroyed = true;
			
			materialLibrary.destroy();
			geometryLibrary.destroy();
			animationLibrary.destroy();

			materialLibrary = null;
			geometryLibrary = null;
			animationLibrary = null;

			if(parent != null)
				parent.removeChild(this);
		}
	}
}
