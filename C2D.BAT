::::::::::::::::::::::::::::::::::::::::::
::　名称：WIN7个人文件夹转移工具　　　　::
::　作者：茗伊          　　　　　　　　::
::　版本：v2.0 2013-2-20　　　　　　　　::
::　用途：可以转移WIN7操作系统下的　　　::
::　　　　个人文件夹（使用硬链接方式）　::
::　　注：如需转移临时文件请务必使用第　::
::　　　　三方引导，否则会出现文件占用　::
::::::::::::::::::::::::::::::::::::::::::
@echo off
color 0A
title 个人文件C→D - By ZYM @ ZhaiYiMing.CoM
setlocal EnableDelayedExpansion
mode con cols=90 lines=30 & REM cols是设置宽度，lines是设置高度
REM 确认管理员权限
set UAC=0
bcdedit>nul
if errorlevel 1 set UAC=1
if %UAC%==1 (
 color CE
 set exitconf=N
 echo 没有管理员权限，请以管理员权限运行该程序！
 set /p exitconf=输入y忽略管理员权限验证，造成的后果自行承担：
 if /i NOT !exitconf!==Y (goto :end)
)
REM 已确认管理员权限

REM 设置分区盘符
:setDriverName
color 0A
cls
set tempFlag=n
set currentSystemDriver=C
set currentBackupDriver=D
set targetBackupDriver=D
echo 【分区设置】
echo ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
set /p currentSystemDriver=请输入当前文件系统下需转移数据的Win7系统所在分区盘符(默认：C):
set /p currentBackupDriver=请输入当前文件系统下文件转移目标所在分区盘符(默认：D):
set /p  targetBackupDriver=请输入目标文件系统下文件转移目标所在分区盘符(默认：D):
echo ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
color 0E
echo 当前文件系统下需转移数据的Win7系统所在分区："%currentSystemDriver%:\"
echo 当前文件系统下文件转移目标所在分区：　　　　"%currentBackupDriver%:\"
echo 目标文件系统下文件转移目标所在分区：　　　　"%targetBackupDriver%:\"
set /p tempFlag=请输入Y确认以上信息,否则请重新输入(Y/N)：
if /i NOT %tempFlag%==Y goto :setDriverName

REM 每轮操作开始时的变量初始化
:start
color 0A
echo off
cls
set userLine=N
set moveAppData=N
set moveAppDataLocal=N
set moveAppDataLocalLow=N
set moveAppDataRoaming=N
set userConform=Null
set tmsTmpFileName=C2D.v2.tmp

REM 选择需要转移的用户
echo Shift +F10
echo =======================
echo 本机用户列表：
dir %currentSystemDriver%:\Users /b /a:d /o>%tmsTmpFileName%
set n=0
for /f "delims=" %%i in (%tmsTmpFileName%) do (
set /a n+=1
echo !n!.%%i
)
echo =======================
set /p userLine=请选择需要转移文件的用户(输入0退出,X to input yourself):
if %userLine%==0 goto :end
if /i %userLine%==N ( goto:start )
if /i %userLine%==X (
	set sourceUserName=
	set /p sourceUserName="请输入需要转移文件的用户名: "
	set targetUserName=!sourceUserName!
	set /p targetUserName="请输入您希望转移到的文件夹(默认'!sourceUserName!'): "
) else (
	call :G_getrowstr %userLine% %tmsTmpFileName% sourceUserName
	set targetUserName=!sourceUserName!
)
if "%sourceUserName%"=="" (
	color 0E
	echo 输入的源用户名错误
	pause
	goto :start
)
if "%targetUserName%"=="" (
	color 0E
	echo 输入的目标用户名错误
	goto :start
)
if exist "%tmsTmpFileName%" del "%tmsTmpFileName%"

REM 选择需要转移的文件夹
set /p moveAppData="是否转移"AppData"文件夹？(该文件夹包含应用程序数据及缓存)(Y/N): "
if /i NOT %moveAppData%==y (
	set /p moveAppDataLocal="是否转移"AppData\Local"文件夹？(该文件夹包含某些应用程序数据及缓存 如Chrome浏览器)(Y/N): "
	set /p moveAppDataLocalLow="是否转移"AppData\LocalLow"文件夹？(该文件夹用来存放共享数据)(Y/N): "
	set /p moveAppDataRoaming="是否转移"AppData\Roaming"文件夹？(该文件夹存放一些使用程序后产生的数据文件，如空间听音乐 登入的号码等而缓存的一些数据)(Y/N): "
)

REM 确认信息
:userConfirm
color 0E
echo =======================
echo ☆☆☆☆☆☆请确认信息(Y/N)☆☆☆☆☆☆
echo ●需要转移的用户文件夹：　　　　"%currentSystemDriver%:\Users\%sourceUserName%\"
echo ●希望转移到的目标文件夹：　　　"%currentBackupDriver%:\Backup\Users\%targetUserName%\"
echo ●目标文件夹在目标系统中的位置："%targetBackupDriver%:\Backup\Users\%targetUserName%\"
echo ●希望转移的目录如下：
if /i %moveAppData%==y echo ◎整个"AppData"文件夹(包括Local,LocalLow,Roaming文件夹)
if /i %moveAppDataLocal%==y echo ◎"AppData\\Local"文件夹
if /i %moveAppDataLocalLow%==y echo ◎"AppData\\LocalLow"文件夹
if /i %moveAppDataRoaming%==y echo ◎"AppData\\Roaming"文件夹
set /p userConform="请确认(Y/N):"
if /i %userConform%==N goto :start
if /i NOT %userConform%==Y goto :userConfirm

REM 准备就绪，开始转移。
color 0A
echo ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
echo 按任意键开始用户"%sourceUserName%"个人文件转移
pause
@echo on


@if /i %moveAppData%==Y (
	call :tmsFuncFolderMove "AppData"
) else (
	if /i %moveAppDataLocal%==Y (
		call :tmsFuncFolderMove "AppData\Local"
	) else (
		call :tmsFuncFolderMove "AppData\Local\TslGame"
	)
	if /i %moveAppDataLocalLow%==Y call :tmsFuncFolderMove "AppData\LocalLow"
	if /i %moveAppDataRoaming%==Y call :tmsFuncFolderMove "AppData\Roaming"
)
@set userType=1
@if /i "%sourceUserName%"=="All Users" ( @set userType=0 )
@if /i "%sourceUserName%"=="Default" ( @set userType=0 )
@if /i "%sourceUserName%"=="Default User" ( @set userType=0 )
@if /i "%sourceUserName%"=="Public" ( @set userType=0 )
@call :tmsFuncFolderMove "Saved Games" %userType%
@call :tmsFuncFolderMove "Contacts" %userType%
@call :tmsFuncFolderMove "Links" %userType%
@call :tmsFuncFolderMove "Favorites" %userType%
@call :tmsFuncFolderMove "Searches" %userType%
@call :tmsFuncFolderMove "Videos" %userType%
@call :tmsFuncFolderMove "Pictures" %userType%
@call :tmsFuncFolderMove "Documents" %userType%
@call :tmsFuncFolderMove "Music" %userType%
@call :tmsFuncFolderMove "Downloads" %userType%
@call :tmsFuncFolderMove "Desktop" %userType%
@call :tmsFuncFolderMove "Virtual Machines" %userType%
@call :tmsFuncFolderMove ".android" %userType%
@call :tmsFuncFolderMove ".idlerc" %userType%
@call :tmsFuncFolderMove ".ssh" %userType%
@call :tmsFuncFolderMove ".vscode" %userType%
@call :tmsFuncFolderMove ".config" %userType%
@echo ＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
@echo %sourceUserName%用户文件转移结束...
@pause
@goto :start

:end
@if exist "%tmsTmpFileName%" del "%tmsTmpFileName%"
@echo 茗伊 @ QQ8421854
@pause
@exit

:tmsFuncFolderMove
 @set fldName=%1
 @set fldName=%fldName:"=%
 @set userType=%2
 @if not exist "%currentBackupDriver%:\Backup\Users\%targetUserName%\%fldName%" @mkdir "%currentBackupDriver%:\Backup\Users\%targetUserName%\%fldName%"
 @if exist "%currentSystemDriver%:\Users\%sourceUserName%\%fldName%" (
  @robocopy "%currentSystemDriver%:\Users\%sourceUserName%\%fldName%" "%currentBackupDriver%:\Backup\Users\%targetUserName%\%fldName%" /E /COPYALL /XJ
  @rmdir "%currentSystemDriver%:\Users\%sourceUserName%\%fldName%" /S /Q
  @mklink /J "%currentSystemDriver%:\Users\%sourceUserName%\%fldName%" "%targetBackupDriver%:\Backup\Users\%targetUserName%\%fldName%"
 ) else (
  @if "%userType%"=="1" @mklink /J "%currentSystemDriver%:\Users\%sourceUserName%\%fldName%" "%targetBackupDriver%:\Backup\Users\%targetUserName%\%fldName%"
 )
 @goto :eof

:G_getrowstr
 set %3=
 set n=0
 for /f "delims=" %%i in (%2) do (
  set /a n+=1
  REM echo !n!
  if !n!==%1 (
   set %3=%%i
   goto :eof
  )
 )
 goto :eof
