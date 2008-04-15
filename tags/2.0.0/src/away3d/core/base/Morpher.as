package away3d.core.base
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.base.*
    
    /** Keyframe animation morpher */
    public class Morpher extends Object3D
    {
        public var weight:Number;
        public var vertices:BaseMesh;

        public function Morpher(vertices:BaseMesh)
        {
            this.vertices = vertices;
        }

        public function start():void
        {
            weight = 0;
            for each (var v:Vertex in vertices.vertices)
            {
                v.x = 0;
                v.y = 0;
                v.z = 0;
            }
        }

        public function mix(comp:BaseMesh, k:Number):void
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

        public function finish(comp:BaseMesh):void
        {
            mix(comp, 1 - weight);
            weight = 1;
        }

    }
}
