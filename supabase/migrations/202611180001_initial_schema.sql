-- BLACK GOLD Database V1.0 | Supabase PostgreSQL
-- Draft migration. Test in a NEW development project before production.
-- Health history has no automatic expiry or retention deletion job.
begin;
create extension if not exists pgcrypto;

create table public.profiles (
 user_id uuid primary key references auth.users(id) on delete cascade,
 display_name text, date_of_birth date,
 height_cm numeric(5,2) check(height_cm is null or height_cm between 50 and 260),
 timezone text not null default 'Asia/Kuala_Lumpur',
 preferred_language text not null default 'zh',
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 deletion_requested_at timestamptz
);

create table public.couples (
 id uuid primary key default gen_random_uuid(),
 status text not null default 'pending' check(status in ('pending','active','ended')),
 created_by uuid not null references public.profiles(user_id),
 created_at timestamptz not null default now(), activated_at timestamptz, ended_at timestamptz
);
create table public.couple_members (
 couple_id uuid not null references public.couples(id) on delete cascade,
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 member_status text not null default 'invited' check(member_status in ('invited','active','left')),
 joined_at timestamptz, primary key(couple_id,user_id)
);
create unique index one_active_couple_per_user on public.couple_members(user_id)
 where member_status='active';

create table public.sharing_permissions (
 id uuid primary key default gen_random_uuid(),
 couple_id uuid not null references public.couples(id) on delete cascade,
 owner_id uuid not null references public.profiles(user_id) on delete cascade,
 recipient_id uuid not null references public.profiles(user_id) on delete cascade,
 data_category text not null check(data_category in
 ('weight_trend','body_metrics','steps','activity','exercise','nutrition_summary',
 'water_summary','sleep_summary','weekly_progress','achievements')),
 permission_status text not null default 'revoked' check(permission_status in ('granted','revoked')),
 granted_at timestamptz, revoked_at timestamptz, created_at timestamptz not null default now(),
 check(owner_id<>recipient_id), unique(couple_id,owner_id,recipient_id,data_category)
);

create table public.health_goals (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 goal_type text not null, target_value numeric(12,3), unit text,
 start_date date not null, target_date date,
 status text not null default 'active' check(status in ('active','completed','paused','cancelled')),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 check(target_date is null or target_date>=start_date)
);
create table public.weight_records (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 weight_kg numeric(6,2) not null check(weight_kg>0 and weight_kg<500),
 session_type text not null check(session_type in ('morning','evening','other')),
 source text not null default 'manual' check(source in ('manual','device','photo_ai','import')),
 recorded_at timestamptz not null, notes text, created_at timestamptz not null default now()
);
create table public.body_metrics (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 weight_kg numeric(6,2), body_fat_pct numeric(5,2), fat_mass_kg numeric(6,2),
 muscle_mass_kg numeric(6,2), skeletal_muscle_kg numeric(6,2),
 body_water_pct numeric(5,2), visceral_fat numeric(6,2), bone_mass_kg numeric(6,2),
 bmr_kcal integer, bmi numeric(5,2), resting_heart_rate integer,
 source text not null default 'manual', device_name text,
 recorded_at timestamptz not null, created_at timestamptz not null default now()
);
create table public.body_measurements (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 waist_cm numeric(6,2), abdomen_cm numeric(6,2), chest_cm numeric(6,2),
 thigh_cm numeric(6,2), arm_cm numeric(6,2), recorded_at timestamptz not null,
 created_at timestamptz not null default now(),
 check(num_nonnulls(waist_cm,abdomen_cm,chest_cm,thigh_cm,arm_cm)>0)
);
create table public.health_photos (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 storage_path text not null unique,
 photo_type text not null check(photo_type in ('front','side','back','other')),
 taken_at timestamptz not null, sharing_enabled boolean not null default false,
 created_at timestamptz not null default now()
);

create table public.food_records (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 meal_type text not null check(meal_type in ('breakfast','lunch','dinner','snack','other')),
 food_name text not null, portion_description text, quantity numeric(10,2), quantity_unit text,
 calories_kcal numeric(9,2), protein_g numeric(8,2), carbs_g numeric(8,2),
 fat_g numeric(8,2), fiber_g numeric(8,2), sugar_g numeric(8,2),
 estimation_min_kcal numeric(9,2), estimation_max_kcal numeric(9,2),
 source text not null default 'manual' check(source in ('manual','photo_ai','barcode','import')),
 confidence numeric(4,3) check(confidence is null or confidence between 0 and 1),
 image_storage_path text, consumed_at timestamptz not null, created_at timestamptz not null default now(),
 check(estimation_min_kcal is null or estimation_max_kcal is null or estimation_min_kcal<=estimation_max_kcal)
);
create table public.water_records (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 volume_ml integer not null check(volume_ml>0 and volume_ml<=10000),
 source text not null default 'manual', recorded_at timestamptz not null,
 created_at timestamptz not null default now()
);

create table public.activity_records (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 activity_type text not null check(activity_type in ('walking','cycling','motorcycle','stationary','other')),
 steps integer check(steps is null or steps>=0), distance_m numeric(12,2),
 duration_seconds integer, estimated_calories_kcal numeric(9,2),
 detection_source text not null default 'manual',
 confidence numeric(4,3), started_at timestamptz not null, ended_at timestamptz,
 created_at timestamptz not null default now(), check(ended_at is null or ended_at>=started_at)
);
create table public.exercise_sessions (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 exercise_type text not null, title text, duration_seconds integer, distance_m numeric(12,2),
 estimated_calories_kcal numeric(9,2),
 intensity text check(intensity is null or intensity in ('low','moderate','high','unknown')),
 source text not null default 'manual', notes text, started_at timestamptz not null,
 ended_at timestamptz, created_at timestamptz not null default now(),
 check(ended_at is null or ended_at>=started_at)
);
create table public.exercise_details (
 id uuid primary key default gen_random_uuid(),
 session_id uuid not null references public.exercise_sessions(id) on delete cascade,
 detail_type text not null, detail_data jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now()
);
create table public.swim_sessions (
 id uuid primary key default gen_random_uuid(),
 exercise_session_id uuid not null unique references public.exercise_sessions(id) on delete cascade,
 pool_length_m numeric(6,2), pool_width_m numeric(6,2), lap_count integer,
 distance_m numeric(10,2),
 stroke_type text check(stroke_type is null or stroke_type in
 ('freestyle','breaststroke','backstroke','butterfly','mixed','other')),
 rest_seconds integer, pool_name text, perceived_effort text
);
create table public.sleep_records (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 sleep_started_at timestamptz not null, wake_at timestamptz not null,
 awakenings integer, quality_score integer check(quality_score is null or quality_score between 1 and 5),
 source text not null default 'manual', notes text, created_at timestamptz not null default now(),
 check(wake_at>sleep_started_at)
);

create table public.device_connections (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 provider text not null, device_name text, device_model text,
 connection_status text not null default 'pending'
 check(connection_status in ('pending','connected','disconnected','error')),
 last_sync_at timestamptz, created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table public.device_sync_logs (
 id uuid primary key default gen_random_uuid(),
 device_connection_id uuid not null references public.device_connections(id) on delete cascade,
 sync_started_at timestamptz not null default now(), sync_finished_at timestamptz,
 sync_status text not null check(sync_status in ('running','success','partial','failed')),
 records_received integer not null default 0, error_code text, error_message text
);

create table public.ai_conversations (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 title text, conversation_type text not null default 'coach',
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.ai_messages (
 id uuid primary key default gen_random_uuid(),
 conversation_id uuid not null references public.ai_conversations(id) on delete cascade,
 role text not null check(role in ('user','assistant','system','tool')),
 content text not null, attachment_storage_path text, created_at timestamptz not null default now()
);
create table public.ai_insights (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 insight_type text not null, insight_text text not null, confidence numeric(4,3),
 generated_at timestamptz not null default now()
);
create table public.daily_reports (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 report_date date not null, report_data jsonb not null, generated_at timestamptz not null default now(),
 unique(user_id,report_date)
);
create table public.weekly_reports (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 week_start date not null, report_data jsonb not null, generated_at timestamptz not null default now(),
 unique(user_id,week_start)
);
create table public.monthly_reports (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 month_start date not null, report_data jsonb not null, generated_at timestamptz not null default now(),
 unique(user_id,month_start)
);
create table public.user_reminders (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 reminder_type text not null, local_time time, enabled boolean not null default true,
 weekdays smallint[] not null default array[1,2,3,4,5,6,7],
 created_at timestamptz not null default now()
);
create table public.notifications (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles(user_id) on delete cascade,
 title text not null, body text not null, notification_type text not null,
 read_at timestamptz, created_at timestamptz not null default now()
);

create table public.upgrade_requests (
 id uuid primary key default gen_random_uuid(),
 submitted_by uuid not null references public.profiles(user_id) on delete cascade,
 title text not null, description text not null,
 status text not null default 'submitted'
 check(status in ('submitted','reviewing','approved_for_dev','in_development','testing',
 'awaiting_release_approval','rejected','released')),
 created_at timestamptz not null default now()
);
create table public.development_tasks (
 id uuid primary key default gen_random_uuid(),
 upgrade_request_id uuid references public.upgrade_requests(id) on delete set null,
 task_description text not null,
 status text not null default 'queued'
 check(status in ('queued','running','blocked','completed','failed')),
 created_at timestamptz not null default now(), completed_at timestamptz
);
create table public.test_runs (
 id uuid primary key default gen_random_uuid(),
 development_task_id uuid references public.development_tasks(id) on delete cascade,
 environment text not null check(environment in ('development','staging','production')),
 status text not null check(status in ('running','passed','failed','cancelled')),
 summary text, started_at timestamptz not null default now(), finished_at timestamptz
);
create table public.app_versions (
 id uuid primary key default gen_random_uuid(), version_name text not null unique,
 build_number integer not null unique,
 release_channel text not null default 'internal'
 check(release_channel in ('internal','beta','production')),
 release_notes text, artifact_storage_path text, created_at timestamptz not null default now()
);
create table public.release_approvals (
 id uuid primary key default gen_random_uuid(),
 app_version_id uuid not null references public.app_versions(id) on delete cascade,
 approver_id uuid not null references public.profiles(user_id) on delete cascade,
 decision text not null check(decision in ('approved','rejected')),
 decided_at timestamptz not null default now(), notes text
);
create table public.release_history (
 id uuid primary key default gen_random_uuid(),
 app_version_id uuid not null references public.app_versions(id),
 released_by uuid references public.profiles(user_id),
 released_at timestamptz not null default now(), release_channel text not null
);
create table public.rollback_history (
 id uuid primary key default gen_random_uuid(),
 from_version_id uuid references public.app_versions(id),
 to_version_id uuid references public.app_versions(id),
 reason text not null, initiated_at timestamptz not null default now()
);

-- Query indexes
create index idx_weight_user_time on public.weight_records(user_id,recorded_at desc);
create index idx_metrics_user_time on public.body_metrics(user_id,recorded_at desc);
create index idx_food_user_time on public.food_records(user_id,consumed_at desc);
create index idx_water_user_time on public.water_records(user_id,recorded_at desc);
create index idx_activity_user_time on public.activity_records(user_id,started_at desc);
create index idx_exercise_user_time on public.exercise_sessions(user_id,started_at desc);
create index idx_sleep_user_time on public.sleep_records(user_id,sleep_started_at desc);
create index idx_ai_conversations_user_time on public.ai_conversations(user_id,updated_at desc);

-- Enable RLS everywhere; owner-only access for private user rows.
do $$ declare t text; begin
 foreach t in array array[
 'profiles','couples','couple_members','sharing_permissions','health_goals','weight_records',
 'body_metrics','body_measurements','health_photos','food_records','water_records',
 'activity_records','exercise_sessions','exercise_details','swim_sessions','sleep_records',
 'device_connections','device_sync_logs','ai_conversations','ai_messages','ai_insights',
 'daily_reports','weekly_reports','monthly_reports','user_reminders','notifications',
 'upgrade_requests','development_tasks','test_runs','app_versions','release_approvals',
 'release_history','rollback_history'
 ] loop execute format('alter table public.%I enable row level security',t); end loop;
end $$;

-- Authenticated user can access only their own records.
do $$ declare t text; begin
 foreach t in array array[
 'health_goals','weight_records','body_metrics','body_measurements','health_photos',
 'food_records','water_records','activity_records','exercise_sessions','sleep_records',
 'device_connections','ai_insights','daily_reports','weekly_reports','monthly_reports',
 'user_reminders','notifications','upgrade_requests'
 ] loop
 execute format(
 'create policy %I on public.%I for all to authenticated using (user_id=(select auth.uid())) with check (user_id=(select auth.uid()))',
 'owner_all_'||t,t);
 end loop;
end $$;

create policy profile_owner_select on public.profiles for select to authenticated
 using(user_id=(select auth.uid()));
create policy profile_owner_insert on public.profiles for insert to authenticated
 with check(user_id=(select auth.uid()));
create policy profile_owner_update on public.profiles for update to authenticated
 using(user_id=(select auth.uid())) with check(user_id=(select auth.uid()));

create policy couple_member_select on public.couples for select to authenticated using
 (exists(select 1 from public.couple_members cm where cm.couple_id=couples.id
 and cm.user_id=(select auth.uid())));
create policy couple_member_select_members on public.couple_members for select to authenticated using
 (user_id=(select auth.uid()) or exists(select 1 from public.couple_members cm
 where cm.couple_id=couple_members.couple_id and cm.user_id=(select auth.uid())
 and cm.member_status='active'));
create policy sharing_permission_participant_select on public.sharing_permissions
 for select to authenticated using(owner_id=(select auth.uid()) or recipient_id=(select auth.uid()));

-- Child-table policies inherit ownership from parent records.
create policy exercise_details_owner_all on public.exercise_details for all to authenticated
 using(exists(select 1 from public.exercise_sessions s where s.id=session_id and s.user_id=(select auth.uid())))
 with check(exists(select 1 from public.exercise_sessions s where s.id=session_id and s.user_id=(select auth.uid())));
create policy swim_sessions_owner_all on public.swim_sessions for all to authenticated
 using(exists(select 1 from public.exercise_sessions s where s.id=exercise_session_id and s.user_id=(select auth.uid())))
 with check(exists(select 1 from public.exercise_sessions s where s.id=exercise_session_id and s.user_id=(select auth.uid())));
create policy ai_messages_owner_all on public.ai_messages for all to authenticated
 using(exists(select 1 from public.ai_conversations c where c.id=conversation_id and c.user_id=(select auth.uid())))
 with check(exists(select 1 from public.ai_conversations c where c.id=conversation_id and c.user_id=(select auth.uid())));
create policy device_sync_logs_owner_select on public.device_sync_logs for select to authenticated
 using(exists(select 1 from public.device_connections d where d.id=device_connection_id and d.user_id=(select auth.uid())));

-- No client write policies for relationship grants or release/system tables.
-- Server-side Edge Functions with narrowly scoped privileges must manage these.
commit;