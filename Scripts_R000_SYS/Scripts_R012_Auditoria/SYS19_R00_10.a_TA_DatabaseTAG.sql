-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			
-- // OPERACION:		LIBERACION / DATOS
-- //////////////////////////////////////////////////////////////

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- SELECT * FROM [dbo].[VALOR_PARAMETRO] 


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DATABASE_TAG]') AND type in (N'U'))
	DROP TABLE [dbo].[DATABASE_TAG]
GO





-- //////////////////////////////////////////////////////////////
-- // DATABASE_TAG
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[DATABASE_TAG] (
	[K_SISTEMA]			INT,
	[K_DATABASE_TAG]	DECIMAL(19,2) NOT NULL,
	[D_DATABASE_TAG]	[VARCHAR] (100) NOT NULL,
	[S_DATABASE_TAG]	[VARCHAR] (10) NOT NULL,
	[O_DATABASE_TAG]	[INT] NOT NULL,
	[C_DATABASE_TAG]	[VARCHAR] (255) NOT NULL,
	[L_DATABASE_TAG]	[INT] NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[DATABASE_TAG]
	ADD CONSTRAINT [PK_DATABASE_TAG]
		PRIMARY KEY CLUSTERED ([K_DATABASE_TAG])
GO

/*
CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_DATABASE_TAG_01_DESCRIPCION] 
	   ON [dbo].[DATABASE_TAG] ( [D_DATABASE_TAG] )
GO
*/

-- //////////////////////////////////////////////////////////////

ALTER TABLE [dbo].[DATABASE_TAG] ADD 
	CONSTRAINT [FK_DATABASE_TAG_01] 
		FOREIGN KEY ( [L_DATABASE_TAG] ) 
		REFERENCES [dbo].[ESTATUS_ACTIVO] ( [K_ESTATUS_ACTIVO] )
GO


-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_DATABASE_TAG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_DATABASE_TAG]
GO


CREATE PROCEDURE [dbo].[PG_CI_DATABASE_TAG]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	-- ========================================
	@PP_K_DATABASE_TAG		DECIMAL(19,2),
	@PP_D_DATABASE_TAG		VARCHAR(100),
	@PP_S_DATABASE_TAG		VARCHAR(10),
	@PP_O_DATABASE_TAG		INT,
	@PP_C_DATABASE_TAG		VARCHAR(255),
	@PP_L_DATABASE_TAG		INT
AS
	-- ===============================

	DECLARE @VP_K_EXISTE	DECIMAL(19,2)

	SELECT	@VP_K_EXISTE =	K_DATABASE_TAG
							FROM	DATABASE_TAG
							WHERE	K_DATABASE_TAG=@PP_K_DATABASE_TAG

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO DATABASE_TAG
			(	K_SISTEMA,
				K_DATABASE_TAG,			D_DATABASE_TAG, 
				S_DATABASE_TAG,			O_DATABASE_TAG,
				C_DATABASE_TAG,
				L_DATABASE_TAG			)		
		VALUES	
			(	@PP_K_SISTEMA_EXE,
				@PP_K_DATABASE_TAG,		@PP_D_DATABASE_TAG,	
				@PP_S_DATABASE_TAG,		@PP_O_DATABASE_TAG,
				@PP_C_DATABASE_TAG,
				@PP_L_DATABASE_TAG		)
	ELSE
		UPDATE	DATABASE_TAG
		SET		D_DATABASE_TAG	= @PP_D_DATABASE_TAG,	
				S_DATABASE_TAG	= @PP_S_DATABASE_TAG,			
				O_DATABASE_TAG	= @PP_O_DATABASE_TAG,
				C_DATABASE_TAG	= @PP_C_DATABASE_TAG,
				L_DATABASE_TAG	= @PP_L_DATABASE_TAG	
		WHERE	K_SISTEMA=@PP_K_SISTEMA_EXE
		AND		K_DATABASE_TAG=@PP_K_DATABASE_TAG

	-- =========================================================
GO



-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////

