# PostTiny

> 在已安装完成的原版 Windows 系统上，应用类似 `tiny11-dev` 的精简与开发者优化设置。

## 目标

`PostTiny` 用于在线系统后处理，不替代 ISO 构建脚本，而是把 `tiny11maker-dev-build.ps1` 中可迁移的动作拆成：

- 单独函数
- 预置清单
- 主菜单执行入口
- 在线系统安全边界

## 当前能力

- 执行 `tiny11-dev` 预置应用清理
- 扫描现有 `Provisioned Appx` 并交互式选择删除
- 执行 `tiny11-dev` 预置设置
- 一键执行“预置清理 + 预置设置”
- 输出日志到 `PostTiny\Logs`

## 目录结构

```text
PostTiny/
  Invoke-PostTiny.ps1
  Modules/
    PostTiny.Core.psm1
    PostTiny.Appx.psm1
    PostTiny.Settings.psm1
  Presets/
    tiny11-dev.psd1
  Logs/
  README.md
```

## 使用方式

### 菜单模式

```powershell
powershell -ExecutionPolicy Bypass -File .\PostTiny\Invoke-PostTiny.ps1
```

### 直接执行预置应用清理

```powershell
powershell -ExecutionPolicy Bypass -File .\PostTiny\Invoke-PostTiny.ps1 -Mode PresetCleanup
```

### 直接执行预置设置

```powershell
powershell -ExecutionPolicy Bypass -File .\PostTiny\Invoke-PostTiny.ps1 -Mode PresetSettings
```

### 一键执行全部

```powershell
powershell -ExecutionPolicy Bypass -File .\PostTiny\Invoke-PostTiny.ps1 -Mode All
```

### 跳过高风险动作

```powershell
powershell -ExecutionPolicy Bypass -File .\PostTiny\Invoke-PostTiny.ps1 -Mode All -SkipHighRisk
```

## 已实现的设置项

- 视觉效果优化
- 文件资源管理器开发者配置
- 关闭 Sponsored Apps / 建议内容
- 关闭 OneDrive 文件夹备份策略
- 隐私与遥测限制
- 关闭 Widgets 与 Search Highlights
- 禁用 Xbox 相关后台服务
- 禁用额外后台服务
- 将 Windows Search 设为手动
- 关闭锁屏 Spotlight / 提示
- Edge 新标签页与侧边栏优化
- 启用传统右键菜单
- 添加 CMD / PowerShell / PowerShell Admin 右键菜单
- 配置 Windows Update 为“手动可控 + 暂停 800 天”
- 尝试移除 OneDrive 安装器、Microsoft PC Manager、扩展壁纸包

## 在线系统与离线镜像的差异

- `boot.wim` 相关修改不会迁移到 `PostTiny`
- `PostTiny` 主要作用于当前系统与当前用户，不是离线写入默认用户模板
- 某些在线删除动作可能需要重启
- 某些系统包在在线系统中删除失败是正常现象，日志会保留失败原因

## 风险提示

- `RemoveExtendedWallpapers` 属于较高风险动作，建议先在虚拟机验证
- Appx 删除会同时尝试处理 `Provisioned` 包和已安装包
- 某些服务禁用后会影响故障诊断、Xbox、搜索或更新体验

## 后续方向

- 增加回滚脚本
- 增加“当前用户 + 默认用户模板”双写模式
- 增加更细的设置子菜单
- 增加 JSON/CSV 导出扫描结果
