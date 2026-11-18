# BLACK GOLD · 双人健康管理

黑金风格的双人健康管理项目。当前仓库整理了可操作的 Web/PWA 核心原型、原生 Android Jetpack Compose 起始工程，以及 Supabase PostgreSQL 数据库草案。

## 当前包含

- `web/`：可在手机浏览器运行的记录型 Web/PWA 原型。
- `android/`：Kotlin + Jetpack Compose 原生 Android UI 起始工程。
- `supabase/migrations/`：双人账户、健康记录、授权共享、AI 对话、版本与回滚等数据库草案。
- `.github/workflows/`：Android Debug APK 自动构建工作流。

## 运行 Web 原型

可直接用浏览器打开 `web/index.html`；PWA 安装通常需要 HTTPS 或 localhost。Web 原型目前把数据保存在当前浏览器的 localStorage，可导入/导出 JSON。它不是云同步版本。

## 构建 Android APK

仓库推送到 `main` 后会触发 GitHub Actions。也可在 Actions 中手动运行 **Build BLACK GOLD APK**。成功后在对应 workflow run 的 Artifacts 下载 `BLACK-GOLD-debug-APK`。

Android 工程位于 `android/`，最低 Android API 26，使用 Java 17、Gradle 8.9、Android Gradle Plugin 8.7.3。

## 重要开发状态

**当前不是完整上线产品。** Android 端目前是原生界面起始骨架；Web 端已有本地记录原型。真实 AI 服务、双手机云端同步、账号邀请与授权流程、照片识别、设备/Health Connect 同步、通知和正式签名发布尚未完成。

数据库 SQL 是开发草案，尚未在真实 Supabase 项目执行或安全审计。请先在全新的开发环境测试，不要直接应用到生产数据库。

## 数据与隐私

本仓库目前为 Public，任何人都能查看代码。不要提交真实姓名、健康记录、身体/饮食照片、密码、API key、访问令牌或签名密钥。数据库设计默认健康记录长期保留、不自动清理；用户可主动删除或注销。双人资料默认相互独立，只有明确授权后才应共享。

## 开发与发布规则

采用 AI 辅助开发与自动测试；每次发布到正式环境前必须由项目所有者明确批准。保留历史版本与数据库备份，升级需具备回滚方案。