USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'1555a341-5597-4079-be59-dd71ebc041c9', @step_name=N'PrintMessage', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'PRINT ''I am a job''', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_id=N'1555a341-5597-4079-be59-dd71ebc041c9', @step_name=N'dummyStep2', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'PRINT ''I am job step2''', 
		@database_name=N'master', 
		@flags=0
GO
