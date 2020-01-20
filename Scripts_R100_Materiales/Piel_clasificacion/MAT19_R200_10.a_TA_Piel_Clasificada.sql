-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	DATA_02Pruebas
-- // MODULO:			CLASIFICACION PIEL
-- // OPERACION:		LIBERACION / TABLAS
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	10/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE DATA_02Pruebas 
GO

-- //////////////////////////////////////////////////////////////








-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIEL_CLASIFICADA_PORCENTAJE]') AND type in (N'U'))
	DROP TABLE [dbo].[PIEL_CLASIFICADA_PORCENTAJE]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIEL_CLASIFICACION]') AND type in (N'U'))
	DROP TABLE [dbo].[PIEL_CLASIFICACION]
GO


-- //////////////////////////////////////////////////////////////
-- // PIEL_CLASIFICACION
-- //////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[PIEL_CLASIFICACION] (
	[K_PIEL_CLASIFICACION]	[INT]				NOT NULL,
	[D_PIEL_CLASIFICACION]	[VARCHAR] (100)		NOT NULL,
	[S_PIEL_CLASIFICACION]	[VARCHAR] (10)		NOT NULL,
	[O_PIEL_CLASIFICACION]	[INT]				NOT NULL,
	[C_PIEL_CLASIFICACION]	[VARCHAR] (255)		NOT NULL,
	[L_PIEL_CLASIFICACION]	[INT]				NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[PIEL_CLASIFICACION]
	ADD CONSTRAINT [PK_PIEL_CLASIFICACION]
		PRIMARY KEY CLUSTERED ([K_PIEL_CLASIFICACION])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_PIEL_CLASIFICACION_01_DESCRIPCION] 
	   ON [dbo].[PIEL_CLASIFICACION] ( [D_PIEL_CLASIFICACION] )
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_PIEL_CLASIFICACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_PIEL_CLASIFICACION]
GO


CREATE PROCEDURE [dbo].[PG_CI_PIEL_CLASIFICACION]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	-- ========================================
	@PP_K_PIEL_CLASIFICACION		INT,
	@PP_D_PIEL_CLASIFICACION		VARCHAR(100),
	@PP_S_PIEL_CLASIFICACION		VARCHAR(10),
	@PP_O_PIEL_CLASIFICACION		INT,
	@PP_C_PIEL_CLASIFICACION		VARCHAR(255),
	@PP_L_PIEL_CLASIFICACION		INT
AS
	
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_PIEL_CLASIFICACION
							FROM	PIEL_CLASIFICACION
							WHERE	K_PIEL_CLASIFICACION=@PP_K_PIEL_CLASIFICACION

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO PIEL_CLASIFICACION	
			(	K_PIEL_CLASIFICACION,				D_PIEL_CLASIFICACION, 
				S_PIEL_CLASIFICACION,				O_PIEL_CLASIFICACION,
				C_PIEL_CLASIFICACION,
				L_PIEL_CLASIFICACION				)		
		VALUES	
			(	@PP_K_PIEL_CLASIFICACION,			@PP_D_PIEL_CLASIFICACION,	
				@PP_S_PIEL_CLASIFICACION,			@PP_O_PIEL_CLASIFICACION,
				@PP_C_PIEL_CLASIFICACION,
				@PP_L_PIEL_CLASIFICACION			)
	ELSE
		UPDATE	PIEL_CLASIFICACION
		SET		D_PIEL_CLASIFICACION	= @PP_D_PIEL_CLASIFICACION,	
				S_PIEL_CLASIFICACION	= @PP_S_PIEL_CLASIFICACION,			
				O_PIEL_CLASIFICACION	= @PP_O_PIEL_CLASIFICACION,
				C_PIEL_CLASIFICACION	= @PP_C_PIEL_CLASIFICACION,
				L_PIEL_CLASIFICACION	= @PP_L_PIEL_CLASIFICACION	
		WHERE	K_PIEL_CLASIFICACION=@PP_K_PIEL_CLASIFICACION

	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////




-- ===============================================
SET NOCOUNT ON
-- ===============================================

EXECUTE [dbo].[PG_CI_PIEL_CLASIFICACION] 0, 0, 0, '(SIN CLASIFICAR)',		'?????', 1, '', 1
EXECUTE [dbo].[PG_CI_PIEL_CLASIFICACION] 0, 0, 1, 'BUENA',					'BUENA', 1, '', 1
EXECUTE [dbo].[PG_CI_PIEL_CLASIFICACION] 0, 0, 2, 'REGULAR',				'REGUL', 1, '', 1
EXECUTE [dbo].[PG_CI_PIEL_CLASIFICACION] 0, 0, 3, 'MALA',					'MALA', 1, '', 1
GO
-- ===============================================
SET NOCOUNT OFF
-- ===============================================

GO


-- //////////////////////////////////////////////////////////////
-- // PIEL_CLASIFICADA_PORCENTAJE
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[PIEL_CLASIFICADA_PORCENTAJE] (
	[K_PIEL_CLASIFICADA_PORCENTAJE]			[INT]			NOT NULL,
	-- ============================	
	[LOTE]									VARCHAR(10)		NOT NULL,
	[PIEL_TOTAL]							INT				NOT NULL,
	[PIEL_TOTAL_CLASIFICADA]				INT				NOT NULL,
	[PIEL_TOTAL_BUENO]						INT				NOT NULL,
	[PIEL_TOTAL_REGULAR]					INT				NOT NULL,
	[PIEL_TOTAL_MALO]						INT				NOT NULL,
	[PIEL_PORCENTAJE_BUENO]					[DECIMAL](19,4)	NOT NULL,
	[PIEL_PORCENTAJE_REGULAR]				[DECIMAL](19,4)	NOT NULL,
	[PIEL_PORCENTAJE_MALO]					[DECIMAL](19,4)	NOT NULL
	

) ON [PRIMARY]
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[PIEL_CLASIFICADA_PORCENTAJE]
	ADD CONSTRAINT [PK_PIEL_CLASIFICADA_PORCENTAJE]
		PRIMARY KEY CLUSTERED ([K_PIEL_CLASIFICADA_PORCENTAJE])
GO


-- //////////////////////////////////////////////////////////////
/*
ALTER TABLE [dbo].[PIEL_CLASIFICADA_PORCENTAJE] ADD 
	CONSTRAINT [FK_PIEL_CLASIFICADA_PORCENTAJE_01]  
		FOREIGN KEY ([K_PIEL_LOTE]) 
		REFERENCES [dbo].[PIEL_LOTE] ([K_PIEL_LOTE])
GO
*/
-- //////////////////////////////////////////////////////////////





-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
