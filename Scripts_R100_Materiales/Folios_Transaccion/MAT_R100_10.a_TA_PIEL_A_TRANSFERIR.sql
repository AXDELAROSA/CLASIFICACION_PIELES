-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	RH
-- // MODULO:			
-- // OPERACION:		PIEL_A_TRANSFERIR DESCRIPCION
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	04/FEB/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////






-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIEL_A_TRANSFERIR]') AND type in (N'U'))
	DROP TABLE [dbo].[PIEL_A_TRANSFERIR]
GO


-- //////////////////////////////////////////////////////////////
-- // PIEL_A_TRANSFERIR
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[PIEL_A_TRANSFERIR] (
	[K_PIEL_A_TRANSFERIR]				[INT]			NOT NULL IDENTITY(1,1),
	-- =================================		
	[TIPO_TRANSFERENCIA]				VARCHAR(50)		NOT NULL,
	[FOLIO_ORIGEN]						INT				NOT NULL,
	[FOLIO_DESTINO]						INT				NOT NULL,
	[LOCACION_ORIGEN]					VARCHAR(5)		NOT NULL,
	[LOCACION_DESTINO]					VARCHAR(5)		NOT NULL,
	[ORDEN_ORIGEN]						VARCHAR(10)		NOT NULL,
	[ORDEN_DESTINO]						VARCHAR(10)		NOT NULL,
	[COLOR]								VARCHAR(20)		NOT NULL,
	[LOTE]								VARCHAR(10)		NOT NULL,
	[PIEL]								VARCHAR(10)		NOT NULL,
	[SQF]								VARCHAR(10)		NOT NULL,
	-- =================================	
	[AUTORIZADO]						INT				NOT NULL DEFAULT 0					
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[PIEL_A_TRANSFERIR]
	ADD CONSTRAINT [PK_PIEL_A_TRANSFERIR]
		PRIMARY KEY CLUSTERED ([K_PIEL_A_TRANSFERIR])
GO

-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[PIEL_A_TRANSFERIR] 
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
