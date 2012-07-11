package com.sloader
{
	import com.sloader.loadhandlers.Loader_Handler;
	import com.sloader.loadhandlers.URLLoader_Handler;
	import com.sloader.loadhandlers.URLStream_Handler;

	public class SLoaderManage
	{
		private var _sloaderInstanceList:Object;
		private var _fileHandlers:Object;

		public function SLoaderManage()
		{
			_sloaderInstanceList = {};
			
			_fileHandlers = {};
			_fileHandlers[SLoaderFileType.SWF.toLowerCase()] = Loader_Handler;
			_fileHandlers[SLoaderFileType.XML.toLowerCase()] = URLLoader_Handler;
			_fileHandlers[SLoaderFileType.DAT.toLowerCase()] = URLStream_Handler;
			_fileHandlers[SLoaderFileType.JPG.toLowerCase()] = Loader_Handler;
			_fileHandlers[SLoaderFileType.PNG.toLowerCase()] = Loader_Handler;
			_fileHandlers[SLoaderFileType.BMP.toLowerCase()] = Loader_Handler;
			_fileHandlers[SLoaderFileType.CSS.toLowerCase()] = URLLoader_Handler;
		}
		
		private static var _instance:SLoaderManage;
		public static function get instance():SLoaderManage
		{
			if (!_instance)
				_instance = new SLoaderManage();
			return _instance;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////
		
		public function addSLoader(sloaderName:String, sloaderInstance:SLoader):void
		{
			if (!(_sloaderInstanceList[sloaderName] is SLoader))
				_sloaderInstanceList[sloaderName] = sloaderInstance;
			else
				throw new Error("Duplication of add sloader(name:"+sloaderName+")");
		}
		
		public function removeSLoader(sloaderName:String):void
		{
			delete _sloaderInstanceList[sloaderName];
		}

		public function getSloader(sloaderName:String):SLoader
		{
			return _sloaderInstanceList[sloaderName];
		}
		
		public function getFileCorrespondSloader(fileTitle:String):SLoader
		{
			for each(var sloader:SLoader in _sloaderInstanceList)
			{
				var fileVO:SLoaderFile = sloader.getFileVO(fileTitle);
				if (fileVO)
					return sloader;
			}
			return null;
		}
		
		public function getFileVO(fileTitle:String, sloaderInstance:SLoader=null):SLoaderFile
		{
			if (sloaderInstance)
				return sloaderInstance.getFileVO(fileTitle);
			else
			{
				for each(var sloader:SLoader in _sloaderInstanceList)
				{
					var fileVO:SLoaderFile = sloader.getFileVO(fileTitle);
					if (fileVO)
						return fileVO;
				}
			}
			return null;
		}
		
		public function getFileType(fileVO:SLoaderFile):String
		{
			if (fileVO.type)
				return fileVO.type;
			else
			{
				var urlPath:Array = fileVO.url.split("/");
				var fileName:String = urlPath.length>0 ? urlPath[urlPath.length-1]:fileVO.url;
				fileName = String(fileName.match(/\.[^?]*/));
				fileName = String(fileName.match(/[^\.].*/));
				if (_fileHandlers[fileName])
					return fileName;
			}
			return null;
		}
		
		public function getFileLoadHandler(fileType:String):Class
		{
			return _fileHandlers[fileType];
		}
		
		public function unLoad(fileTitle:String):void
		{
			var fileVO:SLoaderFile = getFileVO(fileTitle);
			if (!fileVO)
				throw new Error("not has the file[title="+fileTitle+"] on all sloader loaded list");
			
			if (fileVO.loaderInfo)
				fileVO.loaderInfo.loadHandler.unLoad();
		}
	}
}