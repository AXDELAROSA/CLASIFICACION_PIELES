-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	PEARL19_V9999_R0
-- // MODULO:			PIEL_LOTE
-- // OPERACION:		LIBERACION / CARGA INICIAL
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	18/DIC/2019
-- ////////////////////////////////////////////////////////////// 

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> CARGA INICIAL
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_PIEL_LOTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_PIEL_LOTE]
GO


CREATE PROCEDURE [dbo].[PG_CI_PIEL_LOTE]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ========================================
	@PP_K_PIEL_LOTE				INT,			
	@PP_D_PIEL_LOTE				VARCHAR(100),
	@PP_S_PIEL_LOTE				VARCHAR(10),
	@PP_O_PIEL_LOTE				INT,
	@PP_C_PIEL_LOTE				VARCHAR(255),
	-- ========================================
	@PP_K_ESTATUS_PIEL_LOTE		INT,
	@PP_K_TIPO_PIEL_LOTE		INT,
	@PP_PIEL_LOTE_CANTIDAD		INT
AS
	
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_PIEL_LOTE
							FROM	[PIEL_LOTE]
							WHERE	K_PIEL_LOTE=@PP_K_PIEL_LOTE

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO [PIEL_LOTE]	
			(	[K_PIEL_LOTE], [D_PIEL_LOTE],
				[S_PIEL_LOTE], [O_PIEL_LOTE],
				[C_PIEL_LOTE], 
				[K_ESTATUS_PIEL_LOTE],
				[K_TIPO_PIEL_LOTE],
				[PIEL_LOTE_CANTIDAD],
			-- ============================================
				[K_USUARIO_ALTA], [F_ALTA], 
				[K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )		
		VALUES	
			(	@PP_K_PIEL_LOTE, @PP_D_PIEL_LOTE,
				@PP_S_PIEL_LOTE, 1, 
				@PP_C_PIEL_LOTE,
				@PP_K_ESTATUS_PIEL_LOTE,
				@PP_K_TIPO_PIEL_LOTE,						
				@PP_PIEL_LOTE_CANTIDAD,
			-- ============================================
				@PP_K_USUARIO_ACCION, GETDATE(), 
				@PP_K_USUARIO_ACCION, GETDATE(),
				0, NULL, NULL )		
	ELSE
		UPDATE	PIEL_LOTE
		SET		
				[K_PIEL_LOTE]					= @PP_K_PIEL_LOTE,			
				[D_PIEL_LOTE]					= @PP_D_PIEL_LOTE,					
				[S_PIEL_LOTE]					= @PP_S_PIEL_LOTE,					
				[C_PIEL_LOTE]					= @PP_C_PIEL_LOTE,		
				[K_ESTATUS_PIEL_LOTE]			= @PP_K_ESTATUS_PIEL_LOTE,
				[K_TIPO_PIEL_LOTE]				= @PP_K_TIPO_PIEL_LOTE,
				[PIEL_LOTE_CANTIDAD]			= @PP_PIEL_LOTE_CANTIDAD,
			-- ===========================
				[K_USUARIO_CAMBIO]					= @PP_K_USUARIO_ACCION, 
				[F_CAMBIO]							= GETDATE() 
		WHERE	K_PIEL_LOTE=@PP_K_PIEL_LOTE
	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////


-- ===============================================
SET NOCOUNT ON
-- ===============================================
-- SELECT * FROM PIEL_LOTE

EXECUTE [dbo].[PG_CI_PIEL_LOTE] 0, 0, 0, 1, 'PJL2RC4MCKVT9', 'CKVT9' , 1 , '#1 // PJL2RC4MCKVT9' ,1,1,250;
EXECUTE [dbo].[PG_CI_PIEL_LOTE] 0, 0, 0, 2, 'PJL2RC4MCKVT10', 'KVT10' , 1 , '#2 // PJL2RC4MCKVT10' ,1,1,300;
EXECUTE [dbo].[PG_CI_PIEL_LOTE] 0, 0, 0, 3, 'PJL2RC4MCKVT11', 'KVT11' , 1 , '#3 // PJL2RC4MCKVT11' ,1,2,280;
EXECUTE [dbo].[PG_CI_PIEL_LOTE] 0, 0, 0, 4, 'PJL2RC4MCKVT12', 'KVT12' , 1 , '#4 // PJL2RC4MCKVT12' ,1,1,250;
EXECUTE [dbo].[PG_CI_PIEL_LOTE] 0, 0, 0, 5, 'PJL2RC4MCKVT13', 'KVT13' , 1 , '#5 // PJL2RC4MCKVT13' ,1,1,270;
EXECUTE [dbo].[PG_CI_PIEL_LOTE] 0, 0, 0, 6, 'PJL2RC4MCKVT14', 'KVT14' , 1 , '#6 // PJL2RC4MCKVT14' ,1,3,300;
EXECUTE [dbo].[PG_CI_PIEL_LOTE] 0, 0, 0, 7, 'PJL2RC4MCKVT15', 'KVT15' , 1 , '#7 // PJL2RC4MCKVT15' ,1,1,250;
EXECUTE [dbo].[PG_CI_PIEL_LOTE] 0, 0, 0, 8, 'PJL2RC4MCKVT16', 'KVT16' , 1 , '#8 // PJL2RC4MCKVT16' ,1,2,300;
EXECUTE [dbo].[PG_CI_PIEL_LOTE] 0, 0, 0, 9, 'PJL2RC4MCKVT17', 'KVT17' , 1 , '#9 // PJL2RC4MCKVT17' ,1,1,280;
EXECUTE [dbo].[PG_CI_PIEL_LOTE] 0, 0, 0, 10, 'PJL2RC4MCKVT18', 'KVT18' , 1 , '#10 // PJL2RC4MCKVT18' ,1,3,250;


GO

-- ===============================================
SET NOCOUNT OFF
-- ===============================================



GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
