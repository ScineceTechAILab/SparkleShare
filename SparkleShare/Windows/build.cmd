@echo off

set WinDirNet=%WinDir%\Microsoft.NET\Framework
set "msbuild=%WinDirNet%\v4.0\msbuild.exe"
if not exist "%msbuild%" set "msbuild=%WinDirNet%\v4.0.30319\msbuild.exe"
set wixBinDir=%WIX%\bin

if not exist ..\..\bin mkdir ..\..\bin
copy Images\sparkleshare-app.ico ..\..\bin\

if not exist "%msbuild%" (
	echo Build cannot proceed ^(could not find msbuild in .NET Framework v4.0 or v4.0.30319^)
	exit /b 1
)

"%msbuild%" /t:Rebuild /p:Configuration=Release /p:Platform="Any CPU" "%~dp0\SparkleShare.sln"
if errorlevel 1 (
	echo Build failed.
	exit /b 1
)

if "%1"=="installer" (
	if exist "%wixBinDir%" (
	  if not exist "%~dp0\..\..\bin\msysgit" (
	  	echo Not building installer ^(missing required directory: SparkleShare-sources\bin\msysgit^)
	  	exit /b 1
	  )
	  if not exist "%~dp0\..\..\bin\plugins" (
	  	echo Not building installer ^(missing required directory: SparkleShare-sources\bin\plugins^)
	  	exit /b 1
	  )
	  if exist "%~dp0\SparkleShare.msi" del "%~dp0\SparkleShare.msi"
		"%wixBinDir%\heat.exe" dir "%~dp0\..\..\bin\msysgit" -cg msysGitComponentGroup -gg -scom -sreg -sfrag -srd -dr MSYSGIT_DIR -var wix.msysgitpath -o msysgit.wxs
		if errorlevel 1 exit /b 1
		"%wixBinDir%\heat.exe" dir "%~dp0\..\..\bin\plugins" -cg pluginsComponentGroup -gg -scom -sreg -sfrag -srd -dr PLUGINS_DIR -var wix.pluginsdir -o plugins.wxs
		if errorlevel 1 exit /b 1
		"%wixBinDir%\candle" "%~dp0\SparkleShare.wxs" -ext WixUIExtension -ext WixUtilExtension
		if errorlevel 1 exit /b 1
		"%wixBinDir%\candle" "%~dp0\msysgit.wxs" -ext WixUIExtension -ext WixUtilExtension
		if errorlevel 1 exit /b 1
		"%wixBinDir%\candle" "%~dp0\plugins.wxs" -ext WixUIExtension -ext WixUtilExtension
		if errorlevel 1 exit /b 1
		"%wixBinDir%\light" -ext WixUIExtension -ext WixUtilExtension Sparkleshare.wixobj msysgit.wixobj plugins.wixobj -droot="%~dp0\..\.." -dmsysgitpath="%~dp0\..\..\bin\msysgit" -dpluginsdir="%~dp0\..\..\bin\plugins"  -o SparkleShare.msi 
		if errorlevel 1 exit /b 1
		if exist "%~dp0\SparkleShare.msi" echo SparkleShare.msi created.
	) else (
		echo Not building installer ^(could not find wix, Windows Installer XML toolset^)
	  echo wix is available at http://wix.sourceforge.net/
	  exit /b 1
	)
) else echo Not building installer, as it was not requested. ^(Issue "build.cmd installer" to build installer ^)
