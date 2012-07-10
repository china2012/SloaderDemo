package com.sloader
{
	import flash.utils.Dictionary;

	public class SLoaderManage
	{
		private static var _sloaderList:Object = {};

		public static function addSLoader(sloaderName:String, sloaderInstance:SLoader):void
		{
			if (!(_sloaderList[sloaderName] is SLoader))
				_sloaderList[sloaderName] = sloaderInstance;
			else
				throw new Error("Duplication of add sloader(name:"+sloaderName+")");
		}

		public static function removeSLoader(sloaderName:String):void
		{
			delete _sloaderList[sloaderName];
		}

		public static function getSloaderInstance(sloaderName:String):SLoader
		{
			return _sloaderList[sloaderName];
		}

		public static function getFileVO(fileTitle:String, sloaderInstance:SLoader=null):SLoaderFile
		{
			if (sloaderInstance)
				return sloaderInstance.getFileVO(fileTitle);
			else
			{
				for each(var sloader:SLoader in _sloaderList)
				{
					var fileVO:SLoaderFile = sloader.getFileVO(fileTitle);
					if (fileVO)
						return fileVO;
				}
			}
			return null;
		}
	}
}