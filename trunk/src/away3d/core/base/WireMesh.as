package away3d.core.base
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.materials.*;
    import away3d.core.render.*;
    import away3d.core.base.*;
    import away3d.core.utils.*;
    
    /**
    * 3d object containing segment elements 
    */
    public class WireMesh extends BaseMesh implements IPrimitiveProvider
    {
        use namespace arcane;
        
        private var _segments:Array = [];
        
        //TODO: create effective dispose mechanism for wiremeshes
        /*        
        private function clear():void
        {
            for each (var segment:Segment in _segments.concat([]))
                removeSegment(segment);
        }
		*/
		
		/**
		 * Returns an array of the segments contained in the wiremesh object.
		 */
        public function get segments():Array
        {
            return _segments;
        }
		
		/**
		 * Returns an array of the elements contained in the wiremesh object.
		 */
        public override function get elements():Array
        {
            return _segments;
        }
		/**
		 * Defines the material used to render the segments in the wiremesh object.
		 * Individual material settings on segments will override this setting.
		 * 
		 * @see away3d.core.base.Segment#material
		 */
        public var material:ISegmentMaterial;
    	
		/**
		 * Creates a new <code>WireMesh</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
        public function WireMesh(init:Object = null)
        {
            super(init);
            
            material = ini.getSegmentMaterial("material");

            if (material == null)
                material = new WireframeMaterial();
        }
		
		/**
		 * Adds a segment object to the wiremesh object.
		 * 
		 * @param	segment	The segment object to be added.
		 */
        public function addSegment(segment:Segment):void
        {
            addElement(segment);

            _segments.push(segment);
            
            segment._ds.source = segment.parent = this;
            segment._ds.create = createDrawSegment;
        }
		
		/**
		 * Removes a segment object to the wiremesh object.
		 * 
		 * @param	segment	The segment object to be removed.
		 */
        public function removeSegment(segment:Segment):void
        {
            var index:int = _segments.indexOf(segment);
            if (index == -1)
                return;

            removeElement(segment);

            _segments.splice(index, 1);
        }
        
		/**
		 * @inheritDoc
    	 * 
    	 * @see	away3d.core.traverse.PrimitiveTraverser
    	 * @see	away3d.core.draw.DrawSegment
		 */
        override public function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void
        {
        	super.primitives(consumer, session);
        	
            var seg:DrawSegment;
            for each (var segment:Segment in _segments)
            {
                seg = segment._ds;

                seg.v0 = segment._v0.project(projection);
                seg.v1 = segment._v1.project(projection);
    
                if (!seg.v0.visible)
                    continue;

                if (!seg.v1.visible)
                    continue;

                seg.calc();

                if (seg.maxZ < 0)
                    continue;

                seg.material = segment.material || material;

                if (seg.material == null)
                    continue;

                if (!seg.material.visible)
                    continue;
                
                seg.projection = projection;
                consumer.primitive(seg);
            }
        }
    }
}
