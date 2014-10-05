# Playground OSS

本项目从Fork自[Klab的Playground OSS引擎](https://github.com/KLab/PlaygroundOSS "Klab的Playground OSS引擎")](https://github.com/KLab/PlaygroundOSS)], 在其基础上加入如下功能(所有lua文件位于Tutorial\RoundWar目录下)：

 * 为lua添加面向对象特性，即类的概念，具体实现参见classlite.lua。定义一个基类和继承类非常简单，如下面的代码，B表示基类，D1继承于B，自动拥有B的方法和变量，D2继承于D1，拥有B,D的方法和变量
 	
		B = classlite()
		
		function B:ctor() -- 构造函数
			self.id = 100
		end
	
		function B:f()
			syslog("B:f")
			syslog("id=" .. self.id)
		end
		
		D1 = classlite(B)
		
		function D1:ctor()
		end
	
		D2 = classlite(D1)
		
		function D2:ctor()
		end
	
		local d = D2.new()
		d:f()

 * Sprite类，封装了UI_MultiImgItem，拥有*Action方法， 以配合Action系统，具体参见Sprite.lua
 
 * 强大的Action系统，用于制作各种特效，主要分两大类：即时Action和带时长的Action，如移动，缩放，延时，回调函数，动画，顺序系列，并发系列, 缓动系列，具体参见文件Action.lua, ActionInstant.lua, ActionEase.lua, ActionEngine.lua
 
 * 定义动画格式，以json方式存储，具体例子参见spr_apple.json和spr_hetao.json
 
 * 工具SplitSprites(提供两种版本：windows版本和Mac版本)位于Tutorial\Assets目录，可将TexturePacker导出的plist导出为自定义的动画格式和Toboggan所能识别的Texture文件，使用例子：
 	
		SplitSprites -i=apple.plist -c=true -e=true
		
		其中：-i后面跟输入文件（plist文件）或目录
			 -c=true指示导出的图片文件是去掉透明边框部分的
			 -e=true表示导出自定义的动画格式和Toboggan所能识别的Texture文件
 
 * 所有代码都位于Tutorial\RoundWar目录, 该目录提供了一个回合战的游戏，功能比较简单，用于演示上面的Action系统，核心文件为BattleField.lua（战场模块）和Soldier.lua（战斗单元，里面用到大量的Action）

