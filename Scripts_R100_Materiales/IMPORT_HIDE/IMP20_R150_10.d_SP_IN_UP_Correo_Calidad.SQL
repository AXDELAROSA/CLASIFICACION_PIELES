-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			IMPORTACION DE PIELES
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	01/MAR/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_INCINSP_SQL_CORREO_CALIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_INCINSP_SQL_CORREO_CALIDAD]				
GO
/*
EXECUTE  [dbo].[PG_IN_UP_INCINSP_SQL_CORREO_CALIDAD]	0,0,   '210226073445T1000001' 
*/
CREATE PROCEDURE [dbo].[PG_IN_UP_INCINSP_SQL_CORREO_CALIDAD]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_FILE_NO								VARCHAR(50),
	@PP_PP_FECHA							INT,
	@PP_COLOR								VARCHAR(50),
	@PP_LOTE								VARCHAR(50),
	@PP_TOTAL_PIEL_LOTE						INT,
	@PP_TOTAL_SQF_LOTE						DECIMAL(13,2),
	@PP_PACKING_NO							VARCHAR(50),
	@PP_IMPORTACION_MANUAL					INT, --#0 POR SISTEMA, #1 MANUAL
	@PP_USER								VARCHAR(25)
AS

	-- ///////////////SE INGRESA EL REGISTRO EN DEL LOTE EN IncInsp_sql /////////////////////////////////////////////////////
	DECLARE @VP_LOTE_TBL VARCHAR(10) = RIGHT( '000000' + @PP_LOTE, 6)	
	DECLARE @VP_MUESTRA INT = 3
	DECLARE @VP_N_LOTE_INSPECCION INT = 0

	SELECT	@VP_N_LOTE_INSPECCION = COUNT(ID)
	FROM	IncInsp_sql 
	WHERE	LTRIM(RTRIM(Lot)) = @VP_LOTE_TBL 
	AND		PACKING_NO = @PP_PACKING_NO 
	 
	IF ( @VP_N_LOTE_INSPECCION IS NULL OR  @VP_N_LOTE_INSPECCION = 0 )
		BEGIN
			IF @PP_TOTAL_PIEL_LOTE > 5
				SET @VP_MUESTRA = 5

			INSERT INTO IncInsp_sql (	[Date], Lot, [Description], Lot_size, Sample_size, [Status], Accepted, PACKING_NO ) 
							VALUES (	@PP_PP_FECHA, CONCAT('         ', @VP_LOTE_TBL), @PP_COLOR, @PP_TOTAL_PIEL_LOTE, @VP_MUESTRA, '-', '-', @PP_PACKING_NO)

			IF @@ROWCOUNT = 0
				RAISERROR ('NO fue posible agregar el lote en [IncInsp_sql].', 16, 1 ) --MENSAJE - Severity -State.   
		END
	ELSE
		BEGIN
			DECLARE @VP_N_LOTE_INSPECCION_PENDIENTE INT = 0
			SELECT	@VP_N_LOTE_INSPECCION_PENDIENTE = COUNT(ID)
			FROM	IncInsp_sql 
			WHERE	LTRIM(RTRIM(Lot)) = @VP_LOTE_TBL 
			AND		PACKING_NO = @PP_PACKING_NO
			AND		STATUS <> 'C'

			IF ( @VP_N_LOTE_INSPECCION_PENDIENTE IS NULL OR  @VP_N_LOTE_INSPECCION_PENDIENTE = 0 )
				BEGIN							

					IF @PP_TOTAL_PIEL_LOTE > 5
						SET @VP_MUESTRA = 5

					INSERT INTO IncInsp_sql (	[Date], Lot, [Description], Lot_size, Sample_size, [Status], Accepted, PACKING_NO ) 
							VALUES (	@PP_PP_FECHA, CONCAT('         ', @VP_LOTE_TBL), @PP_COLOR, @PP_TOTAL_PIEL_LOTE, @VP_MUESTRA, '-', '-', @PP_PACKING_NO)
					
					IF @@ROWCOUNT = 0
						RAISERROR ('NO fue posible agregar el lote en [IncInsp_sql].', 16, 1 ) --MENSAJE - Severity -State.   
				END
			ELSE
				BEGIN
					DECLARE @VP_ID INT = 0
					DECLARE @VP_TOTAL_LOT_QTY INT = 0
					DECLARE @VP_LOT_QTY INT = 0

					SELECT	@VP_ID = ID,
							@VP_LOT_QTY = Lot_size
					FROM	IncInsp_sql 
					WHERE	LTRIM(RTRIM(Lot)) = @VP_LOTE_TBL 
					AND		PACKING_NO = @PP_PACKING_NO 
					AND		STATUS <> 'C'

					SET @VP_TOTAL_LOT_QTY = @VP_LOT_QTY + @PP_TOTAL_PIEL_LOTE

					IF @VP_TOTAL_LOT_QTY > 5
						SET @VP_MUESTRA = 5

					UPDATE IncInsp_sql
						SET Lot_size	= @VP_TOTAL_LOT_QTY,
							Sample_size	= @VP_MUESTRA
					WHERE ID = @VP_ID

					IF @@ROWCOUNT = 0
						RAISERROR ('NO fue posible actualizar el lote en [IncInsp_sql].', 16, 1 ) --MENSAJE - Severity -State.   

				END
		END

	--///////SE ENVIA CORREO A CALIDAD PARA QUE REALIZE LA INSPECCION////////////////////////////////////////////
	DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = '' --'franciscoe@pearlleather.com.mx'
	DECLARE @VP_SUBJECT		VARCHAR(255) = 'Entrada a inventario MIT en espera de inspección...'
	DECLARE @VP_BODY		NVARCHAR(MAX)  = ''

	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
					FROM	BD_GENERAL.dbo.USUARIO_PEARL AS USERS
					INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR GP_APROB ON GP_APROB.K_USUARIO=USERS.K_USUARIO_PEARL
					WHERE   GP_APROB.S_GRUPO_APROBADOR = 'RECIBI_BPO'
					AND		GP_APROB.K_TIPO_GRUPO_APROBADOR = 7900 -- GRUPO DE CALIDAD QUE INSPECCIONA EL MATERIAL DE BLANKET
					AND		K_ESTATUS_GRUPO_APROBADOR = 1

	SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))

	SET @VP_BODY =  N'<table  border="1" align="center" cellspacing="0">' + 
						N'<thead>' + 
						  N'<tr BGCOLOR="#ADD8E6">' + 
						    N'<th colspan="7">Entrada a inventario MIT en espera de inspección...</th>' + 
						  N'</tr>' + 
						  N'<tr BGCOLOR="#48D1CC">' + 
						    N'<th>File No</th><th>Color</th><th>Lote</th><th>Total Piel</th><th>Total SQF</th><th>Packing No.</th><th>Usuario</th>' + 
						  N'</tr>' + 
						N'</thead>' + 
						N'<tbody>' + 
						  N'<tr>' + 
						  N'<td>'+ @PP_FILE_NO +'</td><td>'+ @PP_COLOR +'</td><td>'+ @PP_LOTE +'</td><td>'+ CONVERT(VARCHAR(10),@PP_TOTAL_PIEL_LOTE) +'</td><td>'+ CONVERT(VARCHAR(10),@PP_TOTAL_SQF_LOTE) +'</td><td>'+ @PP_PACKING_NO +'</td><td>'+  @PP_USER +'</td>' + 
						  N'</tr>' + 
						N'</tbody>' + 
					N'</table>' ;
	SET ROWCOUNT 0
		 				
	EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY
	
	IF @PP_IMPORTACION_MANUAL = 1
		BEGIN
			-- ///////SE ENVIA CORREO TEMPORALMENTE PARA ESTAR MONITORIANDO////////////////////////////////////////////
			SET @VP_RECIPIENTS	  = ''
			SET @VP_RECIPIENTS	  = 'franciscoe@pearlleather.com.mx;monicag@pearlleather.com.mx'

			SET @VP_SUBJECT		= ''
			SET @VP_SUBJECT		= 'Importación de Pieles Manuales...'

			SET @VP_BODY = '' 
			SET @VP_BODY =  N'<table  border="1" align="center" cellspacing="0">' + 
								N'<thead>' + 
								  N'<tr BGCOLOR="#ADD8E6">' + 
								    N'<th colspan="7">Importacion de pieles Manuales... </th>' + 
								  N'</tr>' + 
								  N'<tr BGCOLOR="#48D1CC">' + 
								    N'<th>File No</th><th>Color</th><th>Lote</th><th>Total Piel</th><th>Total SQF</th><th>Factura</th><th>Usuario</th>' + 
								  N'</tr>' + 
								N'</thead>' + 
								N'<tbody>' + 
								  N'<tr>' + 
								  N'<td>'+ @PP_FILE_NO +'</td><td>'+ @PP_COLOR +'</td><td>'+ @PP_LOTE +'</td><td>'+ CONVERT(VARCHAR(10),@PP_TOTAL_PIEL_LOTE) +'</td><td>'+ CONVERT(VARCHAR(10),@PP_TOTAL_SQF_LOTE) +'</td><td>'+ @PP_PACKING_NO +'</td><td>'+  @PP_USER +'</td>' + 
								  N'</tr>' + 
								N'</tbody>' + 
							N'</table>' ;
			SET ROWCOUNT 0
				 				
			EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY
		END

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
