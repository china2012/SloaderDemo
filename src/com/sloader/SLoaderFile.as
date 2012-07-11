
package com.sloader
{
	public class SLoaderFile
	{
		public var name:String;			// *
		
		public var title:String;			// *
		
		public var url:String;				// *
		
		public var group:String;			// *
		
		/////////////////////////////////////////////////////////////////////////////////
		
		/** 文件的版本 **/
		public var version:String;

		/** 如果设置了Type属性的话以Type属性为后缀名来选择不同的加载程序, 否则根据url来进行识别后缀名 **/
		public var type:String;
		
		/** 文件大小 ,当准备进行加载多个文件的时候，如果设置了全部文件的size属性，会让加载进度百分比更加准确 **/
		public var size:Number;

		/** 文件的加载信息，在文件开始加载后这个值才有效**/
		public var loaderInfo:SLoaderFileInfo;
	}
}