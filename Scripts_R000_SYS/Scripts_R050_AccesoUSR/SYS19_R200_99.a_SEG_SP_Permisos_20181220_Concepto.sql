-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			SEGURIDAD // PERMISOS MENU + BOTONES
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////

--//////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////
-- // 
-- //////////////////////////////////////////////////////////////

-- EXECUTE [PG_LI_PERMISO_MENU_X_K_USUARIO] 0,0,0,	@VP_D_FUNCION

-- EXECUTE [PG_LI_PERMISO_MENU_X_K_USUARIO] 0,0,0,	'XFO_PRODUCTO'


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_PERMISO_MENU_X_K_USUARIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_PERMISO_MENU_X_K_USUARIO]
GO


CREATE PROCEDURE [dbo].[PG_LI_PERMISO_MENU_X_K_USUARIO]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ===========================
	@PP_D_MENU			VARCHAR(255)
	-- ===========================
AS
	-- ==========================================
		
	DECLARE @VP_TA_PERMISOS		TABLE
		(	TA_K_MENU			INT,
			TA_D_MENU			VARCHAR(200),
			TA_K_FUNCION		INT,
			TA_D_FUNCION		VARCHAR(200),
			TA_L_VISIBLE		INT,
			TA_L_ACTIVO			INT)
	
	-- ==========================================
/*	
	IF @PP_D_FUNCION=@VP_D_FUNCION
		BEGIN
		INSERT INTO @VP_TA_PERMISOS 
				(	TA_K_MENU, TA_D_MENU, 
												TA_L_VISIBLE, TA_L_ACTIVO,	TA_K_FUNCION,	TA_D_FUNCION		)
		VALUES
				(	1,	@VP_D_FUNCION,		0,0,	1,	'BT_GENERAR_ZONA_UO'	),
				(	1,	@VP_D_FUNCION,		0,1,	2,	'BT_GENERAR_RAZON_SOCIAL'	),
				(	1,	@VP_D_FUNCION,		1,0,	3,	'BT_GENERAR_UNIDAD_OPERATIVA'	),
				(	1,	@VP_D_FUNCION,		1,1,	4,	'BT_EJECUTAR_CAMBIO'	),
				(	1,	@VP_D_FUNCION,		1,1,	5,	'BT_REPROCESAR'	)
		END
		*/
	-- ==========================================

	INSERT INTO @VP_TA_PERMISOS 
			(	TA_K_MENU, TA_D_MENU, 
											TA_L_VISIBLE, TA_L_ACTIVO,	TA_K_FUNCION,	TA_D_FUNCION		)
		VALUES		
			(	1,	'VP_MENU_FLUJO',		1,1,	5,	'>XXXXX'	),
			-- ==========================================
			(	1,	'VP_MENU_FLUJO',		0,1,	5,	'>Control Anual'	),
				(	1,	'VP_MENU_FLUJO',		1,0,	5,	'>Control Anual Global'	),
				(	1,	'VP_MENU_FLUJO',		1,0,	5,	'>Control Anual por Razón Social'	),
				(	1,	'VP_MENU_FLUJO',		1,1,	5,	'>Control Anual por Planta'	),
			(	1,	'VP_MENU_FLUJO',		1,0,	5,	'>Acta de Ingresos'	),
			(	1,	'VP_MENU_FLUJO',		1,1,	5,	'>Libro de Ingresos'	),
			(	1,	'VP_MENU_FLUJO',		1,0,	5,	'>Conciliación de Ingresos'	),
			(	1,	'VP_MENU_FLUJO',		1,1,	5,	'>Movimientos Banco'	),
			(	1,	'VP_MENU_FLUJO',		1,0,	5,	'>Traspasos'	),
			(	1,	'VP_MENU_FLUJO',		1,1,	5,	'>Gestión de Tesorería'	),
			(	1,	'VP_MENU_FLUJO',		1,0,	5,	'>Instrucciones'	),
			(	1,	'VP_MENU_FLUJO',		0,1,	5,	'>Flujo Diario'	),
			(	1,	'VP_MENU_FLUJO',		1,0,	5,	'>Flujo Diario Global'	),
			(	1,	'VP_MENU_FLUJO',		1,1,	5,	'>Flujo Diario por Razón Social'	),
			(	1,	'VP_MENU_FLUJO',		1,0,	5,	'>Flujo Diario por Planta'	),
			-- ==========================================
			(	1,	'VP_MENU_GASTOS',		1,1,	5,	'>Proveedores'	),
			(	1,	'VP_MENU_GASTOS',		1,1,	5,	'>Facturas de Cuentas por Pagar'	),
			(	1,	'VP_MENU_GASTOS',		0,1,	5,	'>Carga de Facturas XML'	),
			(	1,	'VP_MENU_GASTOS',		1,1,	5,	'>Antigüedad de Saldos'	),
			(	1,	'VP_MENU_GASTOS',		1,1,	5,	'>Viaje'	),
			(	1,	'VP_MENU_GASTOS',		1,0,	5,	'>Solicitud de Viaje'	),
			(	1,	'VP_MENU_GASTOS',		1,1,	5,	'>Presupuesto Viaje'	),
			(	1,	'VP_MENU_GASTOS',		1,0,	5,	'>Gasto Viaje'					),
			(	1,	'VP_MENU_GASTOS',		1,1,	5,	'>Captura de Gasto Viaje'		),
			(	1,	'VP_MENU_GASTOS',		1,0,	5,	'>Carga de Facturas de Viaje'	),
			(	1,	'VP_MENU_GASTOS',		1,1,	5,	'>Facturas de Viaje'	),
			(	1,	'VP_MENU_GASTOS',		1,0,	5,	'>Proveedor Viático'	),
			(	1,	'VP_MENU_GASTOS',		1,1,	5,	'>Recurso Viaje'		),
			(	1,	'VP_MENU_GASTOS',		1,0,	5,	'>Cuentas Contables'	)

	SELECT	TA_K_MENU		AS K_MENU, 
			TA_D_MENU		AS D_MENU, 
			TA_L_VISIBLE	AS L_VISIBLE, 
			TA_L_ACTIVO		AS L_ACTIVO,	
			TA_K_FUNCION	AS K_FUNCION, 
			TA_D_FUNCION	AS D_FUNCION
	FROM	@VP_TA_PERMISOS
--	WHERE	TA_D_FUNCION=@PP_D_FUNCION

	-- //////////////////////////////////////////
GO

/*
 EXECUTE [PG_LI_PERMISO_MENU_X_K_USUARIO] 0,0,0,	'XFO_PRODUCTO'
 GO
 */


-- //////////////////////////////////////////////////////////////
-- // 
-- //////////////////////////////////////////////////////////////

-- EXECUTE [PG_LI_PERMISO_FUNCION_X_K_USUARIO] 0,0,0,	'FO_PRODUCTO'

-- EXECUTE [PG_LI_PERMISO_FUNCION_X_K_USUARIO] 0,0,0,	'XFO_PRODUCTO'


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_PERMISO_FUNCION_X_K_USUARIO_V1]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_PERMISO_FUNCION_X_K_USUARIO_V1]
GO


CREATE PROCEDURE [dbo].[PG_LI_PERMISO_FUNCION_X_K_USUARIO_V1]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ===========================
	@PP_D_FUNCION			VARCHAR(255)
	-- ===========================
AS

	DECLARE @VP_D_FUNCION VARCHAR(100)

	SET @VP_D_FUNCION = @PP_D_FUNCION

	-- ==========================================
		
	DECLARE @VP_TA_PERMISOS		TABLE
		(	TA_K_FUNCION		INT,
			TA_D_FUNCION		VARCHAR(200),
			TA_K_PROCESO		INT,
			TA_D_PROCESO		VARCHAR(200),
			TA_L_VISIBLE		INT,
			TA_L_ACTIVO			INT)
	
	-- ==========================================
/*	
	IF @PP_D_FUNCION=@VP_D_FUNCION
		BEGIN
		INSERT INTO @VP_TA_PERMISOS 
				(	TA_K_FUNCION, TA_D_FUNCION, 
												TA_L_VISIBLE, TA_L_ACTIVO,	TA_K_PROCESO,	TA_D_PROCESO	)
		VALUES
				(	1,	@VP_D_FUNCION,		0,0,	1,	'BT_GENERAR_ZONA_UO'	),
				(	1,	@VP_D_FUNCION,		0,1,	2,	'BT_GENERAR_RAZON_SOCIAL'	),
				(	1,	@VP_D_FUNCION,		1,0,	3,	'BT_GENERAR_UNIDAD_OPERATIVA'	),
				(	1,	@VP_D_FUNCION,		1,1,	4,	'BT_EJECUTAR_CAMBIO'	),
				(	1,	@VP_D_FUNCION,		1,1,	5,	'BT_REPROCESAR'	)
		END
*/
	-- ==========================================

	INSERT INTO @VP_TA_PERMISOS 
			(	TA_K_FUNCION, TA_D_FUNCION, 
									TA_L_VISIBLE, TA_L_ACTIVO,	
											TA_K_PROCESO,	TA_D_PROCESO	)
	VALUES		
--		(	1,	@VP_D_FUNCION,		1,1,		5,	'BT_XXXX'	),
		-- ==========================================
		(	1,	@VP_D_FUNCION,		1,1,		5,	'BT_AGREGAR'	),
		(	1,	@VP_D_FUNCION,		1,1,		5,	'BT_EDITAR'		),
		(	1,	@VP_D_FUNCION,		1,0,		5,	'BT_CLONAR'		),
		(	1,	@VP_D_FUNCION,		1,0,		5,	'BT_ELIMINAR'	),
		(	1,	@VP_D_FUNCION,		1,1,		5,	'BT_EXPORTAR_EXCEL'	),
		(	1,	@VP_D_FUNCION,		1,1,		5,	'BT_LISTADO'	),
		(	1,	@VP_D_FUNCION,		1,1,		5,	'BT_GUARDAR'	),
		(	1,	@VP_D_FUNCION,		1,1,		5,	'BT_CANCELAR'	),
		(	1,	@VP_D_FUNCION,		1,1,		5,	'BT_LI_BUSCAR'	)
--		(	1,	@VP_D_FUNCION,		1,1,		5,	'GB_GRAFICA'	)

	-- ==========================================

	SELECT	TA_K_FUNCION	AS K_FUNCION, 
			TA_D_FUNCION	AS D_FUNCION, 
			TA_L_VISIBLE	AS L_VISIBLE, 
			TA_L_ACTIVO		AS L_ACTIVO,	
			TA_K_PROCESO	AS K_PROCESO,
			TA_D_PROCESO	AS D_PROCESO
	FROM	@VP_TA_PERMISOS
	WHERE	TA_D_FUNCION=@PP_D_FUNCION

	-- //////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
