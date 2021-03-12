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

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////

-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TICKET_A_IMPORTAR]') AND type in (N'U'))
	DROP TABLE [dbo].[TICKET_A_IMPORTAR]
GO


-- //////////////////////////////////////////////////////////////
-- // PIEL_CLASIFICADA_PORCENTAJE
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[TICKET_A_IMPORTAR] (
	[K_TICKET_A_IMPORTAR]			INT IDENTITY (1,1),
	[FILE_NO]						VARCHAR(100) NOT NULL, 
	[BUNDLE_NO]						VARCHAR(10),
	[FECHA_TICKET]					VARCHAR(10),
	[CLIENTE]						VARCHAR(50),				
	[COLOR]							VARCHAR(50),
	[D_COLOR]						VARCHAR(100),
	[CRUST_LOT]						VARCHAR(100),
	[LOTE]							VARCHAR(20),
	[TOTAL_PIEL]					INT,
	[AVG_AREA]						DECIMAL(13,2),
	[TOTAL_SQF]						DECIMAL(13,2),
	[CONSECUTIVO]					INT,
	[SQF]							DECIMAL(13,2),
	[UOM]							VARCHAR(10)
) ON [PRIMARY]
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[TICKET_A_IMPORTAR]
	ADD CONSTRAINT [PK_TICKET_A_IMPORTAR]
		PRIMARY KEY CLUSTERED ([K_TICKET_A_IMPORTAR])
GO


-- //////////////////////////////////////////////////////////////

ALTER TABLE [dbo].[TICKET_A_IMPORTAR] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO

-- //////////////////////////////////////////////////////////////





-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
