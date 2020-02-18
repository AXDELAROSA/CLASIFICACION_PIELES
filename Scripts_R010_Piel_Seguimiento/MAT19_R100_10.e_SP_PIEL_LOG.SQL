-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_Folios / Folio Transaccion
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	20/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO


-- EXECUTE [dbo].[PG_IN_RP_FOLIOS] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_IN_PIEL_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_IN_PIEL_LOG]
GO


CREATE PROCEDURE [dbo].[PG_PR_IN_PIEL_LOG]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_TIPO_PIEL_LOG			INT,
	@PP_FOLIO_ORIGEN			INT,
	@PP_COLOR					VARCHAR(10),
	@PP_LOCACION_ORIGEN			VARCHAR(5),
	@PP_ORDEN_ORIGEN			VARCHAR(10),
	@PP_LOCACION_DESTINO		VARCHAR(5),
	@PP_ORDEN_DESTINO			VARCHAR(10)

AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
		
	DECLARE CU_PIELES_A_TRANFERIR CURSOR 
	FOR SELECT	LTRIM(RTRIM(LOT)), LTRIM(RTRIM(HIDE)),LTRIM(RTRIM(SQF)) 
		FROM	RP_SC
		WHERE	LTRIM(RTRIM(TAGNO))=@PP_FOLIO_ORIGEN
		AND		LTRIM(RTRIM(COLOUR))=@PP_COLOR
	
	DECLARE @VP_LOTE	VARCHAR(10)
	DECLARE @VP_PIEL	VARCHAR(10)
	DECLARE @VP_SQF		VARCHAR(10)

	OPEN CU_PIELES_A_TRANFERIR
	FETCH NEXT FROM CU_PIELES_A_TRANFERIR INTO @VP_LOTE, @VP_PIEL, @VP_SQF
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @PP_ORDEN_ORIGEN = '-'
			SET @PP_ORDEN_ORIGEN = 0

		IF @PP_ORDEN_DESTINO = ''
			SET @PP_ORDEN_DESTINO = 0

		SET @PP_ORDEN_ORIGEN = CAST(@PP_ORDEN_ORIGEN AS INT) 

		SET @PP_ORDEN_DESTINO = CAST(@PP_ORDEN_DESTINO AS INT) 

		SET @VP_LOTE = CAST(@VP_LOTE AS INT)
		SET @VP_PIEL = CAST(@VP_PIEL AS INT)
		SET @VP_SQF	 = CAST(@VP_SQF	AS DECIMAL(13,4))

		INSERT INTO PIEL_LOG	
						(					
							[K_TIPO_PIEL_LOG],		
							-- =================
							[COLOR],				
							[LOTE],				
							[PIEL],					
							[LOCACION_ORIGEN],	
							[ORDEN_ORIGEN],		
							[LOCACION_DESTINO],	
							[ORDEN_DESTIDO],		
							[SQF],					
							[F_LOG],	
							-- ===========================
							[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
							[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
					VALUES	
						(	@PP_K_TIPO_PIEL_LOG, 
							@PP_COLOR,			
							@VP_LOTE,			
							@VP_PIEL,				
							@PP_LOCACION_ORIGEN,			
							@PP_ORDEN_ORIGEN,	
							@PP_LOCACION_DESTINO,		
							@PP_ORDEN_DESTINO,				
							@VP_SQF,
							GETDATE(),
							-- ===========================				
							@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
							0, NULL, NULL )	
			
			IF @@ROWCOUNT = 0
				BEGIN
					RAISERROR ('ERROR SP: PG_PR_IN_PIEL_LOG', 16, 1 ) --MENSAJE - Severity -State.
					--SET @VP_MENSAJE = 'ERROR: // UPDATE RP_SC  // '
				END
		-- ///////////////////////////////////////////
		
		
	    FETCH NEXT FROM CU_PIELES_A_TRANFERIR INTO @VP_LOTE, @VP_PIEL, @VP_SQF
	
	END
	
	CLOSE CU_PIELES_A_TRANFERIR
	DEALLOCATE CU_PIELES_A_TRANFERIR

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
