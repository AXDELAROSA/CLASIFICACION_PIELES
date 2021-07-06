-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			TRASPASO DE PIEL POR ORDEN EN PRODUCCION
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	16/JUN/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

-- USE [DATA_02PRUEBAS] 
-- EXECUTE [dbo].[PG_SK_PIEL_TRASPASO_ENTRE_ORDENES_X_FOLIO] 0,0,  3798317
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_PIEL_TRASPASO_ENTRE_ORDENES_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_PIEL_TRASPASO_ENTRE_ORDENES_X_FOLIO]
GO


CREATE PROCEDURE [dbo].[PG_SK_PIEL_TRASPASO_ENTRE_ORDENES_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					INT
AS

	-- ///////////////////////////////////////////
	SELECT	RP_SC.ID									AS ID,
			TAGNO										AS TAGNO,
			LTRIM(RTRIM(ccjobhdr_sql.JOBNO))			AS JOBNO,
			LTRIM(RTRIM(RP_SC.COLOUR))					AS COLOR,
			LTRIM(RTRIM(LOT))							AS LOTE,
			LTRIM(RTRIM(HIDE))							AS PIEL,
			LTRIM(RTRIM(SQF))							AS SQF,
			ISNULL(hidesqm, 0)							AS SQF_CORTADO,
			CONVERT(DECIMAL(13,2 ), LTRIM(RTRIM(SQF))) - ISNULL(hidesqm, 0)	AS SQF_NO_CORTADO,
			LTRIM(RTRIM(ccjobhdr_sql.machine))			AS LOCACION,
			ISNULL(LTRIM(RTRIM(PESO)), '')				AS TIPO
	-- =====================
	FROM	RP_SC (NOLOCK)
	INNER JOIN RP_FOLIOS (NOLOCK) ON TAG = TAGNO AND STATUS <> 'B'
	INNER JOIN ccjobhdr_sql (NOLOCK) ON folio = TAG 
		AND LTRIM(RTRIM(RP_SC.COLOUR)) = CONCAT('F', LTRIM(RTRIM(ccjobhdr_sql.COLOUR)))
	LEFT JOIN CCCUTHST_SQL (NOLOCK) ON CCCUTHST_SQL.jobno = ccjobhdr_sql.jobno 
		AND LTRIM(RTRIM(ccjobhdr_sql.machine)) = LTRIM(RTRIM(CCCUTHST_SQL.machine))
		AND LTRIM(RTRIM(RP_SC.COLOUR)) = LTRIM(RTRIM(CCCUTHST_SQL.COLOUR))
		AND LTRIM(RTRIM(CCCUTHST_SQL.lotno)) = RIGHT('000000' + LTRIM(RTRIM(LOT)), 6) 
		AND	LTRIM(RTRIM(HIDENO)) = LTRIM(RTRIM(HIDE))
	WHERE	TAGNO = @PP_FOLIO 
	AND		TYPE = 'C'
	AND ISNULL(PESO, '') <> '1' -- EXCLUYE LAS PIELES QUE ESTAN MARCADAS PARA DEVOLUCION EN LA APP DE PRD
	ORDER BY HIDE ASC

	---////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE [DATA_02PRUEBAS] 
-- EXECUTE [dbo].[PG_GET_TOTAL_PIEL_SQF_A_TRASNFERIR_A_ORDEN_X_FOLIO] 0,0,  3798317
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_TOTAL_PIEL_SQF_A_TRASNFERIR_A_ORDEN_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_TOTAL_PIEL_SQF_A_TRASNFERIR_A_ORDEN_X_FOLIO]
GO


CREATE PROCEDURE [dbo].[PG_GET_TOTAL_PIEL_SQF_A_TRASNFERIR_A_ORDEN_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					INT
	--@PP_TIPO					VARCHAR(10) -- D = DEVOLUCION, E = EXTRAS, C = NORMAL
AS

	-- ///////////////////////////////////////////
	DECLARE @TBL_PIEL_A_TRANSFERIR TABLE(
		ID		INT,
		FOLIO	INT,
		HIDE	VARCHAR(20),
		SQF		DECIMAL(13,2)
	)

	INSERT INTO @TBL_PIEL_A_TRANSFERIR
		SELECT	RP_SC.ID,
				TAGNO,
				HIDE,
				( CASE WHEN ISNULL(PESO, '') = '2' AND ISNULL(hidesqm, 0) = 0 THEN CONVERT(DECIMAL(13,2 ), LTRIM(RTRIM(SQF)))
						WHEN ISNULL(PESO, '') = '2' AND ISNULL(hidesqm, 0) > 0 AND ISNULL(hidesqm, 0) <> CONVERT(DECIMAL(13,2), LTRIM(RTRIM(SQF))) THEN ( CONVERT(DECIMAL(13,2 ), LTRIM(RTRIM(SQF))) -  ISNULL(hidesqm, 0))
						WHEN ISNULL(PESO, '') = '3' THEN ISNULL(hidesqm, 0)
					ELSE ISNULL(hidesqm, 0) END )
	-- =====================
	FROM	RP_SC (NOLOCK)
	INNER JOIN RP_FOLIOS (NOLOCK) ON TAG = TAGNO AND STATUS <> 'B'
	INNER JOIN ccjobhdr_sql (NOLOCK) ON folio = TAG 
		AND LTRIM(RTRIM(RP_SC.COLOUR)) = CONCAT('F', LTRIM(RTRIM(ccjobhdr_sql.COLOUR)))
	LEFT JOIN CCCUTHST_SQL (NOLOCK) ON CCCUTHST_SQL.jobno = ccjobhdr_sql.jobno 
		AND LTRIM(RTRIM(ccjobhdr_sql.machine)) = LTRIM(RTRIM(CCCUTHST_SQL.machine))
		AND LTRIM(RTRIM(RP_SC.COLOUR)) = LTRIM(RTRIM(CCCUTHST_SQL.COLOUR))
		AND LTRIM(RTRIM(CCCUTHST_SQL.lotno)) = RIGHT('000000' + LTRIM(RTRIM(LOT)), 6) 
		AND	LTRIM(RTRIM(HIDENO)) = LTRIM(RTRIM(HIDE))
	WHERE	TAGNO = @PP_FOLIO 
	AND		TYPE = 'C'
	AND		ISNULL(PESO, '') IN ('2', '3') -- SE USA COMO BANDERA PARA ESPECIFICAR QUE SON PIELES PARA TRASPASO EN APP DE PRODUCCION
	---////////////////////////////////////////////////////////////////

	SELECT COUNT(ID)	AS N_PIEL,
			ISNULL(SUM(SQF), 0)	AS SQF_TRANFERIR
	FROM @TBL_PIEL_A_TRANSFERIR
	---////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE [DATA_02PRUEBAS] 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_AGREGAR_QUITAR_TRASPASO_PIEL_A_ORDEN_EN_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_AGREGAR_QUITAR_TRASPASO_PIEL_A_ORDEN_EN_FOLIO]
GO
/*
	EXECUTE  [dbo].[PG_PR_AGREGAR_QUITAR_TRASPASO_PIEL_A_ORDEN_EN_FOLIO]	0, 144, 1, 'POR FOLIO' , 3793142, 0, '' -- FOLIO TIPO BASE
	EXECUTE  [dbo].[PG_PR_AGREGAR_QUITAR_TRASPASO_PIEL_A_ORDEN_EN_FOLIO]	0, 144, 0, 2, 'POR FOLIO' , 3798317, 0, '' -- FOLIO EN MESA

	EXECUTE  [dbo].[PG_PR_AGREGAR_QUITAR_TRASPASO_PIEL_A_ORDEN_EN_FOLIO]	0, 144, 0, 'POR PIEL', 3793142, 5829115, ''  -- 0242 -- -- FOLIO TIPO BASE
	EXECUTE  [dbo].[PG_PR_AGREGAR_QUITAR_TRASPASO_PIEL_A_ORDEN_EN_FOLIO]	0, 144, 1, 2, 'POR PIEL', 3798317, 5004741, ''  -- 0130 -- AGREGAR DISPONIBLE  
	EXECUTE  [dbo].[PG_PR_AGREGAR_QUITAR_TRASPASO_PIEL_A_ORDEN_EN_FOLIO]	0, 144, 1, 3, 'POR PIEL', 3798317, 5004711, ''  -- 0160 -- AGREGAR CORTE  
	EXECUTE  [dbo].[PG_PR_AGREGAR_QUITAR_TRASPASO_PIEL_A_ORDEN_EN_FOLIO]	0, 144, 1, 2, 'POR PIEL', 3798317, 5004720, ''  -- 0151  -- AGREGAR DISPONIBLE  

	EXECUTE  [dbo].[PG_PR_AGREGAR_QUITAR_TRASPASO_PIEL_A_ORDEN_EN_FOLIO]	0, 144, 1, 'POR ETIQUETA' , 3793142, 0, 'FWLPAX7,401451-0044*43.70' -- FOLIO TIPO BASE
	EXECUTE  [dbo].[PG_PR_AGREGAR_QUITAR_TRASPASO_PIEL_A_ORDEN_EN_FOLIO]	1, 144, 0, 'POR ETIQUETA' , 3798327, 0, 'FWLPAX7,401451-0240*15.00'
*/
CREATE PROCEDURE [dbo].[PG_PR_AGREGAR_QUITAR_TRASPASO_PIEL_A_ORDEN_EN_FOLIO]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_ACCION								INT, --#0 QUITAR, #1 AGREGAR
	@PP_TIPO_TRANSFERENCIA					INT, --#2 DISPONIBLE, #3 CORTADO
	@PP_TIPO_MOVIMIENTO						VARCHAR(50), --POR FOLIO, POR PIEL, POR ETIQUETA
	@PP_FOLIO								INT,
	@PP_ID_PIEL								INT,
	@PP_ETIQUETA_PIEL						VARCHAR(150)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	DECLARE @VP_MENSAJE_TRANSACCION VARCHAR(255) = ''
	DECLARE @VP_TIPO_FOLIO VARCHAR(10) = ''
	DECLARE @VP_SQF_FOLIO DECIMAL(13,2) = 0
	DECLARE @VP_SQF_CORTADO DECIMAL(13,2) = 0	

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
	IF @PP_TIPO_MOVIMIENTO = 'POR ETIQUETA'
		BEGIN
			IF LTRIM(RTRIM(@PP_ETIQUETA_PIEL)) = ''
				SET @VP_MENSAJE = 'La Etiqueta de la piel no contiene datos'
							
			IF @VP_MENSAJE=''
				IF NOT (@PP_ETIQUETA_PIEL LIKE '_______,%_____-____*%')
					SET @VP_MENSAJE = 'Los datos de la Etiqueta de la piel son incorrectos'
		END

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY				

			-- //////PARA CANCELAR LA DEVOLUCION DE UN FOLIO EN PANTALLA NUEVA DE DEVOLUCIONES///////////////////////////////////////////////////////////////
			IF @PP_TIPO_MOVIMIENTO = 'POR FOLIO'
				BEGIN
				-- //////SE VALIDA QUE EL FOLIO NO SEA TIPO BASE///////////////////////////////////////////////////////////////
				SELECT @VP_TIPO_FOLIO = STATUS 
				FROM RP_FOLIOS 
				WHERE TAG = @PP_FOLIO

				IF @VP_TIPO_FOLIO = 'B'
					BEGIN
						SET @VP_MENSAJE_TRANSACCION = 'EROR: El folio es tipo Base: ' + CONVERT(VARCHAR(50), @PP_FOLIO)  + '.'	
						RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
					END

					-- //////SE ACTUALIZA EL TYPE DE LAS PIELES EN EL FOLIO///////////////////////////////////////////////////////////////
					--@PP_ACCION = #0 QUITAR, #1 AGREGAR
					UPDATE RP_SC 
						SET PESO = ( CASE WHEN @PP_ACCION = 1 THEN @PP_TIPO_TRANSFERENCIA --AGREGAR TRASPASO #2 DISPONIBLE, #3 CORTADO
										ELSE NULL END ) -- QUITAR TRASPASO 
					WHERE TAGNO = @PP_FOLIO
					AND LTRIM(RTRIM(TYPE)) = 'C' 
					AND ISNULL(PESO, '') <> '1' -- DIFERENTE DE DEVOLUCION
					AND ID IN ( SELECT	RP_SC.ID
								-- =====================
								FROM	RP_SC (NOLOCK)
								INNER JOIN RP_FOLIOS (NOLOCK) ON TAG = TAGNO
								INNER JOIN ccjobhdr_sql (NOLOCK) ON folio = TAG 
									AND LTRIM(RTRIM(RP_SC.COLOUR)) = CONCAT('F', LTRIM(RTRIM(ccjobhdr_sql.COLOUR)))
								LEFT JOIN CCCUTHST_SQL (NOLOCK) ON CCCUTHST_SQL.jobno = ccjobhdr_sql.jobno 
									AND LTRIM(RTRIM(ccjobhdr_sql.machine)) = LTRIM(RTRIM(CCCUTHST_SQL.machine))
									AND LTRIM(RTRIM(RP_SC.COLOUR)) = LTRIM(RTRIM(CCCUTHST_SQL.COLOUR))
									AND LTRIM(RTRIM(CCCUTHST_SQL.lotno)) = RIGHT('000000' + LTRIM(RTRIM(LOT)), 6) 
									AND	LTRIM(RTRIM(HIDENO)) = LTRIM(RTRIM(HIDE))
								WHERE	TAGNO = @PP_FOLIO 
							)

					IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE_TRANSACCION = 'No fue posible quitar las pieles de devolución del folio:' + CONVERT(VARCHAR(50), @PP_FOLIO)  + '.'
							
							IF @PP_ACCION = 1
								SET @VP_MENSAJE_TRANSACCION = 'No fue posible agregar las pieles como devolución del folio:' + CONVERT(VARCHAR(50), @PP_FOLIO)  + '.'
							
							RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
						END	
				END

			-- //////PARA CANCELAR LA DEVOLUCION DE UNA PIEL EN PANTALLA NUEVA DE DEVOLUCIONES///////////////////////////////////////////////////////////////
			IF @PP_TIPO_MOVIMIENTO = 'POR PIEL'
				BEGIN
					-- //////SE VALIDA QUE EL FOLIO NO SEA TIPO BASE///////////////////////////////////////////////////////////////
					SELECT TOP 1 @VP_TIPO_FOLIO = STATUS
					FROM RP_FOLIOS
					INNER JOIN RP_SC ON TAG = TAGNO
					WHERE TAGNO = @PP_FOLIO

					IF @VP_TIPO_FOLIO = 'B'
					BEGIN
						SET @VP_MENSAJE_TRANSACCION = 'EROR: El folio al que pertenece la piel es tipo Base: ' + CONVERT(VARCHAR(50), @PP_FOLIO)  + '.'		
						RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
					END

					-- //////SE VALIDA QUE LA PIEL NO ESTE CORTADA COMPLETA///////////////////////////////////////////////////////////////
					SET @VP_SQF_FOLIO = 0
					SET @VP_SQF_CORTADO = 0	

					SELECT	@VP_SQF_FOLIO = CONVERT(DECIMAL(12,3), RP_SC.SQF),
							@VP_SQF_CORTADO = CONVERT(DECIMAL(12,3),CCCUTHST_SQL.hidesqm)
					-- =====================
					FROM	RP_SC (NOLOCK)
					INNER JOIN RP_FOLIOS (NOLOCK) ON TAG = TAGNO
					INNER JOIN ccjobhdr_sql (NOLOCK) ON folio = TAG 
						AND LTRIM(RTRIM(RP_SC.COLOUR)) = CONCAT('F', LTRIM(RTRIM(ccjobhdr_sql.COLOUR)))
					LEFT JOIN CCCUTHST_SQL (NOLOCK) ON CCCUTHST_SQL.jobno = ccjobhdr_sql.jobno 
						AND LTRIM(RTRIM(ccjobhdr_sql.machine)) = LTRIM(RTRIM(CCCUTHST_SQL.machine))
						AND LTRIM(RTRIM(RP_SC.COLOUR)) = LTRIM(RTRIM(CCCUTHST_SQL.COLOUR))
						AND LTRIM(RTRIM(CCCUTHST_SQL.lotno)) = RIGHT('000000' + LTRIM(RTRIM(LOT)), 6) 
						AND	LTRIM(RTRIM(HIDENO)) = LTRIM(RTRIM(HIDE))
					WHERE	TAGNO = @PP_FOLIO
					AND	RP_SC.ID = @PP_ID_PIEL 
					
					IF @VP_SQF_FOLIO IS NULL OR @VP_SQF_FOLIO = 0
						RAISERROR ('Piel no encontrada en el folio.', 16, 1 ) --MENSAJE - Severity -State.

					IF @VP_SQF_CORTADO > @VP_SQF_FOLIO
						RAISERROR ('El SQF cortado no puede ser mayor al SQF de la piel.', 16, 1 ) --MENSAJE - Severity -State.
							
					-- //////SE ACTUALIZA EL TYPE DE LAS PIEL///////////////////////////////////////////////////////////////
					--@PP_ACCION = #0 QUITAR, #1 AGREGAR
					UPDATE RP_SC 
						SET PESO = ( CASE WHEN @PP_ACCION = 1 THEN @PP_TIPO_TRANSFERENCIA -- AGREGAR TRASPASO #2 DISPONIBLE, #3 CORTADO
										ELSE NULL END ) -- QUITAR TRASPASO 
					WHERE TAGNO = @PP_FOLIO 
					AND ID = @PP_ID_PIEL
					AND TYPE = 'C' 
					AND ISNULL(PESO, '') <> '1' -- DIFERENTE DE DEVOLUCION

					IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE_TRANSACCION = 'No fue posible quitar la piel de devolución.'
							
							IF @PP_ACCION = 1
								SET @VP_MENSAJE_TRANSACCION = 'No fue posible agregar la piel como devolución.'

							RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
						END	
				END

			-- //////////PARA EL ESCANEO DE LA PIEL A DEVOLVER EN MESA///////////////////////////////////////////////////////////
			IF @PP_TIPO_MOVIMIENTO = 'POR ETIQUETA'
				BEGIN
					-- //////SE VALIDA QUE EL FOLIO NO SEA TIPO BASE///////////////////////////////////////////////////////////////
					SELECT @VP_TIPO_FOLIO = STATUS 
					FROM RP_FOLIOS 
					WHERE TAG = @PP_FOLIO

					IF @VP_TIPO_FOLIO = 'B'
						BEGIN
							SET @VP_MENSAJE_TRANSACCION = 'EROR: El folio es tipo Base: ' + CONVERT(VARCHAR(50), @PP_FOLIO)  + '.'	
							RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
						END

					DECLARE @VP_COLOR		VARCHAR(20)		= ''
					DECLARE @VP_LOTE		VARCHAR(20)		= ''
					DECLARE @VP_PIEL		VARCHAR(10)		= ''
					DECLARE @VP_SQF			VARCHAR(10)		= ''

					-- /////////////////////////OBTENER VALORES DE LA ETIQUETA PIEL////////////////////////////////////////////
					EXECUTE [dbo].[PG_RN_ETIQUETA_PIEL_OBTENER_VALOR]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_ETIQUETA_PIEL,
																		@OU_COLOR	 = @VP_COLOR	OUTPUT,
																		@OU_LOTE	 = @VP_LOTE		OUTPUT,
																		@OU_PIEL	 = @VP_PIEL		OUTPUT,
																		@OU_SQF		 = @VP_SQF		OUTPUT

					SET @VP_COLOR = RTRIM(LTRIM(@VP_COLOR))
					SET @VP_LOTE = RTRIM(LTRIM(@VP_LOTE))
					SET @VP_PIEL = RTRIM(LTRIM(@VP_PIEL))
					SET @VP_SQF = RTRIM(LTRIM(@VP_SQF))

					-- //////SE VALIDA QUE LA PIEL NO ESTE CORTADA COMPLETA///////////////////////////////////////////////////////////////
					SET @VP_SQF_FOLIO = 0
					SET @VP_SQF_CORTADO = 0		

					SELECT	@VP_SQF_FOLIO = CONVERT(DECIMAL(12,3), RP_SC.SQF),
							@VP_SQF_CORTADO = CCCUTHST_SQL.hidesqm
					-- =====================
					FROM	RP_SC (NOLOCK)
					INNER JOIN RP_FOLIOS (NOLOCK) ON TAG = TAGNO
					INNER JOIN ccjobhdr_sql (NOLOCK) ON folio = TAG 
						AND LTRIM(RTRIM(RP_SC.COLOUR)) = CONCAT('F', LTRIM(RTRIM(ccjobhdr_sql.COLOUR)))
					LEFT JOIN CCCUTHST_SQL (NOLOCK) ON CCCUTHST_SQL.jobno = ccjobhdr_sql.jobno 
						AND LTRIM(RTRIM(ccjobhdr_sql.machine)) = LTRIM(RTRIM(CCCUTHST_SQL.machine))
						AND LTRIM(RTRIM(RP_SC.COLOUR)) = LTRIM(RTRIM(CCCUTHST_SQL.COLOUR))
						AND LTRIM(RTRIM(CCCUTHST_SQL.lotno)) = RIGHT('000000' + LTRIM(RTRIM(LOT)), 6) 
						AND	LTRIM(RTRIM(HIDENO)) = LTRIM(RTRIM(HIDE))
					WHERE TAGNO = @PP_FOLIO
					AND RP_SC.COLOUR = @VP_COLOR
					AND	LOT = @VP_LOTE
					AND HIDE = @VP_PIEL
					AND SQF = @VP_SQF

					IF @VP_SQF_FOLIO IS NULL OR @VP_SQF_FOLIO = 0
						RAISERROR ('Piel no encontrada en el folio.', 16, 1 ) --MENSAJE - Severity -State.

					IF @VP_SQF_CORTADO > @VP_SQF_FOLIO
						RAISERROR ('El SQF cortado no puede ser mayor al SQF de la piel.', 16, 1 ) --MENSAJE - Severity -State.

					-- //////SE ACTUALIZA EL TYPE DE LAS PIEL///////////////////////////////////////////////////////////////
					--@PP_ACCION = #0 QUITAR, #1 AGREGAR
					UPDATE RP_SC 
						SET PESO = ( CASE WHEN @PP_ACCION = 1 THEN @PP_TIPO_TRANSFERENCIA -- AGREGAR TRASPASO #2 DISPONIBLE, #3 CORTADO
										ELSE NULL END ) -- QUITAR TRASPASO
					WHERE TAGNO = @PP_FOLIO
					AND COLOUR = @VP_COLOR
					AND	LOT = @VP_LOTE
					AND HIDE = @VP_PIEL
					AND SQF = @VP_SQF
					AND TYPE = 'C' 
					AND ISNULL(PESO, '') <> '1' -- DIFERENTE DE DEVOLUCION

					IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE_TRANSACCION = 'No fue posible quitar la piel de devolución.'
							
							IF @PP_ACCION = 1
								SET @VP_MENSAJE_TRANSACCION = 'No fue posible agregar la piel como devolución.'

							RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
						END		
				END
				
			-- ////////////////////////////////////////////////////////////////////	
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PR_AGREGAR_QUITAR_TRASPASO_PIEL_A_ORDEN_EN_FOLIO] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE =  @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_FOLIO AS CLAVE
	
	-- //////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE [DATA_02PRUEBAS] 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_TRASPASAR_PIEL_A_ORDEN_EN_PRD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_TRASPASAR_PIEL_A_ORDEN_EN_PRD]
GO

/*
EXECUTE  [dbo].[PG_PR_TRASPASAR_PIEL_A_ORDEN_EN_PRD] 0,0,  3798317 , 'FCNPWA3' , '17878' , 'Table 68' , '17843' , 4 , 154.90 , 22

*/
CREATE PROCEDURE [dbo].[PG_PR_TRASPASAR_PIEL_A_ORDEN_EN_PRD]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO_ORIGEN			INT,
	@PP_COLOR_ORIGEN			VARCHAR(20),
	-- ===========================
	@PP_ORDEN_ORIGEN			VARCHAR(10),
	@PP_LOCACION_ORIGEN			VARCHAR(20),
	-- ===========================
	@PP_ORDEN_DESTINO			VARCHAR(10),
	-- ===========================
	@PP_TOTAL_PIEL				INT,
	@PP_TOTAL_SQF				DECIMAL(13,2),
	-- ===========================
	@PP_NUMERO_RELOJ			INT
AS

	-- /////////SE DECLARAN VARIABLES A USAR//////////////////////////////////
	DECLARE @VP_MENSAJE	VARCHAR(255) = '', @VP_MENSAJE_TRANSACCION	VARCHAR(255) = '';
	DECLARE @VP_FOLIO_DESTINO INT = 0, @VP_LOCACION_DESTINO	VARCHAR(20) = '', @VP_COLOR_DESTINO	VARCHAR(20) = '';
	DECLARE @VP_D_LOCACION_DESTINO	VARCHAR(50) = '', @VP_TIPO_PIEL_LOG INT = 15 -- TRASPASO DE PIEL POR PRD
	DECLARE @VP_K_CLASIFICACION	INT = 0, @VP_F_ACTUAL DATE = GETDATE(), @VP_TIPO_FOLIO VARCHAR(10) = '';

	-- ///////RN VALIDACIONES////////////////////////////////////
	IF @VP_MENSAJE = ''
		BEGIN
			DECLARE @VP_N_RELOJ_EXISTE INT = 0
			SELECT @VP_N_RELOJ_EXISTE = COUNT(EN_NUM_EMP) 
			FROM HOWE.dbo.VISTA_GAFETES (NOLOCK)
			WHERE EN_NUM_EMP = @PP_NUMERO_RELOJ

			IF @VP_N_RELOJ_EXISTE IS NULL OR @VP_N_RELOJ_EXISTE = 0
				SET @VP_MENSAJE = 'Numero de Reloj no valido.'
		END
	
	-- //////////SE VALIDA QUE EL FOLIO ORIGEN NO SEA FOLIO BASE/////////////////////////////////
	IF @VP_MENSAJE = ''
		BEGIN			
			SELECT @VP_TIPO_FOLIO = STATUS 
			FROM RP_FOLIOS 
			WHERE TAG = @PP_FOLIO_ORIGEN

			IF @VP_TIPO_FOLIO = 'B'
				SET @VP_MENSAJE = 'El folio es tipo Base.'	
		END

	-- //////////SE OBTIENE LA LOCACION DE LA ORDEN ORIGEN/////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			SELECT	@PP_LOCACION_ORIGEN = LTRIM(RTRIM(LOC))
			FROM	imlocfil_sql 
			INNER	JOIN CCJOBHDR_SQL ON CCJOBHDR_SQL.machine = IMLOCFIL_SQL.loc_desc
			WHERE	JOBNO = @PP_ORDEN_ORIGEN

			IF ( @PP_LOCACION_ORIGEN = '' OR @PP_LOCACION_ORIGEN IS NULL )
				SET @VP_MENSAJE = 'La Locacion de la orden origen no existe en [imlocfil_sql].'			
		END

	-- //////////SE OBTIENE LA LOCACION, FOLIO Y COLOR DE LA ORDEN DESTINO/////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			SELECT	@VP_COLOR_DESTINO = CONCAT('F', LTRIM(RTRIM(COLOUR))),
					@VP_FOLIO_DESTINO = FOLIO,
					@VP_LOCACION_DESTINO = LTRIM(RTRIM(LOC)),
					@VP_D_LOCACION_DESTINO = LTRIM(RTRIM(loc_desc))
			FROM	imlocfil_sql 
			INNER	JOIN CCJOBHDR_SQL ON CCJOBHDR_SQL.machine = IMLOCFIL_SQL.loc_desc
			WHERE	JOBNO = @PP_ORDEN_DESTINO

			IF ( @VP_COLOR_DESTINO = '' OR @VP_COLOR_DESTINO IS NULL )
				SET @VP_MENSAJE = 'No fue posible obtener el color de la orden destino en [CCJOBHDR_SQL].'

			IF @VP_MENSAJE=''
				IF ( @VP_LOCACION_DESTINO = '' OR @VP_LOCACION_DESTINO IS NULL )
					SET @VP_MENSAJE = 'La Locacion de la orden destino no existe en [imlocfil_sql].'

			IF @VP_MENSAJE=''
				IF ( @VP_FOLIO_DESTINO = 0 OR @VP_FOLIO_DESTINO IS NULL )
					SET @VP_MENSAJE = 'La Orden destino no tiene asignado un folio.'
		END

	-- //////////SE VALIDA QUE EL COLOR ORIGEN SEA IGUAL AL COLOR DESTINO/////////////////////////////////
	IF @VP_MENSAJE=''
		IF @VP_COLOR_DESTINO <> @PP_COLOR_ORIGEN
			SET @VP_MENSAJE = 'El color de la orden origen es diferente al color de la orden destino'

	-- //////////VALIDACIONES PARA ORDEN ORIGEN/////////////////////////////////
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_ORDEN_ORIGEN,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
		
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_ORDEN_ORIGEN,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_COLOR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_ORDEN_ORIGEN, @PP_COLOR_ORIGEN,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_VALIDA_ORDEN_Y_FOLIO_CORRESPONDA]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_ORDEN_ORIGEN,
																@OU_RESULTADO_VALIDACION	= @VP_MENSAJE			OUTPUT,
																@OU_FOLIO					= @PP_FOLIO_ORIGEN		OUTPUT

	-- //////////VALIDACIONES PARA ORDEN DESTINO/////////////////////////////////
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_ORDEN_DESTINO,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
		
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_ORDEN_DESTINO,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_COLOR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_ORDEN_DESTINO, @VP_COLOR_DESTINO,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_VALIDA_ORDEN_Y_FOLIO_CORRESPONDA]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_ORDEN_DESTINO,
																@OU_RESULTADO_VALIDACION	= @VP_MENSAJE			OUTPUT,
																@OU_FOLIO					= @VP_FOLIO_DESTINO		OUTPUT

	-- //////////SE VALIDA QUE EL FOLIO DESTINO NO SEA FOLIO BASE/////////////////////////////////
	IF @VP_MENSAJE = ''
		BEGIN
			SET @VP_TIPO_FOLIO = ''
			SELECT @VP_TIPO_FOLIO = STATUS 
			FROM RP_FOLIOS 
			WHERE TAG = @VP_FOLIO_DESTINO

			IF @VP_TIPO_FOLIO = 'B'
				SET @VP_MENSAJE = 'El folio es tipo Base.'	
		END

	-- ////////////INICIA TRANSACCION/////////////////////////////////////////////////////////	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- ////////////////////SE OBTIENE EL NUMERO DE PIELES A TRASPASAR EN EL FOLIO ORIGEN//////////////////////////
				DECLARE @VP_N_PIEL INT = 0
				SELECT	@VP_N_PIEL = COUNT(RP_SC.ID)
				FROM	RP_SC (NOLOCK)
				WHERE	TAGNO = @PP_FOLIO_ORIGEN 
				AND		TYPE = 'C'
				AND		ISNULL(PESO, '') IN ('2', '3') -- SE USA COMO BANDERA PARA ESPECIFICAR QUE SON PIELES PARA TRASPASO EN APP DE PRODUCCION

				IF ( @VP_N_PIEL IS NULL OR  @VP_N_PIEL = 0 )
					RAISERROR ('NO hay pieles marcadas como Traspaso en el Folio Origen.', 16, 1 ) --MENSAJE - Severity -State.							
															
				-- ///////SE DECLARAN VARIABLES A USAR//////////////////////////////////////////////////////////////////////////////
				DECLARE @VP_COLOR_TBL VARCHAR(10) = '', @VP_LOTE_TBL VARCHAR(10) = '', @VP_PIEL_TBL VARCHAR(10) = '', @VP_TIPO_TRASPASO_TBL	VARCHAR(10) = '';
				DECLARE @VP_SQF_PIEL_TBL VARCHAR(10) = '', @VP_SQF_CORTADO_TBL DECIMAL(13,2) = 0, @VP_SQF_NO_CORTADO_TBL DECIMAL(13,2) = 0;
				DECLARE @VP_SQF_TRANSFERIR DECIMAL(13,2) = 0

				-- /////////////////////////SE CREA CURSOR PARA RECORER LAS PIELES DE DEVOLUCION////////////////////////////////////////////
				DECLARE CU_PIEL_TRASPASO CURSOR 
				FOR SELECT	LTRIM(RTRIM(RP_SC.COLOUR))					AS COLOR,
							LTRIM(RTRIM(LOT))							AS LOTE,
							LTRIM(RTRIM(HIDE))							AS PIEL,
							CONVERT(DECIMAL(13,2 ), LTRIM(RTRIM(SQF)))	AS SQF,
							ISNULL(hidesqm, 0)							AS SQF_CORTADO,
							CONVERT(DECIMAL(13,2 ), LTRIM(RTRIM(SQF))) - ISNULL(hidesqm, 0)	AS SQF_NO_CORTADO,
							ISNULL(PESO, '')	
					-- =====================
					FROM	RP_SC (NOLOCK)
					INNER JOIN RP_FOLIOS (NOLOCK) ON TAG = TAGNO
					INNER JOIN ccjobhdr_sql (NOLOCK) ON folio = TAG 
						AND LTRIM(RTRIM(RP_SC.COLOUR)) = CONCAT('F', LTRIM(RTRIM(ccjobhdr_sql.COLOUR)))
					LEFT JOIN CCCUTHST_SQL (NOLOCK) ON CCCUTHST_SQL.jobno = ccjobhdr_sql.jobno 
						AND LTRIM(RTRIM(ccjobhdr_sql.machine)) = LTRIM(RTRIM(CCCUTHST_SQL.machine))
						AND LTRIM(RTRIM(RP_SC.COLOUR)) = LTRIM(RTRIM(CCCUTHST_SQL.COLOUR))
						AND LTRIM(RTRIM(CCCUTHST_SQL.lotno)) = RIGHT('000000' + LTRIM(RTRIM(LOT)), 6) 
						AND	LTRIM(RTRIM(HIDENO)) = LTRIM(RTRIM(HIDE))
					WHERE	TAGNO = @PP_FOLIO_ORIGEN 
					AND		TYPE = 'C'
					AND		ISNULL(PESO, '') IN ('2', '3') -- SE USA COMO BANDERA PARA ESPECIFICAR QUE SON PIELES PARA TRASPASO EN APP DE PRODUCCION
					ORDER BY LOT, HIDE
				
				OPEN CU_PIEL_TRASPASO
				FETCH NEXT FROM CU_PIEL_TRASPASO INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @VP_SQF_PIEL_TBL, @VP_SQF_CORTADO_TBL, @VP_SQF_NO_CORTADO_TBL, @VP_TIPO_TRASPASO_TBL
				
				WHILE @@FETCH_STATUS = 0
					BEGIN
						-- ///////////////////SE VALIDA QUE EL SQF CORTADO DE LA PIEL NO SEA MEYOR AL SQF DE LA PIEL EN EL FOLIO//////////////////////////////////////////////////
						IF CONVERT(DECIMAL(13,2),@VP_SQF_PIEL_TBL) < CONVERT(DECIMAL(13,2),@VP_SQF_CORTADO_TBL)
							BEGIN
								SET @VP_MENSAJE_TRANSACCION = 'El SQF cortado de la Piel:' + @VP_PIEL_TBL + ' es mayor a lo disponible en el folio.'
								RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
							END

						-- ///////////////////SE OBTIENE EL SQF DE LA PIEL A TRASPASAR//////////////////////////////////////////////////						
						IF @VP_TIPO_TRASPASO_TBL = 2 AND @VP_SQF_CORTADO_TBL = 0 -- TIPO TRASPASO 2: SIGNIFICA QUE QUIERE TRANSFERIR LO DISPONIBLE CUANDO NO HAY CORTE SE TRANSFIERE LA PIEL COMPLETA
							SET @VP_SQF_TRANSFERIR = @VP_SQF_PIEL_TBL

						IF @VP_TIPO_TRASPASO_TBL = 2 AND @VP_SQF_CORTADO_TBL > 0 -- TIPO TRASPASO 2: SIGNIFICA QUE QUIERE TRANSFERIR LO DISPONIBLE CUANDO HAY CORTE SE TRANSFIERE LO QUE NO SE HA CORTADO
							SET @VP_SQF_TRANSFERIR = @VP_SQF_NO_CORTADO_TBL

						IF @VP_TIPO_TRASPASO_TBL = 3 AND @VP_SQF_CORTADO_TBL = @VP_SQF_PIEL_TBL -- TIPO TRASPASO 3: SIGNIFICA QUE QUIERE TRANSFERIR EL CORTE SI SE CORTO LA PIEL COMPLETA SE TRANSFIERE LA PIEL MAS CORTE
							SET @VP_SQF_TRANSFERIR = @VP_SQF_CORTADO_TBL

						IF @VP_TIPO_TRASPASO_TBL = 3 AND @VP_SQF_CORTADO_TBL <> @VP_SQF_PIEL_TBL -- TIPO TRASPASO 3: SIGNIFICA QUE QUIERE TRANSFERIR EL CORTE SOLO SE ACORTADO UNA PARTE SOLO SE TRANSFIERE LO CORRESPONDIENTE AL CORTE 
							SET @VP_SQF_TRANSFERIR = @VP_SQF_CORTADO_TBL

						-- ///////////////////INGRESO EL LOG DE LA PIEL A TRANSFERIR//////////////////////////////////////////////////
						EXECUTE [dbo].[PG_IN_PIEL_LOG]		@PP_K_SISTEMA_EXE, @PP_NUMERO_RELOJ,
															@VP_TIPO_PIEL_LOG, @PP_FOLIO_ORIGEN, @VP_COLOR_TBL,
															@VP_LOTE_TBL, @VP_PIEL_TBL, @VP_SQF_TRANSFERIR, 
															@PP_LOCACION_ORIGEN, @PP_ORDEN_ORIGEN, 
															@VP_FOLIO_DESTINO, @VP_LOCACION_DESTINO, @PP_ORDEN_DESTINO --0 -- ORDER_DESTINO
						
						-- /////////////////////////SE VALIDA SI LA PIEL YA EXISTE EN EL FOLIO DESTINO////////////////////////////////////////////
						DECLARE @VP_N_PIEL_FOLIO_DESTINO INT = 0
						SELECT  @VP_N_PIEL_FOLIO_DESTINO = COUNT(ID) 
						FROM RP_SC (NOLOCK)
						WHERE	LTRIM(RTRIM(TAGNO)) = @VP_FOLIO_DESTINO
						AND		LTRIM(RTRIM(COLOUR)) = @VP_COLOR_TBL
						AND		LTRIM(RTRIM(HIDE)) = @VP_PIEL_TBL
						AND		LTRIM(RTRIM(LOT)) = @VP_LOTE_TBL

						IF (@VP_N_PIEL_FOLIO_DESTINO IS NULL OR @VP_N_PIEL_FOLIO_DESTINO = 0 )
							BEGIN
								-- /////////////////////////SE AGREGA LA PIEL CON EL SQF A TRASPASAR AL FOLIO DE LA ORDEN DESTINO////////////////////////////////////////////
								EXECUTE [dbo].[PG_IN_RP_SC]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@VP_F_ACTUAL, @VP_COLOR_TBL, @VP_LOTE_TBL, 
																@VP_PIEL_TBL, @VP_SQF_TRANSFERIR, @VP_FOLIO_DESTINO, 
																NULL, NULL, NULL, 'E', @VP_LOCACION_DESTINO, @VP_K_CLASIFICACION
							END
						ELSE
							BEGIN
								-- /////////////////////////SE OBTIENE EL SQF EN EL FOLIO DESTINO////////////////////////////////////////////
								DECLARE @VP_SQF_PIEL_FOLIO_DESTINO DECIMAL(13, 2) = 0
								SELECT  @VP_SQF_PIEL_FOLIO_DESTINO = CONVERT(DECIMAL(13,2), LTRIM(RTRIM(SQF)))
								FROM RP_SC (NOLOCK)
								WHERE	LTRIM(RTRIM(TAGNO)) = @VP_FOLIO_DESTINO
								AND		LTRIM(RTRIM(COLOUR)) = @VP_COLOR_TBL
								AND		LTRIM(RTRIM(HIDE)) = @VP_PIEL_TBL
								AND		LTRIM(RTRIM(LOT)) = @VP_LOTE_TBL

								-- /////////////////////////SE SUMA EL SQF EN FOLIO DESTINO MAS SQF A TRANSFERIR////////////////////////////////////////////
								DECLARE @VP_TOTAL_SQF DECIMAL(13, 2) = @VP_SQF_PIEL_FOLIO_DESTINO + CONVERT(DECIMAL(13,2),@VP_SQF_TRANSFERIR)

								IF @VP_TOTAL_SQF > 99
									BEGIN
										SET @VP_MENSAJE_TRANSACCION = 'El SQF de la Piel:' + @VP_PIEL_TBL + ' a transferir no es valido.'
										RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
									END

								-- /////////////////////////SE ACTUALIZA LA PIEL DEL FOLIO DESTINO////////////////////////////////////////////
								UPDATE RP_SC
									SET SQF = CONVERT(VARCHAR(10), @VP_TOTAL_SQF)
								WHERE	LTRIM(RTRIM(TAGNO)) = @VP_FOLIO_DESTINO
								AND		LTRIM(RTRIM(COLOUR)) = @VP_COLOR_TBL
								AND		LTRIM(RTRIM(HIDE)) = @VP_PIEL_TBL
								AND		LTRIM(RTRIM(LOT)) = @VP_LOTE_TBL

								IF @@ROWCOUNT = 0
									BEGIN
										SET @VP_MENSAJE_TRANSACCION = 'No fue posible actualizar el SQF de la Piel:' + @VP_PIEL_TBL + ' del folio destino:' + CONVERT(VARCHAR(20), @VP_FOLIO_DESTINO) + '.'
										RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
									END

								-- /////////////////////////SE AGREGA LA PIEL CON EL SQF A TRASPASAR AL FOLIO DE LA ORDEN DESTINO PARA IMPRIMIR EL FOLIO PARA DESPUES SER BORRADA////////////////////////////////////////////
								EXECUTE [dbo].[PG_IN_RP_SC]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@VP_F_ACTUAL, @VP_COLOR_TBL, @VP_LOTE_TBL, 
																@VP_PIEL_TBL, @VP_SQF_TRANSFERIR, @VP_FOLIO_DESTINO, 
																NULL, NULL, NULL, 'E', @VP_LOCACION_DESTINO, @VP_K_CLASIFICACION

								-- ///////SE ENVIA CORREO TEMPORALMENTE PARA ESTAR MONITORIANDO////////////////////////////////////////////
								DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = 'franciscoe@pearlleather.com.mx'
								DECLARE @VP_SUBJECT		VARCHAR(255) = 'Traspaso de Piel existente...'
								DECLARE @VP_FECHA		VARCHAR(10) = CONVERT(VARCHAR(10), GETDATE(),103)
								DECLARE @VP_BODY		NVARCHAR(MAX) 

								SET @VP_BODY =  N'<table  border="1" align="center" cellspacing="0">' + 
													N'<thead>' + 
													  N'<tr BGCOLOR="#ADD8E6">' + 
													    N'<th colspan="10">Traspaso de Piel existente</th>' + 
													  N'</tr>' + 
													  N'<tr BGCOLOR="#48D1CC">' + 
													    N'<th>Piel</th><th>Color</th><th>Folio Ori.</th><th>Folio Des.</th><th>Locacion Ori.</th><th>Locacion Des.</th><th>Orden Ori.</th><th>Orden Des.</th><th>Usuario</th>' + 
													  N'</tr>' + 
													N'</thead>' + 
													N'<tbody>' + 
													  N'<tr>' + 
													  N'<td>'+ @VP_PIEL_TBL +'</td><td>'+ @VP_COLOR_TBL +'</td><td>'+ CONVERT(VARCHAR(10),@PP_FOLIO_ORIGEN) +'</td><td>'+ CONVERT(VARCHAR(10),@VP_FOLIO_DESTINO) +'</td><td>'+ @PP_LOCACION_ORIGEN+'</td><td>'+ @VP_LOCACION_DESTINO +'</td><td>'+ @PP_ORDEN_ORIGEN +'</td><td>'+ @PP_ORDEN_DESTINO +'</td><td>'+ CONVERT(VARCHAR(10),@PP_K_USUARIO_ACCION) +'</td>' + 
													  N'</tr>' + 
													N'</tbody>' + 
												N'</table>' ;
								SET ROWCOUNT 0
									 				
								EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY
							END

							IF @VP_TIPO_TRASPASO_TBL = 3 -- SI LO QUE SE ESTA TRANSFIRIENDO ES LO CORTADO SE ACTUALIZAN LOS DATOS EN LA TABLA cccuthst_sql
								BEGIN
									-- /////////////SE ACTUALIZA EL REGISTRO DEL CORTE CON LOS DATOS DE LA ORDEN DESTINO////////////////////
									UPDATE cccuthst_sql 
										SET jobno		= @PP_ORDEN_DESTINO,
											colour		= @VP_COLOR_DESTINO,
											linenum		=  '0001',
											machine		= @VP_D_LOCACION_DESTINO 
									WHERE JOBNO = @PP_ORDEN_ORIGEN
									AND COLOUR = @PP_COLOR_ORIGEN
									AND hideno = @VP_PIEL_TBL
									AND LTRIM(RTRIM(lotno)) = RIGHT( '000000' + @VP_LOTE_TBL, 6)

									IF @@ROWCOUNT = 0
										BEGIN
											SET @VP_MENSAJE_TRANSACCION = 'No fue posible transferir el corte de la Piel:' + @VP_PIEL_TBL + '.'
											RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
										END

									-- ///////////////////INGRESO EL LOG DE LA PIEL TIPO TRANSFERENCIA PIEL CORTADA #10//////////////////////////////////////////////////
									EXECUTE [dbo].[PG_IN_PIEL_LOG]		@PP_K_SISTEMA_EXE, @PP_NUMERO_RELOJ,
																		10, @PP_FOLIO_ORIGEN, @PP_COLOR_ORIGEN,
																		@VP_LOTE_TBL, @VP_PIEL_TBL, @VP_SQF_TRANSFERIR, 
																		@PP_LOCACION_ORIGEN, @PP_ORDEN_ORIGEN, 
																		@VP_FOLIO_DESTINO, @VP_LOCACION_DESTINO, @PP_ORDEN_DESTINO
								END

						IF @VP_TIPO_TRASPASO_TBL = 2 AND @VP_SQF_CORTADO_TBL = 0 -- TIPO TRASPASO 2: SIGNIFICA QUE QUIERE TRANSFERIR LO DISPONIBLE CUANDO NO HAY CORTE SE TRANSFIERE LA PIEL COMPLETA
							BEGIN
								-- ///////SE ACTUALIZA LA PIEL COM TIPO D PARA IMPRIMIR EL FOLIO DE DEVOLUCION////////////////////////////////////////////
								UPDATE RP_SC
									SET TYPE = 'D',
										PESO = NULL
								WHERE LTRIM(RTRIM(COLOUR)) = @VP_COLOR_TBL
								AND LTRIM(RTRIM(LOT)) = @VP_LOTE_TBL
								AND LTRIM(RTRIM(HIDE)) = @VP_PIEL_TBL
								AND TAGNO = @PP_FOLIO_ORIGEN
								AND TYPE = 'C'
								AND PESO = '2'

								IF @@ROWCOUNT = 0
									BEGIN
										SET @VP_MENSAJE_TRANSACCION = 'No fue posible agregar la Piel:' + @VP_PIEL_TBL + ' del folio origen:' + CONVERT(VARCHAR(20), @PP_FOLIO_ORIGEN) + ' como devolución.'
										RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
									END

							END

						IF @VP_TIPO_TRASPASO_TBL = 2 AND @VP_SQF_CORTADO_TBL > 0 -- TIPO TRASPASO 2: SIGNIFICA QUE QUIERE TRANSFERIR LO DISPONIBLE CUANDO HAY CORTE SE TRANSFIERE LO QUE NO SE HA CORTADO
							BEGIN
								UPDATE RP_SC
								SET SQF = @VP_SQF_CORTADO_TBL,
									PESO = NULL
								WHERE LTRIM(RTRIM(COLOUR)) = @VP_COLOR_TBL
								AND LTRIM(RTRIM(LOT)) = @VP_LOTE_TBL
								AND LTRIM(RTRIM(HIDE)) = @VP_PIEL_TBL
								AND TAGNO = @PP_FOLIO_ORIGEN
								AND TYPE = 'C'
								AND PESO = '2'

								IF @@ROWCOUNT = 0
									BEGIN
										SET @VP_MENSAJE_TRANSACCION = 'No fue posible actualizar el SQF cortado de la Piel:' + @VP_PIEL_TBL + ' del folio origen:' + CONVERT(VARCHAR(20), @VP_FOLIO_DESTINO) + '.'
										RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
									END

								-- ///INGRESA UNA COPIA DE LA PIEL CORTADA CON EL SQF DEVUELTO PARA QUE SE PUEDA IMPRIMIR EN EL FORMATO DE DEVOLUCION///////////////
								INSERT INTO RP_SC( [CDATE],[COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[YARDAS],[YLB],[PESO],[TYPE],[MOVEMENT],[K_CLASIFICACION] )
											SELECT TOP 1 [CDATE],[COLOUR],[LOT],[HIDE],@VP_SQF_NO_CORTADO_TBL,[TAGNO],[YARDAS],[YLB],[PESO],'D',[MOVEMENT],[K_CLASIFICACION]
											FROM	RP_SC (NOLOCK)
											WHERE LTRIM(RTRIM(COLOUR)) = @VP_COLOR_TBL
											AND LTRIM(RTRIM(LOT)) = @VP_LOTE_TBL
											AND LTRIM(RTRIM(HIDE)) = @VP_PIEL_TBL
											AND TAGNO = @PP_FOLIO_ORIGEN
											AND TYPE = 'C'
											AND PESO IS NULL

								IF @@ROWCOUNT = 0
									BEGIN
										SET @VP_MENSAJE_TRANSACCION = 'No fue posible agregar la Piel:' + @VP_PIEL_TBL + ' del folio origen:' + CONVERT(VARCHAR(20), @PP_FOLIO_ORIGEN) + ' como devolución.'
										RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
									END	
							END

						IF @VP_TIPO_TRASPASO_TBL = 3 AND @VP_SQF_CORTADO_TBL = @VP_SQF_PIEL_TBL -- TIPO TRASPASO 3: SIGNIFICA QUE QUIERE TRANSFERIR EL CORTE SI SE CORTO LA PIEL COMPLETA SE TRANSFIERE LA PIEL MAS CORTE
							BEGIN
								-- ///////SE ACTUALIZA LA PIEL COM TIPO D PARA IMPRIMIR EL FOLIO DE DEVOLUCION////////////////////////////////////////////
								UPDATE RP_SC
									SET TYPE = 'D',
										PESO = NULL
								WHERE LTRIM(RTRIM(COLOUR)) = @VP_COLOR_TBL
								AND LTRIM(RTRIM(LOT)) = @VP_LOTE_TBL
								AND LTRIM(RTRIM(HIDE)) = @VP_PIEL_TBL
								AND TAGNO = @PP_FOLIO_ORIGEN
								AND TYPE = 'C'
								AND PESO = '3'

								IF @@ROWCOUNT = 0
									BEGIN
										SET @VP_MENSAJE_TRANSACCION = 'No fue posible agregar la Piel:' + @VP_PIEL_TBL + ' del folio origen:' + CONVERT(VARCHAR(20), @PP_FOLIO_ORIGEN) + ' como devolución.'
										RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
									END

							END

						IF @VP_TIPO_TRASPASO_TBL = 3 AND @VP_SQF_CORTADO_TBL <> @VP_SQF_PIEL_TBL -- TIPO TRASPASO 3: SIGNIFICA QUE QUIERE TRANSFERIR EL CORTE SOLO SE ACORTADO UNA PARTE SOLO SE TRANSFIERE LO CORRESPONDIENTE AL CORTE 
							BEGIN
								UPDATE RP_SC
								SET SQF = @VP_SQF_NO_CORTADO_TBL,
									PESO = NULL
								WHERE LTRIM(RTRIM(COLOUR)) = @VP_COLOR_TBL
								AND LTRIM(RTRIM(LOT)) = @VP_LOTE_TBL
								AND LTRIM(RTRIM(HIDE)) = @VP_PIEL_TBL
								AND TAGNO = @PP_FOLIO_ORIGEN
								AND TYPE = 'C'
								AND PESO = '3'

								IF @@ROWCOUNT = 0
									BEGIN
										SET @VP_MENSAJE_TRANSACCION = 'No fue posible actualizar el SQF cortado de la Piel:' + @VP_PIEL_TBL + ' del folio origen:' + CONVERT(VARCHAR(20), @VP_FOLIO_DESTINO) + '.'
										RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
									END

								-- ///INGRESA UNA COPIA DE LA PIEL CORTADA CON EL SQF DEVUELTO PARA QUE SE PUEDA IMPRIMIR EN EL FORMATO DE DEVOLUCION///////////////
								INSERT INTO RP_SC( [CDATE],[COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[YARDAS],[YLB],[PESO],[TYPE],[MOVEMENT],[K_CLASIFICACION] )
											SELECT TOP 1 [CDATE],[COLOUR],[LOT],[HIDE],@VP_SQF_CORTADO_TBL,[TAGNO],[YARDAS],[YLB],[PESO],'D',[MOVEMENT],[K_CLASIFICACION]
											FROM	RP_SC (NOLOCK)
											WHERE LTRIM(RTRIM(COLOUR)) = @VP_COLOR_TBL
											AND LTRIM(RTRIM(LOT)) = @VP_LOTE_TBL
											AND LTRIM(RTRIM(HIDE)) = @VP_PIEL_TBL
											AND TAGNO = @PP_FOLIO_ORIGEN
											AND TYPE = 'C'
											AND PESO IS NULL

								IF @@ROWCOUNT = 0
									BEGIN
										SET @VP_MENSAJE_TRANSACCION = 'No fue posible agregar la Piel:' + @VP_PIEL_TBL + ' del folio origen:' + CONVERT(VARCHAR(20), @PP_FOLIO_ORIGEN) + ' como devolución.'
										RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
									END	
							END

						FETCH NEXT FROM CU_PIEL_TRASPASO INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @VP_SQF_PIEL_TBL, @VP_SQF_CORTADO_TBL, @VP_SQF_NO_CORTADO_TBL, @VP_TIPO_TRASPASO_TBL
					END

				CLOSE CU_PIEL_TRASPASO
				DEALLOCATE CU_PIEL_TRASPASO		
				
				-- ////////SE VALIDA QUE LOS SQF Y TOTAL DE PIELES SEAN IGUALES A LOS ENVIADOS DESDE LA PANTALLA/////////////////////////////////////////////////////////////
				DECLARE @VP_N_PIEL_TRASPASAR INT = 0
				DECLARE @VP_TOTAL_SQF_TRASPASAR DECIMAL(13,2) = 0

				SELECT	@VP_N_PIEL_TRASPASAR = COUNT(ID), 
						@VP_TOTAL_SQF_TRASPASAR = SUM(CONVERT(DECIMAL(13,2),LTRIM(RTRIM(SQF))))
				FROM	RP_SC (NOLOCK)
				WHERE	TAGNO = @PP_FOLIO_ORIGEN
				AND		TYPE = 'D'	

				IF @PP_TOTAL_PIEL <> @VP_N_PIEL_TRASPASAR
					RAISERROR ('El total de Pieles a Transferir no es correcto.', 16, 1 ) --MENSAJE - Severity -State.

				IF @PP_TOTAL_SQF <> @VP_TOTAL_SQF_TRASPASAR
					RAISERROR ('El total de Pies Cuadrados a Transferir no es correcto.', 16, 1 ) --MENSAJE - Severity -State.
						
				-- ////////SE TRANSFIEREN LOS PIES CUADRADOS/////////////////////////////////////////////////////////////
				EXECUTE [dbo].[PG_PR_TRANSFER_SQF_X_DEVOLUCION_MESA_A_MHI]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																				@PP_FOLIO_ORIGEN, @PP_COLOR_ORIGEN, 
																				@PP_ORDEN_ORIGEN, @PP_LOCACION_ORIGEN,
																				@PP_ORDEN_DESTINO, @VP_LOCACION_DESTINO,
																				@PP_NUMERO_RELOJ, @PP_LOCACION_ORIGEN

				-- /////////////SE OBTIENE EL NUMERO DE PIELES QUE QUEDARAN EN EL FOLIO ORIGEN DESPUES DEL TRASPASO///////////////////////////
				DECLARE @VP_N_PIEL_FOLIO INT = 0
				SELECT	@VP_N_PIEL_FOLIO = COUNT(RP_SC.ID)
				-- =====================
				FROM	RP_SC (NOLOCK)
				WHERE	TAGNO = @PP_FOLIO_ORIGEN 
				AND		TYPE <> 'D'

				IF	( @VP_N_PIEL_FOLIO IS NULL OR @VP_N_PIEL_FOLIO = 0 )
					BEGIN
						EXECUTE	[dbo].[PG_UP_RP_FOLIO_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
																@PP_FOLIO_ORIGEN, 'A', NULL, NULL

						-- ==========================================
						UPDATE ccjobhdr_sql 
						 SET FOLIO = NULL
						WHERE FOLIO = @PP_FOLIO_ORIGEN

						IF @@ROWCOUNT = 0
							RAISERROR ('No fue posible quitar el folio de la Orden.', 16, 1 ) --MENSAJE - Severity -State.
					END		

				-- ////////////SIEMPRE SE DEBE DE IMPRIMIR EL FORMATO DE DEVOLUCION PARA ESTE PROCESO/////////////////////////////////////////////////////////
				EXECUTE [dbo].[PG_IN_RP_SC_PRT]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@PP_FOLIO_ORIGEN, 5

				-- ////////////SIEMPRE SE DEBE DE IMPRIMIR EL FORMATO DE EXTRAS PARA ESTE PROCESO/////////////////////////////////////////////////////////
				EXECUTE [dbo].[PG_IN_RP_SC_PRT]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@VP_FOLIO_DESTINO, 4
				
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRASAC. PG_PR_TRASPASAR_PIEL_A_ORDEN_EN_PRD // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible realizar el Traspaso del [FOLIO]: ' + CONVERT(VARCHAR(20),@PP_FOLIO_ORIGEN) + ' ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_FOLIO_ORIGEN AS CLAVE
	
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
													0, 0, @PP_FOLIO_ORIGEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
