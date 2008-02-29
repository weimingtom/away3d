package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;
    
    import flash.utils.Dictionary;
    
    /** Mesh constisting of segments and segments */
    public class WireMesh extends BaseMesh implements IPrimitiveProvider
    {
        use namespace arcane;

        private var _segments:Array = [];

        public function get segments():Array
        {
            return _segments;
        }

        public override function get elements():Array
        {
            return _segments;
        }

        public var material:ISegmentMaterial;

        public function WireMesh(init:Object = null)
        {
            super(init);

            init = Init.parse(init);

            material = init.getSegmentMaterial("material");

            if (material == null)
                material = new WireframeMaterial();
        }

        public function addSegment(segment:Segment):void
        {
            addElement(segment);

            _segments.push(segment);
            
            segment._ds.source = segment.parent = this;
            segment._ds.create = createDrawSegment;
        }

        public function removeSegment(segment:Segment):void
        {
            var index:int = _segments.indexOf(segment);
            if (index == -1)
                return;

            removeElement(segment);

            _segments.splice(index, 1);
        }

        private function clear():void
        {
            for each (var segment:Segment in _segments.concat([]))
                removeSegment(segment);
        }

        override public function primitives(consumer:IPrimitiveConsumer, session:RenderSession):void
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
