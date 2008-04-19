package away3d.materials
{
	import away3d.core.draw.*;
	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	import flash.filters.*;
	import flash.geom.*;

	public class EnviroColorMaterial extends EnviroShader implements ITriangleMaterial
	{
		internal var _color:uint;
		internal var _red:Number;
		internal var _green:Number;
		internal var _blue:Number;
		internal var _colorMap:BitmapData;
		
		public function set color(val:uint):void
        {
            _color = val;
            _red = ((_color & 0xFF0000) >> 16)/255;
            _green = ((_color & 0x00FF00) >> 8)/255;
            _blue = (_color & 0x0000FF)/255;
            setColorTranform();
        }
		
        public function get color():uint
        {
            return _color;
        }
        
        public override function set reflectiveness(val:Number):void
        {
            _reflectiveness = val;
            setColorTranform();
        }
        
        private function setColorTranform():void
        {
            _colorTransform = new ColorTransform(_red*_reflectiveness, _green*_reflectiveness, _blue*_reflectiveness, 1, (1-_reflectiveness)*_red*255, (1-_reflectiveness)*_green*255, (1-_reflectiveness)*_blue*255, 0);
            _colorMap = _enviroMap.clone();
            _colorMap.colorTransform(_colorMap.rect, _colorTransform);
        }
        
		public function EnviroColorMaterial(enviroMap:BitmapData, init:Object)
		{
			super(enviroMap, init);
			
			init = Init.parse(init);
			
			color = init.getColor("color", 0xFFFFFF);
		}
		
		public function renderTriangle(tri:DrawTriangle):void
		{
			tri.source.session.renderTriangleBitmap(_colorMap, getMapping(tri.face.parent, tri.face), tri.v0, tri.v1, tri.v2, smooth, false);
			
			if (debug)
                tri.source.session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
		}
	}
}