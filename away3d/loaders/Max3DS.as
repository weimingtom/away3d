package away3d.loaders
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;
    
    import flash.utils.*;

   /**
    * @author Philippe Ajoux (philippe.ajoux@gmail.com)
    */
    public class Max3DS
    {
        private var mesh:Mesh;
        private var scaling:Number;

        public function Max3DS(data:ByteArray, init:Object = null)
        {
            init = Init.parse(init);

            scaling = init.getNumber("scaling", 1) * 100;

            mesh = new Mesh(init);

            parse3DS(data);
        }
        
        public static function parse(data:*, init:Object = null):Mesh
        {
            return new Max3DS(Cast.bytearray(data), init).mesh;
        }
    
        public static function load(url:String, init:Object = null):Object3DLoader
        {
            return Object3DLoader.load(url, parse, true, init);
        }
    
        private function parse3DS(data:ByteArray):void
        {
            data.endian = Endian.LITTLE_ENDIAN;

            var vertices:Array = [];
            var faces:Array = [];
            var uvs:Array = [];
            
            var i:uint;
            var size:uint;
            
            while (data.bytesAvailable > 0)
            {
                var chunkID:int = data.readUnsignedShort();
                var chunkLength:uint = data.readUnsignedInt();
                
                switch (chunkID)
                {
                    // MAIN_CHUNK, EDITOR_CHUNK, TRIANGLE_MESH_BLOCK (ignored)
                    case 0x4d4d: break;
                    case 0x3d3d: break;
                    case 0x4100: break;
                    
                    // OBJECT_BLOCK
                    case 0x4000:
                        mesh.name = "";
                        while ((size = data.readByte()) != 0)
                            mesh.name += String.fromCharCode(size);
                        break;
                    
                    // VERTEX_BLOCK 
                    case 0x4110:
                        size = data.readUnsignedShort();
                        for (i = 0; i < size; i++)
                            vertices.push(new Vertex(data.readFloat() * scaling, data.readFloat() * scaling, data.readFloat() * scaling));
                        break;
                        
                    // FACE_BLOCK
                    case 0x4120:
                        size = data.readUnsignedShort();
                        for (i = 0; i < size; i++)
                            faces.push(
                            {
                                a: data.readUnsignedShort(),
                                b: data.readUnsignedShort(),
                                c: data.readUnsignedShort(),
                                flags: data.readUnsignedShort()
                            });
                        break;
                    
                    // TEXTURE_VERTEX_BLOCK
                    case 0x4140:
                        size = data.readUnsignedShort();
                        for (i = 0; i < size; i++)
                            uvs.push(new UV(data.readFloat(), data.readFloat()));
                        break;
                            
                    // Other blocks are just skipped completely by their length
                    default:
                        data.position += chunkLength - 6;
                }
            }

            // Actually add the faces with the proper UV coordinate texturing
            // NOTE: We actually support loading files that have no texturing!
            for each (var face:Object in faces)
                mesh.addFace(new Face(vertices[face.c], vertices[face.b], vertices[face.a], null, uvs[face.c], uvs[face.b], uvs[face.a]));
        }
    }
}