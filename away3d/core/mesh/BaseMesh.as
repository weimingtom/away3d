package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;
    import away3d.objects.*;
    
    import flash.utils.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
    
    /** Base mesh constisting of elements */
    public class BaseMesh extends Object3D
    {
        use namespace arcane;

        public function get elements():Array
        {
            throw new Error("Not implemented");
        }

        private var _vertices:Array;
        private var _verticesDirty:Boolean = true;

        public function get vertices():Array
        {
            if (_verticesDirty)
            {
                _vertices = [];
                var processed:Dictionary = new Dictionary();
                for each (var element:IMeshElement in elements)
                    for each (var vertex:Vertex in element.vertices)
                        if (!processed[vertex])
                        {
                            _vertices.push(vertex);
                            processed[vertex] = true;
                        }
                _verticesDirty = false;
            }
            return _vertices;
        }

        private var _radiusElement:IMeshElement = null;
        private var _radiusDirty:Boolean = false;
        private var _radius:Number = 0;

        public override function get radius():Number
        {
            if (_radiusDirty)
            {
                _radiusElement = null;
                var mr:Number = 0;
                for each (var element:IMeshElement in elements)
                {
                    var r2:Number = element.radius2;
                    if (r2 > mr)
                    {
                        mr = r2;
                        _radiusElement = element;
                    }
                }
                _radius = Math.sqrt(mr);
                _radiusDirty = false;
            }
            return _radius;
        }

        private var _maxXElement:IMeshElement = null;
        private var _maxXDirty:Boolean = false;
        private var _maxX:Number = -Infinity;

        public override function get maxX():Number
        {
            if (_maxXDirty)
            {
                _maxXElement = null;
                var extrval:Number = -Infinity;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.maxX;
                    if (val > extrval)
                    {
                        extrval = val;
                        _maxXElement = element;
                    }
                }
                _maxX = extrval;
                _maxXDirty = false;
            }
            return _maxX;
        }

        private var _minXElement:IMeshElement = null;
        private var _minXDirty:Boolean = false;
        private var _minX:Number = Infinity;

        public override function get minX():Number
        {
            if (_minXDirty)
            {
                _minXElement = null;
                var extrval:Number = Infinity;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.minX;
                    if (val < extrval)
                    {
                        extrval = val;
                        _minXElement = element;
                    }
                }
                _minX = extrval;
                _minXDirty = false;
            }
            return _minX;
        }

        private var _maxYElement:IMeshElement = null;
        private var _maxYDirty:Boolean = false;
        private var _maxY:Number = -Infinity;

        public override function get maxY():Number
        {
            if (_maxYDirty)
            {
                var extrval:Number = -Infinity;
                _maxYElement = null;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.maxY;
                    if (val > extrval)
                    {
                        extrval = val;
                        _maxYElement = element;
                    }
                }
                _maxY = extrval;
                _maxYDirty = false;
            }
            return _maxY;
        }

        private var _minYElement:IMeshElement = null;
        private var _minYDirty:Boolean = false;
        private var _minY:Number = Infinity;

        public override function get minY():Number
        {
            if (_minYDirty)
            {
                var extrval:Number = Infinity;
                _minYElement = null;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.minY;
                    if (val < extrval)
                    {
                        extrval = val;
                        _minYElement = element;
                    }
                }
                _minY = extrval;
                _minYDirty = false;
            }
            return _minY;
        }

        private var _maxZElement:IMeshElement = null;
        private var _maxZDirty:Boolean = false;
        private var _maxZ:Number = -Infinity;

        public override function get maxZ():Number
        {
            if (_maxZDirty)
            {
                var extrval:Number = -Infinity;
                _maxZElement = null;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.maxZ;
                    if (val > extrval)
                    {
                        extrval = val;
                        _maxZElement = element;
                    }
                }
                _maxZ = extrval;
                _maxZDirty = false;
            }
            return _maxZ;
        }

        private var _minZElement:IMeshElement = null;
        private var _minZDirty:Boolean = false;
        private var _minZ:Number = Infinity;

        public override function get minZ():Number
        {
            if (_minZDirty)
            {
                var extrval:Number = Infinity;
                _minZElement = null;
                for each (var element:IMeshElement in elements)
                {
                    var val:Number = element.minZ;
                    if (val < extrval)
                    {
                        extrval = val;
                        _minZElement = element;
                    }
                }
                _minZ = extrval;
                _minZDirty = false;
            }
            return _minZ;
        }

        public var pushback:Boolean;
        public var pushfront:Boolean;

        public function BaseMesh(init:Object = null)
        {
            super(init);

            init = Init.parse(init);
            
            pushback = init.getBoolean("pushback", false);
            pushfront = init.getBoolean("pushfront", false);
        }
    
        public override function scale(scale:Number):void
        {
            scaleXYZ(scale, scale, scale);
        }

        public function scaleX(scaleX:Number):void
        {
            if (scaleX != 1)
                scaleXYZ(scaleX, 1, 1);
        }
    
        public function scaleY(scaleY:Number):void
        {
            if (scaleY != 1)
                scaleXYZ(1, scaleY, 1);
        }
    
        public function scaleZ(scaleZ:Number):void
        {
            if (scaleZ != 1)
                scaleXYZ(1, 1, scaleZ);
        }

        protected function scaleXYZ(scaleX:Number, scaleY:Number, scaleZ:Number):void
        {
            for each (var vertex:Vertex in vertices)
            {
                vertex.x *= scaleX;
                vertex.y *= scaleY;
                vertex.z *= scaleZ;
            }
        }

        protected function addElement(element:IMeshElement):void
        {
            _verticesDirty = true;
                              
            element.addOnVertexChange(onElementVertexChange);
            element.addOnVertexValueChange(onElementVertexValueChange);
                                                
            rememberElementRadius(element);

            launchNotifies();
        }

        protected function removeElement(element:IMeshElement):void
        {
            forgetElementRadius(element);

            element.removeOnVertexValueChange(onElementVertexValueChange);
            element.removeOnVertexChange(onElementVertexChange);

            _verticesDirty = true;

            launchNotifies();
        }
		
		override public function primitives(consumer:IPrimitiveConsumer, session:RenderSession):void
        {
        	super.primitives(consumer, session);
        	_dsStore = _dsStore.concat(_dsActive);
        	_dsActive = new Array();
        }
        
        private var _needNotifyRadiusChange:Boolean = false;
        private var _needNotifyDimensionsChange:Boolean = false;

        private function launchNotifies():void
        {
            if (_needNotifyRadiusChange)
            {
                _needNotifyRadiusChange = false;
                notifyRadiusChange();
            }
            if (_needNotifyDimensionsChange)
            {
                _needNotifyDimensionsChange = false;
                notifyDimensionsChange();
            }
        }

        private function rememberElementRadius(element:IMeshElement):void
        {
            var r2:Number = element.radius2;
            if (r2 > _radius*_radius)
            {
                _radius = Math.sqrt(r2);
                _radiusElement = element;
                _radiusDirty = false;
                _needNotifyRadiusChange = true;
            }
            var mxX:Number = element.maxX;
            if (mxX > _maxX)
            {
                _maxX = mxX;
                _maxXElement = element;
                _maxXDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mnX:Number = element.minX;
            if (mnX < _minX)
            {
                _minX = mnX;
                _minXElement = element;
                _minXDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mxY:Number = element.maxY;
            if (mxY > _maxY)
            {
                _maxY = mxY;
                _maxYElement = element;
                _maxYDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mnY:Number = element.minY;
            if (mnY < _minY)
            {
                _minY = mnY;
                _minYElement = element;
                _minYDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mxZ:Number = element.maxZ;
            if (mxZ > _maxZ)
            {
                _maxZ = mxZ;
                _maxZElement = element;
                _maxZDirty = false;
                _needNotifyDimensionsChange = true;
            }
            var mnZ:Number = element.minZ;
            if (mnZ < _minZ)
            {
                _minZ = mnZ;
                _minZElement = element;
                _minZDirty = false;
                _needNotifyDimensionsChange = true;
            }
        }

        private function forgetElementRadius(element:IMeshElement):void
        {
            if (element == _radiusElement)
            {
                _radiusElement = null;
                _radiusDirty = true;
                _needNotifyRadiusChange = true;
            }
            if (element == _maxXElement)
            {
                _maxXElement = null;
                _maxXDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _minXElement)
            {
                _minXElement = null;
                _minXDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _maxYElement)
            {
                _maxYElement = null;
                _maxYDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _minYElement)
            {
                _minYElement = null;
                _minYDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _maxZElement)
            {
                _maxZElement = null;
                _maxZDirty = true;
                _needNotifyDimensionsChange = true;
            }
            if (element == _minZElement)
            {
                _minZElement = null;
                _minZDirty = true;
                _needNotifyDimensionsChange = true;
            }
        }

        private function onElementVertexChange(event:MeshElementEvent):void
        {
            var element:IMeshElement = event.element;

            forgetElementRadius(element);
            rememberElementRadius(element);

            _verticesDirty = true;

            launchNotifies();
        }

        private function onElementVertexValueChange(event:MeshElementEvent):void
        {
            var element:IMeshElement = event.element;
            forgetElementRadius(element);
            rememberElementRadius(element);
            launchNotifies();
        }

        private function clear():void
        {
            throw new Error("Not implemented");
        }

   		public var frames:Dictionary;
        public var framenames:Dictionary;
        private var _frame:int;

        public function get frame():int
        {
            return animation.frame;
        }

        public function set frame(value:int):void
        {
            if (animation.frame == value)
                return;
			_frame = value;
            animation.frame = value;
            frames[value].adjust(1);
        }
		
		private var _playsequence:Object;
		
		public function gotoAndPlay(value:int):void
		{
			animation.frame = value;
			_frame = value;
			
			if(!animation.run){
				animation.start();
			}
		}
		
		public function gotoAndStop(value:int):void
		{
			animation.frame = value;
			_frame = value;
			if(animation.run){
				animation.stop();
			}
		}
		
		public function setPlaySequences(aPlaylist:Array, loopLast:Boolean = false):void
		{
			if(aPlaylist.length == 0)
				return;
			
			play(aPlaylist.shift());
			
			if(!animation.hasEventListener("CYCLE")){
				_playsequence = new Object();
				_playsequence.playlist = aPlaylist; 
				_playsequence.loopLast = loopLast;
				loop = true;
				animation.addEventListener("CYCLE", updatePlaySequence);
			}
		}
		
		private function updatePlaySequence(e:Event):void
		{
			if(_playsequence.playlist.length == 0){
				animation.removeEventListener("CYCLE", updatePlaySequence);
				if (sequencedone == null)
                	sequencedone = new Event("SEQUENCE_DONE");
				
				dispatchEvent(sequencedone);
			}
			play(_playsequence.playlist.shift());
			
			if(cycle != null)
				dispatchEvent(cycle);
			
		}
		
		private var sequencedone:Event;
		private var cycle:Event;
		
		public function onSequenseDone(listener:Function):void
        {
            addEventListener("SEQUENCE_DONE", listener, false, 0, false);
        }
		
		public function removeOnSequenceDone(listener:Function):void
        {
            removeEventListener("SEQUENCE_DONE", listener, false);
        }
		
		public function onCycleDone(listener:Function):void
        {
			cycle = new Event("CYCLE_DONE");
            addEventListener("CYCLE_DONE", listener, false, 0, false);
        }
		
		public function removeOnCycleDone(listener:Function):void
        {
			cycle = null;
            removeEventListener("CYCLE_DONE", listener, false);
        }
		
		public function set fps(value:int):void
		{
			animation.fps = (value>=1)? value : 1;
		}
		public function set loop(loop:Boolean):void
		{
			animation.loop = loop;
		}
		public function set smooth(smooth:Boolean):void
		{
			animation.smooth = smooth;
		}
		public function get running():Boolean
		{
			return animation.run;
		}
		
        public override function tick(time:int):void
        {
            if ((animation != null) && (frames != null))
                animation.update(this);
        }

        public var animation:Animation;
		
		public function scaleAnimation(val:Number):void
		{
			var tmpnames:Array = new Array();
			var i:int = 0;
			var y:int = 0;
			for (var framename:String in framenames){
				tmpnames.push(framename);
			}				
			var fr:Frame;
			for (i = 0;i<tmpnames.length;i++){
				fr = frames[framenames[tmpnames[i]]];
				for(y = 0; y<fr.vertexpositions.length ;y++){
					fr.vertexpositions[y].x *= val;
					fr.vertexpositions[y].y *= val;
					fr.vertexpositions[y].z *= val;
				}
			}				
		}
		
        public function play(init:Object = null):void
        {
            init = Init.parse(init);
            var fps:Number = init.getNumber("fps", 24);
            var prefix:String = init.getString("prefix", null);
            var smooth:Boolean = init.getBoolean("smooth", false);
            var loop:Boolean = init.getBoolean("loop", false);
			
			if(!animation){
            	animation = new Animation(); 
			} else{
				animation.sequence = new Array();
			}
			
            animation.fps = fps;
            animation.smooth = smooth;
            animation.loop = loop;
			
            if (prefix != null){
				var bvalidprefix:Boolean;
                for (var framename:String in framenames){
                    if (framename.indexOf(prefix) == 0){
						bvalidprefix = true;
                        animation.sequence.push(new AnimationFrame(framenames[framename], ""+parseInt(framename.substring(prefix.length))));
					}
				}
				
				if(bvalidprefix){
					animation.sequence.sortOn("sort", Array.NUMERIC );            
					frames[_frame].adjust(1);
					animation.start();
				} else{
					trace("--------- \n--> unable to play animation: unvalid prefix ["+prefix+"]\n--------- ");
				}
			}
        }
        
        internal var seg:DrawSegment;
        protected var _dsStore:Array = new Array();
        protected var _dsActive:Array = new Array();
        
        public function createDrawSegment(material:ISegmentMaterial, projection:Projection, v0:ScreenVertex, v1:ScreenVertex):DrawSegment
        {
            if (_dsStore.length) {
            	_dsActive.push(seg = _dsStore.pop());
            	seg.create = createDrawSegment;
        	} else {
            	_dsActive.push(seg = new DrawSegment());
	            seg.source = this;
	            seg.create = createDrawSegment;
            }
            seg.material = material;
            seg.projection = projection;
            seg.v0 = v0;
            seg.v1 = v1;
            seg.calc();
            return seg;
        }
                        
        //stats variables
       	public var url:String;
       	public var type:String;
    }
}
                                