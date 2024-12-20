USE [PAP_LIVE_Branch]
GO
/****** Object:  StoredProcedure [dbo].[CIS_WIP_ItemWise_04032021]    Script Date: 12/11/2024 3:26:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--   CIS_WIP_ItemWise_04032021 '177.212.2-WIP'
--   CIS_WIP_ItemWise_04032021 '5800130002-WIP' 

ALTER PROCEDURE [dbo].[CIS_WIP_ItemWise_04032021]
(
 @ItemCode NVARCHAR(100)
)
AS 
BEGIN
 SET NOCOUNT ON
  

CREATE TABLE  #ProductionTable 
(
   ID INTEGER IDENTITY(1,1) NOT NULL ,
   RankNo INTEGER ,
   DocNum NVARCHAR(100) ,
   ItemCode NVARCHAR(100) ,  
   SeqNum  INTEGER , 
   StageName NVARCHAR(100) , 
   INQTY DECIMAL(18,2) NULL , 
   OUTQTY DECIMAL(18,2) NULL , 
   STOCKQTY DECIMAL(18,2) NULL , 
   LocCode NVARCHAR(100) NULL 
) 

INSERT INTO #ProductionTable(RankNo , DocNum , ItemCode , SeqNum , StageName , INQTY ,OUTQTY , STOCKQTY , LocCode)
SELECT RANK () OVER (Order By A.BlockNum) AS RankNo, A.BlockNum [DocNum] , A.ItemCode  [ItemCode] , U_RoutSeq [SeqNum] , U_Routing  [StageName], Quantity  [INQTY], Quantity1 [OUTQTY] , OpenQty [STOCKQTY] , WhsCode [LocCode] 
	FROM(
			SELECT 'GR' 'Type',T0.DocNum,T1.ItemCode,T1.BlockNum,T1.Quantity 'Quantity', 0 as 'Quantity1',T1.OpenQty,T1.WhsCode,T2.U_Routing, T1.U_RoutSeq, 
			T3.U_PrimeProcess 
			FROM OIGN T0
			INNER JOIN IGN1 T1 ON T0.DocEntry = T1.DocEntry 
			INNER JOIN OWHS T2 ON T1.WhsCode = T2.WhsCode
			INNER JOIN ORST T3 ON T2.U_Routing = T3.Code
			WHERE T1.ItemCode = @ItemCode
			--AND T1.BlockNum = '2021118402' 

			UNION ALL

			SELECT 'IT' 'Type', T0.DocNum,T1.ItemCode,T1.BlockNum,T1.Quantity 'Quantity', 0 as 'Quantity1',T1.OpenQty,T1.WhsCode,T2.U_Routing, T1.U_RoutSeq,
			T3.U_PrimeProcess
			FROM OWTR T0
			INNER JOIN WTR1 T1 ON T0.DocEntry = T1.DocEntry 
			INNER JOIN OWHS T2 ON T1.WhsCode = T2.WhsCode
			INNER JOIN ORST T3 ON T2.U_Routing = T3.Code	
		    WHERE T1.ItemCode = @ItemCode
			--AND  T1.BlockNum = '2021118402' 
	  )A  --WHERE U_Routing NOT IN ('FINAL ACCOUTING','FINAL QUALITY')  --AND U_PrimeProcess ='N' AND OpenQty > 0
	  
	  ORDER BY BlockNum, U_RoutSeq  

/* INSERT DATA INTO Second Table */

	SELECT DISTINCT  RANKNO , DocNum ,ItemCode ,SeqNum , StageName , STOCKQTY , LocCode
	INTO #FinalProductionTable
	FROM #ProductionTable WHERE SeqNum > 0	
	UPDATE #FinalProductionTable SET STOCKQTY = 0 where StageName = 'TURNING'

/* INSERT DATA INTO Second Table */


/*FirstLoppVariable*/
	DECLARE @MinIDProductionNumber INTEGER 
	DECLARE @ProductionNumber NVARCHAR(100)

	DECLARE @MaxAccountingID INTEGER 
	DECLARE @MaxQualityID INTEGER 
/*END*/
/*SecondLoopVariable*/

	DECLARE @StageName NVARCHAR(100)
	DECLARE @AddQty DECIMAL(18,2) = 0 
	DECLARE @MAXID INTEGER 
/*END*/


SELECT @MinIDProductionNumber = MIN(RANKNO) FROM #FinalProductionTable
WHILE ISNULL(@MinIDProductionNumber,0) > 0
BEGIN

     SELECT @ProductionNumber = MIN(DocNum) FROM #FinalProductionTable WHERE RANKNO = @MinIDProductionNumber
	 
	/*Second Loop*/

	SELECT  @MAXID = Max(SeqNum) FROM #FinalProductionTable WHERE DocNum =@ProductionNumber
	WHILE ISNULL(@MAXID,0) > 0 
	BEGIN

	   SELECT @StageName = StageName , @AddQty = ISNULL(STOCKQTY,0) 
	   FROM #FinalProductionTable
	   WHERE DocNum =@ProductionNumber  AND SeqNum = @MAXID

	   IF (ISNULL(@StageName,'') = 'ACCOUNTING' OR ISNULL(@StageName,'') = 'QUALITY')
	   BEGIN
      
		  UPDATE #FinalProductionTable SET STOCKQTY = ISNULL(STOCKQTY,0) + @AddQty WHERE  DocNum =@ProductionNumber AND SeqNum = @MAXID- 1 
		  UPDATE #FinalProductionTable SET STOCKQTY = 0 WHERE  DocNum =@ProductionNumber AND SeqNum = @MAXID 	  
		  SET @MAXID = @MAXID-1
	   END 
	   ELSE
		SET @MAXID = @MAXID-1

	END -- Second Loop End


 SELECT @MinIDProductionNumber = MIN(RANKNO) FROM #FinalProductionTable WHERE RANKNO > @MinIDProductionNumber
END -- SECOND Loop End

	DECLARE @FinalTable TABLE
	(
	   ID INTEGER IDENTITY(1,1) NOT NULL ,
	   ItemCode NVARCHAR(100)  NULL , 
	   StageName NVARCHAR(100) NULL , 
	   WhsCode   NVARCHAR(100) NULL ,
	   Quantity  DECIMAL(18,2) NULL , 
	   Price     DECIMAL(18,2) NULL ,
	   Location  NVARCHAR(100) NULL  , 
	   U_PrntSeq  INTEGER NULL , 
	   AbsEntry  INTEGER NULL ,  
	   U_PrimeProcess CHAR  
	)

	INSERT INTO @FinalTable(ItemCode , StageName , WhsCode  , Quantity )
	SELECT  DISTINCT  ItemCode ,StageName , MAX(LocCode) , SUM(ISNULL(STOCKQTY,0)) [STOCKQTY]
	FROM #FinalProductionTable
	WHERE ISNULL(STOCKQTY,0) > 0
	GROUP BY ItemCode ,StageName 


	
	 /*Update Turning Quantity FROM OITW - Start*/

		UPDATE @FinalTable SET Quantity = B.OnHand
		FROM @FinalTable A INNER JOIN OITW B ON A.ItemCode = B.ItemCode AND A.WhsCode = B.WhsCode 
		WHERE A.StageName = 'FINAL ACCOUTING'

		UPDATE @FinalTable SET Quantity = B.OnHand
		FROM @FinalTable A INNER JOIN OITW B ON A.ItemCode = B.ItemCode AND A.WhsCode = B.WhsCode 
		WHERE A.StageName = 'FINAL QUALITY'

		UPDATE @FinalTable SET Quantity = ISNULL(Quantity,0) + ISNULL(B.OnHand,0)
		FROM @FinalTable A INNER JOIN OITW B ON A.ItemCode = B.ItemCode AND A.WhsCode = B.WhsCode 
		WHERE A.StageName = 'TURNING'

	 /*END*/

 	/* Update U_PrntSeq Entry For Report Printing Process */

	  UPDATE @FinalTable SET U_PrntSeq = B.U_PrntSeq , AbsEntry = B.AbsEntry , U_PrimeProcess = B.U_PrimeProcess
	  FROM @FinalTable A INNER JOIN ORST(NOLOCK) B ON A.StageName = B.Code

    /*END*/


	/* Final Query*/
	 SELECT T2.U_customercode AS 'Customer No.'  --, (SELECT T00.BPLName FROM OBPL T00 (NOLOCK) WHERE T00.BPLId = @Loc) AS Location 
	 --, T2.U_customercode AS 'Customer No.' 
	   ,(SELECT TOP 1 IT03.FrgnName 
				FROM ITT1 IT01 (NOLOCK) 
				INNER JOIN OITT IT02 (NOLOCK) ON IT02.Code = IT01.Father
				INNER JOIN OITM IT03 (NOLOCK) ON IT03.ItemCode = IT02.Code
				WHERE IT01.Code = T1.ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS) AS 'Ass. No.'
	   ,	ISNULL((SELECT SUM((ISNULL(T01.INQTY, 0) - ISNULL(T01.OUTQTY, 0))) 
						FROM OINM T01 (NOLOCK)
						WHERE T01.Warehouse = 'FG'
						AND T01.ItemCode = (SELECT TOP 1 IT03.FrgnName 
												FROM ITT1 IT01 (NOLOCK) 
												INNER JOIN OITT IT02 (NOLOCK) ON IT02.Code = IT01.Father
												INNER JOIN OITM IT03 (NOLOCK) ON IT03.ItemCode = IT02.Code
												WHERE IT01.Code = T1.ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS)), 0)  
			AS 'FG Stock (in FG Whs.)'
	   ,ISNULL((SELECT SUM((ISNULL(T01.INQTY, 0) - ISNULL(T01.OUTQTY, 0))) 
						FROM OINM T01 (NOLOCK)
						WHERE T01.Warehouse = 'FG'
						AND T01.ItemCode = (SELECT TOP 1 IT02.Code
												FROM ITT1 IT01 (NOLOCK) 
												INNER JOIN OITT IT02 (NOLOCK) ON IT02.Code = IT01.Father
												--INNER JOIN OITM IT03 (NOLOCK) ON IT03.ItemCode = IT02.Code
												WHERE IT01.Code = T1.ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS)), 0) 
			AS 'Stock (in FG Whs.)' 
	 ,T1.*  
	 FROM 
		(
			   SELECT ItemCode 
			   ,SUM(ISNULL([TURNING_Qty],0)) [TURNING_Qty] ,  SUM(ISNULL([TURNING_Price],0)) [TURNING_Price] 
			   ,SUM(ISNULL([HOBBING_Qty],0)) [HOBBING_Qty] , SUM(ISNULL([HOBBING_Price],0)) [HOBBING_Price] 
			   ,SUM(ISNULL([DRILLING_Qty],0)) [DRILLING_Qty] , SUM(ISNULL([DRILLING_Price],0)) [DRILLING_Price]
			   ,SUM(ISNULL([STRAIGHT_Qty],0)) [STRAIGHT_Qty] , SUM(ISNULL([STRAIGHT_Price],0)) [STRAIGHT_Price]
			   ,SUM(ISNULL([ANEALING_Qty],0)) [ANEALING_Qty] , SUM(ISNULL([ANEALING_Price],0)) [ANEALING_Price]
			   ,SUM(ISNULL([SAND BLASTING_Qty],0)) [SAND BLASTING_Qty]  ,SUM(ISNULL([SAND BLASTING_Price],0)) [SAND BLASTING_Price]
			   ,SUM(ISNULL([CARBURIZING_Qty],0)) [CARBURIZING_Qty]    ,SUM(ISNULL([CARBURIZING_Price],0)) [CARBURIZING_Price]
			   ,SUM(ISNULL([HEAT TREATMENT_Qty],0)) [HEAT TREATMENT_Qty] ,SUM(ISNULL([HEAT TREATMENT_Price],0)) [HEAT TREATMENT_Price] 
			   ,SUM(ISNULL([TEMPERING_Qty],0)) [TEMPERING_Qty]  ,SUM(ISNULL([TEMPERING_Price],0)) [TEMPERING_Price]
			   ,SUM(ISNULL([POLISHING_Qty],0)) [POLISHING_Qty]  ,SUM(ISNULL([POLISHING_Price],0)) [POLISHING_Price]
			   ,SUM(ISNULL([CENTRELESS GRINDING_Qty],0)) [CENTRELESS GRINDING_Qty] ,SUM(ISNULL([CENTRELESS GRINDING_Price],0)) [CENTRELESS GRINDING_Price]
			   ,SUM(ISNULL([MILLING/SLOTTING_Qty],0)) [MILLING/SLOTTING_Qty]   ,SUM(ISNULL([MILLING/SLOTTING_Price],0)) [MILLING/SLOTTING_Price]
			   ,SUM(ISNULL([BACK DRILLING/BORING/SLITTING_Qty],0)) [BACK DRILLING/BORING/SLITTING_Qty] ,SUM(ISNULL([BACK DRILLING/BORING/SLITTING_Price],0)) [BACK DRILLING/BORING/SLITTING_Price]
			   ,SUM(ISNULL([EDM/WIRE EDM_Qty],0)) [EDM/WIRE EDM_Qty] ,SUM(ISNULL([EDM/WIRE EDM_Price],0)) [EDM/WIRE EDM_Price]
			   ,SUM(ISNULL([HUGI/SURFACE GRINDING_Qty],0))  [HUGI/SURFACE GRINDING_Qty] ,SUM(ISNULL([HUGI/SURFACE GRINDING_Price],0))  [HUGI/SURFACE GRINDING_Price]
			   ,SUM(ISNULL([BURNISHING/SALLAZE_Qty],0)) [BURNISHING/SALLAZE_Qty] ,SUM(ISNULL([BURNISHING/SALLAZE_Price],0)) [BURNISHING/SALLAZE_Price]
			   ,SUM(ISNULL([HONNING_Qty],0)) [HONNING_Qty] ,SUM(ISNULL([HONNING_Price],0)) [HONNING_Price]
			   ,SUM(ISNULL([LAPPING/TAPPING/BUFFING_Qty],0)) [LAPPING/TAPPING/BUFFING_Qty]  ,SUM(ISNULL([LAPPING/TAPPING/BUFFING_Price],0)) [LAPPING/TAPPING/BUFFING_Price]
			   ,SUM(ISNULL([CHAMFERING/PIP REMOVING_Qty],0)) [CHAMFERING/PIP REMOVING_Qty]   ,SUM(ISNULL([CHAMFERING/PIP REMOVING_Price],0)) [CHAMFERING/PIP REMOVING_Price]
			   ,SUM(ISNULL([LASER MARKING_Qty],0)) [LASER MARKING_Qty]  ,SUM(ISNULL([LASER MARKING_Price],0)) [LASER MARKING_Price]
			   ,SUM(ISNULL([LASER WELDING_Qty],0)) [LASER WELDING_Qty] ,SUM(ISNULL([LASER WELDING_Price],0)) [LASER WELDING_Price]
			   ,SUM(ISNULL([ASSEMBLY/PUNCHING_Qty],0)) [ASSEMBLY/PUNCHING_Qty] ,SUM(ISNULL([ASSEMBLY/PUNCHING_Price],0)) [ASSEMBLY/PUNCHING_Price]
			   ,SUM(ISNULL([SOLDERING_Qty],0)) [SOLDERING_Qty] ,SUM(ISNULL([SOLDERING_Price],0)) [SOLDERING_Price]
			   ,SUM(ISNULL([GOLD PLATING (JW)_Qty],0))  [GOLD PLATING (JW)_Qty] ,SUM(ISNULL([GOLD PLATING (JW)_Price],0))  [GOLD PLATING (JW)_Price]
			   ,SUM(ISNULL([NICKEL/ELECTROLESS PLATING (JW)_Qty],0)) [NICKEL/ELECTROLESS PLATING (JW)_Qty]    ,SUM(ISNULL([NICKEL/ELECTROLESS PLATING (JW)_Price],0)) [NICKEL/ELECTROLESS PLATING (JW)_Price]
			   ,SUM(ISNULL([TIN PLATING (JW)_Qty],0)) [TIN PLATING (JW)_Qty] ,SUM(ISNULL([TIN PLATING (JW)_Price],0)) [TIN PLATING (JW)_Price]
			   ,SUM(ISNULL([ZINC PLATING (JW)_Qty],0)) [ZINC PLATING (JW)_Qty] ,SUM(ISNULL([ZINC PLATING (JW)_Price],0)) [ZINC PLATING (JW)_Price]
			   ,SUM(ISNULL([CHROME PLATING (JW)_Qty],0)) [CHROME PLATING (JW)_Qty]  ,SUM(ISNULL([CHROME PLATING (JW)_Price],0)) [CHROME PLATING (JW)_Price]
			   ,SUM(ISNULL([ANODIZING (JW)_Qty],0)) [ANODIZING (JW)_Qty] ,SUM(ISNULL([ANODIZING (JW)_Price],0)) [ANODIZING (JW)_Price]
			   ,SUM(ISNULL([PASSIVATION (JW)_Qty],0)) [PASSIVATION (JW)_Qty]  ,SUM(ISNULL([PASSIVATION (JW)_Price],0)) [PASSIVATION (JW)_Price]
			   ,SUM(ISNULL([PIERCING (JW)_Qty],0)) [PIERCING (JW)_Qty]   ,SUM(ISNULL([PIERCING (JW)_Price],0)) [PIERCING (JW)_Price]
			   ,SUM(ISNULL([PROFILE MILLING (JW)_Qty],0)) [PROFILE MILLING (JW)_Qty]  ,SUM(ISNULL([PROFILE MILLING (JW)_Price],0)) [PROFILE MILLING (JW)_Price]
			   ,SUM(ISNULL([WIRE CUTTING (JW)_Qty],0)) [WIRE CUTTING (JW)_Qty] ,SUM(ISNULL([WIRE CUTTING (JW)_Price],0)) [WIRE CUTTING (JW)_Price]
			   ,SUM(ISNULL([DISASSEMBLE_Qty],0)) [DISASSEMBLE_Qty] ,SUM(ISNULL([DISASSEMBLE_Price],0)) [DISASSEMBLE_Price]
			   ,SUM(ISNULL([FINAL QUALITY_Qty],0)) [FINAL QUALITY_Qty] ,SUM(ISNULL([FINAL QUALITY_Price],0)) [FINAL QUALITY_Price]
			   ,SUM(ISNULL([FINAL ACCOUTING_Qty],0)) [FINAL ACCOUTING_Qty] ,SUM(ISNULL([FINAL ACCOUTING_Price],0)) [FINAL ACCOUTING_Price]
			   FROM 
				   (
					   SELECT  ItemCode , StageName +'_Qty' AS [StageName]
					   , StageName + '_Price'  [StageName1]
					   ,  Quantity , Price 
					   FROM @FinalTable

					) ResultData 
				PIVOT (
					  MAX(Quantity)
					  FOR StageName in ([TURNING_Qty]
										,[HOBBING_Qty],[DRILLING_Qty] , [STRAIGHT_Qty] , [ANEALING_Qty] , [SAND BLASTING_Qty] , [CARBURIZING_Qty]
										,[HEAT TREATMENT_Qty] , [TEMPERING_Qty] ,[POLISHING_Qty] , [CENTRELESS GRINDING_Qty] ,[MILLING/SLOTTING_Qty] 
										,[BACK DRILLING/BORING/SLITTING_Qty],[EDM/WIRE EDM_Qty] , [HUGI/SURFACE GRINDING_Qty] , [BURNISHING/SALLAZE_Qty]
										,[HONNING_Qty] , [LAPPING/TAPPING/BUFFING_Qty],[CHAMFERING/PIP REMOVING_Qty],[LASER MARKING_Qty],[LASER WELDING_Qty]
										,[ASSEMBLY/PUNCHING_Qty],[SOLDERING_Qty],[GOLD PLATING (JW)_Qty] ,[NICKEL/ELECTROLESS PLATING (JW)_Qty]
										,[TIN PLATING (JW)_Qty]	,[ZINC PLATING (JW)_Qty],[CHROME PLATING (JW)_Qty],[ANODIZING (JW)_Qty] 
										, [PASSIVATION (JW)_Qty] , [PIERCING (JW)_Qty]
										,[PROFILE MILLING (JW)_Qty],[WIRE CUTTING (JW)_Qty],[DISASSEMBLE_Qty],[FINAL QUALITY_Qty],[FINAL ACCOUTING_Qty]
									   )
					) AS PivotTable
				PIVOT (
					  MAX(Price)
					  FOR StageName1 in ([TURNING_Price]
										,[HOBBING_Price],[DRILLING_Price] , [STRAIGHT_Price] , [ANEALING_Price] , [SAND BLASTING_Price] , [CARBURIZING_Price]
										,[HEAT TREATMENT_Price] , [TEMPERING_Price] ,[POLISHING_Price] , [CENTRELESS GRINDING_Price] ,[MILLING/SLOTTING_Price] 
										,[BACK DRILLING/BORING/SLITTING_Price],[EDM/WIRE EDM_Price] , [HUGI/SURFACE GRINDING_Price] , [BURNISHING/SALLAZE_Price]
										,[HONNING_Price] , [LAPPING/TAPPING/BUFFING_Price],[CHAMFERING/PIP REMOVING_Price],[LASER MARKING_Price],[LASER WELDING_Price]
										,[ASSEMBLY/PUNCHING_Price],[SOLDERING_Price],[GOLD PLATING (JW)_Price] ,[NICKEL/ELECTROLESS PLATING (JW)_Price]
										,[TIN PLATING (JW)_Price]	,[ZINC PLATING (JW)_Price],[CHROME PLATING (JW)_Price],[ANODIZING (JW)_Price] 
										, [PASSIVATION (JW)_Price] , [PIERCING (JW)_Price]
										,[PROFILE MILLING (JW)_Price],[WIRE CUTTING (JW)_Price],[DISASSEMBLE_Price],[FINAL QUALITY_Price],[FINAL ACCOUTING_Price]
									   )
					) AS PivotTable

			GROUP BY ItemCode
	) AS T1 
	INNER JOIN OITM(NOLOCK) T2 ON T1.ItemCode = T2.ItemCode
	ORDER BY T1.ItemCode DESC

 DROP TABLE #ProductionTable
 DROP TABLE #FinalProductionTable


  SET NOCOUNT OFF
END
