package away3d.core.math
{
    /** Quaternion */
    public final class Quaternion
    {
        public var x:Number;
        public var y:Number;
        public var z:Number;
        public var w:Number;
    }
    
    public static function multiply(qa:Quaternion, qb:Quaternion):Quaternion
    {
        var w1:Number = qa.w;  var x1:Number = qa.x;  var y1:Number = qa.y;  var z1:Number = qa.z;
        var w2:Number = qb.w;  var x2:Number = qb.x;  var y2:Number = qb.y;  var z2:Number = qb.z;
   
        var q:Quaternion = new Quaternion();
   
        q.w = w1*w2 - x1*x2 - y1*y2 - z1*z2;
        q.x = w1*x2 + x1*w2 + y1*z2 - z1*y2;
        q.y = w1*y2 + y1*w2 + z1*x2 - x1*z2;
        q.z = w1*z2 + z1*w2 + x1*y2 - y1*x2;
   
        return q;
    }
    
    public static function axis2quaternion(x:Number, y:Number, z:Number, angle:Number):Quaternion
    {
        var sin_a:Number = Math.sin(angle / 2);
        var cos_a:Number = Math.cos(angle / 2);
   
        var q:Quaternion = new Quaternion();
   
        q.x = x * sin_a;
        q.y = y * sin_a;
        q.z = z * sin_a;
        q.w = cos_a;
		q.normalize();
		
        return q;
    }
        
    public function get magnitude():Number
    {
        return(Math.sqrt(w*w + x*x + y*y + z*z));
    }
    
    public function normalize(val:Number = 1):void
    {
        var mag:Number = magnitude*val;
   
        x /= mag;
        y /= mag;
        z /= mag;
        w /= mag;
    }
}