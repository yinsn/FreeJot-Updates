# 释手 / FreeJot：新 Mac 完整安装指南

适用于用户和安装 agent。核验日期：2026-09-14。系统要求：Apple Silicon（M 系列）Mac、macOS 14 或更新版本。首次准备至少留出 20 GB 可用空间；应用和两个模型约占 6.4 GB。运行和离线安装只需 Mac 自带工具，无需 Python、Xcode 或 API Key。

**新机器先装包含模型的完整离线版 0.2.0，再手动更新到 0.2.3，之后可在应用内检查更新。** 约 27 MB 的 `FreeJot-Update-*.zip` 只更新程序，不能单独完成首次安装。完整包压缩后为 5,367,175,477 字节，下载后不必额外寻找 tokenizer 或模型。

- [下载首页](https://yinsn.github.io/FreeJot-Updates/)
- [安装清单（精确文件名、大小、SHA256、路径）](https://yinsn.github.io/FreeJot-Updates/install.json)
- [最新更新描述](https://yinsn.github.io/FreeJot-Updates/app-update.json)
- [本文 Markdown 原文（可直接交给 agent）](https://yinsn.github.io/FreeJot-Updates/INSTALL.md)

## 1. 先判断这台 Mac 应走哪条路径

| 目标机器状态 | 操作 |
| --- | --- |
| 没装过释手，或只有更新器 / 不带模型的应用 | 第 2 节确认环境，第 3 节获取完整离线包 |
| 已有完整离线 0.2.0 / 0.2.1 | 先用第 5 节校验，再走第 6 节手动升级 |
| 已有完整离线 0.2.2 或更高版本 | 校验后在「设置 → 关于释手 → 检查更新」升级 |
| 提示 tokenizer.json 缺失、模型不完整或校验失败 | 按第 8 节排查，不能把失败当作“尚需下载一个小文件” |

**下载权限是安装前提：**完整包目前在私有仓库 [yinsn/FreeJot 的 v0.2.0 发布页](https://github.com/yinsn/FreeJot/releases/tag/v0.2.0)。需要有仓库访问权限的 GitHub 账号；公开文档和更新包均无需登录。完整包链接返回 404 / 403 时，先核对账号权限。没有权限的 agent 应明确报告“无法取得完整安装包”，请用户提供访问权限或完整 ZIP，再继续。不能用源码 ZIP、更新 ZIP 或开发版替代。

另一条有效路径是由拥有者通过隔空投送、移动硬盘或用户授权的文件传输方式提供同一份完整 ZIP，按第 3B 节校验。不要在对话中索取或输出令牌、密码。

## 2. 确认系统、空间与已有安装

```sh
/usr/bin/uname -m
/usr/sbin/sysctl -n hw.optional.arm64
/usr/bin/sw_vers -productVersion
/bin/df -Pk "$HOME/Downloads" /Applications
```

原生终端应显示 `arm64`；若终端运行于 Rosetta，`uname -m` 可能显示 `x86_64`，此时以 `hw.optional.arm64 = 1` 确认硬件。Intel Mac 和 macOS 13 或更早版本不支持这份安装包。下载、合并与解压所在卷需要至少 20,000,000,000 字节可用空间；若应用安装在另一块卷，该卷也需有约 7 GB 空间。

检查 `/Applications/FreeJot.app` 和用户选择的安装位置。已有应用时先确认它的版本与模型完整性，保留原应用，不直接覆盖或删除。历史、词典和偏好位于用户资源库，安装过程不应清理它们。若已有完整的较新版本，不要重新安装 0.2.0。

## 3A. 从发布页下载全部四个文件

打开 [v0.2.0 完整包发布页](https://github.com/yinsn/FreeJot/releases/tag/v0.2.0)，下载以下四项，放到同一个新文件夹。前三项是同一个 ZIP 的字节分卷，**不能分别解压**。

| 文件名 | 字节数 |
| --- | ---: |
| `FreeJot-Offline-AppleSilicon-0.2.0-20260913-153743.zip.part01` | 1,900,000,000 |
| `FreeJot-Offline-AppleSilicon-0.2.0-20260913-153743.zip.part02` | 1,900,000,000 |
| `FreeJot-Offline-AppleSilicon-0.2.0-20260913-153743.zip.part03` | 1,567,175,477 |
| `FreeJot-Prepare-0.2.0-20260913-153743.zip` | 4,526 |

如果机器已有 GitHub CLI 且已登录有权限的账号，agent 可以使用下面的路径；没有 CLI 时用已登录浏览器下载即可，不需要为运行释手安装 CLI。

以下命令在同一个终端会话执行；`task_downloads` 是本次工作文件夹，不是应用安装位置。目录已有文件时先核验它们，不使用覆盖下载选项。

```sh
task_downloads="$HOME/Downloads/FreeJot-FirstInstall"
/bin/mkdir -p "$task_downloads"
gh release download v0.2.0 --repo yinsn/FreeJot --dir "$task_downloads" \
  --pattern 'FreeJot-Offline-AppleSilicon-0.2.0-20260913-153743.zip.part01' \
  --pattern 'FreeJot-Offline-AppleSilicon-0.2.0-20260913-153743.zip.part02' \
  --pattern 'FreeJot-Offline-AppleSilicon-0.2.0-20260913-153743.zip.part03' \
  --pattern 'FreeJot-Prepare-0.2.0-20260913-153743.zip'
```

先取得公开校验清单，再校验全部四项。只有命令成功且四项均为 `OK` 才继续。

```sh
/usr/bin/curl -fL --retry 3 \
  https://yinsn.github.io/FreeJot-Updates/install-sha256.txt \
  -o "$task_downloads/install-sha256.txt"
(cd "$task_downloads" && /usr/bin/shasum -a 256 -c install-sha256.txt)
```

解压安装助手，然后运行它。助手会再次校验分卷、按正确顺序合并、核验完整 ZIP、使用 macOS 自带 `ditto` 解压并校验应用签名、版本与构建号。`--no-open` 只关闭 Finder 自动展示，适合 agent；它仍输出完整进度。

```sh
/usr/bin/ditto -x -k \
  "$task_downloads/FreeJot-Prepare-0.2.0-20260913-153743.zip" \
  "$task_downloads"
/bin/zsh "$task_downloads/FreeJot-Prepare-0.2.0-20260913-153743/双击准备安装.command" --no-open
```

人工操作时也可双击助手 ZIP，再双击其中的「双击准备安装.command」。助手位置可以在分卷旁边的子文件夹内；不要更改分卷名称。准备完成后的应用路径是：

```text
<下载文件夹>/FreeJot-Install-0.2.0-20260913-153743/FreeJot-Offline-AppleSilicon/FreeJot.app
```

助手返回非零或未显示“准备完成”时，先处理报错，不开始安装。已经校验过的完整 ZIP 会保留，助手可重新运行；不要删除分卷制造“已完成”。继续第 4 节。

## 3B. 已通过传输取得完整 ZIP

适用于 `FreeJot-Offline-0.2.0-AppleSilicon.zip` 或合并后的 `FreeJot-Offline-AppleSilicon-0.2.0-20260913-153743.zip`，两者内容相同。

- 精确大小：`5367175477` 字节。
- SHA256：`33348ad46b363a081049a9363e1621efa1a53776ff3cb6ff48348dfcaf3d1df4`。

用 `/usr/bin/stat -f %z <ZIP绝对路径>` 与 `/usr/bin/shasum -a 256 <ZIP绝对路径>` 检查，必须同时匹配。然后用 `/usr/bin/ditto -x -k <ZIP绝对路径> <新的解压文件夹>` 解压。路径包含空格时加双引号。

这个大文件采用 macOS 打包方式，统一使用 `ditto` 或系统归档实用工具；不要因为其他 ZIP 库报大文件偏移错误就重建归档或跳过校验。解压结果内应有 `FreeJot-Offline-AppleSilicon/FreeJot.app`、安装说明和第三方声明。

## 4. 安装完整应用

将刚才得到的整个 `FreeJot.app` 拖入「应用程序」，保留应用内部的模型目录。模型位于 `Contents/Resources/Models/`，并不在下载文件夹旁，也不能通过只复制 `Contents/MacOS/FreeJot` 完成安装。

agent 可使用 `ditto` 复制整个应用。下面仅适用于第 3A 节路径，且目标不存在的首次安装；已有目标时命令会停止。不要把旧的完整应用与新包合并覆盖。

```sh
task_source="$task_downloads/FreeJot-Install-0.2.0-20260913-153743/FreeJot-Offline-AppleSilicon/FreeJot.app"
task_target='/Applications/FreeJot.app'
if [ -e "$task_target" ] || [ -L "$task_target" ]; then
  echo '目标已有应用，请先核验版本和模型，选择升级或保留旧版后再安装。'
else
  /usr/bin/ditto --rsrc --extattr "$task_source" "$task_target"
fi
```

如 `/Applications` 不可写，可使用用户同意的 `~/Applications/FreeJot.app`；随后所有校验、升级、启动都使用这个真实路径。不要从 ZIP、磁盘映像或系统临时转置目录运行后再更新。

## 5. 校验全部模型和应用签名

下载以下两份文本到同一文件夹。`verify-install.sh` 只读文件，不下载模型、不修改或安装应用。

```sh
/usr/bin/curl -fL --retry 3 \
  https://yinsn.github.io/FreeJot-Updates/verify-install.sh \
  -o "$task_downloads/verify-install.sh"
/usr/bin/curl -fL --retry 3 \
  https://yinsn.github.io/FreeJot-Updates/model-sha256.txt \
  -o "$task_downloads/model-sha256.txt"
/bin/zsh "$task_downloads/verify-install.sh" '/Applications/FreeJot.app'
```

若走第 3B 节，请先将 `task_downloads` 指向这两份文本的存放文件夹。自定义安装位置要相应替换最后一个参数。

校验器检查应用标识、架构、离线标记、签名、模型清单及全部 20 个模型文件的 SHA256，包括 **4,760,339 字节的语音分词器 `tokenizer.json`**。这套模型校验适用于完整 0.2.0 及复用同一组模型的 0.2.1–0.2.3；未来更换模型时应使用对应发布的配套清单。

新装基准版应显示版本 `0.2.0`、构建号 `20260913-153743`。只有校验成功才继续；文件校验不代表麦克风、快捷键和自动输入已验证。

## 6. 手动升级一次，再使用应用内更新

完整 0.2.0 没有应用内更新入口，需要运行一次公开的轻量更新器。已核验可直接从完整 0.2.0 升级到 **0.2.3 / 20260914-003359**，无需先安装 0.2.1 或 0.2.2。

1. 从 [公开更新页](https://yinsn.github.io/FreeJot-Updates/) 下载更新包。agent 应先读取 `app-update.json`，选取与 `tag_name` 版本一致的唯一 `FreeJot-Update-X.Y.Z-AppleSilicon.zip` 附件，按其中的 `size` 与 `digest` 校验。拒绝未发布、预发布或不匹配的附件；不要仅以 `releases/latest` 推测包名。
2. 当前已核验包为 [FreeJot-Update-0.2.3-AppleSilicon.zip](https://github.com/yinsn/FreeJot-Updates/releases/download/v0.2.3/FreeJot-Update-0.2.3-AppleSilicon.zip)，大小 `26697875` 字节，SHA256 为 `e60ecd4e2b26767c080d08d2e4ea5c8499643615d7c3ef22aed63ced343d1046`。未来 feed 版本更高时，使用那次发布的元数据，不沿用这里的摘要。
3. 用 `ditto -x -k` 解压到新的更新文件夹，退出所有释手实例。不要强制终止正在听写的应用。
4. 打开解压出的 `FreeJotUpdater.app（释手更新器）`，选择刚才安装且校验通过的完整 `FreeJot.app`，点「开始更新」。建议安装卷预留约 7 GB。更新器会复用模型，核验并重建完整应用，再替换旧版，保留旧应用备份。
5. 完成后打开安装目录中的新版，在「设置 → 关于释手」核对版本与构建号，并重跑第 5 节校验。版本 0.2.2 及以后可直接「检查更新 → 下载并更新」。

有命令执行能力的 agent 可调用更新器已有的 CLI。先确认解压结果里唯一的更新器绝对路径，把它赋给 `task_updater`；不要使用 `--resources` 覆盖内置资源。`--check` 成功、释手已退出后才执行 `--apply`：

```sh
# task_updater = 已核实的 FreeJotUpdater.app 绝对路径
/usr/bin/codesign --verify --deep --strict "$task_updater"
"$task_updater/Contents/MacOS/FreeJotUpdater" --check '/Applications/FreeJot.app'
"$task_updater/Contents/MacOS/FreeJotUpdater" --apply '/Applications/FreeJot.app'
```

各命令必须成功才进入下一步。更新器报模型不匹配时保留原应用并排查，不更改模型来绕过检查。

## 7. 系统权限和实际验收

当前应用为自签名，未经过 Apple Developer ID 公证。首次打开被系统阻止时，由用户在确认来源后按「系统设置 → 隐私与安全性」提示允许打开；参考 [Apple 官方说明](https://support.apple.com/102445)。不要关闭 Gatekeeper、批量移除隔离属性或重签应用来绕过检查。

每台 Mac 都需要单独为释手授予「麦克风」「辅助功能」「输入监视」权限。这些系统确认由用户完成；agent 可以引导，不能声称已代替用户授权。授权后退出并重新打开同一份应用。

在设置里选择实际可用的快捷键。默认是 F16；MacBook 键盘没有 F16 时可选右 Option。等语音识别模型就绪后，在备忘录等可编辑文本区放好光标，按一次开始录音，说一句话，再按一次结束，确认文字出现并自动输入。不要一直按住按键。首次打开“保护第一个字”默认关闭，按用户需要设置。

完成条件必须逐项满足：

- 实际安装路径指向完整 `FreeJot.app`，签名、模型和分词器检查通过。
- 关于页版本与选用更新包一致；后续检查更新没有尚待安装的目标版本。
- 麦克风、辅助功能、输入监视权限已由用户确认。
- 在目标 Mac 上实际录音、转写和自动输入成功；同一时刻仅运行一份应用。

若只有前两项通过，应报告“文件安装与校验完成，等待系统授权和实际听写验收”，不能报告安装已经完全可用。向用户交付安装路径、版本/构建号、文件校验结果和仍需用户完成的具体步骤。确认成功后再由用户决定是否删除下载分卷、完整 ZIP 和旧版备份。

## 8. 常见故障

| 现象 | 含义与处理 |
| --- | --- |
| 缺少语音分词器 `tokenizer.json`，约 4.76 MB | 完整应用内应有该文件。核对选用的是否是完整包、四项下载是否校验成功、复制的是否为整个应用。重新取得并完整解压，不要从模型站点猜测下载地址、生成占位 JSON 或写入已签名应用 |
| 只下载了约 27 MB | 取得的是更新包，返回第 3 节获取约 5.37 GB 的完整包 |
| 完整包页面 404 / 下载 403 | 私有仓库访问权限不足或未登录。取得权限或由拥有者提供完整 ZIP；不是模型文件不存在 |
| 分卷缺失、大小不对或 SHA256 失败 | 四项文件放在同一目录、保持原名，仅重新取得失败项；全部通过后再运行助手 |
| 应用签名校验失败 | 解压、复制或内容发生变化。重新用完整原始包和 `ditto` 准备，不修改包内资源或重新签名 |
| 文件校验通过但没有声音 | 检查麦克风权限及系统输入设备 |
| 快捷键无效 | 检查当前快捷键、输入监视权限；默认 F16 可能不在当前键盘上 |
| 已转写但没有自动输入 | 检查辅助功能权限、目标文本区焦点，并重新打开释手 |
| 无法更新或模型不匹配 | 选中真实安装目录中的完整应用，先退出正在运行的实例，检查可用空间及第 5 节结果 |
