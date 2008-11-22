package away3d.containers;

	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.core.render.*;
	import away3d.core.traverse.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
    
	use namespace arcane;
	
    /**
    * The root container of all 3d objects in a single scene
    */
    class Scene3D extends ObjectContainer3D {
		public var sceneTransform(getSceneTransform, null) : Matrix3D
        ;
		/** @private */
        
		/** @private */
        arcane function internalRemoveView(view:View3D):Void
        {
        	view.removeEventListener(ViewEvent.UPDATE_SCENE, onUpdate);
        }
		/** @private */
        arcane function internalAddView(view:View3D):Void
        {
        	view.addEventListener(ViewEvent.UPDATE_SCENE, onUpdate);
        }
        
        var _view:View3D;
        var _currentView:View3D;
        var _mesh:Mesh;
        var _time:Int;
        var _autoUpdate:Bool;
        var _projtraverser:ProjectionTraverser ;
        var _sessiontraverser:SessionTraverser ;
        var _lighttraverser:LightTraverser ;
        
        function onUpdate(event:ViewEvent):Void
        {
        	if (autoUpdate) {
        		
        		if (_currentView && _currentView != event.view)
        			Debug.warning("Multiple views detected! Should consider switching to manual update");
        		
        		_currentView = event.view;
        		
        		update();
        	}
        }
        
        public var viewDictionary:Dictionary ;
        
		/**
		 * Traverser object for all custom <code>tick()</code> methods
		 * 
		 * @see away3d.core.base.Object3D#tick()
		 */
        public var tickTraverser:TickTraverser ;
        
        /**
        * Library of updated 3d objects in the scene.
        */
        public var updatedObjects:Dictionary;
        
        /**
        * Library of updated sessions in the scene.
        */
        public var updatedSessions:Dictionary;
        
        /**
        * Library of  all meshes in the scene.
        */
        public var meshes:Dictionary;
        
        /**
        * Defines whether scene events are automatically triggered by the view, or manually by <code>updateScene()</code>
        */
		public var autoUpdate:Bool;
        
    	/**
    	 * Interface for physics (not implemented)
    	 */
        public var physics:IPhysicsScene;
        
		/**
		 * @inheritDoc
		 */
        public override function getSceneTransform():Matrix3D
        {
        	if (_transformDirty)
        		 _sceneTransformDirty = true;
			
        	if (_sceneTransformDirty)
        		notifySceneTransformChange();
        	
            return transform;
        }
    	
		/**
		 * Creates a new <code>Scene3D</code> object
		 * 
	    * @param	...initarray		An array of 3d objects to be added as children of the scene on instatiation. Can contain an initialisation object
		 */
        public function new(initarray:Array<Dynamic>)
        {
            
            _projtraverser = new ProjectionTraverser();
            _sessiontraverser = new SessionTraverser();
            _lighttraverser = new LightTraverser();
            viewDictionary = new Dictionary(true);
            tickTraverser = new TickTraverser();
            var init:Dynamic;
            var childarray:Array<Dynamic> = [];
            
            for each (var object:Dynamic in initarray)
            	if (Std.is( object, Object3D))
            		childarray.push(object);
            	else
            		init = object;
			
			//force ownCanvas and ownLights
			if (init) {
				init.ownCanvas = true;
				init.ownLights = true;
			} else {
				init = {ownCanvas:true, ownLights:true};
            }
            
            super(init);
			
			autoUpdate = ini.getBoolean("autoUpdate", true);
			
            var ph:Dynamic = ini.getObject("physics");
            if (Std.is( ph, IPhysicsScene))
                physics = cast( ph, IPhysicsScene);
            if (Std.is( ph, Boolean))
                if (ph == true)
                    physics = null; // new RobPhysicsEngine();
            if (Std.is( ph, Object))
                physics = null; // new RobPhysicsEngine(ph); // ph - init object
                
            for each (var child:Object3D in childarray)
                addChild(child);
        }
		
		/**
		 * Calling manually will update scene specific variables
		 */
        public function update():Void
        {
        	//clear updated objects
        	updatedObjects = new Dictionary(true);
        	
        	//clear updated sessions
        	updatedSessions = new Dictionary(true);
        	
        	//traverse lights
			traverse(_lighttraverser);
				
        	//execute projection traverser on each view
        	for (_view in viewDictionary) {
        		
	        	//clear meshes
	        	meshes = new Dictionary(true);
	        	
	        	//clear camera view transforms
	        	_view.camera.clearViewTransforms();
	        	
	        	//clear blockers
	        	_view.blockerarray.clip = _view.clip;
	        	
	        	//traverse scene
        		_projtraverser.view = _view;
				traverse(_projtraverser);
	        	
	        	_time = getTimer();
	        	
	        	//update materials in meshes
	        	for (_mesh in meshes) {
	        		//update node materials
		        	_mesh.updateMaterials(_mesh, _view);
		        	//update geometry materials
		        	_mesh.geometry.updateMaterials(_mesh, _view);
		        	//update elements
	        		_mesh.geometry.updateElements(_time);
	        	}
        	}
        	
        	//traverse sessions
			traverse(_sessiontraverser);
        }
		
		/**
		 * Calling manually will update 3d objects that execute updates on their <code>tick()</code> methods.
		 * Uses the <code>TickTraverser</code> to traverse all tick methods in the scene.
		 * 
		 * @see	away3d.core.base.Object3D#tick()
		 * @see	away3d.core.traverse.TickTraverser
		 */
        public function updateTime(?time:Int = -1):Void
        {
        	//set current time
            if (time == -1)
                time = getTimer();
            
            //traverser scene ticks
            tickTraverser.now = time;
            traverse(tickTraverser);
            
            
            if (physics != null)
                physics.updateTime(time);
        }
    }
