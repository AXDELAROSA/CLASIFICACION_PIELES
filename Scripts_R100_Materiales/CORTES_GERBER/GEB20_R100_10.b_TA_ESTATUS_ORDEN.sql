-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	DATA_02Pruebas
-- // MODULO:			PROYECTO/GERBER
-- // OPERACION:		LIBERACION / TABLAS
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	27/AGO/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ESTATUS_ORDEN]') AND type in (N'U'))
	DROP TABLE [dbo].[ESTATUS_ORDEN]
GO


-- //////////////////////////////////////////////////////////////
-- // ESTATUS_ORDEN
-- //////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[ESTATUS_ORDEN] (
	[K_ESTATUS_ORDEN]	[INT]				NOT NULL,
	[D_ESTATUS_ORDEN]	[VARCHAR] (100)		NOT NULL,
	[S_ESTATUS_ORDEN]	[VARCHAR] (10)		NOT NULL,
	[O_ESTATUS_ORDEN]	[INT]				NOT NULL,
	[C_ESTATUS_ORDEN]	[VARCHAR] (255)		NOT NULL,
	[L_ESTATUS_ORDEN]	[INT]				NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[ESTATUS_ORDEN]
	ADD CONSTRAINT [PK_ESTATUS_ORDEN]
		PRIMARY KEY CLUSTERED ([K_ESTATUS_ORDEN])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_ESTATUS_ORDEN_01_DESCRIPCION] 
	   ON [dbo].[ESTATUS_ORDEN] ( [D_ESTATUS_ORDEN] )
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_ESTATUS_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_ESTATUS_ORDEN]
GO


CREATE PROCEDURE [dbo].[PG_CI_ESTATUS_ORDEN]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	-- ========================================
	@PP_K_ESTATUS_ORDEN		INT,
	@PP_D_ESTATUS_ORDEN		VARCHAR(100),
	@PP_S_ESTATUS_ORDEN		VARCHAR(10),
	@PP_O_ESTATUS_ORDEN		INT,
	@PP_C_ESTATUS_ORDEN		VARCHAR(255),
	@PP_L_ESTATUS_ORDEN		INT
AS
	
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_ESTATUS_ORDEN
							FROM	ESTATUS_ORDEN
							WHERE	K_ESTATUS_ORDEN=@PP_K_ESTATUS_ORDEN

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO ESTATUS_ORDEN	
			(	K_ESTATUS_ORDEN,				D_ESTATUS_ORDEN, 
				S_ESTATUS_ORDEN,				O_ESTATUS_ORDEN,
				C_ESTATUS_ORDEN,
				L_ESTATUS_ORDEN				)		
		VALUES	
			(	@PP_K_ESTATUS_ORDEN,			@PP_D_ESTATUS_ORDEN,	
				@PP_S_ESTATUS_ORDEN,			@PP_O_ESTATUS_ORDEN,
				@PP_C_ESTATUS_ORDEN,
				@PP_L_ESTATUS_ORDEN			)
	ELSE
		UPDATE	ESTATUS_ORDEN
		SET		D_ESTATUS_ORDEN	= @PP_D_ESTATUS_ORDEN,	
				S_ESTATUS_ORDEN	= @PP_S_ESTATUS_ORDEN,			
				O_ESTATUS_ORDEN	= @PP_O_ESTATUS_ORDEN,
				C_ESTATUS_ORDEN	= @PP_C_ESTATUS_ORDEN,
				L_ESTATUS_ORDEN	= @PP_L_ESTATUS_ORDEN	
		WHERE	K_ESTATUS_ORDEN=@PP_K_ESTATUS_ORDEN

	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////




-- ===============================================
SET NOCOUNT ON
-- ===============================================
EXECUTE [dbo].[PG_CI_ESTATUS_ORDEN] 0, 0, 0, '(TODOS)',						'T', 0, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_ORDEN] 0, 0, 1, 'PENDIENTE',					'P', 1, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_ORDEN] 0, 0, 2, 'CERRADA',						'C', 1, '', 1

GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
