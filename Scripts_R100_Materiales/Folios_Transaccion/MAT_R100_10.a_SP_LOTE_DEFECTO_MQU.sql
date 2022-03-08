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


-- EXECUTE [dbo].[PG_IN_RP_FOLIOS] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_LOTE_DEFECTO_MQU]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_LOTE_DEFECTO_MQU]
GO


CREATE PROCEDURE [dbo].[PG_IN_UP_LOTE_DEFECTO_MQU]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_PIEL_A_TRANSFERIR_TRANSACCION	INT,
	@PP_FOLIO_ORIGEN			INT,
	@PP_LOCACION_ORIGEN			VARCHAR(10),
	@PP_LOCACION_DESTINO		VARCHAR(10),
	@PP_LOTE					VARCHAR(50),
	@PP_CLAVE_DEFECTO			VARCHAR(255)
AS

	DECLARE @VP_MENSAJE	VARCHAR(255) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	DECLARE @VP_DEFECTO VARCHAR(255) = ''
	SELECT @VP_DEFECTO = LTRIM(RTRIM(clave)) 
	FROM PPMS_PEARL.DBO.def 
	WHERE clave = @PP_CLAVE_DEFECTO
	--descripcion='NATURAL'
	--AND clave = @PP_CLAVE_DEFECTO

	IF ( @VP_DEFECTO IS NULL OR @VP_DEFECTO = '' )
		SET @VP_MENSAJE = 'La clave del defecto proporcionado no existe.'

	IF @VP_MENSAJE = ''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				DECLARE @VP_N_LOTE_EXISTE INT = 0
				SELECT @VP_N_LOTE_EXISTE = COUNT([K_LOTE_DEFECTO_MQU])
				FROM [LOTE_DEFECTO_MQU]
				WHERE [K_PIEL_A_TRANSFERIR_TRANSACCION] = @PP_K_PIEL_A_TRANSFERIR_TRANSACCION
				AND [FOLIO_ORIGEN]	= @PP_FOLIO_ORIGEN
				AND [LOCACION_ORIGEN]	= @PP_LOCACION_ORIGEN
				AND [LOCACION_DESTINO]	= @PP_LOCACION_DESTINO
				AND [LOTE]	= 	@PP_LOTE

				IF @VP_N_LOTE_EXISTE IS NULL
					SET @VP_N_LOTE_EXISTE = 0
				-- ===========================

				IF @VP_N_LOTE_EXISTE > 0
					BEGIN		
						UPDATE [LOTE_DEFECTO_MQU]
							SET	DEFECTO = @VP_DEFECTO,
								[K_USUARIO_CAMBIO] = @PP_K_USUARIO_ACCION, 
								[F_CAMBIO] = GETDATE()
						WHERE [K_PIEL_A_TRANSFERIR_TRANSACCION] = @PP_K_PIEL_A_TRANSFERIR_TRANSACCION
						AND [FOLIO_ORIGEN]	= @PP_FOLIO_ORIGEN
						AND [LOCACION_ORIGEN]	= @PP_LOCACION_ORIGEN
						AND [LOCACION_DESTINO]	= @PP_LOCACION_DESTINO
						AND [LOTE]	= 	@PP_LOTE

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR SP: No fue posible Actualizar el defecto en [LOTE_DEFECTO_MQU]', 16, 1 ) --MENSAJE - Severity -State.
					END
				ELSE
					BEGIN	
						INSERT INTO [LOTE_DEFECTO_MQU]	
										(	[K_PIEL_A_TRANSFERIR_TRANSACCION],				
											-- =================================			
											[FOLIO_ORIGEN],										
											[LOCACION_ORIGEN],								
											[LOCACION_DESTINO],									
											[LOTE],											
											[DEFECTO],										
											-- ===========================
											[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
											[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
									VALUES	
										(	@PP_K_PIEL_A_TRANSFERIR_TRANSACCION,		 
											@PP_FOLIO_ORIGEN,	
											@PP_LOCACION_ORIGEN,
											@PP_LOCACION_DESTINO,		
											@PP_LOTE,			
											@VP_DEFECTO,	
											-- ===========================				
											@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
											0, NULL, NULL )	
							
							IF @@ROWCOUNT = 0
								RAISERROR ('ERROR SP: No fue posible Agregar el defecto en [LOTE_DEFECTO_MQU]', 16, 1 ) --MENSAJE - Severity -State.
						END
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_IN_UP_LOTE_DEFECTO_MQU] // ' + @VP_ERROR_TRANS
			END CATCH
		END
			-- ///////////////////////////////////////////
		IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible guardar el Defecto para el Lote: ' + '[' + @PP_LOTE +'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_LOTE AS CLAVE

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
