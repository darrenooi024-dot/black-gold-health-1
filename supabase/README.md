# Supabase 数据库草案

`migrations/202611180001_initial_schema.sql` 是初始数据库设计草案，包含个人资料、双人关系、共享授权、健康记录、AI 对话、提醒、升级/测试/版本与回滚记录等表，并启用 Row Level Security。

**尚未部署或安全审计。** 先在新的 Supabase 开发项目中测试。不要把 Service Role Key、数据库密码或用户健康数据放进 Git。生产上线前需由开发者审查 RLS、关系邀请/共享授权和服务端管理策略。