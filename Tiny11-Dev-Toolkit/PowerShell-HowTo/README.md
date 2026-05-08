# PowerShell 常用系统功能指南

## 关于

此文件夹提供常见系统功能恢复与命令行工具启用示例，适合在 Tiny11 Dev Edition 安装完成后按需执行。

## 包含内容

| 文件 | 功能 | 需要管理员 |
|------|------|:---------:|
| `01-Enable-SMB1.ps1` | 启用 SMB 1.0/CIFS Client | ✅ |
| `02-Set-ExecutionPolicy.ps1` | 调整 PowerShell 默认执行策略 | ✅ |
| `03-Install-Common-Windows-Tools.ps1` | 安装 Telnet、TFTP、OpenSSH Client | ✅ |

## 使用方法

1. 右键 PowerShell，选择“以管理员身份运行”
2. 切换到本文件夹
3. 按需执行对应脚本，例如：

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\01-Enable-SMB1.ps1
```

## 注意事项

- SMB 1.0 存在安全风险，仅在确有旧设备兼容需求时启用
- 修改 Execution Policy 会影响后续脚本执行规则，请按企业或个人安全策略设置
- Telnet/TFTP/OpenSSH Client 都是按需安装，不建议默认全部启用

## 建议

- 优先使用 `RemoteSigned` 或 `Bypass (Process Scope)`，不建议长期设置为 `Unrestricted`
- 仅启用自己实际需要的 Windows Optional Features
