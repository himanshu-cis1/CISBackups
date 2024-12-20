USE [PAP_LIVE_Branch]
GO
/****** Object:  StoredProcedure [dbo].[CIS_ProductionPlanning]    Script Date: 12/11/2024 3:25:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[CIS_ProductionPlanning]
 AS Begin 


Create table #WIPRep
  (PORN NVarchar (200),ItemCode Nvarchar(2000),ItemCode1 Nvarchar(2000),ItemName Nvarchar(250) ,WIPQTY dec(19,6),WIPCOST dec(19,6),PrCode Nvarchar(200),FinalPrCode Nvarchar(200),Seq Nvarchar(3) )
Insert into #WIPRep (PORN,ItemCode,ItemCode1,ItemName,WIPQTY,WIPCOST,PrCode,FinalPrCode,Seq)

Select A.U_PORN,A.U_ITCD,D.FrgnName,A.U_ITNM,ISNULL(A.U_TUQT,0),ISNULL(A.U_TUCT,0) ,C.U_PRCO, C.U_MPRS,C.LineId
from [dbo].[@TURNH] A 
Inner Join [dbo].[@ROTIH] B On A.U_ITCD = B.U_ITEM 
Inner Join [dbo].[@ROTID] C On C.DocEntry=B.DocEntry And A.U_SEQU=C.LineId
Inner Join OITM D On A.U_ITCD =D.ItemCode
Where A.DocEntry=(Select Max(P.DocEntry) From [dbo].[@TURNH] P Where P.U_PORN=A.U_PORN And A.U_ITCD=P.U_ITCD);
/*
Select T0.ItemCode,T0.ItemName,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='TURNING' )'TURNING WIP Qty',	
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='TURNING' )'TURNING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='HOBBING' )'HOBBING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='HOBBING' )'HOBBING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='HONNING' )'HONNING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='HONNING' )'HONNING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='MILLING/SLOTTING' )'MILLING/SLOTTING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='MILLING/SLOTTING' )'MILLING/SLOTTING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='HEAT TREATMENT' )'HEAT TREATMENT WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='HEAT TREATMENT' )'HEAT TREATMENT WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='TEMPERING' )'TEMPERING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='TEMPERING' )'TEMPERING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='CARBURIZING' )'CARBURIZING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='CARBURIZING' )'CARBURIZING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='ANEALING' )'ANEALING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='ANEALING' )'ANEALING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='POLISHING' )'POLISHING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='POLISHING' )'POLISHING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='SAND BLASTING' )'SAND BLASTING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='SAND BLASTING' )'SAND BLASTING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='LASER MARKING' )'LASER MARKING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='LASER MARKING' )'LASER MARKING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='LASER WELDING' )'LASER WELDING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='LASER WELDING' )'LASER WELDING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='HUGI/SURFACE GRINDING' )'HUGI/SURFACE GRINDING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='HUGI/SURFACE GRINDING' )'HUGI/SURFACE GRINDING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='LAPPING/TAPPING/BUFFING')'LAPPING/TAPPING/BUFFING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='LAPPING/TAPPING/BUFFING')'LAPPING/TAPPING/BUFFING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='CHAMFERING/PIP REMOVING')'CHAMFERING/PIP REMOVING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='CHAMFERING/PIP REMOVING')'CHAMFERING/PIP REMOVING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='CENTRELESS GRINDING')'CENTRELESS GRINDING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='CENTRELESS GRINDING')'CENTRELESS GRINDING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='EDM/WIRE EDM')'EDM/WIRE EDM WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='EDM/WIRE EDM')'EDM/WIRE EDM WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='BACK DRILLING/BORING/SLITTING')'BACK DRILLING/BORING/SLITTING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='BACK DRILLING/BORING/SLITTING')'BACK DRILLING/BORING/SLITTING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='ASSEMBLY/PUNCHING')'ASSEMBLY/PUNCHING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='ASSEMBLY/PUNCHING')'ASSEMBLY/PUNCHING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='BURNISHING/SALLAZE')'BURNISHING/SALLAZE WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='BURNISHING/SALLAZE')'BURNISHING/SALLAZE WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='DRILLING')'DRILLING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='DRILLING')'DRILLING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='FINAL ACCOUTING')'FINAL ACCOUTING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='FINAL ACCOUTING')'FINAL ACCOUTING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='FINAL QUALITY')'FINAL QUALITY WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='FINAL QUALITY')'FINAL QUALITY WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)')'NICKEL/ELECTROLESS PLATING (JW) WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)')'NICKEL/ELECTROLESS PLATING (JW) WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='TIN PLATING (JW)')'TIN PLATING (JW) WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='TIN PLATING (JW)')'TIN PLATING (JW) WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='GOLD PLATING (JW)')'GOLD PLATING (JW) WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='GOLD PLATING (JW)')'GOLD PLATING (JW) WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='CHROME PLATING (JW)')'CHROME PLATING (JW) WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='CHROME PLATING (JW)')'CHROME PLATING (JW) WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='PASSIVATION (JW)')'PASSIVATION (JW) WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='PASSIVATION (JW)')'PASSIVATION (JW) WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='ANODIZING (JW)')'ANODIZING (JW) WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='ANODIZING (JW)')'ANODIZING (JW) WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='ZINC PLATING (JW)')'ZINC PLATING (JW) WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='ZINC PLATING (JW)')'ZINC PLATING (JW) WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='SILVER PLATING (JW)')'SILVER PLATING (JW) WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='SILVER PLATING (JW)')'SILVER PLATING (JW) WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='PIERCING (JW)')'PIERCING (JW) WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='PIERCING (JW)')'PIERCING (JW) WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='PROFILE MILLING (JW)')'PROFILE MILLING (JW) WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='PROFILE MILLING (JW)')'PROFILE MILLING (JW) WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='WIRE CUTTING (JW)')'WIRE CUTTING (JW) WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='WIRE CUTTING (JW)')'WIRE CUTTING (JW) WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='STRAIGHT')'STRAIGHT WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='STRAIGHT')'STRAIGHT WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='DISASSEMBLE')'DISASSEMBLE WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='DISASSEMBLE')'DISASSEMBLE WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='SOLDERING')'SOLDERING WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode And T1.FinalPrCode='SOLDERING')'SOLDERING WIP Cost'
,
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode )'Total WIP Qty',
(Select SUM(T1.WIPCOST) From #WIPRep T1 Where T1.ItemCode=T0.ItemCode )'Total WIP Cost'


--,SUM(WIPCOST) 'Turning WIP Cost'
from #WIPRep T0
--Where FinalPrCode='01'
Group by ItemCode,ItemName
*/




Select W1.ItemCode 'ASS. NO', NUll 'Rev No',SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)) 'Open PO',
(Select 'PO Date' = STUFF((
         SELECT ',' +FORMAT(a.CreateDate,'yyyy-MM-dd')  FROM OOAT a
		 Inner Join OAT1 a1 on a.AbsID=a1.AgrNo 
			Where A1.ItemCode=W1.ItemCode
			--Group By a1.ItemCode,a.CreateDate
			FOR XML PATH('')
         ), 1, 1, ''))'PO Date',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))*25)/100 'Min Qty 25%',
SUM(W1.UndlvQty)'RELEASE AGAINST OPEN PO',
(Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))'FINISH STOCK IN DESPATCH',

ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='TURNING'),0)'TURNING WIP Qty',	
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='HOBBING'),0)'HOBBING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='HONNING'),0)'HONNING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='MILLING/SLOTTING'),0)'MILLING/SLOTTING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='HEAT TREATMENT'),0)'HEAT TREATMENT WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='TEMPERING'),0)'TEMPERING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='CARBURIZING'),0)'CARBURIZING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='ANEALING'),0)'ANEALING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='POLISHING'),0)'POLISHING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='SAND BLASTING'),0)'SAND BLASTING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='LASER MARKING'),0)'LASER MARKING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='LASER WELDING'),0)'LASER WELDING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='HUGI/SURFACE GRINDING'),0)'HUGI/SURFACE GRINDING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='LAPPING/TAPPING/BUFFING'),0)'LAPPING/TAPPING/BUFFING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='CHAMFERING/PIP REMOVING'),0)'CHAMFERING/PIP REMOVING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='CENTRELESS GRINDING'),0)'CENTRELESS GRINDING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='EDM/WIRE EDM'),0)'EDM/WIRE EDM WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='BACK DRILLING/BORING/SLITTING'),0)'BACK DRILLING/BORING/SLITTING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='ASSEMBLY/PUNCHING'),0)'ASSEMBLY/PUNCHING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='BURNISHING/SALLAZE'),0)'BURNISHING/SALLAZE WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='DRILLING'),0)'DRILLING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='FINAL ACCOUTING'),0)'FINAL ACCOUTING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='FINAL QUALITY'),0)'FINAL QUALITY WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)'),0)'NICKEL/ELECTROLESS PLATING (JW) WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='TIN PLATING (JW)'),0)'TIN PLATING (JW) WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='GOLD PLATING (JW)'),0)'GOLD PLATING (JW) WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='CHROME PLATING (JW)'),0)'CHROME PLATING (JW) WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='PASSIVATION (JW)'),0)'PASSIVATION (JW) WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='ANODIZING (JW)'),0)'ANODIZING (JW) WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='ZINC PLATING (JW)'),0)'ZINC PLATING (JW) WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='SILVER PLATING (JW)'),0)'SILVER PLATING (JW) WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='PIERCING (JW)'),0)'PIERCING (JW) WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='PROFILE MILLING (JW)'),0)'PROFILE MILLING (JW) WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='WIRE CUTTING (JW)'),0)'WIRE CUTTING (JW) WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='STRAIGHT'),0)'STRAIGHT WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='DISASSEMBLE'),0)'DISASSEMBLE WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='SOLDERING'),0)'SOLDERING WIP Qty',
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0)'Total WIP Qty',

((((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))*25)/100)+ (SUM(W1.UndlvQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0)) 'Below to 25%' ,

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0)))*1.1 End as 'PPC Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TURNING','QUALITY','ACCOUNTING') And L1.FinalPrCode='TURNING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='TURNING'),0) 'TURNING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HOBBING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HOBBING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='HOBBING'),0)'HOBBING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HONNING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HONNING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='HONNING'),0)'HONNING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('MILLING/SLOTTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='MILLING/SLOTTING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='MILLING/SLOTTING'),0)'MILLING/SLOTTING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HEAT TREATMENT','QUALITY','ACCOUNTING') And L1.FinalPrCode='HEAT TREATMENT' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='HEAT TREATMENT'),0)'HEAT TREATMENT Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TEMPERING','QUALITY','ACCOUNTING') And L1.FinalPrCode='TEMPERING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='TEMPERING'),0)'TEMPERING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CARBURIZING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CARBURIZING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='CARBURIZING'),0)'CARBURIZING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ANEALING','QUALITY','ACCOUNTING') And L1.FinalPrCode='ANEALING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='ANEALING'),0)'ANEALING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('POLISHING','QUALITY','ACCOUNTING') And L1.FinalPrCode='POLISHING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='POLISHING'),0)'POLISHING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SAND BLASTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='SAND BLASTING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='SAND BLASTING'),0)'SAND BLASTING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LASER MARKING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LASER MARKING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='LASER MARKING'),0)'LASER MARKING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LASER WELDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LASER WELDING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='LASER WELDING'),0)'LASER WELDING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HUGI/SURFACE GRINDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HUGI/SURFACE GRINDING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='HUGI/SURFACE GRINDING'),0)'HUGI/SURFACE GRINDING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LAPPING/TAPPING/BUFFING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LAPPING/TAPPING/BUFFING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='LAPPING/TAPPING/BUFFING'),0)'LAPPING/TAPPING/BUFFING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CHAMFERING/PIP REMOVING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CHAMFERING/PIP REMOVING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='CHAMFERING/PIP REMOVING'),0)'CHAMFERING/PIP REMOVING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CENTRELESS GRINDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CENTRELESS GRINDING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='CENTRELESS GRINDING'),0)'CENTRELESS GRINDING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('EDM/WIRE EDM','QUALITY','ACCOUNTING') And L1.FinalPrCode='EDM/WIRE EDM' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='EDM/WIRE EDM'),0)'EDM/WIRE EDM Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('BACK DRILLING/BORING/SLITTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='BACK DRILLING/BORING/SLITTING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='BACK DRILLING/BORING/SLITTING'),0)'BACK DRILLING/BORING/SLITTING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ASSEMBLY/PUNCHING','QUALITY','ACCOUNTING') And L1.FinalPrCode='ASSEMBLY/PUNCHING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='ASSEMBLY/PUNCHING'),0)'ASSEMBLY/PUNCHING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('BURNISHING/SALLAZE','QUALITY','ACCOUNTING') And L1.FinalPrCode='BURNISHING/SALLAZE' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='BURNISHING/SALLAZE'),0)'BURNISHING/SALLAZE Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('DRILLING','QUALITY','ACCOUNTING') And L1.FinalPrCode='DRILLING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='DRILLING'),0)'DRILLING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('FINAL ACCOUTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='FINAL ACCOUTING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='FINAL ACCOUTING'),0)'FINAL ACCOUTING Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('FINAL QUALITY','QUALITY','ACCOUNTING') And L1.FinalPrCode='FINAL QUALITY' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='FINAL QUALITY'),0)'FINAL QUALITY Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('NICKEL/ELECTROLESS PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)'),0)'NICKEL/ELECTROLESS PLATING (JW) Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TIN PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='TIN PLATING (JW)' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='TIN PLATING (JW)'),0)'TIN PLATING (JW) Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('GOLD PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='GOLD PLATING (JW)' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='GOLD PLATING (JW)'),0)'GOLD PLATING (JW) Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CHROME PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='CHROME PLATING (JW)' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='CHROME PLATING (JW)'),0)'CHROME PLATING (JW) Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PASSIVATION (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PASSIVATION (JW)' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='PASSIVATION (JW)'),0)'PASSIVATION (JW) Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ANODIZING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='ANODIZING (JW)' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='ANODIZING (JW)'),0)'ANODIZING (JW) Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ZINC PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='ZINC PLATING (JW)' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='ZINC PLATING (JW)'),0)'ZINC PLATING (JW) Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SILVER PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='SILVER PLATING (JW)' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='SILVER PLATING (JW)'),0)'SILVER PLATING (JW) Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PIERCING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PIERCING (JW)' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='PIERCING (JW)'),0)'PIERCING (JW) Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PROFILE MILLING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PROFILE MILLING (JW)' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='PROFILE MILLING (JW)'),0)'PROFILE MILLING (JW) Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('WIRE CUTTING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='WIRE CUTTING (JW)' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='WIRE CUTTING (JW)'),0)'WIRE CUTTING (JW) Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('STRAIGHT','QUALITY','ACCOUNTING') And L1.FinalPrCode='STRAIGHT' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='STRAIGHT'),0)'STRAIGHT Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('DISASSEMBLE','QUALITY','ACCOUNTING') And L1.FinalPrCode='DISASSEMBLE' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='DISASSEMBLE'),0)'DISASSEMBLE Plan',

Case When ((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0))) < 0.00 then 0 Else  
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT),0 )))*1.1 End +
(Select ISNULL(SUM(T1.WIPQTY),0.00) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.Seq <
(Select Min(L1.Seq) From #WIPRep L1 Where L1.ItemCode1=T1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SOLDERING','QUALITY','ACCOUNTING') And L1.FinalPrCode='SOLDERING' ))-
ISNULL((Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='SOLDERING'),0)'SOLDERING Plan'

/*
,
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='HOBBING'))) 'Hobbing Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='HONNING'))) 'HONNING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='MILLING/SLOTTING'))) 'MILLING/SLOTTING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='HEAT TREATMENT'))) 'HEAT TREATMENT Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='TEMPERING'))) 'TEMPERING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='CARBURIZING'))) 'CARBURIZING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='ANEALING'))) 'ANEALING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='POLISHING'))) 'POLISHING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='SAND BLASTING'))) 'SAND BLASTING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='LASER MARKING'))) 'LASER MARKING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='LASER WELDING'))) 'LASER WELDING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='HUGI/SURFACE GRINDING'))) 'HUGI/SURFACE GRINDING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='LAPPING/TAPPING/BUFFING'))) 'LAPPING/TAPPING/BUFFING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='CHAMFERING/PIP REMOVING'))) 'CHAMFERING/PIP REMOVING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='CENTRELESS GRINDING'))) 'CENTRELESS GRINDING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='EDM/WIRE EDM'))) 'EDM/WIRE EDM Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='BACK DRILLING/BORING/SLITTING'))) 'BACK DRILLING/BORING/SLITTING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='ASSEMBLY/PUNCHING'))) 'ASSEMBLY/PUNCHING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='BURNISHING/SALLAZE'))) 'BURNISHING/SALLAZE Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='DRILLING'))) 'DRILLING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='FINAL ACCOUTING'))) 'FINAL ACCOUTING Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='FINAL QUALITY'))) 'FINAL QUALITY Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)'))) 'NICKEL/ELECTROLESS PLATING (JW) Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='TIN PLATING (JW)'))) 'TIN PLATING (JW) Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='GOLD PLATING (JW)'))) 'GOLD PLATING (JW) Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='CHROME PLATING (JW)'))) 'CHROME PLATING (JW) Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='PASSIVATION (JW)'))) 'PASSIVATION (JW) Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='ANODIZING (JW)'))) 'ANODIZING (JW) Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='ZINC PLATING (JW)'))) 'ZINC PLATING (JW) Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='SILVER PLATING (JW)'))) 'SILVER PLATING (JW) Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='PIERCING (JW)'))) 'PIERCING (JW) Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='PROFILE MILLING (JW)'))) 'PROFILE MILLING (JW) Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='WIRE CUTTING (JW)'))) 'WIRE CUTTING (JW) Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='STRAIGHT'))) 'STRAIGHT Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='DISASSEMBLE'))) 'DISASSEMBLE Plan',
((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))-((Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))+
(Select SUM(T1.WIPQTY) From #WIPRep T1 Where T1.ItemCode1=W1.ItemCode COLLATE DATABASE_DEFAULT And T1.FinalPrCode='SOLDERING'))) 'SOLDERING Plan',

(((SUM(W1.PlanQty)-(SUM(W1.UndlvQty)-SUM(W1.CumQty)))*25)/100 + SUM(W1.UndlvQty))-(Select SUM(A11.OnHand) From OITW A11 Where A11.ItemCode=W1.ItemCode And A11.WhsCode in('FG','FG-B'))
'ASSEMBLY PLAN for min'
*/

From 

ITT1 T0
Left Join OAT1 W1 On T0.Father=W1.ItemCode
LEFT JOIN ITT1 T1 ON T0.Code = T1.Father
LEFT JOIN ITT1 T2 ON T1.Code = T2.Father
LEFT JOIN ITT1 T3 ON T2.Code = T3.Father
LEFT JOIN ITT1 T4 ON T3.Code = T4.Father
LEFT JOIN ITT1 T5 ON T4.Code = T5.Father
LEFT JOIN ITT1 T6 ON T5.Code = T6.Father
LEFT JOIN oitm t20 ON t0.father = t20.itemcode
LEFT JOIN oitm t10 ON t0.code = t10.itemcode
LEFT JOIN oitm t11 ON t1.code = t11.itemcode
LEFT JOIN oitm t12 ON t2.code = t12.itemcode
LEFT JOIN oitm t13 ON t3.code = t13.itemcode
LEFT JOIN oitm t14 ON t4.code = t14.itemcode
LEFT JOIN oitm t15 ON t5.code = t15.itemcode
--Left Join OITM W2 on W1.ItemCode=W2.ItemCode
Where W1.LineStatus='O'--And W1.ItemCode='177.211.2'
Group By W1.ItemCode

Drop table #WIPRep

END
