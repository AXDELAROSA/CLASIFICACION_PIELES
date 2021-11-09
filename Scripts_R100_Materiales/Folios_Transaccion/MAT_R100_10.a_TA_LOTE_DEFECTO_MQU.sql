-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			
-- // OPERACION:		LOTE_DEFECTO_MQU
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	27/OCT/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LOTE_DEFECTO_MQU]') AND type in (N'U'))
	DROP TABLE [dbo].[LOTE_DEFECTO_MQU]
GO

-- //////////////////////////////////////////////////////////////
-- // LOTE_DEFECTO_MQU
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[LOTE_DEFECTO_MQU] (
	[K_LOTE_DEFECTO_MQU]				[INT]			NOT NULL IDENTITY(1,1),
	[K_PIEL_A_TRANSFERIR_TRANSACCION]	[INT]			NOT NULL,
	-- =================================		
	[FOLIO_ORIGEN]						INT				NOT NULL,
	[LOCACION_ORIGEN]					VARCHAR(10)		NOT NULL,
	[LOCACION_DESTINO]					VARCHAR(10)		NOT NULL,
	[LOTE]								VARCHAR(50)		NOT NULL,
	[DEFECTO]							VARCHAR(255)	NOT NULL			
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[LOTE_DEFECTO_MQU]
	ADD CONSTRAINT [PK_LOTE_DEFECTO_MQU]
		PRIMARY KEY CLUSTERED ([K_LOTE_DEFECTO_MQU])
GO

-- //////////////////////////////////////////////////////////////


--ALTER TABLE [dbo].[PIEL_A_TRANSFERIR] ADD 
--	CONSTRAINT [FK_PIEL_A_TRANSFERIR]  
--		FOREIGN KEY ([K_PIEL_A_TRANSFERIR_TRANSACCION]) 
--		REFERENCES [dbo].[PIEL_A_TRANSFERIR_TRANSACCION] ([K_PIEL_A_TRANSFERIR_TRANSACCION])
--GO


-- //////////////////////////////////////////////////////


ALTER TABLE [dbo].[LOTE_DEFECTO_MQU] 
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
