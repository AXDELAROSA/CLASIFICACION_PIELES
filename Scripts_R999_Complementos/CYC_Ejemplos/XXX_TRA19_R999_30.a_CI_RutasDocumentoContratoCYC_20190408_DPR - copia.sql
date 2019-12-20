-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:		TRA19
-- // MÓDULO:				EXPEDIENTE_DOCUMENTO - DOCUMENTACIÓN
-- // OPERACIÓN:			
-- ////////////////////////////////////////////////////////////// 
-- // Autor:				AX DE LA ROSA
-- // Fecha creación:		10/JUN/2019
-- ////////////////////////////////////////////////////////////// 

USE [TRA19_Transportadora_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////




-- ///////////////////////////////////////////////////////////////
-- // CYC19 // #205 | RUTA DOCUMENTOS CONTRATO
-- ///////////////////////////////////////////////////////////////


-- ===============================================
SET NOCOUNT ON
-- ===============================================

EXECUTE [dbo].[PG_CI_PARAMETRO]			0, 0,
										205, 'RUTA CONTRATO/DOCS',	'', 10, 'PARAMETRO = @PP_RUTAS_DOC_CON', 1 
GO

-- ===============================================

EXECUTE [dbo].[PG_CI_VALOR_PARAMETRO]	0, 2002, 2002,
										2051, 'RUTA CONTRATO/DOCS', 'RUTA FÍSICA',
										01, 205, 
										'C:\TOMZA.SYS\CYC19.sys\CYC19_DocumentosContrato.sys\DOCUMENTACION_1_PROD\', 
										'TXT_2', 'TXT_3',
										-1, -1, -1, 
										-1, -1, -1 

EXECUTE [dbo].[PG_CI_VALOR_PARAMETRO]	0, 2002, 2002,
										2052, 'RUTA CONTRATO/DOCS', 'RUTA FÍSICA',
										02, 205, 
										'C:\TOMZA.SYS\CYC19.sys\CYC19_DocumentosContrato.sys\DOCUMENTACION_2_PERF\', 
										'TXT_2', 'TXT_3',
										-1, -1, -1, 
										-1, -1, -1 

EXECUTE [dbo].[PG_CI_VALOR_PARAMETRO]	0, 2002, 2002,
										2053, 'RUTA CONTRATO/DOCS', 'RUTA FÍSICA',
										03, 205, 
										'C:\TOMZA.SYS\CYC19.sys\CYC19_DocumentosContrato.sys\DOCUMENTACION_3_UAT\', 
										'TXT_2', 'TXT_3',
										-1, -1, -1, 
										-1, -1, -1 

EXECUTE [dbo].[PG_CI_VALOR_PARAMETRO]	0, 2002, 2002,
										2054, 'RUTA CONTRATO/DOCS', 'RUTA FÍSICA',
										04, 205, 
										'C:\TOMZA.SYS\CYC19.sys\CYC19_DocumentosContrato.sys\DOCUMENTACION_4_CERT\', 
										'TXT_2', 'TXT_3',
										-1, -1, -1, 
										-1, -1, -1 

EXECUTE [dbo].[PG_CI_VALOR_PARAMETRO]	0, 2002, 2002,
										2055, 'RUTA CONTRATO/DOCS', 'RUTA FÍSICA',
										05, 205, 
										'C:\TOMZA.SYS\CYC19.sys\CYC19_DocumentosContrato.sys\DOCUMENTACION_5_LAB\', 
										'TXT_2', 'TXT_3',
										-1, -1, -1, 
										-1, -1, -1 

EXECUTE [dbo].[PG_CI_VALOR_PARAMETRO]	0, 2002, 2002,
										2056, 'RUTA CONTRATO/DOCS', 'RUTA FÍSICA',
										06, 205, 
										'C:\TOMZA.SYS\CYC19.sys\CYC19_DocumentosContrato.sys\DOCUMENTACION_6_UNIT\', 
										'TXT_2', 'TXT_3',
										-1, -1, -1, 
										-1, -1, -1 

EXECUTE [dbo].[PG_CI_VALOR_PARAMETRO]	0, 2002, 2002,
										2057, 'RUTA CONTRATO/DOCS', 'RUTA FÍSICA',
										07, 205, 
										'C:\TOMZA.SYS\CYC19.sys\CYC19_DocumentosContrato.sys\DOCUMENTACION_7_DESA\', 
										'TXT_2', 'TXT_3',
										-1, -1, -1, 
										-1, -1, -1 
GO

-- ===============================================
SET NOCOUNT OFF
-- ===============================================




-- ///////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////