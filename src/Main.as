package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.setInterval;
	
	/**
	 * ...
	 * @author 
	 */
	public class Main extends Sprite 
	{
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			setInterval(loop, 125);
			
		}
		
		private function loop():void {
			draw();
			//VRP[0] -= 0.2;
			//VRP[1] -= 0.1;
			//VPN[0] += 0.01;
			//PRP[2] += 1;
		}
			
			/**
			 * 定义VRC,观察坐标系
			 */
			var VRP:Array = [0, 0, 54];//投影平面原点(WC)
			var VPN:Array = [0, 0, 1];//投影平面法线(WC)
			var VUP:Array = [0, 1, 0];//上方向向量(WC)
			
			/**
			 * 定义观察点和窗口大小
			 */
			var PRP:Array = [8, 8, 30];//投影中心(VRC)u,v,n
			var WINDOW:Array = [ -1, 17, -1, 17];//观察窗口的Umin,Umax,Vmin,Vmax(VRC)
			var Z_Near = 1;
			var Z_Far = 40;
			
		private function draw():void 
		{
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
			
			/**
			 * 生成世界坐标系到观察坐标系的变换矩阵
			 */
			var m:Matrix3D = new Matrix3D();
			m.appendTranslation( -VRP[0], -VRP[1], -VRP[2]);//平移
			var a:Number,i:int;
			if (VPN[0] != 0) {//Y轴旋转
				a = Math.acos(VPN[0] / Math.sqrt(VPN[0] * VPN[0] + VPN[2] * VPN[2])) - Math.PI/2;
				a *= (180 / Math.PI);
				m.appendRotation(a, Vector3D.Y_AXIS, null);
			}
			if (VPN[2] != 0) {//X轴旋转
				a = Math.acos(VPN[2] / Math.sqrt(VPN[1] * VPN[1] + VPN[2] * VPN[2]));
				a *= (180 / Math.PI);
				if (VPN[1] < 0) {
					a *= -1;
				}
				m.appendRotation(a, Vector3D.X_AXIS, null);
			}
			//TODO 处理VUP,使用Z轴旋转
			
			//将模型变换到观察坐标系
			trace("观察坐标系----------");
			for (i = 0; i < points.length; i++ ) {
				points[i] = m.transformVector(points[i]);
				trace("point["+i+"]:"+points[i]);
			}
			
			//生成NDC
			trace("NDC坐标---------");
			for (i = 0; i < points.length; i++ ) {

				//按PRPx,y平移
				points[i].x -= PRP[0];
				points[i].y -= PRP[1];
				
				a = (0 - PRP[2]) / (points[i].z - PRP[2]);
				
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