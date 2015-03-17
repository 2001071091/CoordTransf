package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.setInterval;
	/**
	 * ...
	 * @author 
	 */
	public class Main2 extends Sprite 
	{
		
		public function Main2():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			setInterval(loop, 125);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		private function onMouseMove(event:MouseEvent):void {
			angle = Math.PI * 2 * (stage.mouseX / stage.stageWidth);
			angle2 =Math.PI * 2 * (stage.mouseY / stage.stageHeight);
		}
		
		private var angle:Number = 0;
		private var angle2:Number = 0;
		private function loop():void {
			//angle += 0.1;
			var r:Number = 84;
			var y:Number = Math.sin(angle2) * r;
			var r2:Number = Math.cos(angle2) * r;
			var x:Number = Math.cos(angle) * r2;
			var z:Number = Math.sin(angle) * r2;
			
			EYE[0] = x;
			EYE[1] = y;
			EYE[2] = z;
			draw();
		}
		
			/**
			 * 定义VRC,观察坐标系
			 */
			var EYE:Array = [8, 8, 84];//投影平面原点(WC)
			var LOOK:Array = [0, 0, 0];//投影平面法线(WC)
			var VUP:Array = [0, 1, 0];//上方向向量(WC)
			var FOVY:Number = 60;//视角,ZY平面的视角
			var ASPECT:Number = 1;//纵横比
			var Z_Near = 1;
			var Z_Far = 40;
			
			private function getAngle(x:Number, y:Number):Number {
				var a:Number = Math.acos(x / Math.sqrt(x * x +y * y));
				//3,4象限
				if (y < 0) {
					a = Math.PI * 2 - a;
				}
				return a * (180 / Math.PI);
			}
		
		private function draw():void {
//WC (word coordinate)世界坐标系
			//VRC (viewing-reference coordinate)观察坐标系 由VRP,VPN,VUP构造的一个右手坐标系
			var points:Array = [
				new Vector3D(0, 0, 30),
				new Vector3D(0, 10, 30),
				new Vector3D(8, 16, 30),
				new Vector3D(16, 10, 30),
				new Vector3D(16, 0, 30),
				new Vector3D(0, 0, 54),
				new Vector3D(0, 10, 54),
				new Vector3D(8, 16, 54),
				new Vector3D(16, 10, 54),
				new Vector3D(16,0,54)
			];//模型的顶点坐标(WC)
			
			var VPN:Array = [EYE[0] - LOOK[0], EYE[1] - LOOK[1], EYE[2] - LOOK[2]];
			var top:Number = Math.tan((FOVY / 2) * (Math.PI / 180)) * Z_Near;
			var WINDOW:Array = [
			-top*ASPECT//Umin
			,top*ASPECT//Umax
			,-top//Vmin
			,top//Vmax
			]
			
			
			/**
			 * 生成世界坐标系到观察坐标系的变换矩阵
			 */
			var m:Matrix3D = new Matrix3D();
			m.appendTranslation(-EYE[0], -EYE[1], -EYE[2]);//平移
			var a:Number, i:int;
			if (VPN[0] != 0) {//Y轴旋转
				a = getAngle(VPN[0], VPN[2]) - 90;
				m.appendRotation(a, Vector3D.Y_AXIS, null);
			}
			if (VPN[2] != 0) {//X轴旋转
				a = getAngle(Math.sqrt(VPN[0] * VPN[0]+VPN[2] * VPN[2]), VPN[1]);
				m.appendRotation(a, Vector3D.X_AXIS, null);
			}
			//TODO 处理VUP,使用Z轴旋转
			//VPN叉乘VUP,和VPN叉乘Y轴正方向的两个向量的夹角就是Z轴需要旋转的角度
			
			//将模型变换到观察坐标系
			trace("观察坐标系----------");
			for (i = 0; i < points.length; i++ ) {
				points[i] = m.transformVector(points[i]);
				trace("point["+i+"]:"+points[i]);
			}
			
			//生成NDC
			trace("NDC坐标---------");
			for (i = 0; i < points.length; i++ ) {	
				a = ( -Z_Near) / points[i].z;
				points[i].x *= a;
				points[i].y *= a;

				//trace("point[" + i + "]:" + points[i]);
				//规格化
				points[i].x /= (WINDOW[1] - WINDOW[0]) / 2;
				points[i].y /= (WINDOW[3] - WINDOW[2]) / 2;
				trace("point[" + i + "]:" + points[i]);
			}
			
			//NDC到视口
			trace("视口坐标---------");
			var viewport:Array = [100, 100, 200, 200];
			for (i = 0; i < points.length; i++ ) {
				points[i].x = points[i].x * (viewport[2] / 2) + (viewport[2] / 2) + viewport[0];
				points[i].y = -points[i].y * (viewport[3] / 2) + (viewport[3] / 2) + viewport[1];
				trace("point[" + i + "]:" + points[i]);
			}
			
			//绘制
			graphics.clear();
			graphics.lineStyle(1, 0, 1);
			graphics.moveTo(viewport[0], viewport[1]);
			graphics.lineTo(viewport[0]+viewport[2], viewport[1]);
			graphics.lineTo(viewport[0]+viewport[2], viewport[1]+viewport[3]);
			graphics.lineTo(viewport[0], viewport[1]+viewport[3]);
			graphics.lineTo(viewport[0], viewport[1]);
			
			graphics.lineStyle(1,0xFF0000, 1);
			graphics.moveTo(points[0].x, points[0].y);
			graphics.lineTo(points[1].x, points[1].y);
			graphics.lineTo(points[2].x, points[2].y);
			graphics.lineTo(points[3].x, points[3].y);
			graphics.lineTo(points[4].x, points[4].y);
			graphics.lineTo(points[0].x, points[0].y);

			graphics.moveTo(points[5].x, points[5].y);
			graphics.lineTo(points[6].x, points[6].y);
			graphics.lineTo(points[7].x, points[7].y);
			graphics.lineTo(points[8].x, points[8].y);
			graphics.lineTo(points[9].x, points[9].y);
			graphics.lineTo(points[5].x, points[5].y);
			
			graphics.moveTo(points[0].x, points[0].y);
			graphics.lineTo(points[5].x, points[5].y);
			
			graphics.moveTo(points[1].x, points[1].y);
			graphics.lineTo(points[6].x, points[6].y);
			
			graphics.moveTo(points[2].x, points[2].y);
			graphics.lineTo(points[7].x, points[7].y);
			
			graphics.moveTo(points[3].x, points[3].y);
			graphics.lineTo(points[8].x, points[8].y);
			
			graphics.moveTo(points[4].x, points[4].y);
			graphics.lineTo(points[9].x, points[9].y);
		}
	}

}