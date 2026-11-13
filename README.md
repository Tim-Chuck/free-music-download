# Free Music Download

一个面向 Windows 的 Apple Music 桌面下载助手。提供中文界面，用于搜索歌曲和专辑、管理下载任务，并在本机查看下载历史。

> 本项目是独立的第三方项目，与 Apple Inc. 无关。下载能力依赖第三方后台及有效的 Apple Music 订阅、曲库地区和网络环境；并非每首歌曲都提供所选音质。请遵守所在地法律、服务条款及作品的相关权利。

## 功能

- 搜索歌曲和专辑；筛选结果、查看专辑曲目，并选择多首歌曲。
- 通过 Apple Music 专辑或公开歌单链接加载曲目；不自动同步私人资料库歌单。
- 选择 ALAC 或 AAC，查看下载队列及后台提供的进度。
- 尝试将动态封面保存为歌曲目录中的独立 MP4；资源是否存在取决于专辑和地区，播放器是否显示取决于其支持情况。
- 查看本机下载历史及文件位置。历史从功能启用后开始记录，不自动补录以前的下载。

## 使用

需要 64 位 Windows、.NET Framework 4.x、联网及有效的 Apple Music 订阅。编译后的程序与 `音乐后台组件.exe` 需要放在同一文件夹，首次运行时程序会校验并准备该组件。

点击设置中的“登录 Apple 账户”并按窗口提示操作。**登录由第三方 Wrapper Lite 后台处理，不是 Apple 官方登录页面。** 本项目的界面不保存密码，但后台可能保存登录会话。请勿将密码、验证码、会话数据、下载历史或配置文件上传到公开仓库。

## 从源码构建

在项目根目录打开 Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

脚本使用系统自带的 .NET Framework 编译器，将程序放在 `build/Free Music Download.exe`。默认会从 [apmyx v1.1.1 官方发布页](https://github.com/rwnk-12/apmyx-gui/releases/tag/v1.1.1) 下载后台安装包，并核对 SHA-256；构建本身不会执行安装包。首次打开本程序时会按照界面提示准备后台。

仅编译前端、不下载后台：

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1 -SkipBackend
```

不带后台安装包的前端只能在已经准备了兼容后台的环境中使用下载功能。版本更新后后台协议或 Apple Music 接口可能发生变化。

仓库不包含苹方字体。默认构建使用 Windows 系统字体；如已合法取得可供本地使用的字体，可通过 `-FontPath "字体文件路径"` 指定。请自行确认字体的使用和再分发许可。

## 本地数据

历史记录、封面缓存及后台组件位于 `%LOCALAPPDATA%\MusicHelper\`。歌曲保存在应用内选择的目录。仓库不包含登录会话、下载记录、下载的音乐、字体或后台二进制文件。

## 第三方项目和许可

本仓库中本项目的源码采用 [MIT 许可证](LICENSE)。下载后台依赖 [apmyx](https://github.com/rwnk-12/apmyx-gui) 及其第三方组件；它们采用各自的许可（包括 GPL 和 AGPL），不因本项目采用 MIT 而改变。后台安装包不包含在本仓库中；如再分发后台或组合包，请核对相应组件的许可证和源码提供要求。

Apple Music、Apple 和相关标识属于各自权利人。
