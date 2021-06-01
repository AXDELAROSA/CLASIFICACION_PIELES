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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_PLANNING_CREAR_ORDER_2_TONO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_PLANNING_CREAR_ORDER_2_TONO]
GO

/*
	 EXEC [PG_PR_PLANNING_CREAR_ORDER_2_TONO] 0 ,144, 'MAGN03' , 'FCNPJRR' , 'Table 38' , 
								'PLMWARM/PWD2TFB/PWD2TBL/PWD2TCR/PWD2TCL/PW2RB40/PW2RB60/PW2RC40/PWDRC60' , 
								'30/30/30/30/30/30/30/30/30' , '' , 'ORDEN GENERADA POR SISTEMAS PARA PRUEBAS' , 'franciscoe' , 'IT-010'  
*/

CREATE PROCEDURE [dbo].[PG_PR_PLANNING_CREAR_ORDER_2_TONO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN_PRINCIPAL			VARCHAR(50),
	@PP_CLIENTE					VARCHAR(50),
	@PP_MESA					VARCHAR(50),
	@PP_COMENTARIO				VARCHAR(255),
	@PP_USER					VARCHAR(25), 
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	-- ///////SE OBTIENE EL NUMERO DE LA ULTIMA ORDEN GENERADA//////////////////////////////////////////////
	DECLARE @VP_ORDEN_COMPLEMENTO VARCHAR(50) = ''
	SELECT	TOP 1 @VP_ORDEN_COMPLEMENTO = CONVERT(INT, LTRIM(RTRIM(user_def_fld_4)))
	FROM	imlocfil_sql 
	WHERE LOC = 'MFP'

	IF @VP_ORDEN_COMPLEMENTO IS NULL
		RAISERROR ('ERROR: No fue posible obtener el numero de orden en [CCJOBHDR_SQL]', 16, 1 ) --MENSAJE - Severity -State.

	SET @VP_ORDEN_COMPLEMENTO = @VP_ORDEN_COMPLEMENTO + 1
	SET @VP_ORDEN_COMPLEMENTO = RIGHT('00000' + @VP_ORDEN_COMPLEMENTO, 5)

	-- ///////SE ACTUALIZA LA LOCACION MFP CON LA ORDEN CREADA//////////////////////////////////////////////	
	UPDATE imlocfil_sql 
		SET user_def_fld_4 = @VP_ORDEN_COMPLEMENTO
	WHERE LOC = 'MFP'

	IF @@ROWCOUNT = 0
		RAISERROR ('ERROR: No fue posible Actualizar la orden en [imlocfil_sql]', 16, 1 ) --MENSAJE - Severity -State.

	-- //////SE DECLARAN VARIABLES A USARSE/////////////////////////////////////
	DECLARE @VP_KIT VARCHAR(50) = '', @VP_ITEM_NO VARCHAR(100) = '', @VP_CANTIDAD INT = 0, @VP_U_ITEM_NO VARCHAR(100) = '';
	DECLARE @VP_GROSS DECIMAL(16,4) = 0, @VP_NETO DECIMAL(16,4) = 0, @VP_PATRON INT = 0;
	DECLARE @VP_TOTAL_GROSS DECIMAL(16,4) = 0, @VP_TOTAL_NETO DECIMAL(16,4) = 0, @VP_TOTAL_PATRON INT = 0, @VP_CONSECUTIVO INT = 1;

	-- //////SE CREA CURSOR PARA DARLE FORMATO A LOS DATOS/////////////////////////////////////
	DECLARE CU_ORDEN_2_TONO_A_PROGRAMAR CURSOR 
	FOR SELECT Kit, IMKITFIL_SQL.Item_No, ccjoblin_sql.item_no, OriginalQty
		FROM IMKITFIL_SQL
		INNER JOIN ccjoblin_sql ON   ccjoblin_sql.Item_No = comp_item_no
		WHERE JOBNO = @PP_ORDEN_PRINCIPAL
		ORDER BY Ser_No

	OPEN CU_ORDEN_2_TONO_A_PROGRAMAR
	FETCH NEXT FROM CU_ORDEN_2_TONO_A_PROGRAMAR INTO @VP_KIT, @VP_U_ITEM_NO, @VP_ITEM_NO, @VP_CANTIDAD

	WHILE @@FETCH_STATUS = 0
		BEGIN
			-- ////////SE OBTIENE EL NUMERO DE COMPLEMENTOS PARA EL KIT ORIGINAL///////////////////////////////////
			DECLARE @VP_N_ITEM_NO INT = 0
			SELECT  @VP_N_ITEM_NO = COUNT(A4GLIdentity)
			FROM imkitfil_sql 
			WHERE item_no = @VP_U_ITEM_NO AND comp_item_no <> @VP_ITEM_NO

			IF @VP_N_ITEM_NO IS NULL OR @VP_N_ITEM_NO = 0
				RAISERROR ('ERROR: No fue posible obtener el Item No Complemento en [imkitfil_sql]', 16, 1 ) --MENSAJE - Severity -State.

			IF @VP_N_ITEM_NO > 1
				RAISERROR ('ERROR: Existe mas de un Item No Complemento en [imkitfil_sql]', 16, 1 ) --MENSAJE - Severity -State.

			-- ////////SE OBTIENE EL KIT COMPLEMENTO PARA EL KIT ORIGINAL///////////////////////////////////
			DECLARE @VP_ITEM_NO_COMPLEMENTO VARCHAR(50) = ''
			SELECT  @VP_ITEM_NO_COMPLEMENTO = comp_item_no
			FROM imkitfil_sql 
			WHERE item_no = @VP_U_ITEM_NO AND comp_item_no <> @VP_ITEM_NO						

			DECLARE @VP_COLOR VARCHAR(50) = CONCAT('F', RIGHT(LTRIM(RTRIM(@VP_ITEM_NO_COMPLEMENTO)),6))
			
			DECLARE @VP_CUBE_LENGTH DECIMAL(13,4) = 0, @VP_CUBE_WIDTH DECIMAL(13,4) = 0, @VP_CUBE_QTY_PER DECIMAL(13,4) = 0;
			DECLARE @VP_D_ITEM	VARCHAR(255), @VP_CHANGE_LEVEL	VARCHAR(100), @VP_MODELO	VARCHAR(50), @VP_VERSION VARCHAR(50);

			-- ////////SE OBTIENE EL MODELO Y ULTIMA VERSION DEL KIT///////////////////////////////////
			SELECT	DISTINCT TOP (1) PERCENT 
				 @VP_VERSION = ccverhdr_sql.versionno, 
				 @VP_MODELO = ccverhdr_sql.modelno
			FROM	dbo.ccverhdr_sql
			INNER JOIN cccusitm_sql ON CONCAT(ccverhdr_sql.modelno, ccverhdr_sql.versionno ) = CONCAT(cccusitm_sql.modelno, cccusitm_sql.versionno ) 
				AND SUBSTRING(LTRIM(RTRIM(cccusitm_sql.item_no)) ,1 ,1)  = 'P' 
				AND cus_item_no <> ''
			INNER JOIN IMITMIDX_SQL ON IMITMIDX_SQL.item_no = cccusitm_sql.item_no
			INNER JOIN  IMCATFIL_SQL ON dbo.IMITMIDX_SQL.prod_cat = IMCATFIL_SQL.prod_cat 
				AND IMCATFIL_SQL.L_BORRADO = 0
			WHERE ccverhdr_sql.specstatus = 'U' 
			AND ccverhdr_sql.status = 'L' 
			AND CONCAT('F', RIGHT(LTRIM(RTRIM(cccusitm_sql.item_no)),6)) = @VP_COLOR
			AND ccverhdr_sql.cus_no = @PP_CLIENTE
			AND cccusitm_sql.item_no = @VP_ITEM_NO_COMPLEMENTO
			--ORDER BY versionno DESC

			SET @VP_CHANGE_LEVEL = @VP_MODELO + @VP_VERSION

			-- ////////SE OBTIENE EL GROSS, NETO Y PATRONES DEL KIT///////////////////////////////////
			SELECT TOP 1 @VP_CUBE_LENGTH	= CUBE_LENGTH,
					@VP_CUBE_WIDTH			= CUBE_WIDTH,
					@VP_CUBE_QTY_PER		= CUBE_QTY_PER,
					@VP_D_ITEM				= LTRIM(RTRIM(item_desc_1))
			FROM IMITMIDX_SQL   
			WHERE	LTRIM(RTRIM(ITEM_NO)) = @VP_ITEM_NO_COMPLEMENTO

			IF @VP_CUBE_LENGTH IS NULL
				SET @VP_CUBE_LENGTH = 0

			IF @VP_CUBE_WIDTH IS NULL
				SET @VP_CUBE_WIDTH = 0

			IF @VP_CUBE_QTY_PER IS NULL
				SET @VP_CUBE_QTY_PER = 0						 

			SET @VP_GROSS	= @VP_CUBE_LENGTH	* @VP_CANTIDAD
			SET @VP_NETO	= @VP_CUBE_WIDTH	* @VP_CANTIDAD
			SET @VP_PATRON	= @VP_CUBE_QTY_PER	* @VP_CANTIDAD 

			SET @VP_TOTAL_GROSS = @VP_TOTAL_GROSS + @VP_GROSS
			SET @VP_TOTAL_NETO = @VP_TOTAL_NETO + @VP_NETO
			SET @VP_TOTAL_PATRON = @VP_TOTAL_PATRON + @VP_PATRON
			
			-- ////////SE OBTIENE EL STANDARD PACK DEL KIT///////////////////////////////////			
			DECLARE @VP_STD_PACK INT = 0
			SELECT	TOP(1) 
					@VP_STD_PACK = user_def_fld_5 
			FROM ccitmidx_sql WHERE LTRIM(RTRIM(item_no)) = @VP_ITEM_NO_COMPLEMENTO
			ORDER BY versionno DESC
			
			IF @VP_STD_PACK IS NULL
				RAISERROR ('ERROR: No fue posible obtener el Estandar Pack en [ccitmidx_sql]', 16, 1 ) --MENSAJE - Severity -State.

			-- //////SE INGRESAN LOS KITS EN LA TABLA ccjoblin_sql/////////////////////////////////////
			IF @VP_CANTIDAD > @VP_STD_PACK
				BEGIN
					WHILE  @VP_CANTIDAD > 0
						BEGIN
							IF @VP_CANTIDAD > @VP_STD_PACK
								BEGIN
									INSERT INTO	ccjoblin_sql(	jobno, kit, kitdesc,item_no, PlannedQty, OriginalQty, CompletedQty, 
																netsqmper, stdsqmper, patternsper, customer, ChangeLevel, Ser_no	
															)
													VALUES(		@VP_ORDEN_COMPLEMENTO, @VP_KIT, @VP_D_ITEM, @VP_ITEM_NO_COMPLEMENTO, @VP_STD_PACK, @VP_STD_PACK, 0,
																@VP_CUBE_WIDTH, @VP_CUBE_LENGTH, @VP_CUBE_QTY_PER, @PP_CLIENTE, @VP_CHANGE_LEVEL, @VP_CONSECUTIVO
															)
									
									IF @@ROWCOUNT = 0
										RAISERROR ('ERROR: No fue posible agregar el kit a la orden en [ccjoblin_sql]', 16, 1 ) --MENSAJE - Severity -State.
								END
							ELSE
								BEGIN
									INSERT INTO	ccjoblin_sql(	jobno, kit, kitdesc,item_no, PlannedQty, OriginalQty, CompletedQty, 
																netsqmper, stdsqmper, patternsper, customer, ChangeLevel, Ser_no	)
													VALUES(		@VP_ORDEN_COMPLEMENTO, @VP_KIT, @VP_D_ITEM, @VP_ITEM_NO_COMPLEMENTO, @VP_CANTIDAD, @VP_CANTIDAD, 0,
																@VP_CUBE_WIDTH, @VP_CUBE_LENGTH, @VP_CUBE_QTY_PER, @PP_CLIENTE, @VP_CHANGE_LEVEL, @VP_CONSECUTIVO	)
									
									IF @@ROWCOUNT = 0
										RAISERROR ('ERROR: No fue posible agregar el kit a la orden en [ccjoblin_sql]', 16, 1 ) --MENSAJE - Severity -State.
								END

							SET @VP_CANTIDAD = @VP_CANTIDAD - @VP_STD_PACK
							SET @VP_CONSECUTIVO = @VP_CONSECUTIVO + 1
						END
				END
			ELSE
				BEGIN
					INSERT INTO	ccjoblin_sql(	jobno, kit, kitdesc,item_no, PlannedQty, OriginalQty, CompletedQty, 
												netsqmper, stdsqmper, patternsper, customer, ChangeLevel, Ser_no	)
									VALUES(		@VP_ORDEN_COMPLEMENTO, @VP_KIT, @VP_D_ITEM, @VP_ITEM_NO_COMPLEMENTO, @VP_CANTIDAD, @VP_CANTIDAD, 0,
												@VP_CUBE_WIDTH, @VP_CUBE_LENGTH, @VP_CUBE_QTY_PER, @PP_CLIENTE, @VP_CHANGE_LEVEL, @VP_CONSECUTIVO	)
					
					IF @@ROWCOUNT = 0
						RAISERROR ('ERROR: No fue posible agregar el kit a la orden en [ccjoblin_sql]', 16, 1 ) --MENSAJE - Severity -State.

					SET @VP_CONSECUTIVO = @VP_CONSECUTIVO + 1
				END
			
			FETCH NEXT FROM CU_ORDEN_2_TONO_A_PROGRAMAR INTO @VP_KIT, @VP_U_ITEM_NO, @VP_ITEM_NO, @VP_CANTIDAD
		END
	
	CLOSE CU_ORDEN_2_TONO_A_PROGRAMAR
	DEALLOCATE CU_ORDEN_2_TONO_A_PROGRAMAR

	-- ///////SE OBTIENE LA DESCRIPCION DEL COLOR//////////////////////////////////////////////
	DECLARE @VP_COLOR_SIN_F VARCHAR(25) = SUBSTRING(@VP_COLOR, 2 , 10)
	DECLARE @VP_D_COLOR VARCHAR(255) = ''

	SELECT TOP 1 @VP_D_COLOR = LTRIM(RTRIM(ITEM_DESC_1))
	FROM IMITMIDX_SQL   
	WHERE	LTRIM(RTRIM(ITEM_NO)) = @VP_COLOR

	IF @VP_D_COLOR IS NULL
		RAISERROR ('ERROR: No fue posible obtener la descripción del color en [IMITMIDX_SQL]', 16, 1 ) --MENSAJE - Severity -State.

	-- ///////SE OBTIENE LA FECHA EN FORMATO NUMERICO//////////////////////////////////////////////
	DECLARE @VP_FECHA	INT = DBO.CONVERT_DATE_TO_INT(GETDATE(), 'yyyyMMdd');
	DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
	DECLARE @VP_TURNO	VARCHAR(5) = '2'
	
	IF @VP_HORA > 2000 AND @VP_HORA < 60002
		SET @VP_TURNO = '3'
	ELSE IF @VP_HORA > 60001 AND @VP_HORA < 153001
		SET @VP_TURNO = '1'

	-- /////////SE OBTIENE LA UTILIDAD//////////////////////////////////
	DECLARE @VP_UTILIDAD_MINIMA DECIMAL(13,2) = 0
	SELECT @VP_UTILIDAD_MINIMA = User_Def_Fld_2
	FROM arcusfil_sql 
	WHERE CUS_NO = @PP_CLIENTE

	IF @VP_UTILIDAD_MINIMA IS NULL
		SET @VP_UTILIDAD_MINIMA = 0

	SET @VP_UTILIDAD_MINIMA = @VP_UTILIDAD_MINIMA / 1000000				

	-- ///////SE INGRESA EL REGISTRO DE LA ORDEN EN CCJOBHDR_SQL//////////////////////////////////////////////
	INSERT INTO CCJOBHDR_SQL (	jobno, status, colour, colourdesc, machine, datecreated, dateplanned,
								printedflag, instruct1, instruct2, netsqm, standardsqm, targetutil,
								customer, patterns, plannedshift, plannedseq, startedflag, comments, lotno	)
                               VALUES (	@VP_ORDEN_COMPLEMENTO, 'P', @VP_COLOR_SIN_F, @VP_D_COLOR, @PP_MESA, @VP_FECHA, @VP_FECHA, 
								'2', @PP_COMENTARIO, '', @VP_TOTAL_NETO, @VP_TOTAL_GROSS, @VP_UTILIDAD_MINIMA, 
								@PP_CLIENTE, @VP_TOTAL_PATRON, @VP_TURNO, '0', '', @PP_COMENTARIO, @PP_ORDEN_PRINCIPAL	)

	IF @@ROWCOUNT = 0
		RAISERROR ('ERROR: No fue posible agregar la orden en [CCJOBHDR_SQL]', 16, 1 ) --MENSAJE - Severity -State.
	
	-- ///////SE ACTUALIZA EL REGISTRO DE LA ORDEN PRINCIPAL EN CCJOBHDR_SQL//////////////////////////////////////////////
	UPDATE CCJOBHDR_SQL 
		SET	LOTNO	=	@VP_ORDEN_COMPLEMENTO
	WHERE jobno	= @PP_ORDEN_PRINCIPAL
	
	IF @@ROWCOUNT = 0
		RAISERROR ('ERROR: No fue posible Actualizar la orden en [CCJOBHDR_SQL]', 16, 1 ) --MENSAJE - Severity -State.

	-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
	DECLARE @VP_DETAIL VARCHAR(100) = 'Creacion de Orden: ' + @VP_ORDEN_COMPLEMENTO
	EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
										@PP_USER, @PP_COMPUTER_NAME, 'Planning',
										@VP_ORDEN_COMPLEMENTO, 'Crear orden',
										@VP_DETAIL, ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
