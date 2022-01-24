-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			PLANNING
-- // OPERACION:		LIBERACION / TABLAS
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	17/NOV/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_MODIFICAR_ORDER_X_CAMBIO_NIVEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_MODIFICAR_ORDER_X_CAMBIO_NIVEL]
GO

/*
	 EXEC [PG_PR_MODIFICAR_ORDER_X_CAMBIO_NIVEL] 0 ,144,  '39201' , '39201004' , 'PWLFB2RWLNPX7' , 'franciscoe' , 'IT-010' 
*/

CREATE PROCEDURE [dbo].[PG_PR_MODIFICAR_ORDER_X_CAMBIO_NIVEL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN					VARCHAR(50),
	@PP_SERIAL					VARCHAR(50),
	@PP_ITEM_NO_NUEVO			VARCHAR(50),
	@PP_USER					VARCHAR(50),
	@PP_COMPUTER_NAME			VARCHAR(50)
AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	SET @PP_ITEM_NO_NUEVO = UPPER(@PP_ITEM_NO_NUEVO)

	-- ///////////RN VALIDACIONES////////////////////////////////
	IF SUBSTRING(@PP_ITEM_NO_NUEVO, 1, 1)  <> 'P'
		SET @VP_MENSAJE = 'El Item No (Pearl) que desea asignar no es valido.' 

	IF @VP_MENSAJE=''
		IF LEN(@PP_ITEM_NO_NUEVO)  <> 13
			SET @VP_MENSAJE = 'El Item No (Pearl) que desea asignar no es valido.' 

	IF @VP_MENSAJE=''
		BEGIN	
			DECLARE @VP_N_KIT_ANTERIOR INT = 0
			SELECT @VP_N_KIT_ANTERIOR = COUNT(col_key)
			FROM ccjoblin_sql (NOLOCK)
			WHERE	LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) = @PP_SERIAL

			IF @VP_N_KIT_ANTERIOR IS NULL OR @VP_N_KIT_ANTERIOR = 0
				SET @VP_MENSAJE = 'El serial que desea modificar no existe en la orden.'  
			
			IF @VP_MENSAJE=''
				IF @VP_N_KIT_ANTERIOR > 1
					SET @VP_MENSAJE = 'El serial que desea modificar existe mas de una vez en la orden.' 
		END

	IF @VP_MENSAJE=''
		BEGIN	
			DECLARE @VP_N_KIT_NUEVO INT = 0
			SELECT @VP_N_KIT_NUEVO = COUNT(A4GLIdentity)
			FROM	IMITMIDX_SQL (NOLOCK)
			WHERE LTRIM(RTRIM(item_no)) = @PP_ITEM_NO_NUEVO

			IF @VP_N_KIT_NUEVO IS NULL OR @VP_N_KIT_NUEVO = 0
				SET @VP_MENSAJE = 'El Item No (Pearl) que desea asignar no existe en [IMITMIDX_SQL].'  
			
			IF @VP_MENSAJE=''
				IF @VP_N_KIT_NUEVO > 1
					SET @VP_MENSAJE = 'El Item No (Pearl) que desea asignar existe mas de una vez en [IMITMIDX_SQL].' 
		END

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY	
				-- ///////////SE DECLARAN VARIABLES///////////////////////////////////////////////////
				DECLARE @VP_CLIENTE_ANTERIOR VARCHAR(20)= '', @VP_MODELO_ANTERIOR VARCHAR(10) = '', @VP_ITEM_NO_ANTERIOR VARCHAR(100) = '';
				DECLARE @VP_NETO_ANTERIOR DECIMAL(13,4) = 0, @VP_GROSS_ANTERIOR DECIMAL(13,4) = 0, @VP_PATRON_ANTERIOR INT = 0;
				DECLARE @VP_CLIENTE_NUEVO VARCHAR(20)= '', @VP_MODELO_NUEVO VARCHAR(10) = '', @VP_D_ITEM_NUEVO VARCHAR(255);
				DECLARE @VP_NETO_NUEVO DECIMAL(13,4) = 0, @VP_GROSS_NUEVO DECIMAL(13,4) = 0, @VP_PATRON_NUEVO INT = 0;

				-- ///////////SE OBTIENEN LOS DATOS DEL KIT ANTERIOR///////////////////////////////////////////////////
				SELECT  @VP_CLIENTE_ANTERIOR = LTRIM(RTRIM(customer)),
						@VP_MODELO_ANTERIOR = LTRIM(RTRIM(ChangeLevel)),
						@VP_ITEM_NO_ANTERIOR = LTRIM(RTRIM(Item_No)),
						@VP_NETO_ANTERIOR = netsqmper,
						@VP_GROSS_ANTERIOR = stdsqmper,
						@VP_PATRON_ANTERIOR = patternsper
				FROM ccjoblin_sql (NOLOCK)
				WHERE	LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) = @PP_SERIAL

				-- ///////////SE OBTIENEN LOS DATOS DEL KIT NUEVO///////////////////////////////////////////////////
				SELECT  TOP 1 
						@VP_CLIENTE_NUEVO = LTRIM(RTRIM(user_def_fld_1)),
						@VP_MODELO_NUEVO = LTRIM(RTRIM(last_item_revision)),
						@VP_NETO_NUEVO = cube_width,
						@VP_GROSS_NUEVO = cube_length,
						@VP_PATRON_NUEVO = cube_qty_per,
						@VP_D_ITEM_NUEVO = LTRIM(RTRIM(item_desc_1))
				FROM	IMITMIDX_SQL (NOLOCK)
				WHERE LTRIM(RTRIM(item_no)) = @PP_ITEM_NO_NUEVO

				IF ( @VP_CLIENTE_ANTERIOR <> @VP_CLIENTE_NUEVO)
					RAISERROR ('ERROR: Los Kits no pertenecen al mismo Cliente.', 16, 1 ) --MENSAJE - Severity -State.
				
				IF ( SUBSTRING(@VP_MODELO_ANTERIOR, 1, 3) <> SUBSTRING(@VP_MODELO_NUEVO, 1, 3) )
					RAISERROR ('ERROR: Los Kits no pertenecen al mismo Modelo.', 16, 1 ) --MENSAJE - Severity -State.

				--IF ( @VP_NETO_ANTERIOR <> @VP_NETO_NUEVO OR @VP_GROSS_ANTERIOR <> @VP_GROSS_NUEVO OR @VP_PATRON_ANTERIOR <> @VP_PATRON_NUEVO)
				--	RAISERROR ('ERROR: Los Kits no son iguales en cantidad (Neto, Gross o Patrones).', 16, 1 ) --MENSAJE - Severity -State.
				
				-- ///////////SI EL SERIAL YA ESTA EN PRODUCTO TERMINADO SE BORRA///////////////////////////////////////////////////
				DECLARE @VP_N_SERIAL_MFP INT = 0
				SELECT @VP_N_SERIAL_MFP = COUNT(K_INVENTARIO_EMBARQUE) 
				FROM [INVENTARIO_EMBARQUE] (NOLOCK)
				WHERE SERIAL_1 = @PP_SERIAL
				
				IF @VP_N_SERIAL_MFP IS NULL
					SET @VP_N_SERIAL_MFP = 0

				IF @VP_N_SERIAL_MFP > 1
					RAISERROR ('ERROR: El serial se encuentra Duplicado en [INVENTARIO_EMBARQUE]', 16, 1 ) --MENSAJE - Severity -State.

				IF @VP_N_SERIAL_MFP > 0
					BEGIN
						DECLARE @VP_ESTATUS_INVENTARIO_EMBARQUE INT = 0
						SELECT @VP_ESTATUS_INVENTARIO_EMBARQUE = K_ESTATUS_INVENTARIO_EMBARQUE
						FROM [INVENTARIO_EMBARQUE] (NOLOCK)
						WHERE SERIAL_1 = @PP_SERIAL

						IF @VP_ESTATUS_INVENTARIO_EMBARQUE <> 1
							RAISERROR ('ERROR: No es posible Eliminar el serial de [INVENTARIO_EMBARQUE] el Estatus no lo permite', 16, 1 ) --MENSAJE - Severity -State.

						DELETE	[INVENTARIO_EMBARQUE] 
						WHERE SERIAL_1 = @PP_SERIAL

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Eliminar el serial de [INVENTARIO_EMBARQUE]', 16, 1 ) --MENSAJE - Severity -State.
					END

				-- ///////////SI EL SERIAL YA PASO POR LA ESTACION DE QC LIBERA SE BORRA///////////////////////////////////////////////////
				DECLARE @VP_N_SERIAL_QC_LIBERA INT = 0
				SELECT @VP_N_SERIAL_QC_LIBERA = COUNT(ID) 
				FROM QCLIBERA_SQL  (NOLOCK)
				WHERE  SERIAL = @PP_SERIAL
				
				IF @VP_N_SERIAL_QC_LIBERA IS NULL
					SET @VP_N_SERIAL_QC_LIBERA = 0

				IF @VP_N_SERIAL_QC_LIBERA > 0
					BEGIN
						DELETE QCLIBERA_SQL  
						WHERE  SERIAL = @PP_SERIAL

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Eliminar el serial de [QCLIBERA_SQL]', 16, 1 ) --MENSAJE - Severity -State.
					END

				DECLARE @VP_KIT VARCHAR(10) = SUBSTRING(@PP_ITEM_NO_NUEVO, 1, 7)

				UPDATE ccjoblin_sql 
					SET KIT = @VP_KIT,
						Item_No = @PP_ITEM_NO_NUEVO,
						KITDESC = @VP_D_ITEM_NUEVO,
						ChangeLevel = @VP_MODELO_NUEVO
				WHERE	customer = @VP_CLIENTE_ANTERIOR
				AND Item_No = @VP_ITEM_NO_ANTERIOR
				AND ChangeLevel = @VP_MODELO_ANTERIOR
				AND LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) = @PP_SERIAL
			
				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Actualizar el serial en [ccjoblin_sql]', 16, 1 ) --MENSAJE - Severity -State.		

				-- /////////////////////////INGRESO EL LOG EN PEARL_LOG////////////////////////////////////////////
				DECLARE @VP_DETAIL VARCHAR(100) = 'Serial: ' + @PP_SERIAL + ' Item No Old: ' + @VP_ITEM_NO_ANTERIOR + ' Mod: ' + @VP_MODELO_ANTERIOR + ' A ' + @PP_ITEM_NO_NUEVO + ' Mod: ' + @VP_MODELO_NUEVO
				EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@PP_USER, @PP_COMPUTER_NAME, 'Label',
													@PP_ORDEN,'Modificar orden',
													@VP_DETAIL, ''
				
				-- /////////////////////////INGRESO EL LOG EN [MATERIAL_PROGRAMADO_LOG]////////////////////////////////////////////
				INSERT INTO [MATERIAL_PROGRAMADO_LOG]	
										(					
											[K_TIPO_EVENTO_KIT],			
											-- =====================				
											[SERIAL],					
											[ITEM_NO],				
											[USUARIO_EVENTO],			
											[ESTACION],				
											[K_RESPONSABLE],			
											[CODIGO_ETIQUETA],		
											[F_LOG],			
											-- ===========================
											[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
											[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
									VALUES	
										(	3,	-- CAMBIO DE NIVEL
											@PP_SERIAL,				
											@PP_ITEM_NO_NUEVO,				
											'CAMBIO_NIVEL',			
											@PP_COMPUTER_NAME,						
											@PP_K_USUARIO_ACCION,		
											@VP_DETAIL,								
											GETDATE(),
											-- ===========================				
											@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
											0, NULL, NULL )	
							
				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible guardar el Log del Cambio de Nivel en [PG_IN_MATERIAL_PROGRAMADO_LOG]', 16, 1 ) --MENSAJE - Severity -State.

			-- ///////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PR_MODIFICAR_ORDER_X_CAMBIO_NIVEL] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Actualizar el Serial: ' + '[' + @PP_SERIAL +'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_ORDEN AS CLAVE
	
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
	--												0, 0, @PP_ORDEN, '' , 0.00, 0.00,
	--												-- === @PP_VALOR_1 al 6_DATO
	--												'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
