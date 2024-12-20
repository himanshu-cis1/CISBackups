USE [Novateur]
GO
/****** Object:  StoredProcedure [dbo].[CIS_PROC_PRI_Calculation]    Script Date: 17/12/2024 3:30:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXEC [CIS_PROC_PRI_Calculation] 15005147, 15005147, '20200103', '20200103' 
ALTER PROC [dbo].[CIS_PROC_PRI_Calculation] (@FRM_RFP INT, @TO_RFP INT, @Frm_RFP_DT VARCHAR(20), @To_RFP_DT VARCHAR(20))
AS
BEGIN

	--===========================================================================================================================================================================
	-- Creating temp table
	--===========================================================================================================================================================================
	CREATE TABLE #Temp_ProdDetails_WithChildComponents (ProdDE INT, PRODNo INT, RFPDE INT, RFPNo INT
	, FGItem VARCHAR(100) COLLATE DATABASE_DEFAULT, RMItem VARCHAR(100)  COLLATE DATABASE_DEFAULT
	, Quantity DECIMAL(19, 6), TotalIssuedQty DECIMAL(19, 6), TotalIssuedCost DECIMAL(19, 6)
	, IssuedPerQty DECIMAL(19, 6), RMBaseQty DECIMAL(19, 6), BasicBomCost DECIMAL(19, 2))

	CREATE TABLE #Temp_ProdDetails_WithSecondChildComponents (ProdDE INT, PRODNo INT, RFPDE INT, RFPNo INT
	, FGItem VARCHAR(100) COLLATE DATABASE_DEFAULT, RMItem VARCHAR(100)  COLLATE DATABASE_DEFAULT
	, TotalIssuedQty DECIMAL(19, 6), TotalIssuedCost DECIMAL(19, 6), BasicBomCost DECIMAL(19, 6))

	CREATE TABLE #Temp_PRIDetails (ProdDE INT, PRODNo INT, RFPDE INT, RFPNo INT
	, FGItem VARCHAR(100) COLLATE DATABASE_DEFAULT, BasicBomCost DECIMAL(19, 6)
	, NBIType VARCHAR(100), NBIValue DECIMAL(19, 6),AddedValueType VARCHAR(100)
	, AddedValue DECIMAL(19, 6), PRI DECIMAL(19, 6))
	--===========================================================================================================================================================================

	--===========================================================================================================================================================================
	-- Inserting BOM Details
	--===========================================================================================================================================================================
	INSERT INTO #Temp_ProdDetails_WithChildComponents (ProdDE, PRODNo, RFPDE, RFPNo, FGItem, RMItem
	, RMBaseQty, TotalIssuedCost, Quantity, TotalIssuedQty)
	SELECT T1.BaseEntry, T1.BaseRef, T0.DocEntry, T0.DocNum, T1.ItemCode, T2.ItemCode, (T2.PlannedQty / T4.PlannedQty) --T2.BaseQty
	, CASE WHEN ISNULL(T2.IssuedQty, 0.00) = 0.00 THEN  
					T3.LstEvlPric
		   ELSE 
				--(SELECT SUM(ISNULL(C0.StockPrice, 0.00) * C0.Quantity)   
				-- FROM IGE1 (NOLOCK) C0 
				-- WHERE C0.BaseEntry = T1.BaseEntry AND C0.BaseType = '202' AND C0.BaseLine = T2.LineNum) 

			(SELECT SUM(A.Total) -- (SUM(A.StockPrice) * SUM(A.Quantity))
				FROM 
					(SELECT C0.ItemCode, ISNULL(C0.StockPrice, 0.00) AS StockPrice, C0.Quantity, C0.BaseLine , ((-1) * ISNULL(C2.TransValue, 0.00)) AS Total
						FROM IGE1 (NOLOCK) C0 
						INNER JOIN OINM C2 ON C2.ITEMCODE = C0.ITEMCODE AND C2.CREATEDBY = C0.DOCENTRY AND C2.TRANSTYPE = C0.OBJTYPE AND C2.DocLineNum = C0.LINENUM
						WHERE C0.BaseEntry = T4.DocEntry AND C0.BaseType = '202' AND C0.ItemCode = T2.ItemCode
					UNION
					SELECT C0.ItemCode, ((-1) * ISNULL(C0.StockPrice, 0.00)) AS StockPrice, ((-1) * C0.Quantity) AS Quantity, C0.BaseLine,
					   ((-1) * ISNULL(C2.TransValue, 0.00)) AS Total
						FROM IGN1 (NOLOCK) C0 
						INNER JOIN OINM C2 ON C2.ITEMCODE = C0.ITEMCODE AND C2.CREATEDBY = C0.DOCENTRY AND C2.TRANSTYPE = C0.OBJTYPE AND C2.DocLineNum = C0.LINENUM
						WHERE C0.BaseEntry = T4.DocEntry AND C0.BaseType = '202' AND C0.ItemCode = T2.ItemCode
						AND C0.ItemCode NOT IN (SELECT TT.ItemCode FROM WOR1 TT WHERE ISNULL((T2.PlannedQty / T4.PlannedQty), 0) < 0 AND TT.DocEntry = T4.DocEntry)
					 ) A
					 WHERE A.BASELINE = T2.LINENUM
					 GROUP BY A.BaseLine
					-- HAVING (SUM(A.StockPrice) * SUM(A.Quantity)) > 0
					Having SUM(A.Total)>0
			)
	  END BOMPrice 
	, T1.Quantity, ISNULL(T2.IssuedQty, 0)
	FROM OIGN (NOLOCK) T0
	INNER JOIN IGN1 (NOLOCK) T1 ON T0.DocEntry = T1.DocEntry
	INNER JOIN WOR1 (NOLOCK) T2 ON T1.BaseEntry = T2.DocEntry 
	INNER JOIN OWOR (NOLOCK) T4 ON T4.DOCENTRY = T2.DOCENTRY AND T4.ITEMCODE = T1.ITEMCODE
	INNER JOIN OITM (NOLOCK) T3 ON T2.ItemCode = T3.ItemCode
	WHERE T1.BaseType = '202'
	AND T0.DocDate BETWEEN @Frm_RFP_DT AND @To_RFP_DT 
	AND (T0.DocNum >= ISNULL(@FRM_RFP, 0) OR  ISNULL(@FRM_RFP, 0) = 0)
	AND (T0.DocNum <= ISNULL(@TO_RFP, 0) OR  ISNULL(@TO_RFP, 0) = 0)
	--===========================================================================================================================================================================

	--===========================================================================================================================================================================
	UPDATE #Temp_ProdDetails_WithChildComponents
	SET IssuedPerQty = (ISNULL(TotalIssuedCost, 0) / ISNULL(TotalIssuedQty, 0))
	WHERE ISNULL(TotalIssuedQty, 0.00) <> 0
	
	UPDATE #Temp_ProdDetails_WithChildComponents
	SET IssuedPerQty = ISNULL(TotalIssuedCost, 0)
	WHERE ISNULL(TotalIssuedQty, 0.00) = 0
	
	UPDATE #Temp_ProdDetails_WithChildComponents
	SET BasicBomCost = ISNULL(RMBaseQty, 0) * ISNULL(IssuedPerQty, 0)
	--===========================================================================================================================================================================

	--===========================================================================================================================================================================
	-- Inserting Second Level BOM Details
	--===========================================================================================================================================================================
	--INSERT INTO #Temp_ProdDetails_WithChildComponents (ProdDE, PRODNo, RFPDE, RFPNo, FGItem, RMItem, BasicBomCost)
	--SELECT T0.ProdDE, T0.PRODNo, T0.RFPDE, T0.RFPNo, T1.Code, T2.Code
	--, CASE WHEN T4.OnHand = 0.00 THEN 
	--		T3.LstEvlPric 
	--	ELSE 
	--		(SELECT SUM(ISNULL(C0.CalcPrice, 0.00)) FROM OINM (NOLOCK) C0 WHERE C0.ItemCode = T2.Code AND C0.Warehouse = T2.wareHouse)
	--END BasicBomCost 
	--FROM #Temp_ProdDetails_WithChildComponents T0
	--INNER JOIN OITT T1 ON T0.RMItem = T1.Code
	--INNER JOIN ITT1 T2 ON T1.Code = T2.Father
	--INNER JOIN OITM (NOLOCK) T3 ON T2.Code = T3.ItemCode
	--INNER JOIN OITW (NOLOCK) T4 ON T4.ItemCode = T2.Code AND T4.WhsCode = T2.wareHouse
	--===========================================================================================================================================================================

	--===========================================================================================================================================================================
	-- Inserting data into PRI Table
	--===========================================================================================================================================================================
	INSERT INTO #Temp_PRIDetails (ProdDE, PRODNo, RFPDE, RFPNo, FGItem, BasicBomCost)
	SELECT DISTINCT ProdDE, PRODNo, RFPDE, RFPNo, FGItem
	, SUM(ISNULL(BasicBomCost, 0.00)) --* ISNULL(T0.Quantity, 0.00))
	FROM #Temp_ProdDetails_WithChildComponents T0
	GROUP BY ProdDE, PRODNo, RFPDE, RFPNo, FGItem
	--===========================================================================================================================================================================

	--===========================================================================================================================================================================
	-- Updating NBI & AV type and value
	--===========================================================================================================================================================================
	UPDATE T0
	SET NBIType = CASE WHEN ISNULL(T1.Code, '') <> '' AND (ISNULL(T1.U_NBIVal, 0.00) <> 0 OR ISNULL(T1.U_AVVal, 0.00) <> 0)  THEN 
								T1.U_NBIType 
					   ELSE 
								T2.U_NBIType 
				   END	
	, NBIValue = CASE WHEN ISNULL(T1.Code, '') <> '' AND (ISNULL(T1.U_NBIVal, 0.00) <> 0 OR ISNULL(T1.U_AVVal, 0.00) <> 0) THEN 
								ISNULL(T1.U_NBIVal, 0)
					  ELSE 
								ISNULL(T2.U_NBIVal, 0)
				  END
	, AddedValueType = CASE WHEN ISNULL(T1.Code, '') <> '' AND (ISNULL(T1.U_NBIVal, 0.00) <> 0 OR ISNULL(T1.U_AVVal, 0.00) <> 0) THEN 
								T1.U_AVTyp 
						    ELSE 
								T2.U_AVTyp 
					   END	
	, AddedValue = CASE WHEN ISNULL(T1.Code, '') <> ''  AND (ISNULL(T1.U_NBIVal, 0.00) <> 0 OR ISNULL(T1.U_AVVal, 0.00) <> 0) THEN 
							ISNULL(T1.U_AVVal, 0)
						ELSE 
							ISNULL(T2.U_AVVal, 0)
					END
	FROM #Temp_PRIDetails T0
	INNER JOIN OITM ITM ON T0.FGItem = ITM.ItemCode
	LEFT JOIN [@ITEM_PRISETUP] T1 ON T0.FGItem = T1.Code
	LEFT JOIN [@FGPRODUCTGROUP] T2 ON ITM.U_FGPrdgrp = T2.Code
	--===========================================================================================================================================================================	

	--===========================================================================================================================================================================
	-- Calculating NBI & AV type and value
	--===========================================================================================================================================================================
	-- Calculating NBI (if NBI Type = Percent)
	UPDATE T0
	SET NBIValue = ISNULL(BasicBomCost, 0) * (ISNULL(NBIValue, 0) / 100.00)
	FROM #Temp_PRIDetails T0
	WHERE NBIType = 'P'
	
	-- -- Calculating AV (if AV Type = Percent)
	UPDATE T0
	SET AddedValue = (ISNULL(BasicBomCost, 0.00) + ISNULL(NBIValue, 0.00)) * (ISNULL(AddedValue, 0) / 100.00)
	FROM #Temp_PRIDetails T0
	WHERE AddedValueType = 'P'
	--===========================================================================================================================================================================
	
	--===========================================================================================================================================================================

	
	-- PRI VALUE
	--===========================================================================================================================================================================
	UPDATE T0
	SET PRI = ISNULL(BasicBomCost, 0.00)  + ISNULL(NBIValue, 0.00) + ISNULL(AddedValue, 0.00)
	FROM #Temp_PRIDetails T0
	--===========================================================================================================================================================================

	SELECT * FROM #Temp_PRIDetails
	--SELECT * FROM #Temp_ProdDetails_WithChildComponents
	--===========================================================================================================================================================================
	-- Dropping temp table
	--===========================================================================================================================================================================
	DROP TABLE #Temp_PRIDetails
	DROP TABLE #Temp_ProdDetails_WithChildComponents
	--=================================================================================================================

END
