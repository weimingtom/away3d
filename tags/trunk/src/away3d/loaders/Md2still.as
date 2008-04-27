package away3d.loaders
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.base.*
    import away3d.core.base.*;
    import away3d.materials.*;
    import away3d.core.utils.*;
    import away3d.core.stats.*;
    import flash.utils.*;

   /**
    * @author Philippe Ajoux (philippe.ajoux@gmail.com)
    */
    public class Md2still
    {
        private var ident:int;
        private var version:int;
        private var skinwidth:int;
        private var skinheight:int;
        private var framesize:int;
        private var num_skins:int;
        private var num_vertices:int;
        private var num_st:int;
        private var num_tris:int;
        private var num_glcmds:int;
        private var num_frames:int;
        private var offset_skins:int;
        private var offset_st:int;
        private var offset_tris:int;
        private var offset_frames:int;
        private var offset_glcmds:int;
        private var offset_end:int;
        private var mesh:Mesh;
        private var scaling:Number;

        public function Md2still(data:ByteArray, init:Object = null)
        {
            init = Init.parse(init);

            scaling = init.getNumber("scaling", 1) * 100;

            mesh = new Mesh(init);

            parseMd2still(data);
        }
        
        public static function parse(data:*, init:Object = null, loader:Object3DLoader = null):Mesh
        {
            return new Md2still(Cast.bytearray(data), init).mesh;
        }
    
        public static function load(url:String, init:Object = null):Object3DLoader
        {
            return Object3DLoader.loadGeometry(url, parse, true, init);
        }
    
        private function parseMd2still(data:ByteArray):void
        {
            data.endian = Endian.LITTLE_ENDIAN;

            var vertices:Array = [];
            var faces:Array = [];
            var uvs:Array = [];
            
            ident = data.readInt();
            version = data.readInt();

            // Make sure it is valid MD2 file
            if (ident != 844121161 || version != 8)
                throw new Error("Error loading MD2 file: Not a valid MD2 file/bad version");
                
            skinwidth = data.readInt();
            skinheight = data.readInt();
            framesize = data.readInt();
            num_skins = data.readInt();
            num_vertices = data.readInt();
            num_st = data.readInt();
            num_tris = data.readInt();
            num_glcmds = data.readInt();
            num_frames = data.readInt();
            offset_skins = data.readInt();
            offset_st = data.readInt();
            offset_tris = data.readInt();
            offset_frames = data.readInt();
            offset_glcmds = data.readInt();
            offset_end = data.readInt();

            var i:int;
            // Vertice setup
            //      Be sure to allocate memory for the vertices to the object
            //      These vertices will be updated each frame with the proper coordinates
            for (i = 0; i < num_vertices; i++)
                vertices.push(new Vertex());

            // UV coordinates
            data.position = offset_st;
            for (i = 0; i < num_st; i++)
                uvs.push(new UV(data.readShort() / skinwidth, 1 - ( data.readShort() / skinheight) ));

            // Faces
            data.position = offset_tris;
            for (i = 0; i < num_tris; i++)
            {
                var a:int = data.readUnsignedShort();
                var b:int = data.readUnsignedShort();
                var c:int = data.readUnsignedShort();
                var ta:int = data.readUnsignedShort();
                var tb:int = data.readUnsignedShort();
                var tc:int = data.readUnsignedShort();
                
                mesh.addFace(new Face(vertices[a], vertices[b], vertices[c], null, uvs[ta], uvs[tb], uvs[tc]));
            }
            
            // Frame animation data
            //      This part is a little funky.
            data.position = offset_frames;
            readFrames(data, vertices, num_frames);
            
            mesh.type = ".Md2";
        }
        
        private function readFrames(data:ByteArray, vertices:Array, num_frames:int):void
        {
            for (var i:int = 0; i < num_frames; i++)
            {
                var frame:Object = {name:""};
                
                var sx:Number = data.readFloat();
                var sy:Number = data.readFloat();
                var sz:Number = data.readFloat();
                
                var tx:Number = data.readFloat();
                var ty:Number = data.readFloat();
                var tz:Number = data.readFloat();

                for (var j:int = 0; j < 16; j++)
                {
                    var char:int = data.readUnsignedByte();
                    if (char != 0)
                        frame.name += String.fromCharCode(char);
                }
                
                for (var h:int = 0; h < vertices.length; h++)
                {
                    vertices[h].x = -((sx * data.readUnsignedByte()) + tx) * scaling;
                    vertices[h].z = ((sy * data.readUnsignedByte()) + ty) * scaling;
                    vertices[h].y = ((sz * data.readUnsignedByte()) + tz) * scaling;
                    data.readUnsignedByte(); // "vertex normal index"
                }
                break; // only 1st frame for now
            }
        }
        
    }
}