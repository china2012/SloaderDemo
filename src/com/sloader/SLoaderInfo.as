package com.sloader
{
	import flash.system.LoaderContext;

	/**
	 * @author jjww
	 * SLoader运行状态
	 */	
	public class SLoaderInfo
	{
		/**
		 * Sloader已经加载的文件总数量 -
		 */		
		public var loadedFileCount:int;
		
		/**
		 * Sloader已经加载的文件总字节数 -
		 */		
		public var loadedBytes:Number;

		/**
		 * 本次加载队列已经加载的文件数量 -
		 */		
		public var currLoadedFileCount:int;
		
		/**
		 * 本次加载队列的所有文件数量 -
		 */		
		public var currTotalFileCount:int;
		
		/**
		 * 本次加载队列已经加载的文件字节数 -
		 */		
		public var currLoadedBytes:Number;
		
		/**
		 * 本次加载队列所有文件字节数总和 -
		 * -- 该值的计算方式为将所有文件属性中的size相加
		 * -- 执行计算的条件是为本次加载列队的文件都设置了有效的size属性
		 */		
		public var currTotalBytes:Number;

		/**
		 * 当前队列文件加载的百分比
		 * 
		 * 当【本次加载队列所有文件字节数总和】有效时优先采用计算方式2
		 * -- 计算方式1：当前文件加载的大小/当前文件总大小/当前列队文件数量 + 已经加载文件数量/当前列队文件数量
		 * -- 计算方式2：本次加载队列已经加载的文件字节数/本次加载队列所有文件字节数总和
		 */		
		public var currLoadPercentage:Number;
		
		/**
		 * currLoadingFiles映射当前正在加载中的文件 -
		 */		
		public var currLoadingFiles:Array;
		
		/**
		 * 加载文件所在位置 -
		 */
		public var loaderContext:LoaderContext;
	}
}