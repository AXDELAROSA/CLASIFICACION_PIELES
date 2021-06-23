-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			PLANNING
-- // OPERACION:		LIBERACION / TABLAS
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	21/ABR/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_PLANNING_ELIMINAR_ORDER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_PLANNING_ELIMINAR_ORDER]
GO

/*
	 EXEC [PG_PR_PLANNING_ELIMINAR_ORDER] 0 ,144,  '31617' , 'FCPRHL1' , 'Table 71' , 'franciscoe' , 'IT-010'  
*/

CREATE PROCEDURE [dbo].[PG_PR_PLANNING_ELIMINAR_ORDER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN					VARCHAR(50),
	@PP_COLOR					VARCHAR(50),
	@PP_MESA					VARCHAR(50),
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

		-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE	VARCHAR(255) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_ORDEN,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
								
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_ORDEN,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	IF @VP_MENSAJE=''
		BEGIN
			DECLARE @VP_N_FOLIO_ASIGNADO INT = 0
			SELECT @VP_N_FOLIO_ASIGNADO = folio
			FROM	ccjobhdr_sql (NOLOCK)
			WHERE	LTRIM(RTRIM(jobno)) = @PP_ORDEN

			IF @VP_N_FOLIO_ASIGNADO IS NULL
				SET @VP_N_FOLIO_ASIGNADO = 0 
			
			IF @VP_N_FOLIO_ASIGNADO > 0
				SET @VP_MENSAJE = 'La orden no puede ser Eliminada porque tiene un Folio asignado'
		END
	
	IF @VP_MENSAJE=''
		BEGIN
			DECLARE @VP_N_PIEL_CORTADA INT = 0
			SELECT @VP_N_PIEL_CORTADA = COUNT(COLKEY)
			FROM CCCUTHST_SQL (NOLOCK)
			WHERE JOBNO = @PP_ORDEN

			IF @VP_N_PIEL_CORTADA IS NULL
				SET @VP_N_PIEL_CORTADA = 0

			IF @VP_N_PIEL_CORTADA > 0
				SET @VP_MENSAJE = 'La orden no puede ser Eliminada porque tiene pieles cortadas.'
		END	

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY	
				DECLARE @VP_LOCACION VARCHAR(50) = ''
				SELECT	@VP_LOCACION = LTRIM(RTRIM(LOC))
				FROM	imlocfil_sql (NOLOCK)
				WHERE	loc_desc = @PP_MESA

				IF @VP_LOCACION IS NULL OR @VP_LOCACION = ''
					RAISERROR ('ERROR: No fue posible obtener la Locacion en [imlocfil_sql].', 16, 1 ) --MENSAJE - Severity -State

				-- //////////SE OBTIENE LAS TRANSACCIONES A LA ORDEN/////////////////////////////////
					DECLARE @VP_LOTE VARCHAR(20) = '', @VP_LEVEL VARCHAR(20) = '', @VP_DOC_TYPE VARCHAR(5) = '', @VP_DOC_ORD_NO	VARCHAR(10) = '';
					DECLARE @VP_TRX_QTY DECIMAL(13,4) = 0, @VP_SQF_TRANSFERIDO DECIMAL(13,4) = 0;

					DECLARE @TBL_SQF_EN_ORDEN TABLE(
								LOTE				VARCHAR(20),
								SQF_TRANSFER		DECIMAL(13,4)
							)
					SET NOCOUNT ON

					DECLARE CU_SQF_EN_ORDEN CURSOR 
					FOR	SELECT IMLSTRX_SQL.ser_lot_no, IMLSTRX_SQL.lev_no, IMINVTRX_SQL.doc_type, LTRIM(RTRIM(IMINVTRX_SQL.doc_ord_no)), IMLSTRX_SQL.trx_qty
						-- ===========================
						 FROM IMLSTRX_SQL (NOLOCK)
							-- ===========================
							INNER JOIN IMINVTRX_SQL ON IMLSTRX_SQL.source = IMINVTRX_SQL.source 
								AND IMLSTRX_SQL.ord_no = IMINVTRX_SQL.ord_no 
						     AND IMLSTRX_SQL.ctl_no = IMINVTRX_SQL.ctl_no 
						     AND IMLSTRX_SQL.line_no = IMINVTRX_SQL.line_no 
						     AND IMLSTRX_SQL.lev_no = IMINVTRX_SQL.lev_no 
						     AND IMLSTRX_SQL.seq_no = IMINVTRX_SQL.seq_no
						-- ===========================
						 WHERE IMINVTRX_SQL.item_no = @PP_COLOR
						 AND LTRIM(RTRIM(IMINVTRX_SQL.loc)) = @VP_LOCACION
						 -- ===========================
						 AND (	LTRIM(RTRIM(IMINVTRX_SQL.doc_ord_no)) = @PP_ORDEN
								OR	LTRIM(RTRIM(IMINVTRX_SQL.doc_ord_no)) = 'J' + @PP_ORDEN
								OR	LTRIM(RTRIM(IMINVTRX_SQL.doc_ord_no)) = @PP_ORDEN
								)
						-- ===========================  
						ORDER BY IMLSTRX_SQL.ser_lot_no, IMINVTRX_SQL.lev_no DESC
					-- ///////////////////////////////////////////
							
					OPEN CU_SQF_EN_ORDEN
					FETCH NEXT FROM CU_SQF_EN_ORDEN INTO @VP_LOTE, @VP_LEVEL, @VP_DOC_TYPE, @VP_DOC_ORD_NO, @VP_TRX_QTY
							
					WHILE @@FETCH_STATUS = 0
						BEGIN
							-- ///////////////////////////////////////////
							DECLARE @VP_LOTE_ACTUAL VARCHAR(20) = @VP_LOTE

							-- /////////// TRANSFERENCIA A LA ORDEN ///////////////////////
							IF @VP_DOC_TYPE = 'R' --AND SUBSTRING(@VP_DOC_ORD_NO, 1, 1) <> 'J'
								BEGIN
									SET @VP_SQF_TRANSFERIDO = @VP_SQF_TRANSFERIDO + @VP_TRX_QTY
								END

							IF @VP_DOC_TYPE = 'I' --AND SUBSTRING(@VP_DOC_ORD_NO, 1, 1) <> 'J'
								BEGIN
								 SET @VP_SQF_TRANSFERIDO = @VP_SQF_TRANSFERIDO - @VP_TRX_QTY 
								END

							IF @VP_DOC_TYPE = 'T' AND @VP_LEVEL = 1
								BEGIN
									SET @VP_SQF_TRANSFERIDO = @VP_SQF_TRANSFERIDO + @VP_TRX_QTY
								END

							IF @VP_DOC_TYPE = 'T' AND @VP_LEVEL = 0
								BEGIN
								 SET @VP_SQF_TRANSFERIDO = @VP_SQF_TRANSFERIDO - @VP_TRX_QTY 
								END

							-- ///////////////////////////////////////////
							FETCH NEXT FROM CU_SQF_EN_ORDEN INTO @VP_LOTE, @VP_LEVEL, @VP_DOC_TYPE, @VP_DOC_ORD_NO, @VP_TRX_QTY

							-- ///////////////////////////////////////////
							IF ( @VP_LOTE_ACTUAL <> @VP_LOTE OR @@FETCH_STATUS <> 0 )
								BEGIN
									INSERT INTO @TBL_SQF_EN_ORDEN
									SELECT	RIGHT( '000000' + @VP_LOTE_ACTUAL, 6),
											@VP_SQF_TRANSFERIDO

									SET @VP_SQF_TRANSFERIDO = 0
								END
						END
					
					CLOSE CU_SQF_EN_ORDEN
					DEALLOCATE CU_SQF_EN_ORDEN	

				-- ///////SE OBTIENE EL TOTAL DE SQF EN LA ORDEN///////////////////////////////////////////////////////
				DECLARE @VP_TOTAL_SQF DECIMAL(13,4) = 0
				SELECT @VP_TOTAL_SQF = SUM(SQF_TRANSFER)
				FROM @TBL_SQF_EN_ORDEN

				IF @VP_TOTAL_SQF IS NULL
				 SET @VP_TOTAL_SQF = 0

				 IF @VP_TOTAL_SQF > 0
					RAISERROR ('ERROR: No fue posible eliminar la Orden porque tiene Pies Cuadrados asignados.', 16, 1 ) --MENSAJE - Severity -State

				-- ///////SE ELIMINAN LOS KITS DE LA ORDEN///////////////////////////////////////////////////////
				DELETE ccjoblin_sql 
				WHERE JOBNO = @PP_ORDEN

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible eliminar la Orden en [ccjoblin_sql].', 16, 1 ) --MENSAJE - Severity -State

				DELETE ccjobhdr_sql 
				WHERE JOBNO = @PP_ORDEN

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible eliminar la Orden en [ccjobhdr_sql].', 16, 1 ) --MENSAJE - Severity -State

				-- ///////SE ELIMINAN LOS KITS LOS CODIGOS DE LA CAMARA DEL CAMPO SERIAL///////////////////////////////////////////////////////
				INSERT INTO SERIALCAM_SQL 
				SELECT code, NULL, NULL 
				FROM SERIALCAM_SQL (NOLOCK)
				WHERE SERIAL LIKE @PP_ORDEN	+ '%'

				IF @@ROWCOUNT > 50
					RAISERROR ('ERROR: Verifique el numero de Kits a Ingresar en [SERIALCAM_SQL].', 16, 1 ) --MENSAJE - Severity -State

				DELETE SERIALCAM_SQL 
				WHERE SERIAL LIKE @PP_ORDEN	+ '%'

				IF @@ROWCOUNT > 50
					RAISERROR ('ERROR: Verifique el numero de Kits a Eliminar en [SERIALCAM_SQL].', 16, 1 ) --MENSAJE - Severity -State

				INSERT INTO SERIALCAM_SQL 
				SELECT code, NULL, NULL 
				FROM SERIALCAM_SQL (NOLOCK)
				WHERE SERIAL2 LIKE @PP_ORDEN	+ '%'

				IF @@ROWCOUNT > 50
					RAISERROR ('ERROR: Verifique el numero de Kits a Ingresar en [SERIALCAM_SQL].', 16, 1 ) --MENSAJE - Severity -State

				DELETE SERIALCAM_SQL 
				WHERE SERIAL2 LIKE @PP_ORDEN	+ '%'
				
				IF @@ROWCOUNT > 50
					RAISERROR ('ERROR: Verifique el numero de Kits a Eliminar en [SERIALCAM_SQL].', 16, 1 ) --MENSAJE - Severity -State

				-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
				DECLARE @VP_DETAIL VARCHAR(100) = 'Eliminacion de Orden: ' + @PP_ORDEN
				EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@PP_USER, @PP_COMPUTER_NAME, 'Planning',
													@PP_ORDEN, 'Eliminar orden',
													@VP_DETAIL, ''

			-- ///////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PR_PLANNING_ELIMINAR_ORDER] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Eliminar la Orden: ' + '[' + @PP_ORDEN +'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_ORDEN AS CLAVE
	
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
													0, 0, @PP_ORDEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
