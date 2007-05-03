package away3d.core.render
{
    import away3d.core.*;
    import away3d.core.math.*;

    public class Projection
    {
        public var n11:Number;     
        public var n12:Number;     
        public var n13:Number;     
        public var n14:Number;
        public var n21:Number;     
        public var n22:Number;     
        public var n23:Number;     
        public var n24:Number;
        public var n31:Number;     
        public var n32:Number;     
        public var n33:Number;     
        public var n34:Number;

        public var focus:Number;
        public var zoom:Number;

        public function Projection(view:Matrix3D, focus:Number, zoom:Number)
        {
            this.n11 = view.n11;   
            this.n12 = view.n12;   
            this.n13 = view.n13;   
            this.n14 = view.n14;
            this.n21 = view.n21;   
            this.n22 = view.n22;   
            this.n23 = view.n23;   
            this.n24 = view.n24;
            this.n31 = view.n31;   
            this.n32 = view.n32;   
            this.n33 = view.n33;   
            this.n34 = view.n34;
            this.focus = focus;
            this.zoom = zoom;
        }
    }
}
