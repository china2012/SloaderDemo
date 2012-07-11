package com.sloader
{
	import com.sloader.loadhandlers.Binary_LoadHandler;
	import com.sloader.loadhandlers.CSS_LoadHandler;
	import com.sloader.loadhandlers.Image_LoadHandler;
	import com.sloader.loadhandlers.SWF_LoadHandler;
	import com.sloader.loadhandlers.XML_LoadHandler;
	
	import flash.utils.Dictionary;
	
	public class SLoaderManage
	{
		private var _sloaders:Object;
		
		private var _fileHandlers:Object;
		
		private var _groups:Dictionary;
		
		public function SLoaderManage()
		{
			if (_instance)
				throw new Error("SloaderManage is Singleton Pattern");
			
			_sloaders = {};
			
			_fileHandlers = {};
			_fileHandlers[SLoaderFileType.SWF.toLowerCase()] = SWF_LoadHandler;
			_fileHandlers[SLoaderFileType.XML.toLowerCase()] = XML_LoadHandler;
			_fileHandlers[SLoaderFileType.DAT.toLowerCase()] = Binary_LoadHandler;
			_fileHandlers[SLoaderFileType.JPG.toLowerCase()] = Image_LoadHandler;
			_fileHandlers[SLoaderFileType.PNG.toLowerCase()] = Image_LoadHandler;
			_fileHandlers[SLoaderFileType.BMP.toLowerCase()] = Image_LoadHandler;
			_fileHandlers[SLoaderFileType.CSS.toLowerCase()] = CSS_LoadHandler;
			
			_groups = new Dictionary();
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
			if (!(_sloaders[sloaderName] is SLoader))
				_sloaders[sloaderName] = sloaderInstance;
			else
				throw new Error("Duplication of add sloader(name:"+sloaderName+")");
		}
		
		public function removeSLoader(sloaderName:String):void
		{
			delete _sloaders[sloaderName];
		}
		
		public function getSloader(sloaderName:String):SLoader
		{
			return _sloaders[sloaderName];
		}
		
		public function getFileCorrespondSloader(fileTitle:String):SLoader
		{
			for each(var sloader:SLoader in _sloaders)
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
				for each(var sloader:SLoader in _sloaders)
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
		
		public function addFileToGroup(groupName:String, fileVO:SLoaderFile):void
		{
			if (groupName == fileVO.group)
				return;
			
			if (!_groups[fileVO.group])
				return;
			
			var index:int;
			index = _groups[fileVO.group].indexOf(fileVO);
			if (index != -1)
				_groups[fileVO.group].splice(index, 1);
			else
			{
				for each(var group:Array in _groups)
				{
					index = group.indexOf(fileVO);
					if (index != -1){
						group.splice(index, 1);
						break;
					}
				}
			}
				
			_groups[groupName].push(fileVO);
		}
		
		public function getGroupFiles(groupName:String):Array
		{
			var groupFiles:Array = [];
			groupFiles.concat(_groups[groupName]);
			return groupFiles;
		}
	}
}