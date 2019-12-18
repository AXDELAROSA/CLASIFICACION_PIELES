-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			USUARIO_X_RAS 
-- // OPERACION:		LIBERACION / TABLAS 
-- ////////////////////////////////////////////////////////////// 

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////

   



-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS3_ACCESO_USR_X_RAS]') AND type in (N'U'))
	DROP TABLE [dbo].[SYS3_ACCESO_USR_X_RAS]
GO


-- //////////////////////////////////////////////////////////////
-- // USUARIO_X_RAS
-- //////////////////////////////////////////////////////////////
-- SELECT * FROM [SYS3_ACCESO_USR_X_RAS]

CREATE TABLE [dbo].[SYS3_ACCESO_USR_X_RAS] (
	[K_SISTEMA]				[INT]	NOT NULL DEFAULT 0,
	[K_USUARIO]				[INT]	NOT NULL,
	[K_RAZON_SOCIAL]		[INT]	NOT NULL,
	[L_ACCESO]				[INT]	NOT NULL DEFAULT 0
) ON [PRIMARY]
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[SYS3_ACCESO_USR_X_RAS]
	ADD CONSTRAINT [PK_USUARIO_X_RAS]
		PRIMARY KEY CLUSTERED ( [K_SISTEMA], [K_USUARIO], [K_RAZON_SOCIAL] )
GO

-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[SYS3_ACCESO_USR_X_RAS] ADD 
	CONSTRAINT [FK_SYS3_ACCESO_USR_X_RAS]  
		FOREIGN KEY ([K_RAZON_SOCIAL]) 
		REFERENCES [dbo].[RAZON_SOCIAL] ([K_RAZON_SOCIAL])
GO


/*

ALTER TABLE [dbo].[SYS3_ACCESO_USR_X_RAS] ADD 
	CONSTRAINT [FK_SYS3_ACCESO_USR_X_RAS_01]  
		FOREIGN KEY ([K_USUARIO]) 
		REFERENCES [dbo].[USUARIO] ([K_USUARIO])
	
GO

*/

-- //////////////////////////////////////////////////////


ALTER TABLE [dbo].[SYS3_ACCESO_USR_X_RAS] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO


ALTER TABLE [dbo].[SYS3_ACCESO_USR_X_RAS] ADD 
	CONSTRAINT [FK_SYS3_ACCESO_USR_X_RAS_USUARIO_ALTA]  
		FOREIGN KEY ([K_USUARIO_ALTA]) 
		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
	CONSTRAINT [FK_SYS3_ACCESO_USR_X_RAS_USUARIO_CAMBIO]  
		FOREIGN KEY ([K_USUARIO_CAMBIO]) 
		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
	CONSTRAINT [FK_SYS3_ACCESO_USR_X_RAS_USUARIO_BAJA]  
		FOREIGN KEY ([K_USUARIO_BAJA]) 
		REFERENCES [dbo].[USUARIO] ([K_USUARIO])
GO



-- //////////////////////////////////////////////////////
-- //
-- //////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_SYS3_ACCESO_USR_X_RAS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_SYS3_ACCESO_USR_X_RAS]
GO


CREATE PROCEDURE [dbo].[PG_CI_SYS3_ACCESO_USR_X_RAS]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- =============================
	@PP_K_USUARIO				INT,
	@PP_K_RAZON_SOCIAL			INT,
	@PP_L_ACCESO				INT
AS	

	INSERT INTO SYS3_ACCESO_USR_X_RAS
		(	[K_SISTEMA], 
			[K_USUARIO],		[K_RAZON_SOCIAL],
			[L_ACCESO],	
			-- ===========================
			[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], 
			[F_CAMBIO], [L_BORRADO], [K_USUARIO_BAJA], [F_BAJA] 		)	
	VALUES	
		(	@PP_K_SISTEMA_EXE, 
			@PP_K_USUARIO,		@PP_K_RAZON_SOCIAL,
			@PP_L_ACCESO,
			-- ===========================
			@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
			0, NULL, NULL		)			

	-- ==============================================
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
