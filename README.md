# 释手 / FreeJot 安装与更新

下载首页：https://yinsn.github.io/FreeJot-Updates/

本仓库公开提供下载页面、安装文档、校验信息和程序更新包。

## 新 Mac 首次安装

先读 [完整安装指南](https://yinsn.github.io/FreeJot-Updates/INSTALL.md) 或 [网页版](https://yinsn.github.io/FreeJot-Updates/install.html)。完整 0.2.0 安装包包含两个模型，约 5.37 GB，需先安装再更新到当前版本。完整包仍在私有 `yinsn/FreeJot` 仓库，需要有权限的 GitHub 账号；也可由拥有者提供相同的完整 ZIP。访问失败时按指南处理，不要使用轻量更新包代替。

agent 入口：[llms.txt](https://yinsn.github.io/FreeJot-Updates/llms.txt) · [install.json](https://yinsn.github.io/FreeJot-Updates/install.json)。文档有分卷、完整 ZIP、全部模型和应用签名的验证方法，包括 `tokenizer.json` 缺失处理。只有系统权限确认且实际听写成功，才能报告安装可用。

## 已有完整离线版

使用公开的轻量更新包，复用本机模型。0.2.1 及更早版本需手动升级一次；完整 0.2.0 可直接升级到 0.2.3，无需逐版安装。0.2.2 及以后可在「设置 → 关于释手 → 检查更新」完成后续升级。

应用读取 `app-update.json` 获取最新正式版本。语音识别与文字整理仍在本机进行；检查和下载更新仅在用户主动操作时发生。

页面和文档源文件由主项目的 `Resources/Updates/` 维护；分发仓库只保存公开文件，不包含应用源码或用户数据。
