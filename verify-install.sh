#!/bin/zsh -f
# Read-only validation of the complete offline model set shared by 0.2.0–0.2.20.
# Keep model-sha256.txt beside this script. No downloads, installs, or repair.
set -euo pipefail
fail() { print -u2 -- "校验未通过：$*"; exit 1; }
(( $# == 1 )) || fail '用法：/bin/zsh verify-install.sh /Applications/FreeJot.app'
task_app=${1:A}
task_checksums=${0:A:h}/model-sha256.txt
task_models="$task_app/Contents/Resources/Models"
[[ -d "$task_app" ]] || fail '应用不存在。新机器请先按 INSTALL.md 安装完整离线包。'
[[ -f "$task_checksums" && ! -L "$task_checksums" ]] || fail '请从下载页取得配套 model-sha256.txt 并放在脚本旁。'
[[ -f "$task_app/Contents/Info.plist" ]] || fail '应用缺少 Info.plist。'
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$task_app/Contents/Info.plist")" == dev.yin.freejot ]] || fail '所选文件不是 FreeJot.app。'
[[ -f "$task_app/Contents/Resources/OfflineModelBundle.json" && -d "$task_models" ]] || fail '这份应用没有完整离线模型。轻量更新包不能用于新机器首次安装。'
task_tokenizer="$task_models/asr/qwen3-asr-1.7b-bf16/tokenizer.json"
[[ -f "$task_tokenizer" && ! -L "$task_tokenizer" ]] || fail '缺少语音分词器 tokenizer.json（4,760,339 字节）。请重新取得并解压完整离线包，不要单独生成或补入签名应用。'
[[ "$(/usr/bin/stat -f %z "$task_tokenizer")" == 4760339 ]] || fail '语音分词器大小不匹配。请按 INSTALL.md 核对完整包和解压结果。'
[[ "$(/usr/bin/lipo -archs "$task_app/Contents/MacOS/FreeJot")" == arm64 ]] || fail '这不是预期的 Apple Silicon 应用。'
/usr/bin/codesign --verify --deep --strict "$task_app" || fail '应用签名校验失败。请重新取得完整包；不要修改包内文件或重新签名。'
print -- '正在逐项校验全部模型和清单，约需读取 6.4 GB…'
(cd "$task_models" && /usr/bin/shasum -a 256 -c "$task_checksums") || fail '模型文件缺失、损坏或属于另一组模型。请核对完整安装版本。'
task_version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$task_app/Contents/Info.plist")
task_build=$(/usr/libexec/PlistBuddy -c 'Print :FreeJotBuildID' "$task_app/Contents/Info.plist")
print -- "文件校验通过：FreeJot $task_version · $task_build"
print -- '还需在目标 Mac 授予系统权限，并完成一次真实听写和自动输入，才能确认安装可用。'
