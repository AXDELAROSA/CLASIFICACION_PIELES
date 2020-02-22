-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			TRANSFERENCIA DE FOLIOS
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	18/DIC/2019
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_ISSUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_ISSUE]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_ISSUE]	0,0,   3785577 , 'MQU' , '' , 'franciscoe' , 'ITX-002' 

*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_ISSUE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO_ORIGEN			INT,
	@PP_LOCACION_ORIGEN			VARCHAR(5),
	-- ===========================
	@PP_COMENTARIO				VARCHAR(MAX),
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- /////////////////////////// RN - VALIDACIONES //////////////////////////////////////////
	
		
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- /////////QUITAMOS LOS METROS CUADRADOS DEL INVENTARIO E INGRESAMOS LAS TRRANSACCIONES///////////////////////
				EXECUTE	[dbo].[PG_PM_TRANSFER_ISSUE_COMPLEMENTO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_FOLIO_ORIGEN, @PP_LOCACION_ORIGEN,
																	@PP_COMENTARIO, @PP_USER

				-- /////////INGRESAMOS LAS PIELES DEL FOLIO A LOS LOS DIFERENTES LOGS PARA SEGUIMINETO ANTES DE BORRARLAS///////
				DECLARE @VP_COLOR	VARCHAR(10)
				DECLARE @VP_LOTE	INT
				DECLARE @VP_PIEL	INT
				DECLARE @VP_SQF		DECIMAL(13,4)

				DECLARE CU_PIELES_A_BORRAR CURSOR 
				FOR SELECT	LTRIM(RTRIM(COLOUR)), LTRIM(RTRIM(LOT)), LTRIM(RTRIM(HIDE)), LTRIM(RTRIM(SQF)) 
					FROM	RP_SC
					WHERE   TAGNO= @PP_FOLIO_ORIGEN
				
				OPEN CU_PIELES_A_BORRAR
				FETCH NEXT FROM CU_PIELES_A_BORRAR INTO @VP_COLOR, @VP_LOTE, @VP_PIEL, @VP_SQF
				
				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- ///////////////////INGRESO EL LOG DE LA PIEL//////////////////////////////////////////////////
					EXECUTE [dbo].[PG_IN_PIEL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														7, @PP_FOLIO_ORIGEN, @VP_COLOR,
														@VP_LOTE, @VP_PIEL, @VP_SQF, 
														@PP_LOCACION_ORIGEN, 0, 
														0, 0, 0
					-- /////////////////////////////////////////////////////////////////////
	
					DECLARE @VP_DETAIL VARCHAR(100) = 'Scrap Ticket'
						
					EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_USER, @PP_COMPUTER_NAME, 'Transactions',
														@PP_FOLIO_ORIGEN, 'Issue Out',
														@VP_DETAIL, @VP_PIEL

				  FETCH NEXT FROM CU_PIELES_A_BORRAR INTO @VP_COLOR, @VP_LOTE, @VP_PIEL, @VP_SQF
	
				END
				
				CLOSE CU_PIELES_A_BORRAR
				DEALLOCATE CU_PIELES_A_BORRAR
				-- ////////////////////////////////////////////////////////////////////	

				DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = 'franciscoe@pearlleather.com.mx;rafaelf@pearlleather.com.mx'
				--'dianan@pearlleather.com.mx;manuelg@pearlleather.com.mx;fernandog@pearlleather.com.mx;pedrov@pearlleather.com.mx'
			
			DECLARE @VP_SUBJECT		VARCHAR(255) = 'Issue Out MQU'
			DECLARE @VP_FECHA		VARCHAR(10) = CONVERT(VARCHAR(10), GETDATE(),103)
			DECLARE @VP_BODY		NVARCHAR(MAX) 
			
			SET @VP_BODY = N'<table  border="1" align="center" cellspacing="0">' + 
								N'<thead>' + 
								  N'<tr BGCOLOR="#ADD8E6">' + 
								    N'<th colspan="7">Se han eliminado las siguientes pieles</th>' + 
								  N'</tr>' + 
								  N'<tr BGCOLOR="#48D1CC">' + 
								    N'<th>Folio</th><th>Color</th><th>Lote</th><th>Piel</th><th>SQF</th><th>Usuario</th><th>Fecha</th>' + 
								  N'</tr>' + 
								N'</thead>' + 
								N'<tbody>' + 
								  N'<tr>' + 
							CAST ( ( SELECT td = RTRIM(LTRIM(TAGNO)),'',  
							                td = RTRIM(LTRIM(COLOUR)), '',  
							                td = RTRIM(LTRIM(LOT)), '',  
							                td = RTRIM(LTRIM(HIDE)), '',  
							                td = RTRIM(LTRIM(SQF)), '',  
											td = @PP_USER, '',  
							                td = CONVERT(DATE,GETDATE())  
							         FROM RP_SC
									 WHERE RTRIM(LTRIM(TAGNO)) = @PP_FOLIO_ORIGEN
							          FOR XML PATH('tr'), TYPE   
							) AS NVARCHAR(MAX) ) +  
							  N'</tr>' + 
								N'</tbody>' + 
							N'</table>' ; 
				SET ROWCOUNT 0
				 				
			EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY
				-- ////////////////////////////////////////////////////////////////////	
			DELETE	RP_SC
			WHERE	LTRIM(RTRIM(TAGNO)) = @PP_FOLIO_ORIGEN

			IF @@ROWCOUNT = 0
				RAISERROR ('No fue posible borrar las Piles', 16, 1 ) --MENSAJE - Severity -State.
			-- ////////////////////////////////////////////////////////////////////	

			DELETE	RP_Folios
			WHERE	LTRIM(RTRIM(TAG)) = @PP_FOLIO_ORIGEN
			
			IF @@ROWCOUNT = 0
				RAISERROR ('No fue posible borrar el folio', 16, 1 ) --MENSAJE - Severity -State.
						
		COMMIT TRANSACTION 
		END TRY
	
		BEGIN CATCH
			/* Ocurrió un error, deshacemos los cambios*/ 
			ROLLBACK TRANSACTION
			DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
			SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
			SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_PM_TRANSFER_ISSUE // ' + @VP_ERROR_TRANS
		END CATCH
			
	END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Eliminar el [FOLIO]: '+CONVERT(VARCHAR(10),@PP_FOLIO_ORIGEN)+']' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_FOLIO_ORIGEN AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'PROCESO',
													'',
													-- ===========================================
													'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_FOLIO_ORIGEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
