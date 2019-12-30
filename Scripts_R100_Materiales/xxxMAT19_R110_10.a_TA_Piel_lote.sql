-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	PEARL19_V9999_R0
-- // MODULO:			PIEL_LOTE
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


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIEL_LOTE]') AND type in (N'U'))
	DROP TABLE [dbo].[PIEL_LOTE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ESTATUS_PIEL_LOTE]') AND type in (N'U'))
	DROP TABLE [dbo].[ESTATUS_PIEL_LOTE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TIPO_PIEL_LOTE]') AND type in (N'U'))
	DROP TABLE [dbo].[TIPO_PIEL_LOTE]
GO






-- //////////////////////////////////////////////////////////////
-- // TIPO_PIEL_LOTE
-- //////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[TIPO_PIEL_LOTE] (
	[K_TIPO_PIEL_LOTE]	[INT]				NOT NULL,
	[D_TIPO_PIEL_LOTE]	[VARCHAR] (100)		NOT NULL,
	[S_TIPO_PIEL_LOTE]	[VARCHAR] (10)		NOT NULL,
	[O_TIPO_PIEL_LOTE]	[INT]				NOT NULL,
	[C_TIPO_PIEL_LOTE]	[VARCHAR] (255)		NOT NULL,
	[L_TIPO_PIEL_LOTE]	[INT]				NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[TIPO_PIEL_LOTE]
	ADD CONSTRAINT [PK_TIPO_PIEL_LOTE]
		PRIMARY KEY CLUSTERED ([K_TIPO_PIEL_LOTE])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_TIPO_PIEL_LOTE_01_DESCRIPCION] 
	   ON [dbo].[TIPO_PIEL_LOTE] ( [D_TIPO_PIEL_LOTE] )
GO

-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[TIPO_PIEL_LOTE] ADD 
	CONSTRAINT [FK_TIPO_PIEL_LOTE_01] 
		FOREIGN KEY ( [L_TIPO_PIEL_LOTE] ) 
		REFERENCES [dbo].[ESTATUS_ACTIVO] ( [K_ESTATUS_ACTIVO] )
GO


-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_TIPO_PIEL_LOTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_TIPO_PIEL_LOTE]
GO


CREATE PROCEDURE [dbo].[PG_CI_TIPO_PIEL_LOTE]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	-- ========================================
	@PP_K_TIPO_PIEL_LOTE		INT,
	@PP_D_TIPO_PIEL_LOTE		VARCHAR(100),
	@PP_S_TIPO_PIEL_LOTE		VARCHAR(10),
	@PP_O_TIPO_PIEL_LOTE		INT,
	@PP_C_TIPO_PIEL_LOTE		VARCHAR(255),
	@PP_L_TIPO_PIEL_LOTE		INT
AS
	
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_TIPO_PIEL_LOTE
							FROM	TIPO_PIEL_LOTE
							WHERE	K_TIPO_PIEL_LOTE=@PP_K_TIPO_PIEL_LOTE

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO TIPO_PIEL_LOTE	
			(	K_TIPO_PIEL_LOTE,				D_TIPO_PIEL_LOTE, 
				S_TIPO_PIEL_LOTE,				O_TIPO_PIEL_LOTE,
				C_TIPO_PIEL_LOTE,
				L_TIPO_PIEL_LOTE				)		
		VALUES	
			(	@PP_K_TIPO_PIEL_LOTE,			@PP_D_TIPO_PIEL_LOTE,	
				@PP_S_TIPO_PIEL_LOTE,			@PP_O_TIPO_PIEL_LOTE,
				@PP_C_TIPO_PIEL_LOTE,
				@PP_L_TIPO_PIEL_LOTE			)
	ELSE
		UPDATE	TIPO_PIEL_LOTE
		SET		D_TIPO_PIEL_LOTE	= @PP_D_TIPO_PIEL_LOTE,	
				S_TIPO_PIEL_LOTE	= @PP_S_TIPO_PIEL_LOTE,			
				O_TIPO_PIEL_LOTE	= @PP_O_TIPO_PIEL_LOTE,
				C_TIPO_PIEL_LOTE	= @PP_C_TIPO_PIEL_LOTE,
				L_TIPO_PIEL_LOTE	= @PP_L_TIPO_PIEL_LOTE	
		WHERE	K_TIPO_PIEL_LOTE=@PP_K_TIPO_PIEL_LOTE

	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////




-- ===============================================
SET NOCOUNT ON
-- ===============================================

EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOTE] 0, 0, 0, '(SIN DEFINIR)',	'?????', 1, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOTE] 0, 0, 1, 'GENUINA',		'GENUA', 1, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOTE] 0, 0, 2, 'SINTETICA',		'SINTA', 1, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOTE] 0, 0, 3, 'NAPPA',			'NAPPA', 1, '', 1
GO
-- ===============================================
SET NOCOUNT OFF
-- ===============================================








-- //////////////////////////////////////////////////////////////
-- // ESTATUS_PIEL_LOTE
-- //////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[ESTATUS_PIEL_LOTE] (
	[K_ESTATUS_PIEL_LOTE]	[INT]				NOT NULL,
	[D_ESTATUS_PIEL_LOTE]	[VARCHAR] (100)		NOT NULL,
	[S_ESTATUS_PIEL_LOTE]	[VARCHAR] (10)		NOT NULL,
	[O_ESTATUS_PIEL_LOTE]	[INT]				NOT NULL,
	[C_ESTATUS_PIEL_LOTE]	[VARCHAR] (255)		NOT NULL,
	[L_ESTATUS_PIEL_LOTE]	[INT]				NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[ESTATUS_PIEL_LOTE]
	ADD CONSTRAINT [PK_ESTATUS_PIEL_LOTE]
		PRIMARY KEY CLUSTERED ([K_ESTATUS_PIEL_LOTE])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_ESTATUS_PIEL_LOTE_01_DESCRIPCION] 
	   ON [dbo].[ESTATUS_PIEL_LOTE] ( [D_ESTATUS_PIEL_LOTE] )
GO

-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[ESTATUS_PIEL_LOTE] ADD 
	CONSTRAINT [FK_ESTATUS_PIEL_LOTE_01] 
		FOREIGN KEY ( [L_ESTATUS_PIEL_LOTE] ) 
		REFERENCES [dbo].[ESTATUS_ACTIVO] ( [K_ESTATUS_ACTIVO] )
GO


-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_ESTATUS_PIEL_LOTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_ESTATUS_PIEL_LOTE]
GO


CREATE PROCEDURE [dbo].[PG_CI_ESTATUS_PIEL_LOTE]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	-- ========================================
	@PP_K_ESTATUS_PIEL_LOTE		INT,
	@PP_D_ESTATUS_PIEL_LOTE		VARCHAR(100),
	@PP_S_ESTATUS_PIEL_LOTE		VARCHAR(10),
	@PP_O_ESTATUS_PIEL_LOTE		INT,
	@PP_C_ESTATUS_PIEL_LOTE		VARCHAR(255),
	@PP_L_ESTATUS_PIEL_LOTE		INT
AS
	
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_ESTATUS_PIEL_LOTE
							FROM	ESTATUS_PIEL_LOTE
							WHERE	K_ESTATUS_PIEL_LOTE=@PP_K_ESTATUS_PIEL_LOTE

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO ESTATUS_PIEL_LOTE	
			(	K_ESTATUS_PIEL_LOTE,				D_ESTATUS_PIEL_LOTE, 
				S_ESTATUS_PIEL_LOTE,				O_ESTATUS_PIEL_LOTE,
				C_ESTATUS_PIEL_LOTE,
				L_ESTATUS_PIEL_LOTE				)		
		VALUES	
			(	@PP_K_ESTATUS_PIEL_LOTE,			@PP_D_ESTATUS_PIEL_LOTE,	
				@PP_S_ESTATUS_PIEL_LOTE,			@PP_O_ESTATUS_PIEL_LOTE,
				@PP_C_ESTATUS_PIEL_LOTE,
				@PP_L_ESTATUS_PIEL_LOTE			)
	ELSE
		UPDATE	ESTATUS_PIEL_LOTE
		SET		D_ESTATUS_PIEL_LOTE	= @PP_D_ESTATUS_PIEL_LOTE,	
				S_ESTATUS_PIEL_LOTE	= @PP_S_ESTATUS_PIEL_LOTE,			
				O_ESTATUS_PIEL_LOTE	= @PP_O_ESTATUS_PIEL_LOTE,
				C_ESTATUS_PIEL_LOTE	= @PP_C_ESTATUS_PIEL_LOTE,
				L_ESTATUS_PIEL_LOTE	= @PP_L_ESTATUS_PIEL_LOTE	
		WHERE	K_ESTATUS_PIEL_LOTE=@PP_K_ESTATUS_PIEL_LOTE

	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////




-- ===============================================
SET NOCOUNT ON
-- ===============================================

EXECUTE [dbo].[PG_CI_ESTATUS_PIEL_LOTE] 0, 0, 0, '(SIN DEFINIR)',		'?????', 1, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_PIEL_LOTE] 0, 0, 1, 'RECIBIDA',			'RECIBA', 1, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_PIEL_LOTE] 0, 0, 2, 'RECHAZADA',			'RECHAD', 1, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_PIEL_LOTE] 0, 0, 3, 'CALCELADA',			'CANCEL', 1, '', 1
GO
-- ===============================================
SET NOCOUNT OFF
-- ===============================================







-- //////////////////////////////////////////////////////////////
-- // PIEL_LOTE
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[PIEL_LOTE] (
	[K_PIEL_LOTE]					[INT]			NOT NULL,
	[D_PIEL_LOTE]					[VARCHAR](100)	NOT NULL,
	[S_PIEL_LOTE]					[VARCHAR](10)	NOT NULL,
	[O_PIEL_LOTE]					[INT]			NOT NULL DEFAULT 1,
	[C_PIEL_LOTE]					[VARCHAR](255)	NOT NULL DEFAULT '',
	[L_PIEL_LOTE]					[INT]			NOT NULL DEFAULT 1,
	-- ============================	
	[K_ESTATUS_PIEL_LOTE]			[INT]			NOT NULL,
	[K_TIPO_PIEL_LOTE]				[INT]			NOT NULL,
	[PIEL_LOTE_CANTIDAD]			[INT]			NOT NULL DEFAULT 0
) ON [PRIMARY]
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[PIEL_LOTE]
	ADD CONSTRAINT [PK_PIEL_LOTE]
		PRIMARY KEY CLUSTERED ([K_PIEL_LOTE])
GO

-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[PIEL_LOTE] ADD 
	CONSTRAINT [FK_PIEL_LOTE_01]  
		FOREIGN KEY ([K_ESTATUS_PIEL_LOTE]) 
		REFERENCES [dbo].[ESTATUS_PIEL_LOTE] ([K_ESTATUS_PIEL_LOTE]),
	CONSTRAINT [FK_PIEL_LOTE_02]
		FOREIGN KEY ([K_TIPO_PIEL_LOTE]) 
		REFERENCES [dbo].[TIPO_PIEL_LOTE] ([K_TIPO_PIEL_LOTE])
GO

/* --COMENTADAS PARA RECONSTRUIR 
ALTER TABLE [dbo].[PIEL_LOTE] ADD 
	CONSTRAINT [FK_PIEL_LOTE_03]  
		FOREIGN KEY ([K_PUNTO]) 
		REFERENCES [dbo].[PUNTO] ([K_PUNTO])
GO
*/
-- //////////////////////////////////////////////////////


ALTER TABLE [dbo].[PIEL_LOTE] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO


ALTER TABLE [dbo].[PIEL_LOTE] ADD 
	CONSTRAINT [FK_PIEL_LOTE_USUARIO_ALTA]  
		FOREIGN KEY ([K_USUARIO_ALTA]) 
		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
	CONSTRAINT [FK_PIEL_LOTE_USUARIO_CAMBIO]  
		FOREIGN KEY ([K_USUARIO_CAMBIO]) 
		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
	CONSTRAINT [FK_PIEL_LOTE_USUARIO_BAJA]  
		FOREIGN KEY ([K_USUARIO_BAJA]) 
		REFERENCES [dbo].[USUARIO] ([K_USUARIO])
GO










-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
