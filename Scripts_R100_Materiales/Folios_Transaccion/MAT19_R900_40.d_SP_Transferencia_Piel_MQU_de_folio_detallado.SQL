-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			CREAR FOLIO NUEVO Y MOVER A LOCACION (MHI-MSL) CON PIELES DE FOLIO DETALLADO
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	26/MAY/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_TRANSFERIR_PIEL_DE_FOLIO_DETALLADO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_TRANSFERIR_PIEL_DE_FOLIO_DETALLADO]
GO
/*
	EXECUTE  [dbo].[PG_PR_TRANSFERIR_PIEL_DE_FOLIO_DETALLADO]	0, 144,  3789698 , 'franciscoe' , 'IT-010' 
*/
CREATE PROCEDURE [dbo].[PG_PR_TRANSFERIR_PIEL_DE_FOLIO_DETALLADO]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_FOLIO_DETALLADO						INT,
	-- ===========================
	@PP_USER								VARCHAR(25),
	@PP_COMPUTER_NAME						VARCHAR(25)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	DECLARE @VP_MENSAJE_TRANSACCION VARCHAR(255) = ''
	DECLARE @VP_LOCACION_ORIGEN VARCHAR(20) = 'MQU'

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
	DECLARE @VP_N_FOLIO_DETALLADO INT = 0
	SELECT @VP_N_FOLIO_DETALLADO = COUNT(ID)
	FROM RP_SC_FOLIO_TYPE_2
	WHERE TAGNO = @PP_FOLIO_DETALLADO
	AND	COLOUR IN  ( SELECT COLOR
					 FROM COLORES_CONTROLADOS )

	IF @VP_N_FOLIO_DETALLADO IS NULL OR @VP_N_FOLIO_DETALLADO = 0
		SET @VP_MENSAJE = 'Folio detallado no encontrado o sin pieles de colores controlados.'

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY				
				-- /////////////////////////////////////////////////////////////////////
				DECLARE @VP_COLOR			VARCHAR(10)	= ''
				DECLARE @VP_LOTE			VARCHAR(10)	= ''
				DECLARE @VP_PIEL			VARCHAR(10)	= ''
				DECLARE @VP_SQF_FOLIO		DECIMAL(5,2) = 0
				DECLARE @VP_COLOR_ANTERIOR	VARCHAR(10)	= ''


				DECLARE CU_PIEL_X_FOLIO_DETALLADO CURSOR 
				FOR SELECT LTRIM(RTRIM(COLOUR)) , LTRIM(RTRIM(LOT)), LTRIM(RTRIM(HIDE)), CONVERT(DECIMAL(5,2),LTRIM(RTRIM(SQF)))
					FROM RP_SC_FOLIO_TYPE_2
					WHERE TAGNO = @PP_FOLIO_DETALLADO
					AND	COLOUR IN  (	SELECT COLOR
										FROM COLORES_CONTROLADOS )
					--AND LOT IN ('401531', '401781', '750041') -- PARA PRUEBAS
					ORDER BY COLOUR, LOT

				OPEN CU_PIEL_X_FOLIO_DETALLADO
				FETCH NEXT FROM CU_PIEL_X_FOLIO_DETALLADO INTO @VP_COLOR, @VP_LOTE, @VP_PIEL, @VP_SQF_FOLIO
					
				WHILE @@FETCH_STATUS = 0
					BEGIN
						IF @VP_COLOR_ANTERIOR <> @VP_COLOR
							BEGIN
								-- ///////////SE OBTIENE EL CONSECUTIVO DEL FOLIO///////////////////////////////////////////////////
								DECLARE @VP_TAGNO_DESTINO		INT = 0
								EXECUTE BD_GENERAL.[dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_K_SISTEMA_EXE, 
																					--'DATA_02Pruebas', -- PARA PRUEBAS
																					'DATA_02', 
																					'RP_FOLIOS', 'TAG',
																					@OU_K_TABLA_DISPONIBLE = @VP_TAGNO_DESTINO	OUTPUT
								
								---- ///////////SE CREA UN FOLIO PARA SEPARAR LAS PIELES QUE SE DESEAN MOVER///////////////////////////////////////////////////
								--INSERT INTO DATA_02Pruebas.DBO.RP_Folios (	-- PARA PRUEBAS
								INSERT INTO RP_Folios (	
										TAG, STATUS, MACHINE, JOBNO	) 
								VALUES(
										@VP_TAGNO_DESTINO, 'A', '-', '-'	)
								
								IF @@ROWCOUNT = 0
									BEGIN
										SET @VP_MENSAJE_TRANSACCION = ' No fue posible crear el folio en [RP_Folios].'
										RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
									END

								DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = 'franciscoe@pearlleather.com.mx'
								DECLARE @VP_SUBJECT		VARCHAR(255) = 'Creacion de Folio con Detallado'
								DECLARE @VP_FECHA		VARCHAR(10) = CONVERT(VARCHAR(10), GETDATE(),103)
								DECLARE @VP_COMENTARIO		VARCHAR(255) = 'Folio creado apartir del Folio detallado: ' + CONVERT(VARCHAR(10),@PP_FOLIO_DETALLADO) 
								DECLARE @VP_BODY		NVARCHAR(MAX) 
								
								SET @VP_BODY = N'<table  border="1" align="center" cellspacing="0">' + 
													N'<thead>' + 
													  N'<tr BGCOLOR="#ADD8E6">' + 
													    N'<th colspan="6">Folio creado apartir del detallado: '+ CONVERT(VARCHAR(10),@PP_FOLIO_DETALLADO) +'</th>' + 
													  N'</tr>' + 
													  N'<tr BGCOLOR="#48D1CC">' + 
													    N'<th>Fecha</th><th>Locacion Ori.</th><th>Color</th><th>Folio</th><th>Comentario</th><th>Usuario</th>' + 
													  N'</tr>' + 
													N'</thead>' + 
													N'<tbody>' + 
													  N'<tr>' + 
													  N'<td>'+ @VP_FECHA +'</td><td>'+ @VP_LOCACION_ORIGEN +'</td><td>'+ @VP_COLOR +'</td><td>'+ CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO) +'</td><td>'+ @VP_COMENTARIO+'</td><td>'+ @PP_USER +'</td>' + 
													  N'</tr>' + 
													N'</tbody>' + 
												N'</table>' ;
									SET ROWCOUNT 0
									 				
								EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY
							END

						-- /////////SE VALIDA QUE EL LOTE Y PIEL EXISTA EN MQU Y QUE NO ESTE DUPLICADA///////////////////////////////////////////////////////////	
						DECLARE @VP_N_PIEL INT = 0
						SELECT @VP_N_PIEL = COUNT(ID)
						FROM RP_SC 
						WHERE COLOUR = @VP_COLOR
						AND LOT = @VP_LOTE 
						AND HIDE = @VP_PIEL
						AND CONVERT(DECIMAL(13,2), SQF) = @VP_SQF_FOLIO
						AND MOVEMENT = @VP_LOCACION_ORIGEN --'MQU'

						IF @VP_N_PIEL IS NULL OR  @VP_N_PIEL = 0
							BEGIN
								SET @VP_MENSAJE_TRANSACCION = ' La Piel:' + @VP_PIEL  + ' Lote:' + @VP_LOTE + ' no existe en MQU.'
								RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
							END	

						IF @VP_N_PIEL > 1
							BEGIN
								SET @VP_MENSAJE_TRANSACCION = ' La Piel:' + @VP_PIEL  + ' Lote:' + @VP_LOTE + ' se encuentra duplicada en MQU.'
								RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
							END	

						-- /////////SE OBTIENE EL FOLIO ORIGEN///////////////////////////////////////////////////////////	
						DECLARE @VP_FOLIO_ORIGEN INT = 0
						SELECT @VP_FOLIO_ORIGEN = TAGNO
						FROM RP_SC 
						WHERE COLOUR = @VP_COLOR
						AND LOT = @VP_LOTE 
						AND HIDE = @VP_PIEL
						AND CONVERT(DECIMAL(13,2), SQF) = @VP_SQF_FOLIO
						AND MOVEMENT = @VP_LOCACION_ORIGEN --'MQU'

						IF @VP_FOLIO_ORIGEN IS NULL OR  @VP_FOLIO_ORIGEN = 0
							BEGIN
								SET @VP_MENSAJE_TRANSACCION = 'No fue posible obtener el folio origen de La Piel:' + @VP_PIEL  + ' Lote:' + @VP_LOTE + '.'
								RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
							END	

						-- /////////SE ACTUALIZA LA PIEL CON EL NUEVO FOLIO///////////////////////////////////////////////////////////
						UPDATE RP_SC 
							SET TAGNO = @VP_TAGNO_DESTINO
						WHERE TAGNO = @VP_FOLIO_ORIGEN
						AND COLOUR = @VP_COLOR
						AND LOT = @VP_LOTE 
						AND HIDE = @VP_PIEL
						AND CONVERT(DECIMAL(13,2), SQF) = @VP_SQF_FOLIO
						AND MOVEMENT = @VP_LOCACION_ORIGEN --'MQU'

						IF @@ROWCOUNT = 0
							BEGIN
								SET @VP_MENSAJE_TRANSACCION = 'No fue posible actualizar el folio de la Piel:' + @VP_PIEL  + ' Lote:' + @VP_LOTE + '.'
								RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
							END	
							
						-- /////////SE INGRESA EL LOG DEL LA ASIGNACION DE LA PIEL A OTRO FOLIO DE LA MISMA LOCACION EN LA TABLA PIEL_LOG//////////////////////////////////////////////////////////	
						EXECUTE [dbo].[PG_IN_PIEL_LOG]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														3, @VP_FOLIO_ORIGEN, @VP_COLOR,
														@VP_LOTE, @VP_PIEL, @VP_SQF_FOLIO, 
														@VP_LOCACION_ORIGEN, 0, 
														@VP_TAGNO_DESTINO, @VP_LOCACION_ORIGEN, 0

						-- ////////SE INGRESA EL LOG DE LA PIEL EN LA TABLA PIEL_LOG/////////////////////////////////////////////////////////////
						DECLARE @VP_DETAIL VARCHAR(255) = 'Transfer hide: ' + @VP_PIEL + ' to: ' + CONVERT(VARCHAR(20),@VP_TAGNO_DESTINO) + ' Lot: ' + RIGHT('000000' + Ltrim(Rtrim(@VP_LOTE)), 6)
							
						EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
															@VP_FOLIO_ORIGEN, 'Transfer Nuevo',
															@VP_DETAIL, @VP_PIEL
						
						-- ////////SE ASIGNA EL COLOR ACTUAL AL ANTERIOR/////////////////////////////////////////////////////////////
						SET @VP_COLOR_ANTERIOR = @VP_COLOR

						FETCH NEXT FROM CU_PIEL_X_FOLIO_DETALLADO INTO @VP_COLOR, @VP_LOTE, @VP_PIEL, @VP_SQF_FOLIO
	
					END
	
				CLOSE CU_PIEL_X_FOLIO_DETALLADO
				DEALLOCATE CU_PIEL_X_FOLIO_DETALLADO

				-- ////////////////////////////////////////////////////////////////////	
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PR_TRANSFERIR_PIEL_DE_FOLIO_DETALLADO] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible transferir las pieles del Folio: [' + CONVERT(VARCHAR(10),@PP_FOLIO_DETALLADO)+'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_FOLIO_DETALLADO AS CLAVE
	
	-- //////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
