-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			TRANSFERENCIA DE FOLIOS
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	14/OCT/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_X_CAMBIO_COLOR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_X_CAMBIO_COLOR]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_X_CAMBIO_COLOR]	0,0,3788363, 'MHI', 'FMCKTX7', 'FGMPAT5', 'cambio de color de FMCKTX7 a FGMPAT5', 'FRANCISCOE', 'IT-010'
*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_X_CAMBIO_COLOR]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_TAGNO_ORIGEN						INT,
	-- ===========================
	@PP_LOCACION_ORIGEN						VARCHAR(10),
	-- ===========================
	@PP_COLOR_ORIGEN						VARCHAR(20),
	@PP_COLOR_DESTINO						VARCHAR(20),
	@PP_COMENTARIO							VARCHAR(255),
	-- ===========================
	@PP_USER								VARCHAR(25),
	@PP_COMPUTER_NAME						VARCHAR(25)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
			-- ////////////////////////////////////////////////////////////////////	
			DECLARE @VP_PIEL_MAYOR			VARCHAR(5) = ''
			DECLARE @VP_PIEL_CONSECUTIVO	VARCHAR(5) = ''
			DECLARE @VP_N_PIEL_DUPLICADA INT = 0

			SELECT	@VP_N_PIEL_DUPLICADA = COUNT(ID)
			FROM	RP_SC
			WHERE LTRIM(RTRIM(COLOUR)) = @PP_COLOR_DESTINO
			AND	LTRIM(RTRIM(LOT))	IN (	SELECT	DISTINCT LTRIM(RTRIM(LOT))
											FROM	RP_SC
											WHERE	TAGNO = @PP_TAGNO_ORIGEN )
			AND	LTRIM(RTRIM(HIDE))	IN (	SELECT	DISTINCT LTRIM(RTRIM(HIDE))
											FROM	RP_SC
											WHERE	TAGNO = @PP_TAGNO_ORIGEN )
			
			IF @VP_N_PIEL_DUPLICADA IS NULL
				SET @VP_N_PIEL_DUPLICADA = 0

			IF @VP_N_PIEL_DUPLICADA > 0
				BEGIN
					--DECLARE @VP_PIEL_MAYOR	VARCHAR(5) = ''
					--DECLARE @VP_PIEL_CONSECUTIVO	VARCHAR(5) = ''

					SELECT	@VP_PIEL_MAYOR = MAX(CONVERT(INT, LTRIM(RTRIM(HIDE))))
					FROM	RP_SC
					WHERE LTRIM(RTRIM(COLOUR)) = @PP_COLOR_DESTINO
										
					SET @VP_PIEL_MAYOR =  RIGHT('0000' + @VP_PIEL_MAYOR, 4)

					--SELECT @VP_PIEL_MAYOR

					SET @VP_PIEL_CONSECUTIVO = SUBSTRING(@VP_PIEL_MAYOR, 1, 1)

					--SELECT @VP_PIEL_CONSECUTIVO

					SET @VP_PIEL_CONSECUTIVO = @VP_PIEL_CONSECUTIVO + 1

					--SELECT  @VP_PIEL_CONSECUTIVO

					--SELECT @VP_PIEL_CONSECUTIVO + SUBSTRING(@VP_PIEL_MAYOR, 2, 4)
				END
			
			DECLARE @VP_FOLIO	INT = 0
	
			SELECT	TOP 1 @VP_FOLIO=TAG
			-- =====================
			FROM	RP_Folios  
			-- =====================
			INNER JOIN RP_SC ON TAG=TAGNO
				AND RTRIM(LTRIM(STATUS)) = 'B' 
				AND COLOUR=@PP_COLOR_DESTINO
			-- =====================
			GROUP BY TAG, COLOUR

			--SELECT * FROM RP_FOLIOS WHERE TAG = 3795143
			--SELECT * FROM RP_SC WHERE TAGNO = 3795143

			IF @VP_FOLIO IS NULL OR @VP_FOLIO = ''
				BEGIN
					EXECUTE BD_GENERAL.[dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_K_SISTEMA_EXE, 
																		'DATA_02Pruebas', 'RP_FOLIOS', 'TAG',
																		@OU_K_TABLA_DISPONIBLE = @VP_FOLIO	OUTPUT

					--EXECUTE [dbo].[PG_IN_RP_FOLIOS]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
					--								@VP_FOLIO, 'B', '', '', ''
				END

			--INSERT INTO RP_SC( 
			--					[CDATE], [COLOUR], [LOT], [HIDE], [SQF], [TAGNO], [YARDAS], [YLB], [PESO], [TYPE], [MOVEMENT], [K_CLASIFICACION]
			--				)
					SELECT GETDATE(), @PP_COLOR_DESTINO, [LOT], 
							(CASE WHEN @VP_PIEL_CONSECUTIVO = '' THEN [HIDE]
									ELSE	CONCAT(@VP_PIEL_CONSECUTIVO, SUBSTRING(LTRIM(RTRIM([HIDE])), 2, 4)) END ), 
							RTRIM(LTRIM([SQF])), @VP_FOLIO, [YARDAS], [YLB], [PESO], 'C', @PP_LOCACION_ORIGEN, [K_CLASIFICACION]
							FROM RP_SC 
							WHERE TAGNO = @PP_TAGNO_ORIGEN

			IF @@ROWCOUNT = 0
			BEGIN
				DECLARE @VP_MENSAJE_TRANSACCION VARCHAR(255)= 'No fue posible actualizar las pieles en RP_SC'
				RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
			END

		-- ////////////////////////////////////////////////////////////////////	
								
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PM_TRANSFER_PIEL_X_LOCACION] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible cambiar de color las pieles del [FOLIO]: ' + '[#FOL.'+CONVERT(VARCHAR(10),@PP_TAGNO_ORIGEN)+'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAGNO_ORIGEN AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	--EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												-- ===========================================
	--												2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
	--												'PROCESO',
	--												'',
	--												-- ===========================================
	--												'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
	--												0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
	--												-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
	--												0, 0, @PP_TAGNO_ORIGEN, '' , 0.00, 0.00,
	--												-- === @PP_VALOR_1 al 6_DATO
	--												'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
