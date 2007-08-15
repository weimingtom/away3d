// note Only the geometry and mapping of one mesh is currently parsed. Group is not supported yet.

// Class tested with the following 3D apps:
// - Strata CX mac 5.0 ok
// - Biturn ver 0.87b4 PC ok
// - LightWave 3D OBJ Export v2.1 PC ok
// - Max2Obj Version 4.0 PC --> ok, with no groups
// - tags f,v,vt are being parsed

// export from apps as polygon group or mesh as .obj file.

package away3d.loaders
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;

    import flash.net.URLRequest;
    import flash.net.URLLoader;
    import flash.events.EventDispatcher;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;

    public class Obj 
    {
        private var mesh:Mesh;
        private var scaling:Number;

        public function Obj(data:String, init:Object = null)
        {
            init = Init.parse(init);

            scaling = init.getNumber("scaling", 1) * 10;

            mesh = new Mesh(init);

            parseObj(data);
        }

        public static function parse(data:*, init:Object = null):Mesh
        {
            return new Obj(Cast.string(data), init).mesh;
        }
    
        public static function load(url:String, init:Object = null):Object3DLoader
        {
            return Object3DLoader.load(url, parse, false, init);
        }
    
        private function parseObj(data:String):void 
        {
            var lines:Array = data.split('\n');

            // zero start -> index start
            var vertices:Array = [new Vertex()];
            var uvs:Array = [new UV()];
            
            for each (var line:String in lines)
            {
                var trunk:Array = line.replace("  "," ").replace("  "," ").replace("  "," ").split(" ");
                switch (trunk[0])
                {
                    case "v":
                        // y and z swap
                        var x:Number =   parseFloat(trunk[1]) * scaling;
                        var y:Number = - parseFloat(trunk[3]) * scaling;
                        var z:Number =   parseFloat(trunk[2]) * scaling;
                        vertices.push(new Vertex(x, y, z));
                        break;
                    case "vt":
                        uvs.push(new UV(parseFloat(trunk[1]), parseFloat(trunk[2])));
                        break;
                    case "f":
                        var face0:Array = trysplit(trunk[1], "/");
                        var face1:Array = trysplit(trunk[2], "/");
                        var face2:Array = trysplit(trunk[3], "/");
                        var face3:Array = trysplit(trunk[4], "/");

                        if (face3 != null)
                        {
                            mesh.addFace(new Face(vertices[parseInt(face1[0])], vertices[parseInt(face0[0])], vertices[parseInt(face3[0])], 
                                             null, uvs[parseInt(face1[1])], uvs[parseInt(face0[1])], uvs[parseInt(face3[1])]));

                            mesh.addFace(new Face(vertices[parseInt(face2[0])], vertices[parseInt(face1[0])], vertices[parseInt(face3[0])], 
                                             null, uvs[parseInt(face2[1])], uvs[parseInt(face1[1])], uvs[parseInt(face3[1])]));
                        }
                        else
                        {
                            mesh.addFace(new Face(vertices[parseInt(face2[0])], vertices[parseInt(face1[0])], vertices[parseInt(face0[0])], 
                                             null, uvs[parseInt(face2[1])], uvs[parseInt(face1[1])], uvs[parseInt(face0[1])]));
                        }
                        break;
                    case "vn": // vector normal
                        break;
                    case "g": // group
                        break;
                }
            }
        }
            
        private static function trysplit(source:String, by:String):Array
        {
            if (source == null)
                return null;
            if (source.indexOf(by) == -1)
                return [source];
            return source.split(by);
        }
    }
}