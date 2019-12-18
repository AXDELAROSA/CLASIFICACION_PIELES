-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			STORED PROCEDURES - BASICOS
-- // OPERACION:		LIBERACION
-- //////////////////////////////////////////////////////////////

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////



/*

	EXECUTE [dbo].[PG_BD_MASTER_SQL_BACKUP] 1, 0, 0

	EXECUTE [dbo].[PG_BD_MASTER_SQL_BACKUP] 0, 0, 0

	SELECT	F_BITACORA_SYS_EVENTO,
			D_BITACORA_SYS, C_BITACORA_SYS, STORED_PROCEDURE
	FROM	BITACORA_SYS
	ORDER BY K_BITACORA_SYS	DESC

	SELECT	*
	FROM	BITACORA_SYS

*/




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SQ_BACKUP_DATABASE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SQ_BACKUP_DATABASE]
GO


CREATE PROCEDURE [dbo].[PG_SQ_BACKUP_DATABASE]
	@PP_L_DEBUG					[INT],
	@PP_K_SISTEMA_EXE			[INT],
	@PP_K_USUARIO				[INT], 
	@PP_NOMBRE_BD				VARCHAR(200),
	@PP_DISPOSITIVO				VARCHAR(200)
AS

	EXECUTE	[dbo].[PG_IN_BITACORA_SYS_BASICO]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,												
									--			K_CLASE, K_IMPORTANCIA, K_GRUPO
												5, 6, 1,		-- #5-BD/SQL | #6-CRITICA | #1-BACKUP
												'BACKUP DATABASE', @PP_NOMBRE_BD,
												'[PG_SQ_BACKUP_DATABASE]', 0, 0
	-- ====================================

	BACKUP 
		DATABASE	@PP_NOMBRE_BD
		TO 			@PP_DISPOSITIVO
		WITH 		INIT ,
					NAME = 'TRA19 Respaldo/FLASH',
					DESCRIPTION = 'TRA19 -> [PG_BD_TRA19_SQL_BACKUP]'

	-- //////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_TRA19_SQL_BACKUP]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_TRA19_SQL_BACKUP]
GO


CREATE PROCEDURE [dbo].[PG_RN_TRA19_SQL_BACKUP]
	@PP_L_DEBUG					[INT],
	@PP_K_SISTEMA_EXE			[INT],
	@PP_K_USUARIO				[INT], 
	-- ===============================
	@OU_PREFIJO					VARCHAR(100)	OUTPUT,
	@OU_NOMBRE_BD				VARCHAR(100) 	OUTPUT,
	@OU_RUTA_RESPALDOS			VARCHAR(100)	OUTPUT
AS
	DECLARE @VP_PREFIJO			VARCHAR(100)
	DECLARE @VP_NOMBRE_BD		VARCHAR(100) 

	SET @VP_PREFIJO		= 'TRA19'
	SET @VP_NOMBRE_BD	= 'PEARL19_V9999_R0'
	
	-- ====================================
	
	DECLARE @VP_AMBIENTE	INT		
 
	EXECUTE [dbo].[PG_SK_CONFIGURACION_AMBIENTE_GET]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, 
														@OU_AMBIENTE = @VP_AMBIENTE			OUTPUT
	-- ====================================
	-- @VP_AMBIENTE = #0 N/A | #1 PROD | #2 PERF | #3 UAT | #4 CERT | #5 LAB | #6 UNIT | #7 DESA
	

	DECLARE @VP_RUTA_RESPALDOS		VARCHAR(255)
	
	SET @VP_RUTA_RESPALDOS	= 'C:\'	
	
	IF @VP_AMBIENTE IN ( 2 )		-- @VP_AMBIENTE = #2 PERF 
		SET @VP_RUTA_RESPALDOS	= 'D:\Tomza.SQL\'+@VP_PREFIJO+'_bak\'	-- SERVER PERF / BRUNO

	IF @VP_AMBIENTE IN ( 7 )		-- @VP_AMBIENTE = #7 DESA
		SET @VP_RUTA_RESPALDOS	= 'D:\Tomza.SQL\'+@VP_PREFIJO+'_bak\'	-- DESARROLLO / HGF
	
	-- ==================================== EXCEPCION

	SET @VP_RUTA_RESPALDOS	= 'D:\Tomza.SQL\'+@VP_PREFIJO+'_bak\'	-- DESARROLLO / HGF

	-- ====================================
	
--	IF @PP_L_DEBUG>0
--		SELECT @VP_PREFIJO AS PREFIJO, @VP_RUTA_RESPALDOS AS RUTA_RESPALDOS, @VP_AMBIENTE AS AMBIENTE

	SET @OU_PREFIJO			= @VP_PREFIJO
	SET @OU_NOMBRE_BD		= @VP_NOMBRE_BD
	SET @OU_RUTA_RESPALDOS	= @VP_RUTA_RESPALDOS

	-- //////////////////////////////////////////////////////////////
GO






-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_BD_ARCHIVO_BACKUP_ZIP]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_BD_ARCHIVO_BACKUP_ZIP]
GO



CREATE PROCEDURE [dbo].[PG_BD_ARCHIVO_BACKUP_ZIP]
	@PP_L_DEBUG					[INT],
	@PP_K_SISTEMA_EXE			[INT],
	@PP_K_USUARIO				[INT],
	@PP_RUTA_RESPALDOS			[VARCHAR] (255),
	@PP_DISPOSITIVO				[VARCHAR] (255)
AS
	-- ===============================================

    DECLARE @VP_SENTENCIA_DOS VARCHAR (500) = ''

--	=============================== USANDO EL ZIP.EXE
--	SET @VP_SENTENCIA_DOS = @PP_RUTA_RESPALDOS + 'ZIP ' + @PP_RUTA_RESPALDOS + @PP_DISPOSITIVO+'.zip'
--	SET @VP_SENTENCIA_DOS = @VP_SENTENCIA_DOS +     ' ' + @PP_RUTA_RESPALDOS + @PP_DISPOSITIVO+'.bak'

--	=============================== USANDO EL 7z.EXE
	SET @VP_SENTENCIA_DOS = @PP_RUTA_RESPALDOS + '7z.exe a ' + @PP_RUTA_RESPALDOS + @PP_DISPOSITIVO+'.zip'
	SET @VP_SENTENCIA_DOS = @VP_SENTENCIA_DOS  +         ' ' + @PP_RUTA_RESPALDOS + @PP_DISPOSITIVO+'.bak'

	-- ===============================================

	EXECUTE [dbo].[PG_SQ_EXECUTE_configure_xp_cmdshell_1]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO	

	-- ===============================================

	EXECUTE [dbo].[PG_SQ_EXECUTE_xp_cmdshell]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO, 
												@VP_SENTENCIA_DOS
	-- ======================================
	
	SET @VP_SENTENCIA_DOS = 'DEL "' + @PP_RUTA_RESPALDOS + @PP_DISPOSITIVO+'.bak"'
	
	EXECUTE [dbo].[PG_SQ_EXECUTE_xp_cmdshell]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO, 
												@VP_SENTENCIA_DOS

	-- ======================================

	EXECUTE [dbo].[PG_SQ_EXECUTE_configure_xp_cmdshell_0]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO	

	-- ===============================================
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_BD_TRA19_SQL_BACKUP]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_BD_TRA19_SQL_BACKUP]
GO


CREATE PROCEDURE [dbo].[PG_BD_TRA19_SQL_BACKUP]
	@PP_L_DEBUG					[INT],
	@PP_K_SISTEMA_EXE			[INT],
	@PP_K_USUARIO				[INT] 
AS
	
	DECLARE @VP_PREFIJO				VARCHAR(100)
	DECLARE @VP_NOMBRE_BD			VARCHAR(100) 
	DECLARE @VP_RUTA_RESPALDOS		VARCHAR(255)
	
	EXECUTE [dbo].[PG_RN_TRA19_SQL_BACKUP]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO, 
												@OU_PREFIJO			= @VP_PREFIJO			OUTPUT,
												@OU_NOMBRE_BD		= @VP_NOMBRE_BD			OUTPUT,
												@OU_RUTA_RESPALDOS	= @VP_RUTA_RESPALDOS	OUTPUT
	-- ====================================

	DECLARE @VP_STORED_PROCEDURE	VARCHAR(100)
	
	SET		@VP_STORED_PROCEDURE = 'PG_BD_SISTEMA_'+@VP_PREFIJO+'_SQL_BACKUP'

	-- ====================================

	EXECUTE	[dbo].[PG_IN_BITACORA_SYS_JOB_BACKUP_LIMITE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,	3

	-- ====================================

	EXECUTE	[dbo].[PG_IN_BITACORA_SYS_BASICO]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,												
									--			K_CLASE, K_IMPORTANCIA, K_GRUPO
												5, 6, 1,		-- #5-BD/SQL | #6-CRITICA | #1-BACKUP
												'INICIO - BACKUP', @VP_NOMBRE_BD,
												@VP_STORED_PROCEDURE, 0, 0
	-- ====================================

	DECLARE @VP_FECHA_HOY	DATETIME
	
	SET		@VP_FECHA_HOY = GETDATE()

	-- ====================================

	DECLARE @VP_FECHA_HOY_YYYYMMDD_HHMM AS VARCHAR(100)
	
	SET @VP_FECHA_HOY_YYYYMMDD_HHMM = ''
	SET @VP_FECHA_HOY_YYYYMMDD_HHMM = @VP_FECHA_HOY_YYYYMMDD_HHMM +				CONVERT( VARCHAR(10), YEAR(@VP_FECHA_HOY) )
	SET @VP_FECHA_HOY_YYYYMMDD_HHMM = @VP_FECHA_HOY_YYYYMMDD_HHMM +	RIGHT( ('0'+CONVERT( VARCHAR(10), MONTH(@VP_FECHA_HOY))), 2 )
	SET @VP_FECHA_HOY_YYYYMMDD_HHMM = @VP_FECHA_HOY_YYYYMMDD_HHMM +	RIGHT( ('0'+CONVERT( VARCHAR(10), DAY(@VP_FECHA_HOY))), 2 )
	SET @VP_FECHA_HOY_YYYYMMDD_HHMM = @VP_FECHA_HOY_YYYYMMDD_HHMM +	'_'
	SET @VP_FECHA_HOY_YYYYMMDD_HHMM = @VP_FECHA_HOY_YYYYMMDD_HHMM +'h'+	RIGHT( ('0'+CONVERT( VARCHAR(10), DATEPART(hh,@VP_FECHA_HOY))), 2 )
	SET @VP_FECHA_HOY_YYYYMMDD_HHMM = @VP_FECHA_HOY_YYYYMMDD_HHMM +'m'+	RIGHT( ('0'+CONVERT( VARCHAR(10), DATEPART(mi,@VP_FECHA_HOY))), 2 )
	
	-- ====================================

	DECLARE @VP_DISPOSITIVO			VARCHAR(255)
	DECLARE @VP_RUTA_Y_DISPOSITIVO	VARCHAR(255)

	-- ====================================

	SET @VP_DISPOSITIVO	=			'RESPALDO_' + @VP_NOMBRE_BD + '_' + @VP_FECHA_HOY_YYYYMMDD_HHMM  
	SET @VP_RUTA_Y_DISPOSITIVO =	@VP_RUTA_RESPALDOS + @VP_DISPOSITIVO + '.bak'

	-- ====================================
	
	EXECUTE [dbo].[PG_SQ_EXECUTE_sp_addumpdevice]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,
													@VP_DISPOSITIVO, @VP_RUTA_Y_DISPOSITIVO	
	-- ====================================

	EXECUTE	[dbo].[PG_SQ_BACKUP_DATABASE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,												
											@VP_NOMBRE_BD, @VP_DISPOSITIVO	
	-- ====================================
	
	EXECUTE [dbo].[PG_SQ_EXECUTE_sp_dropdevice]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,
													@VP_DISPOSITIVO, @VP_RUTA_Y_DISPOSITIVO	
	-- ====================================

	EXECUTE	[dbo].[PG_IN_BITACORA_SYS_JOB_BACKUP_LIMITE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,	1	

	-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////

	-- ====================================
	-- DEPURAR ARCHIVOS ANTERIORES
	
	EXECUTE [dbo].[PG_BD_DIRECTORIO_BACKUP_DEPURAR] @PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,
													@VP_RUTA_RESPALDOS, @VP_FECHA_HOY,  -3
	EXECUTE [dbo].[PG_BD_DIRECTORIO_BACKUP_DEPURAR] @PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,
													@VP_RUTA_RESPALDOS, @VP_FECHA_HOY,  -4
	EXECUTE [dbo].[PG_BD_DIRECTORIO_BACKUP_DEPURAR] @PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,
													@VP_RUTA_RESPALDOS, @VP_FECHA_HOY,  -5
	EXECUTE [dbo].[PG_BD_DIRECTORIO_BACKUP_DEPURAR] @PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,
													@VP_RUTA_RESPALDOS, @VP_FECHA_HOY,  -6
	EXECUTE [dbo].[PG_BD_DIRECTORIO_BACKUP_DEPURAR] @PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,
													@VP_RUTA_RESPALDOS, @VP_FECHA_HOY,  -7
	EXECUTE [dbo].[PG_BD_DIRECTORIO_BACKUP_DEPURAR] @PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,
													@VP_RUTA_RESPALDOS, @VP_FECHA_HOY,  -8

	-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////

	EXECUTE	[dbo].[PG_IN_BITACORA_SYS_JOB_BACKUP_LIMITE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,	1	


	EXECUTE [dbo].[PG_BD_ARCHIVO_BACKUP_ZIP]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,
													@VP_RUTA_RESPALDOS, @VP_DISPOSITIVO
	-- ====================================

	EXECUTE	[dbo].[PG_IN_BITACORA_SYS_JOB_BACKUP_LIMITE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO,	3

	-- ///////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////
-- EXECUTE [dbo].[PG_BD_MASTER_SQL_BACKUP] 0, 0, 0


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_BD_MASTER_SQL_BACKUP]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_BD_MASTER_SQL_BACKUP]
GO


CREATE PROCEDURE [dbo].[PG_BD_MASTER_SQL_BACKUP]
	@PP_L_DEBUG					[INT],
	@PP_K_SISTEMA_EXE			[INT],
	@PP_K_USUARIO				[INT] 
AS
				  
	EXECUTE [dbo].[PG_BD_TRA19_SQL_BACKUP]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, 
												@PP_K_USUARIO 
	-- ========================================
GO




-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
