package away3d.test;

    import flash.display.*;

    /**
    * Simple rounded rectangle panel
    */ 
    class Panel extends Shape {
        
        public function new(x: Int, y: Int, width: Int, height: Int, ?alpha:Float = 0.3)
        {
            graphics.clear();
            graphics.lineStyle(1, 0x000000, 0.5, true);
            graphics.beginFill(0xBBBBCC, alpha);
            graphics.drawRoundRect(0, 0, width-1, height-1, 7, 7);
            this.x = x;
            this.y = y;
        }
    }
