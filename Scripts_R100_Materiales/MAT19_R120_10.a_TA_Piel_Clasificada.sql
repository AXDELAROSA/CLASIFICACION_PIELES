-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	PEARL19_V9999_R0
-- // MODULO:			PIEL_CLASIFICADA
-- // OPERACION:		LIBERACION / TABLAS
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	18/DIC/2019
-- ////////////////////////////////////////////////////////////// 

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TIPO_PIEL_CLASIFICADA]') AND type in (N'U'))
	DROP TABLE [dbo].[PIEL_PORCENTAJE_X_ESTATUS]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIEL_CLASIFICADA]') AND type in (N'U'))
	DROP TABLE [dbo].[PIEL_CLASIFICADA]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ESTATUS_PIEL_CLASIFICADA]') AND type in (N'U'))
	DROP TABLE [dbo].[ESTATUS_PIEL_CLASIFICADA]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TIPO_PIEL_CLASIFICADA]') AND type in (N'U'))
	DROP TABLE [dbo].[TIPO_PIEL_CLASIFICADA]
GO






-- //////////////////////////////////////////////////////////////
-- // TIPO_PIEL_CLASIFICADA
-- //////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[TIPO_PIEL_CLASIFICADA] (
	[K_TIPO_PIEL_CLASIFICADA]	[INT]				NOT NULL,
	[D_TIPO_PIEL_CLASIFICADA]	[VARCHAR] (100)		NOT NULL,
	[S_TIPO_PIEL_CLASIFICADA]	[VARCHAR] (10)		NOT NULL,
	[O_TIPO_PIEL_CLASIFICADA]	[INT]				NOT NULL,
	[C_TIPO_PIEL_CLASIFICADA]	[VARCHAR] (255)		NOT NULL,
	[L_TIPO_PIEL_CLASIFICADA]	[INT]				NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[TIPO_PIEL_CLASIFICADA]
	ADD CONSTRAINT [PK_TIPO_PIEL_CLASIFICADA]
		PRIMARY KEY CLUSTERED ([K_TIPO_PIEL_CLASIFICADA])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_TIPO_PIEL_CLASIFICADA_01_DESCRIPCION] 
	   ON [dbo].[TIPO_PIEL_CLASIFICADA] ( [D_TIPO_PIEL_CLASIFICADA] )
GO

-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[TIPO_PIEL_CLASIFICADA] ADD 
	CONSTRAINT [FK_TIPO_PIEL_CLASIFICADA_01] 
		FOREIGN KEY ( [L_TIPO_PIEL_CLASIFICADA] ) 
		REFERENCES [dbo].[ESTATUS_ACTIVO] ( [K_ESTATUS_ACTIVO] )
GO


-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_TIPO_PIEL_CLASIFICADA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_TIPO_PIEL_CLASIFICADA]
GO


CREATE PROCEDURE [dbo].[PG_CI_TIPO_PIEL_CLASIFICADA]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	-- ========================================
	@PP_K_TIPO_PIEL_CLASIFICADA		INT,
	@PP_D_TIPO_PIEL_CLASIFICADA		VARCHAR(100),
	@PP_S_TIPO_PIEL_CLASIFICADA		VARCHAR(10),
	@PP_O_TIPO_PIEL_CLASIFICADA		INT,
	@PP_C_TIPO_PIEL_CLASIFICADA		VARCHAR(255),
	@PP_L_TIPO_PIEL_CLASIFICADA		INT
AS
	
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_TIPO_PIEL_CLASIFICADA
							FROM	TIPO_PIEL_CLASIFICADA
							WHERE	K_TIPO_PIEL_CLASIFICADA=@PP_K_TIPO_PIEL_CLASIFICADA

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO TIPO_PIEL_CLASIFICADA	
			(	K_TIPO_PIEL_CLASIFICADA,				D_TIPO_PIEL_CLASIFICADA, 
				S_TIPO_PIEL_CLASIFICADA,				O_TIPO_PIEL_CLASIFICADA,
				C_TIPO_PIEL_CLASIFICADA,
				L_TIPO_PIEL_CLASIFICADA				)		
		VALUES	
			(	@PP_K_TIPO_PIEL_CLASIFICADA,			@PP_D_TIPO_PIEL_CLASIFICADA,	
				@PP_S_TIPO_PIEL_CLASIFICADA,			@PP_O_TIPO_PIEL_CLASIFICADA,
				@PP_C_TIPO_PIEL_CLASIFICADA,
				@PP_L_TIPO_PIEL_CLASIFICADA			)
	ELSE
		UPDATE	TIPO_PIEL_CLASIFICADA
		SET		D_TIPO_PIEL_CLASIFICADA	= @PP_D_TIPO_PIEL_CLASIFICADA,	
				S_TIPO_PIEL_CLASIFICADA	= @PP_S_TIPO_PIEL_CLASIFICADA,			
				O_TIPO_PIEL_CLASIFICADA	= @PP_O_TIPO_PIEL_CLASIFICADA,
				C_TIPO_PIEL_CLASIFICADA	= @PP_C_TIPO_PIEL_CLASIFICADA,
				L_TIPO_PIEL_CLASIFICADA	= @PP_L_TIPO_PIEL_CLASIFICADA	
		WHERE	K_TIPO_PIEL_CLASIFICADA=@PP_K_TIPO_PIEL_CLASIFICADA

	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////




-- ===============================================
SET NOCOUNT ON
-- ===============================================

EXECUTE [dbo].[PG_CI_TIPO_PIEL_CLASIFICADA] 0, 0, 0, '(SIN DEFINIR)',	'?????', 1, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_CLASIFICADA] 0, 0, 1, 'ROJA',		'ROJA', 1, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_CLASIFICADA] 0, 0, 2, 'NEGRA',		'NEGRA', 1, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_CLASIFICADA] 0, 0, 3, 'GRIS',		'GRIS', 1, '', 1
GO
-- ===============================================
SET NOCOUNT OFF
-- ===============================================








-- //////////////////////////////////////////////////////////////
-- // ESTATUS_PIEL_CLASIFICADA
-- //////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[ESTATUS_PIEL_CLASIFICADA] (
	[K_ESTATUS_PIEL_CLASIFICADA]	[INT]				NOT NULL,
	[D_ESTATUS_PIEL_CLASIFICADA]	[VARCHAR] (100)		NOT NULL,
	[S_ESTATUS_PIEL_CLASIFICADA]	[VARCHAR] (10)		NOT NULL,
	[O_ESTATUS_PIEL_CLASIFICADA]	[INT]				NOT NULL,
	[C_ESTATUS_PIEL_CLASIFICADA]	[VARCHAR] (255)		NOT NULL,
	[L_ESTATUS_PIEL_CLASIFICADA]	[INT]				NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[ESTATUS_PIEL_CLASIFICADA]
	ADD CONSTRAINT [PK_ESTATUS_PIEL_CLASIFICADA]
		PRIMARY KEY CLUSTERED ([K_ESTATUS_PIEL_CLASIFICADA])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_ESTATUS_PIEL_CLASIFICADA_01_DESCRIPCION] 
	   ON [dbo].[ESTATUS_PIEL_CLASIFICADA] ( [D_ESTATUS_PIEL_CLASIFICADA] )
GO

-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[ESTATUS_PIEL_CLASIFICADA] ADD 
	CONSTRAINT [FK_ESTATUS_PIEL_CLASIFICADA_01] 
		FOREIGN KEY ( [L_ESTATUS_PIEL_CLASIFICADA] ) 
		REFERENCES [dbo].[ESTATUS_ACTIVO] ( [K_ESTATUS_ACTIVO] )
GO


-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_ESTATUS_PIEL_CLASIFICADA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_ESTATUS_PIEL_CLASIFICADA]
GO


CREATE PROCEDURE [dbo].[PG_CI_ESTATUS_PIEL_CLASIFICADA]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	-- ========================================
	@PP_K_ESTATUS_PIEL_CLASIFICADA		INT,
	@PP_D_ESTATUS_PIEL_CLASIFICADA		VARCHAR(100),
	@PP_S_ESTATUS_PIEL_CLASIFICADA		VARCHAR(10),
	@PP_O_ESTATUS_PIEL_CLASIFICADA		INT,
	@PP_C_ESTATUS_PIEL_CLASIFICADA		VARCHAR(255),
	@PP_L_ESTATUS_PIEL_CLASIFICADA		INT
AS
	
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_ESTATUS_PIEL_CLASIFICADA
							FROM	ESTATUS_PIEL_CLASIFICADA
							WHERE	K_ESTATUS_PIEL_CLASIFICADA=@PP_K_ESTATUS_PIEL_CLASIFICADA

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO ESTATUS_PIEL_CLASIFICADA	
			(	K_ESTATUS_PIEL_CLASIFICADA,				D_ESTATUS_PIEL_CLASIFICADA, 
				S_ESTATUS_PIEL_CLASIFICADA,				O_ESTATUS_PIEL_CLASIFICADA,
				C_ESTATUS_PIEL_CLASIFICADA,
				L_ESTATUS_PIEL_CLASIFICADA				)		
		VALUES	
			(	@PP_K_ESTATUS_PIEL_CLASIFICADA,			@PP_D_ESTATUS_PIEL_CLASIFICADA,	
				@PP_S_ESTATUS_PIEL_CLASIFICADA,			@PP_O_ESTATUS_PIEL_CLASIFICADA,
				@PP_C_ESTATUS_PIEL_CLASIFICADA,
				@PP_L_ESTATUS_PIEL_CLASIFICADA			)
	ELSE
		UPDATE	ESTATUS_PIEL_CLASIFICADA
		SET		D_ESTATUS_PIEL_CLASIFICADA	= @PP_D_ESTATUS_PIEL_CLASIFICADA,	
				S_ESTATUS_PIEL_CLASIFICADA	= @PP_S_ESTATUS_PIEL_CLASIFICADA,			
				O_ESTATUS_PIEL_CLASIFICADA	= @PP_O_ESTATUS_PIEL_CLASIFICADA,
				C_ESTATUS_PIEL_CLASIFICADA	= @PP_C_ESTATUS_PIEL_CLASIFICADA,
				L_ESTATUS_PIEL_CLASIFICADA	= @PP_L_ESTATUS_PIEL_CLASIFICADA	
		WHERE	K_ESTATUS_PIEL_CLASIFICADA=@PP_K_ESTATUS_PIEL_CLASIFICADA

	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////




-- ===============================================
SET NOCOUNT ON
-- ===============================================

--EXECUTE [dbo].[PG_CI_ESTATUS_PIEL_CLASIFICADA] 0, 0, 0, '(SIN DEFINIR)',		'?????', 1, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_PIEL_CLASIFICADA] 0, 0, 1, 'BUENA',		'BUENA', 1, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_PIEL_CLASIFICADA] 0, 0, 2, 'REGULAR',		'REGUL', 1, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_PIEL_CLASIFICADA] 0, 0, 3, 'MALA',			'MALA', 1, '', 1
GO
-- ===============================================
SET NOCOUNT OFF
-- ===============================================




-- //////////////////////////////////////////////////////////////
-- // PIEL_CLASIFICADA
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[PIEL_CLASIFICADA] (
	[K_PIEL_CLASIFICADA]					[INT]			NOT NULL,
	[D_PIEL_CLASIFICADA]					[VARCHAR](100)	NOT NULL,
	[S_PIEL_CLASIFICADA]					[VARCHAR](10)	NOT NULL,
	[O_PIEL_CLASIFICADA]					[INT]			NOT NULL DEFAULT 1,
	[C_PIEL_CLASIFICADA]					[VARCHAR](255)	NOT NULL DEFAULT '',
	[L_PIEL_CLASIFICADA]					[INT]			NOT NULL DEFAULT 1,
	-- ============================
	[K_PIEL_LOTE]							[INT]			NOT NULL,	
	[K_ESTATUS_PIEL_CLASIFICADA]			[INT]			NOT NULL,
	[K_TIPO_PIEL_CLASIFICADA]				[INT]			NOT NULL
) ON [PRIMARY]
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[PIEL_CLASIFICADA]
	ADD CONSTRAINT [PK_PIEL_CLASIFICADA]
		PRIMARY KEY CLUSTERED ([K_PIEL_CLASIFICADA])
GO

-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[PIEL_CLASIFICADA] ADD 
	CONSTRAINT [FK_PIEL_CLASIFICADA_01]  
		FOREIGN KEY ([K_ESTATUS_PIEL_CLASIFICADA]) 
		REFERENCES [dbo].[ESTATUS_PIEL_CLASIFICADA] ([K_ESTATUS_PIEL_CLASIFICADA]),
	CONSTRAINT [FK_PIEL_CLASIFICADA_02]
		FOREIGN KEY ([K_TIPO_PIEL_CLASIFICADA]) 
		REFERENCES [dbo].[TIPO_PIEL_CLASIFICADA] ([K_TIPO_PIEL_CLASIFICADA])
GO

/* --COMENTADAS PARA RECONSTRUIR 
ALTER TABLE [dbo].[PIEL_CLASIFICADA] ADD 
	CONSTRAINT [FK_PIEL_CLASIFICADA_03]  
		FOREIGN KEY ([K_PUNTO]) 
		REFERENCES [dbo].[PUNTO] ([K_PUNTO])
GO
*/
-- //////////////////////////////////////////////////////


ALTER TABLE [dbo].[PIEL_CLASIFICADA] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO


ALTER TABLE [dbo].[PIEL_CLASIFICADA] ADD 
	CONSTRAINT [FK_PIEL_CLASIFICADA_USUARIO_ALTA]  
		FOREIGN KEY ([K_USUARIO_ALTA]) 
		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
	CONSTRAINT [FK_PIEL_CLASIFICADA_USUARIO_CAMBIO]  
		FOREIGN KEY ([K_USUARIO_CAMBIO]) 
		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
	CONSTRAINT [FK_PIEL_CLASIFICADA_USUARIO_BAJA]  
		FOREIGN KEY ([K_USUARIO_BAJA]) 
		REFERENCES [dbo].[USUARIO] ([K_USUARIO])

GO

-- //////////////////////////////////////////////////////////////
-- // PIEL_PORCENTAJE_X_ESTATUS
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[PIEL_PORCENTAJE_X_ESTATUS] (
	[K_PIEL_PORCENTAJE_X_ESTATUS]			[INT]			NOT NULL,
	-- ============================	
	[K_PIEL_LOTE]							[INT]			NOT NULL,
	[PIEL_LOTE_CANTIDAD]					[INT]			NOT NULL,
	[PIEL_PORCENTAJE_BUENO]					[DECIMAL](19,4)	NOT NULL,
	[PIEL_PORCENTAJE_REGULAR]				[DECIMAL](19,4)	NOT NULL,
	[PIEL_PORCENTAJE_MALO]					[DECIMAL](19,4)	NOT NULL,
) ON [PRIMARY]
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[PIEL_PORCENTAJE_X_ESTATUS]
	ADD CONSTRAINT [PK_PIEL_PORCENTAJE_X_ESTATUS]
		PRIMARY KEY CLUSTERED ([K_PIEL_PORCENTAJE_X_ESTATUS])
GO


-- //////////////////////////////////////////////////////////////

ALTER TABLE [dbo].[PIEL_PORCENTAJE_X_ESTATUS] ADD 
	CONSTRAINT [FK_PIEL_PORCENTAJE_X_ESTATUS_01]  
		FOREIGN KEY ([K_PIEL_LOTE]) 
		REFERENCES [dbo].[PIEL_LOTE] ([K_PIEL_LOTE])
GO

-- //////////////////////////////////////////////////////////////











-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
