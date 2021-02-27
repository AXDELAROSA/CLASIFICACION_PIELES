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

USE [DATA_02] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_IMPRIMIR_FORMATO_DEVOLUCION_EXTRA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_IMPRIMIR_FORMATO_DEVOLUCION_EXTRA]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_IMPRIMIR_FORMATO_DEVOLUCION_EXTRA] 0,0, 46 , 'DEVOLUCION' , 'B' , 'FMCKTX7' , 3788360 , 
					2137674 , 'T17' , 'MHI' , '11611' , '-' , 0 , 0 , 0 , 0 , 0 , '' , 'franciscoe' , 'IT-010' 

*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_IMPRIMIR_FORMATO_DEVOLUCION_EXTRA]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_TAGNO_ORIGEN						INT,
	@PP_TAGNO_DESTINO						INT,
	-- ===========================
	@PP_LOCACION_ORIGEN						VARCHAR(10)
	-- ===========================
AS
	
	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
				BEGIN TRY
					-- /////////////////////////SI DESEA IMPRIMIR EL FORMATO DE DEVOLUCION Y EXTRAS////////////////////////////////////////////
						
					DECLARE	@VP_ESTATUS	VARCHAR(5) = ''

					-- /////////////////VALIDA ESTATUS FOLIO ORIGEN////////////////////////////////////////////////////
					SELECT	@VP_ESTATUS	= LTRIM(RTRIM(STATUS))
										FROM RP_Folios
										WHERE LTRIM(RTRIM(TAG)) = @PP_TAGNO_ORIGEN

					IF @VP_ESTATUS <> 'B' AND @PP_LOCACION_ORIGEN <> 'MHI'
						BEGIN
							-- /////////////////SE INGRESA EL FOLIO ORIGEN DE DONDE SE REALIZO LA DEVOLUCION////////////////////////////////////////////////////
							EXECUTE [dbo].[PG_IN_RP_SC_PRT]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_TAGNO_ORIGEN, 5
						END

					-- /////////////////VALIDA ESTATUS FOLIO DESTINO////////////////////////////////////////////////////
					SET	@VP_ESTATUS = ''
					SELECT	@VP_ESTATUS	= LTRIM(RTRIM(STATUS))
										FROM RP_Folios
										WHERE LTRIM(RTRIM(TAG)) = @PP_TAGNO_DESTINO

					IF @VP_ESTATUS <> 'B'
						BEGIN
							-- /////////////////SE INGRESA EL FOLIO DESTINO A DONDE SE MANDARON LAS EXTRAS////////////////////////////////////////////////////
							EXECUTE [dbo].[PG_IN_RP_SC_PRT]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_TAGNO_DESTINO, 4
						END
					-- ///////////////////////////////////////////
					
							
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRASAC. PG_PM_TRANSFER_PIEL_IMPRIMIR_FORMATO_DEVOLUCION_EXTRA // ' + @VP_ERROR_TRANS

				DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = 'franciscoe@pearlleather.com.mx'
				DECLARE @VP_SUBJECT		VARCHAR(255) = 'Error al Imprimir formato de Devolución y Extra...'
				DECLARE @VP_FECHA		VARCHAR(10) = CONVERT(VARCHAR(10), GETDATE(),103)
				DECLARE @VP_BODY		NVARCHAR(MAX) = ''

				SET @VP_BODY =  N'<table  border="1" align="center" cellspacing="0">' + 
									N'<thead>' + 
									  N'<tr BGCOLOR="#ADD8E6">' + 
									    N'<th colspan="2">Error al Imprimir formato de Devolución y Extra...</th>' + 
									  N'</tr>' + 
									  N'<tr BGCOLOR="#48D1CC">' + 
									    N'<th>Folio Origen</th><th>Folio Destino</th>' + 
									  N'</tr>' + 
									N'</thead>' + 
									N'<tbody>' + 
									  N'<tr>' + 
									  N'<td>'+ CONVERT(VARCHAR(10),@PP_TAGNO_ORIGEN) +'</td><td>'+ CONVERT(VARCHAR(10),@PP_TAGNO_DESTINO) +'</td>'+ 
									  N'</tr>' + 
									N'</tbody>' + 
								N'</table>' ;
				SET ROWCOUNT 0
					 				
				EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No fue posible imprimir el formato de Devolución y Extra: ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAGNO_DESTINO AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'PROCESO',
													'',
													-- ===========================================
													'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAGNO_DESTINO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
