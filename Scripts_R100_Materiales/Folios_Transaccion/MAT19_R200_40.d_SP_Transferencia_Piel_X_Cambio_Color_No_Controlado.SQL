-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			CAMBIO DE COLOR NO CONTROLADO A CONTROLADO
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	18/MAY/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_FOLIO_COLOR_NO_CONTROLADO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_FOLIO_COLOR_NO_CONTROLADO]
GO
/*
 EXEC PG_LI_FOLIO_COLOR_NO_CONTROLADO 0 ,0, 3790196
 EXEC PG_LI_FOLIO_COLOR_NO_CONTROLADO 0 ,0, 3827689
 EXEC PG_LI_FOLIO_COLOR_NO_CONTROLADO 0 ,0, 3777313 -- FOLIO BASE

 EXEC PG_LI_FOLIO_COLOR_NO_CONTROLADO 0 ,0, 3793146 --COLOR CONTROLADO
*/

CREATE PROCEDURE [dbo].[PG_LI_FOLIO_COLOR_NO_CONTROLADO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					INT
AS

	-- ///////////////////////////////////////////

	SELECT DISTINCT
			LTRIM(RTRIM(COLOUR))	AS COLOUR,
			LTRIM(RTRIM(LOT))		AS LOT,
			LTRIM(RTRIM(HIDE))		AS HIDE,
			LTRIM(RTRIM(SQF))		AS SQF,
			LTRIM(RTRIM(TAGNO))		AS TAGNO,
			LTRIM(RTRIM(TYPE))		AS TYPE
	FROM	RP_SC (NOLOCK)
	-- =======================
	INNER JOIN RP_Folios (NOLOCK) ON TAG = TAGNO
		AND STATUS <> 'B'
	WHERE	LTRIM(RTRIM(TAGNO))=@PP_FOLIO
	AND LTRIM(RTRIM(COLOUR)) NOT IN (SELECT COLOR FROM COLORES_CONTROLADOS (NOLOCK)) 
	-- =======================
	ORDER BY LOT, HIDE
          

	---////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_X_CAMBIO_COLOR_NO_CONTROLADO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_X_CAMBIO_COLOR_NO_CONTROLADO]
GO
/*
	EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_X_CAMBIO_COLOR_NO_CONTROLADO]	0, 144, 3827689, 'FWLNPX7', 'FRANCISCOE', 'IT-010'
	EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_X_CAMBIO_COLOR_NO_CONTROLADO]	0, 144, 3790196, 'FWLNPX7', 'FRANCISCOE', 'IT-010'
*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_X_CAMBIO_COLOR_NO_CONTROLADO]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_TAGNO_ORIGEN						INT,
	-- ===========================
	@PP_COLOR_DESTINO						VARCHAR(20),
	-- ===========================
	@PP_USER								VARCHAR(25),
	@PP_COMPUTER_NAME						VARCHAR(25)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	DECLARE @VP_MENSAJE_TRANSACCION VARCHAR(255) = ''
	DECLARE @VP_LOCACION_ORIGEN		VARCHAR(5) = 'MHI'

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
	DECLARE @VP_COLOR_ORIGEN VARCHAR(50) = '' 
	SELECT TOP 1 @VP_COLOR_ORIGEN = LTRIM(RTRIM(COLOUR))
	FROM RP_SC (NOLOCK)
	WHERE TAGNO = @PP_TAGNO_ORIGEN

	IF @VP_COLOR_ORIGEN IS NULL OR @VP_COLOR_ORIGEN = ''
		SET @VP_MENSAJE = 'No fue posible obtener el color del folio origen.'
	
	IF @VP_MENSAJE = ''	
		BEGIN
			DECLARE @VP_N_COLOR_CONTROLADO INT = 0
			SELECT @VP_N_COLOR_CONTROLADO = COUNT(ID) 
			FROM COLORES_CONTROLADOS (NOLOCK)
			WHERE COLOR = @VP_COLOR_ORIGEN

			IF @VP_N_COLOR_CONTROLADO IS NULL
				SET @VP_N_COLOR_CONTROLADO = 0
			
			IF @VP_N_COLOR_CONTROLADO > 0
				SET @VP_MENSAJE = 'No fue posible realizar el cambio porque el folio es color controlado.'
		END

	-- /////////////////////////////////////////////////////
	IF @VP_MENSAJE = ''	
		BEGIN
			DECLARE @VP_ESTATUS	VARCHAR(5) = ''
			SELECT @VP_ESTATUS = LTRIM(RTRIM(STATUS))
			FROM RP_FOLIOS (NOLOCK)
			WHERE TAG = @PP_TAGNO_ORIGEN

			IF @VP_ESTATUS IS NULL OR @VP_ESTATUS = ''
				SET @VP_MENSAJE = 'No fue posible obtener el tipo del folio origen.'
				
			IF @VP_MENSAJE = ''
				IF @VP_ESTATUS = 'B'
					SET @VP_MENSAJE = 'El folio origen es tipo base, no se puede cambiar de color.'
		END

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				DECLARE @VP_COLOR	VARCHAR(10)	= ''
				DECLARE @VP_LOTE	VARCHAR(10)	= ''
				DECLARE @VP_PIEL	VARCHAR(10)	= ''
				DECLARE @VP_SQF_FOLIO	DECIMAL(5,2) = 0

				DECLARE CU_PIEL_X_FOLIO CURSOR 
				FOR SELECT  LTRIM(RTRIM(COLOUR)) , LTRIM(RTRIM(LOT)), LTRIM(RTRIM(HIDE)), CONVERT(DECIMAL(5,2),LTRIM(RTRIM(SQF)))
					FROM RP_SC (NOLOCK)
					WHERE TAGNO = @PP_TAGNO_ORIGEN

				OPEN CU_PIEL_X_FOLIO
				FETCH NEXT FROM CU_PIEL_X_FOLIO INTO @VP_COLOR, @VP_LOTE, @VP_PIEL, @VP_SQF_FOLIO
					
				WHILE @@FETCH_STATUS = 0
					BEGIN
						-- /////////SE VALIDA QUE EL LOTE Y PIEL NO EXISTA EN EL COLOR NUEVO///////////////////////////////////////////////////////////	
						DECLARE @VP_N_PIEL_DUPLICADA INT = 0
						SELECT	@VP_N_PIEL_DUPLICADA = COUNT(ID)
						FROM	RP_SC (NOLOCK)
						WHERE LTRIM(RTRIM(COLOUR)) = @PP_COLOR_DESTINO
						AND	LTRIM(RTRIM(LOT)) = @VP_LOTE
						AND	LTRIM(RTRIM(HIDE)) = @VP_PIEL
						
						IF @VP_N_PIEL_DUPLICADA IS NULL
							SET @VP_N_PIEL_DUPLICADA = 0

						IF @VP_N_PIEL_DUPLICADA > 0
							BEGIN
								SET @VP_MENSAJE_TRANSACCION = ' La Piel:' + @VP_PIEL  + ' Lote:' + @VP_LOTE + ' existe en el Color Destino:' + @PP_COLOR_DESTINO + '.'
								RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
							END	

						-- /////////SE VALIDA QUE LA PIEL NO ESTE ASIGNADA A UN FOLIO QUE ESTE EN MESA///////////////////////////////////////////////////////////	
						DECLARE @VP_N_PIEL_EN_MESA INT = 0
						SELECT @VP_N_PIEL_EN_MESA = COUNT(RP_SC.ID) 
						FROM RP_SC (NOLOCK)
						INNER JOIN RP_FOLIOS (NOLOCK) ON TAG = TAGNO
							AND SUBSTRING(LTRIM(RTRIM(MACHINE)), 1, 1) IN ('T', 'G')
						WHERE LOT = @VP_LOTE 
						AND HIDE = @VP_PIEL
						AND TAGNO <> @PP_TAGNO_ORIGEN

						IF @VP_N_PIEL_EN_MESA IS NULL 
							SET @VP_N_PIEL_EN_MESA = 0

						IF @VP_N_PIEL_EN_MESA > 0
							BEGIN
								SET @VP_MENSAJE_TRANSACCION = ' La Piel:' + @VP_PIEL  + ' Lote:' + @VP_LOTE + ' se encuentra en un folio asignado a Mesa.'
								RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
							END	
						
						-- /////////SE ELIMINAN LAS PIELES QUE ESTEN EN FOLIOS DIFERENTE AL ORIGEN///////////////////////////////////////////////////////////
						DELETE RP_SC 
						WHERE LOT = @VP_LOTE 
						AND HIDE = @VP_PIEL
						AND TAGNO <> @PP_TAGNO_ORIGEN

						-- AGREGADO PARA PRUEBAS FEG
						--IF @@ROWCOUNT = 0
						--	SET @VP_MENSAJE_TRANSACCION = ''

						-- /////////SE ELIMINA EL REGISTRO DE REIMPRESION PARA QUE PUEDEN IMPRIMIR LA ETIQUETA//////////////////////////////////////////////////////////
						DELETE PIEL_LOG 
						WHERE LOTE IN (@VP_LOTE)    
						AND  PIEL = @VP_PIEL 
						AND PIEL_LOG.K_TIPO_PIEL_LOG IN (8) -- REIMPRESION
						
						-- AGREGADO PARA PRUEBAS FEG
						--IF @@ROWCOUNT = 0
						--	SET @VP_MENSAJE_TRANSACCION = ''

						-- /////////SE VALIDA QUE EL SQF DE LA PIEL A CAMBIAR DE COLOR SE IGUAL AL ORIGINAL///////////////////////////////////////////////////////////	
						DECLARE @VP_SQF_ORIGINAL	DECIMAL(5,2) = 0 
						SELECT TOP 1 @VP_SQF_ORIGINAL = ISNULL(SQF,0) 
						FROM HIDESHDR_SQL   (NOLOCK)
						INNER JOIN HIDESLIN_SQL (NOLOCK) ON  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
						AND	LTRIM(RTRIM(PLOT)) = @VP_LOTE
						AND LTRIM(RTRIM(HIDE)) =  @VP_PIEL

						IF @VP_SQF_ORIGINAL IS NULL 
							SET @VP_SQF_ORIGINAL = 0

						IF @VP_SQF_ORIGINAL <> @VP_SQF_FOLIO
							BEGIN
								SET @VP_MENSAJE_TRANSACCION = 'El SQF de la Piel:' + @VP_PIEL  + ' Lote:' + @VP_LOTE + ' no es igual al Original.'
								RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
							END																	
						
						-- /////////SE OBTIENE EL FOLIO BASE DEL COLOR NUEVO///////////////////////////////////////////////////////////	
						DECLARE @VP_FOLIO	INT = 0
						SELECT	TOP 1 @VP_FOLIO=TAG
						-- =====================
						FROM	RP_Folios  (NOLOCK)
						-- =====================
						INNER JOIN RP_SC (NOLOCK) ON TAG=TAGNO
							AND RTRIM(LTRIM(STATUS)) = 'B' 
							AND COLOUR=@PP_COLOR_DESTINO
						-- =====================
						GROUP BY TAG, COLOUR
						
						-- /////////SI NO EXISTE UN FOLIO BASE PARA EL COLOR NUEVO SE CREA///////////////////////////////////////////////////////////	
						IF @VP_FOLIO IS NULL OR @VP_FOLIO = ''
							BEGIN
								EXECUTE BD_GENERAL.[dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_K_SISTEMA_EXE, 
																					'DATA_02', 'RP_FOLIOS', 'TAG',
																					@OU_K_TABLA_DISPONIBLE = @VP_FOLIO	OUTPUT

								EXECUTE [dbo].[PG_IN_RP_FOLIOS]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@VP_FOLIO, 'B', '', '', ''
							END
						
						-- /////////SE INGRESA LA PIEL AL FOLIO BASE DEL COLOR NUEVO///////////////////////////////////////////////////////////	
						INSERT INTO RP_SC( 
											[CDATE], 
											[COLOUR], 
											[LOT], 
											[HIDE], 
											[SQF], 
											[TAGNO], 
											[YARDAS], 
											[YLB], 
											[PESO], 
											[TYPE], 
											[MOVEMENT], 
											[K_CLASIFICACION]
										)
									SELECT	GETDATE(), 
											@PP_COLOR_DESTINO, 
											[LOT], 
											[HIDE],
											RTRIM(LTRIM([SQF])), 
											@VP_FOLIO, 
											[YARDAS], 
											[YLB], 
											[PESO], 
											'C', 
											@VP_LOCACION_ORIGEN, 
											[K_CLASIFICACION]
									FROM RP_SC 
									WHERE TAGNO = @PP_TAGNO_ORIGEN
									AND RTRIM(LTRIM(COLOUR)) = @VP_COLOR
									AND RTRIM(LTRIM(LOT)) = @VP_LOTE
									AND RTRIM(LTRIM(HIDE)) = @VP_PIEL

						IF @@ROWCOUNT = 0
							BEGIN
								SET @VP_MENSAJE_TRANSACCION = 'No fue posible agregar la piel:' + @VP_PIEL + ' al color destino.'
								RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
							END	
							
						IF @@ROWCOUNT > 1
							BEGIN
								SET @VP_MENSAJE_TRANSACCION = 'No fue posible agregar la piel:' + @VP_PIEL + ' al color destino porque esta duplicada.'
								RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
							END										

						-- /////////SE INGRESA EL LOG DEL CAMBIO DE COLOR DE LA PIEL///////////////////////////////////////////////////////////							
						INSERT INTO PIEL_LOG	
										(					
											[K_TIPO_PIEL_LOG],		
											-- =================
											[FOLIO_ORIGEN],
											[COLOR],				
											[LOTE],				
											[PIEL],					
											[LOCACION_ORIGEN],	
											[ORDEN_ORIGEN],	
											[FOLIO_DESTINO],	
											[COLOR_DESTINO],
											[LOCACION_DESTINO],	
											[ORDEN_DESTIDO],		
											[SQF],					
											[F_LOG],	
											-- ===========================
											[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
											[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
									VALUES	
										(	11, 
											@PP_TAGNO_ORIGEN,
											@VP_COLOR,			
											@VP_LOTE,			
											@VP_PIEL,				
											@VP_LOCACION_ORIGEN,			
											0,	
											@VP_FOLIO,
											@PP_COLOR_DESTINO,
											@VP_LOCACION_ORIGEN,		
											0,				
											@VP_SQF_FOLIO,
											GETDATE(),
											-- ===========================				
											@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
											0, NULL, NULL )	
		
						IF @@ROWCOUNT = 0
							BEGIN
								SET @VP_MENSAJE_TRANSACCION = 'No fue posible agregar el Log de la piel:' + @VP_PIEL
								RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
							END

						FETCH NEXT FROM CU_PIEL_X_FOLIO INTO @VP_COLOR, @VP_LOTE, @VP_PIEL, @VP_SQF_FOLIO
	
					END
	
				CLOSE CU_PIEL_X_FOLIO
				DEALLOCATE CU_PIEL_X_FOLIO

				-- /////////////SE TRANSFIEREN LOS PIES CUADRADOS AL NUEVO COLOR///////////////////////////////////////////////////////	
				DECLARE @VP_COMENTARIO VARCHAR(255) = 'Cambio de color de ' + @VP_COLOR_ORIGEN  + ' a ' + @PP_COLOR_DESTINO + ' solicitado por materiales'
				EXECUTE [dbo].[PG_PM_TRANSFER_SQF_X_CAMBIO_COLOR]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_TAGNO_ORIGEN, @PP_COLOR_DESTINO,
																	@VP_LOCACION_ORIGEN, @VP_COMENTARIO, @PP_USER	
																							
				-- ///////////SE ELIMINAN LAS PIELES DEL FOLIO ORIGEN/////////////////////////////////////////////////////////	
				EXECUTE [dbo].[PG_DL_RP_SC_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@PP_TAGNO_ORIGEN

				-- ////////////////////////////////////////////////////////////////////	

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PM_TRANSFER_PIEL_X_CAMBIO_COLOR] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible cambiar de color las pieles del [FOLIO]: ' +CONVERT(VARCHAR(10),@PP_TAGNO_ORIGEN)+' ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_FOLIO AS CLAVE
	
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
