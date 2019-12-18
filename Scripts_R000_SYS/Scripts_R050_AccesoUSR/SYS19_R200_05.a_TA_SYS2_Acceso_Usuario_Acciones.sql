-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			
-- // OPERACION:		LIBERACION // STORED PROCEDURE
-- ////////////////////////////////////////////////////////////// 

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////

-- SELECT * FROM [SYS2_PERFIL_ACCESO]


-- //////////////////////////////////////////////////////////////
-- // DROPS
-- //////////////////////////////////////////////////////////////



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS2_ACCESO_USR_FRM_BTN]') AND type in (N'U'))
	DROP TABLE [dbo].[SYS2_ACCESO_USR_FRM_BTN]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS2_ACCESO_USR_FRM_ACCIONES]') AND type in (N'U'))
	DROP TABLE [dbo].[SYS2_ACCESO_USR_FRM_ACCIONES]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS2_PERFIL_ACCESO]') AND type in (N'U'))
	DROP TABLE [dbo].[SYS2_PERFIL_ACCESO]
GO





-- //////////////////////////////////////////////////////////////
-- // SYS2_PERFIL_ACCESO
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[SYS2_PERFIL_ACCESO] (
	[K_SYS2_PERFIL_ACCESO]	[INT] NOT NULL,
	[D_SYS2_PERFIL_ACCESO]	[VARCHAR] (100) NOT NULL,
	[S_SYS2_PERFIL_ACCESO]	[VARCHAR] (10) NOT NULL,
	[O_SYS2_PERFIL_ACCESO]	[INT] NOT NULL,
	[C_SYS2_PERFIL_ACCESO]	[VARCHAR] (255) NOT NULL,
	[L_SYS2_PERFIL_ACCESO]	[INT] NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[SYS2_PERFIL_ACCESO]
	ADD CONSTRAINT [PK_SYS2_PERFIL_ACCESO]
		PRIMARY KEY CLUSTERED ( [K_SYS2_PERFIL_ACCESO] )
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_SYS2_PERFIL_ACCESO_01_DESCRIPCION] 
	   ON [dbo].[SYS2_PERFIL_ACCESO] ( [D_SYS2_PERFIL_ACCESO] )
GO

-- //////////////////////////////////////////////////////////////

ALTER TABLE [dbo].[SYS2_PERFIL_ACCESO] ADD 
	CONSTRAINT [FK_SYS2_PERFIL_ACCESO_01] 
		FOREIGN KEY ( [L_SYS2_PERFIL_ACCESO] ) 
		REFERENCES [dbo].[ESTATUS_ACTIVO] ( [K_ESTATUS_ACTIVO] )
GO


-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_SYS2_PERFIL_ACCESO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_SYS2_PERFIL_ACCESO]
GO


CREATE PROCEDURE [dbo].[PG_CI_SYS2_PERFIL_ACCESO]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	-- ========================================
	@PP_K_SYS2_PERFIL_ACCESO		INT,
	@PP_D_SYS2_PERFIL_ACCESO		VARCHAR(100),
	@PP_S_SYS2_PERFIL_ACCESO		VARCHAR(10),
	@PP_O_SYS2_PERFIL_ACCESO		INT,
	@PP_C_SYS2_PERFIL_ACCESO		VARCHAR(255),
	@PP_L_SYS2_PERFIL_ACCESO		INT
AS
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_SYS2_PERFIL_ACCESO
							FROM	SYS2_PERFIL_ACCESO
							WHERE	K_SYS2_PERFIL_ACCESO=@PP_K_SYS2_PERFIL_ACCESO

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO SYS2_PERFIL_ACCESO
			(	K_SYS2_PERFIL_ACCESO,			D_SYS2_PERFIL_ACCESO, 
				S_SYS2_PERFIL_ACCESO,			O_SYS2_PERFIL_ACCESO,
				C_SYS2_PERFIL_ACCESO,
				L_SYS2_PERFIL_ACCESO			)		
		VALUES	
			(	@PP_K_SYS2_PERFIL_ACCESO,		@PP_D_SYS2_PERFIL_ACCESO,	
				@PP_S_SYS2_PERFIL_ACCESO,		@PP_O_SYS2_PERFIL_ACCESO,
				@PP_C_SYS2_PERFIL_ACCESO,
				@PP_L_SYS2_PERFIL_ACCESO		)
	ELSE
		UPDATE	SYS2_PERFIL_ACCESO
		SET		D_SYS2_PERFIL_ACCESO	= @PP_D_SYS2_PERFIL_ACCESO,	
				S_SYS2_PERFIL_ACCESO	= @PP_S_SYS2_PERFIL_ACCESO,			
				O_SYS2_PERFIL_ACCESO	= @PP_O_SYS2_PERFIL_ACCESO,
				C_SYS2_PERFIL_ACCESO	= @PP_C_SYS2_PERFIL_ACCESO,
				L_SYS2_PERFIL_ACCESO	= @PP_L_SYS2_PERFIL_ACCESO	
		WHERE	K_SYS2_PERFIL_ACCESO=@PP_K_SYS2_PERFIL_ACCESO

	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////





-- ===============================================
SET NOCOUNT ON
-- ===============================================
-- SELECT * FROM SYS2_PERFIL_ACCESO

EXECUTE [dbo].[PG_CI_SYS2_PERFIL_ACCESO] 0, 0,  0, 'NINGUNO',		'XXXX', 1, '', 1
EXECUTE [dbo].[PG_CI_SYS2_PERFIL_ACCESO] 0, 0,  1, 'FULL CONTROL',	'FULL', 1, '', 1
EXECUTE [dbo].[PG_CI_SYS2_PERFIL_ACCESO] 0, 0,  2, 'CORDINACION',	'CORD', 1, '', 1
EXECUTE [dbo].[PG_CI_SYS2_PERFIL_ACCESO] 0, 0,  3, 'OPERACION',		'OPER', 1, '', 1
EXECUTE [dbo].[PG_CI_SYS2_PERFIL_ACCESO] 0, 0,  4, 'CONSULTA',		'CONS', 1, '', 1
EXECUTE [dbo].[PG_CI_SYS2_PERFIL_ACCESO] 0, 0,  5, 'ESPECIAL',		'XPEC', 1, '', 1
EXECUTE [dbo].[PG_CI_SYS2_PERFIL_ACCESO] 0, 0,  6, 'GRID/EDIT',		'GRID', 1, '', 1
GO

-- ===============================================
SET NOCOUNT OFF
-- ===============================================






-- ///////////////////////////////////////////////////////////////
-- // DATA_SISTEMA 							
-- ///////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[SYS2_ACCESO_USR_FRM_ACCIONES] (
	[K_SISTEMA]				[INT] NOT NULL,
	[K_USUARIO]				[INT] NOT NULL,
	[FO_NOMBRE]				VARCHAR(100) NOT NULL,
	-- ====================================
	[K_SYS2_PERFIL_ACCESO]		[INT] NOT NULL,
	-- ====================================
	[L_BT_AGREGAR]			[INT] NOT NULL	DEFAULT  -1, 
	[L_BT_EDITAR]			[INT] NOT NULL	DEFAULT  -1, 
	[L_BT_CLONAR]			[INT] NOT NULL	DEFAULT  -1, 
	[L_BT_ELIMINAR]			[INT] NOT NULL	DEFAULT  -1, 
	-- ====================================
	[L_BT_GUARDAR]			[INT] NOT NULL	DEFAULT  -1, 
	[L_BT_CANCELAR]			[INT] NOT NULL	DEFAULT  -1, 
	-- ====================================
	[L_BT_EXPORTAR_EXCEL]	[INT] NOT NULL	DEFAULT  -1, 
	[L_BT_LISTADO]			[INT] NOT NULL	DEFAULT  -1, 
	[L_BT_LI_BUSCAR]		[INT] NOT NULL	DEFAULT  -1, 
) ON [PRIMARY]
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[SYS2_ACCESO_USR_FRM_ACCIONES]
	ADD CONSTRAINT [PK_SYS2_ACCESO_USR_FRM_ACCIONES]
		PRIMARY KEY CLUSTERED ( [K_SISTEMA], [K_USUARIO], [FO_NOMBRE] )
GO

/*

CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_DATA_SISTEMA_01_DESCRIPCION] 
	   ON [dbo].[DATA_SISTEMA] ( [D_DATA_SISTEMA] )
GO

*/


-- //////////////////////////////////////////////////////

-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_SYS2_ACCESO_USR_FRM_ACCIONES]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_SYS2_ACCESO_USR_FRM_ACCIONES]
GO


CREATE PROCEDURE [dbo].[PG_CI_SYS2_ACCESO_USR_FRM_ACCIONES]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ========================================
	@PP_K_SYS2_PERFIL_ACCESO	INT,
	@PP_FO_NOMBRE			VARCHAR(100)
	-- ========================================
AS

	DECLARE @VP_K_EXISTE	INT
/*
	SELECT	@VP_K_EXISTE =	K_SYS_SYS2_ACCESO_USR_FRM_ACCIONES
							FROM	SYS_SYS2_ACCESO_USR_FRM_ACCIONES
							WHERE	K_SYS_SYS2_ACCESO_USR_FRM_ACCIONES=@PP_K_SYS_SYS2_ACCESO_USR_FRM_ACCIONES
							*/
	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO SYS2_ACCESO_USR_FRM_ACCIONES
			(	K_SISTEMA, 
				K_USUARIO,				FO_NOMBRE,			K_SYS2_PERFIL_ACCESO			)		
		VALUES	
			(	@PP_K_SISTEMA_EXE,	
				@PP_K_USUARIO_ACCION,	@PP_FO_NOMBRE,		@PP_K_SYS2_PERFIL_ACCESO		)
	ELSE
		UPDATE	SYS_SYS2_ACCESO_USR_FRM_ACCIONES
		SET		FO_NOMBRE			= @PP_FO_NOMBRE,	
				K_SYS2_PERFIL_ACCESO	= @PP_K_SYS2_PERFIL_ACCESO
		WHERE	K_SISTEMA_EXE=@PP_K_SISTEMA_EXE
		AND		FO_NOMBRE=@PP_FO_NOMBRE
		AND		K_USUARIO_ACCION=@PP_K_USUARIO_ACCION

	-- =========================================================
GO





-- //////////////////////////////////////////////////////////////
-- // CARGA INICIAL
-- //////////////////////////////////////////////////////////////


-- K_SYS2_PERFIL_ACCESO = #0 NINGUNO | #1 FULL CONTROL | #2 CORDINACION | #3 OPERACION | #4 CONSULTA

-- SELECT * FROM SYS2_ACCESO_USR_FRM_ACCIONES


-- ===============================================
SET NOCOUNT ON
-- ===============================================

EXECUTE [dbo].[PG_CI_SYS2_ACCESO_USR_FRM_ACCIONES]	0,0,0,	0, 'FO_PRODUCTO'
EXECUTE [dbo].[PG_CI_SYS2_ACCESO_USR_FRM_ACCIONES]	0,0,0,	2, 'FO_TASA_IMPUESTO'
EXECUTE [dbo].[PG_CI_SYS2_ACCESO_USR_FRM_ACCIONES]	0,0,0,	1, 'FO_PRECIO'
-- ===================================
EXECUTE [dbo].[PG_CI_SYS2_ACCESO_USR_FRM_ACCIONES]	0,0,0,	3, 'FO_SITIO'
EXECUTE [dbo].[PG_CI_SYS2_ACCESO_USR_FRM_ACCIONES]	0,0,0,	4, 'FO_CLIENTE'
EXECUTE [dbo].[PG_CI_SYS2_ACCESO_USR_FRM_ACCIONES]	0,0,0,	1, 'FO_CARGO'
EXECUTE [dbo].[PG_CI_SYS2_ACCESO_USR_FRM_ACCIONES]	0,0,0,	2, 'FO_CONDICION_COMERCIAL'
-- ===================================

EXECUTE [dbo].[PG_CI_SYS2_ACCESO_USR_FRM_ACCIONES]	0,0,0,	0, 'FO_ADMINISTRADOR'
-- ===================================
EXECUTE [dbo].[PG_CI_SYS2_ACCESO_USR_FRM_ACCIONES]	0,0,0,	3, 'FO_ALMACEN_SITIO'
-- ===================================

GO


-- ===============================================
SET NOCOUNT OFF
-- ===============================================




-- ///////////////////////////////////////////////////////////////
-- // [SYS2_ACCESO_USR_FRM_BTN] 							
-- ///////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[SYS2_ACCESO_USR_FRM_BTN] (
	[K_SISTEMA]			[INT] NOT NULL,
	[K_USUARIO]			[INT] NOT NULL,
	[FO_NOMBRE]			VARCHAR(100) NOT NULL,
	[D_BOTON]			VARCHAR(200) NOT NULL,
	-- ====================================
	[L_VISIBLE]			[INT] NOT NULL	DEFAULT  1, 
	[L_ACTIVO]			[INT] NOT NULL	DEFAULT  1
) ON [PRIMARY]
GO



-- //////////////////////////////////////////////////////



ALTER TABLE [dbo].[SYS2_ACCESO_USR_FRM_BTN]
	ADD CONSTRAINT [PK_SYS2_ACCESO_USR_FRM_BTN]
		PRIMARY KEY CLUSTERED ( [K_SISTEMA], [K_USUARIO], [FO_NOMBRE], [D_BOTON] )
GO



-- ////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////


