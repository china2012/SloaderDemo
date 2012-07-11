package com.sloader
{
	public class SLoaderFile
	{
		public var name:String;			// *
		
		// 在所有Sloader实例中的准备加载的文件和已经加载的文件中，不允许有相同的title出现
		public var title:String;			// *
		
		public var url:String;				// *
		
		// 文件所在的组的名称
		// 组名称不能重复，在所有Sloader实例中
		// 将文件纳入一个组后可以更好的管理加载的文件，在SloaderManage中包含操作组的一些方法
		public var group:String;			// *
		
		/////////////////////////////////////////////////////////////////////////////////
		
		public var version:String;

		// 程序依靠文件后缀名来选择不同的加载程序, 如果设置了Type属性的话以Type属性为后缀名, 否则根据url来进行识别后缀名
		public var type:String;
		
		// 文件大小
		// 当准备进行加载多个文件的时候，如果设置了文件的size属性，会让加载进度百分比更加准确
		public var size:Number;

		// 文件的加载信息，在文件开始加载后这个值才有效
		public var loaderInfo:SLoaderFileInfo;
	}
}