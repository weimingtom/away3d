package away3d.core.geom
{
    import away3d.core.*;
    import away3d.core.geom.*;
    import away3d.core.scene.*;
    
    /** Keyframe animation morpher */
    public class Morpher extends Object3D
    {
        public var weight:Number;
        public var vertices:Vertices3D;

        public function Morpher(vertices:Vertices3D)
        {
            this.vertices = vertices;
        }

        public function start():void
        {
            weight = 0;
            for each (var v:Vertex3D in vertices.vertices)
            {
                v.x = 0;
                v.y = 0;
                v.z = 0;
            }
        }

        public function mix(comp:Vertices3D, k:Number):void
        {
            weight += k;
            var length:int = vertices.vertices.length;
            for (var i:int = 0; i < length; i++)
            {
                vertices.vertices[i].x += comp.vertices[i].x * k;
                vertices.vertices[i].y += comp.vertices[i].y * k;
                vertices.vertices[i].z += comp.vertices[i].z * k;
            }
        }

        public function finish(comp:Vertices3D):void
        {
            mix(comp, 1 - weight);
            weight = 1;
        }

    }
}
