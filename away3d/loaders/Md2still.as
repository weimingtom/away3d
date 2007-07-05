/**
 * @author Philippe Ajoux (philippe.ajoux@gmail.com)
 */
package away3d.loaders
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    import flash.utils.*;

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
        
        private var mesh:Mesh3D;
        private var scaling:Number;

        public function Md2still(data:ByteArray, material:IMaterial, init:Object = null)
        {
            init = Init.parse(init);

            scaling = init.getNumber("scaling", 1) * 100;

            mesh = new Mesh3D(material, init);

            parseMd2still(data);
        }
        
        public static function parse(data:*, material:* = null, init:Object = null):Mesh3D
        {
            var max:Md2still = new Md2still(Cast.bytearray(data), Cast.material(material), init);
            return max.mesh;
        }
    
        private function parseMd2still(data:ByteArray):void
        {
            data.endian = Endian.LITTLE_ENDIAN;

            var a:int, b:int, c:int, ta:int, tb:int, tc:int;
            var vertices:Array = mesh.vertices;
            var faces:Array = mesh.faces;
            var i:int, uvs:Array = new Array();
            
            // Make sure to have this in Little Endian or you will hate you life.
            // At least I did the first time I did this for a while.
            
            // Read the header and make sure it is valid MD2 file
            readMd2Header(data);
            if (ident != 844121161 || version != 8)
                throw new Error("Error loading MD2 file: Not a valid MD2 file/bad version");
                
            // Vertice setup
            //      Be sure to allocate memory for the vertices to the object
            //      These vertices will be updated each frame with the proper coordinates
            for (i = 0; i < num_vertices; i++)
                vertices.push(new Vertex3D());

            // UV coordinates
            //      Load them!
            data.position = offset_st;
            for (i = 0; i < num_st; i++)
                uvs.push(new NumberUV(data.readShort() / skinwidth, 1 - ( data.readShort() / skinheight) ));

            // Faces
            //      Creates the faces with the proper references to vertices
            //      NOTE: DO NOT change the order of the variable assignments here, 
            //            or nothing will work.
            data.position = offset_tris;
            for (i = 0; i < num_tris; i++)
            {
                a = data.readUnsignedShort();
                b = data.readUnsignedShort();
                c = data.readUnsignedShort();
                ta = data.readUnsignedShort();
                tb = data.readUnsignedShort();
                tc = data.readUnsignedShort();
                
                // Create and add the face
                faces.push(new Face3D
                (
                    vertices[a], vertices[b], vertices[c], null,
                    uvs[ta], uvs[tb], uvs[tc]
                ));
            }
            
            // Frame animation data
            //      This part is a little funky.
            data.position = offset_frames;
            readFrames(data);
        }
        
        /**
         * Reads in all the frames
         */
        private function readFrames(data:ByteArray):void
        {
            var sx:Number, sy:Number, sz:Number;
            var tx:Number, ty:Number, tz:Number;
            var i:int, j:int, char:int;
            
            for (i = 0; i < num_frames; i++)
            {
                var frame:Object = {name:""};
                
                sx = data.readFloat();
                sy = data.readFloat();
                sz = data.readFloat();
                
                tx = data.readFloat();
                ty = data.readFloat();
                tz = data.readFloat();
                
                for (j = 0; j < 16; j++)
                    if ((char = data.readUnsignedByte()) != 0)
                        frame.name += String.fromCharCode(char);
                
                // Note, the extra data.position++ in the for loop is there 
                // to skip over a byte that holds the "vertex normal index"
                for (j = 0; j < num_vertices; j++, data.position++)
                {
                    mesh.vertices[j].x = -((sx * data.readUnsignedByte()) + tx) * scaling;
                    mesh.vertices[j].z = ((sy * data.readUnsignedByte()) + ty) * scaling;
                    mesh.vertices[j].y = ((sz * data.readUnsignedByte()) + tz) * scaling;

                }
                break;
            }
        }
        
        /**
         * Reads in all that MD2 Header data that is declared as private variables.
         * I know its a lot, and it looks ugly, but only way to do it in Flash
         */
        private function readMd2Header(data:ByteArray):void
        {
            ident = data.readInt();
            version = data.readInt();
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
        }
    }
}