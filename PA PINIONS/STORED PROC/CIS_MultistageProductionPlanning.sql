USE [PAP_LIVE_Branch]
GO
/****** Object:  StoredProcedure [dbo].[CIS_MultistageProductionPlanning]    Script Date: 12/11/2024 3:23:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[CIS_MultistageProductionPlanning]
(
@DocEntry INTEGER
)

AS
begin

--Execute CIS_MultistageProductionPlanning

Create table #WIPPPR
  (PORN NVarchar (200),ItemCode Nvarchar(2000),ItemCode1 Nvarchar(2000),ItemName Nvarchar(250) ,WIPQTY dec(19,6),WIPCOST dec(19,6),PrCode Nvarchar(200),FinalPrCode Nvarchar(200),Seq Nvarchar(3) )
Insert into #WIPPPR (PORN,ItemCode,ItemCode1,ItemName,WIPQTY,WIPCOST,PrCode,FinalPrCode,Seq)

Select A.U_PORN,A.U_ITCD,D.FrgnName,A.U_ITNM,ISNULL(A.U_TUQT,0),ISNULL(A.U_TUCT,0) ,C.U_PRCO, C.U_MPRS,C.LineId
from [dbo].[@TURNH] A 
Inner Join [dbo].[@ROTIH] B On A.U_ITCD = B.U_ITEM 
Inner Join [dbo].[@ROTID] C On C.DocEntry=B.DocEntry And A.U_SEQU=C.LineId
Inner Join OITM D On A.U_ITCD =D.ItemCode
Where A.DocEntry=(Select Max(P.DocEntry) From [dbo].[@TURNH] P Where P.U_PORN=A.U_PORN And A.U_ITCD=P.U_ITCD);


SELECT Distinct  T0.[Father] as 'Assembly',

-- T0.[Quantity],

T202.U_PPQT as 'BuildQty',

T0.[Code] as 'Component1', t10.[ItemName] 'Description1', T0.[Quantity] as 'Quantity1',

T202.U_PPQT * t0.[Quantity] as 'ExtQty1',

t10.OnHand as 'OnHand1',

case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else

-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end as 'Shortage1',
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TURNING'),0)'Com1 TURNING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TURNING','QUALITY','ACCOUNTING') And L1.FinalPrCode='TURNING' )) 'Com1 TURNING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HOBBING'),0)'Com1 HOBBING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HOBBING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HOBBING' )) 'Com1 HOBBING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HONNING'),0)'Com1 HONNING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HONNING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HONNING' )) 'Com1 HONNING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='MILLING/SLOTTING'),0)'Com1 MILLING/SLOTTING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('MILLING/SLOTTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='MILLING/SLOTTING' )) 'Com1 MILLING/SLOTTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HEAT TREATMENT'),0)'Com1 HEAT TREATMENT WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HEAT TREATMENT','QUALITY','ACCOUNTING') And L1.FinalPrCode='HEAT TREATMENT' )) 'Com1 HEAT TREATMENT Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TEMPERING'),0)'Com1 TEMPERING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TEMPERING','QUALITY','ACCOUNTING') And L1.FinalPrCode='TEMPERING' )) 'Com1 TEMPERING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CARBURIZING'),0)'Com1 CARBURIZING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CARBURIZING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CARBURIZING' )) 'Com1 CARBURIZING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ANEALING'),0)'Com1 ANEALING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ANEALING','QUALITY','ACCOUNTING') And L1.FinalPrCode='ANEALING' )) 'Com1 ANEALING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='POLISHING'),0)'Com1 POLISHING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('POLISHING','QUALITY','ACCOUNTING') And L1.FinalPrCode='POLISHING' )) 'Com1 POLISHING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SAND BLASTING'),0)'Com1 SAND BLASTING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SAND BLASTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='SAND BLASTING' )) 'Com1 SAND BLASTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LASER MARKING'),0)'Com1 LASER MARKING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LASER MARKING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LASER MARKING' )) 'Com1 LASER MARKING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LASER WELDING'),0)'Com1 LASER WELDING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LASER WELDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LASER WELDING' )) 'Com1 LASER WELDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HUGI/SURFACE GRINDING'),0)'Com1 HUGI/SURFACE GRINDING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HUGI/SURFACE GRINDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HUGI/SURFACE GRINDING' )) 'Com1 HUGI/SURFACE GRINDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LAPPING/TAPPING/BUFFING'),0)'Com1 LAPPING/TAPPING/BUFFING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LAPPING/TAPPING/BUFFING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LAPPING/TAPPING/BUFFING' )) 'Com1 LAPPING/TAPPING/BUFFING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CHAMFERING/PIP REMOVING'),0)'Com1 CHAMFERING/PIP REMOVING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CHAMFERING/PIP REMOVING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CHAMFERING/PIP REMOVING' )) 'Com1 CHAMFERING/PIP REMOVING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CENTRELESS GRINDING'),0)'Com1 CENTRELESS GRINDING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CENTRELESS GRINDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CENTRELESS GRINDING' )) 'Com1 CENTRELESS GRINDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='EDM/WIRE EDM'),0)'Com1 EDM/WIRE EDM WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('EDM/WIRE EDM','QUALITY','ACCOUNTING') And L1.FinalPrCode='EDM/WIRE EDM' )) 'Com1 EDM/WIRE EDM Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='BACK DRILLING/BORING/SLITTING'),0)'Com1 BACK DRILLING/BORING/SLITTING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('BACK DRILLING/BORING/SLITTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='BACK DRILLING/BORING/SLITTING' )) 'Com1 BACK DRILLING/BORING/SLITTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ASSEMBLY/PUNCHING'),0)'Com1 ASSEMBLY/PUNCHING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ASSEMBLY/PUNCHING','QUALITY','ACCOUNTING') And L1.FinalPrCode='ASSEMBLY/PUNCHING' )) 'Com1 ASSEMBLY/PUNCHING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='BURNISHING/SALLAZE'),0)'Com1 BURNISHING/SALLAZE WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('BURNISHING/SALLAZE','QUALITY','ACCOUNTING') And L1.FinalPrCode='BURNISHING/SALLAZE' )) 'Com1 BURNISHING/SALLAZE Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='DRILLING'),0)'Com1 DRILLING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('DRILLING','QUALITY','ACCOUNTING') And L1.FinalPrCode='DRILLING' )) 'Com1 DRILLING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='FINAL ACCOUTING'),0)'Com1 FINAL ACCOUTING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('FINAL ACCOUTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='FINAL ACCOUTING' )) 'Com1 FINAL ACCOUTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='FINAL QUALITY'),0)'Com1 FINAL QUALITY WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('FINAL QUALITY','QUALITY','ACCOUNTING') And L1.FinalPrCode='FINAL QUALITY' )) 'Com1 FINAL QUALITY Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)'),0)'Com1 NICKEL/ELECTROLESS PLATING (JW) WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('NICKEL/ELECTROLESS PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)' )) 'Com1 NICKEL/ELECTROLESS PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TIN PLATING (JW)'),0)'Com1 TIN PLATING (JW) WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TIN PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='TIN PLATING (JW)' )) 'Com1 TIN PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='GOLD PLATING (JW)'),0)'Com1 GOLD PLATING (JW) WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('GOLD PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='GOLD PLATING (JW)' )) 'Com1 GOLD PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CHROME PLATING (JW)'),0)'Com1 CHROME PLATING (JW) WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CHROME PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='CHROME PLATING (JW)' )) 'Com1 CHROME PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PASSIVATION (JW)'),0)'Com1 PASSIVATION (JW) WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PASSIVATION (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PASSIVATION (JW)' )) 'Com1 PASSIVATION (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ANODIZING (JW)'),0)'Com1 ANODIZING (JW) WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ANODIZING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='ANODIZING (JW)' )) 'Com1 ANODIZING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ZINC PLATING (JW)'),0)'Com1 ZINC PLATING (JW) WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ZINC PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='ZINC PLATING (JW)' )) 'Com1 ZINC PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SILVER PLATING (JW)'),0)'Com1 SILVER PLATING (JW) WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SILVER PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='SILVER PLATING (JW)' )) 'Com1 SILVER PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PIERCING (JW)'),0)'Com1 PIERCING (JW) WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PIERCING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PIERCING (JW)' )) 'Com1 PIERCING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PROFILE MILLING (JW)'),0)'Com1 PROFILE MILLING (JW) WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PROFILE MILLING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PROFILE MILLING (JW)' )) 'Com1 PROFILE MILLING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='WIRE CUTTING (JW)'),0)'Com1 WIRE CUTTING (JW) WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('WIRE CUTTING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='WIRE CUTTING (JW)' )) 'Com1 WIRE CUTTING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='STRAIGHT'),0)'Com1 STRAIGHT WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('STRAIGHT','QUALITY','ACCOUNTING') And L1.FinalPrCode='STRAIGHT' )) 'Com1 STRAIGHT Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='DISASSEMBLE'),0)'Com1 DISASSEMBLE WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('DISASSEMBLE','QUALITY','ACCOUNTING') And L1.FinalPrCode='DISASSEMBLE' )) 'Com1 DISASSEMBLE Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SOLDERING'),0)'Com1 SOLDERING WIP Qty',
case when t10.OnHand - (T202.U_PPQT * t0.[Quantity]) > 0 then 0 else
-(t10.OnHand - (T202.U_PPQT * t0.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T10.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=t10.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SOLDERING','QUALITY','ACCOUNTING') And L1.FinalPrCode='SOLDERING' )) 'Com1 SOLDERING Plan',


T1.[Code] as 'Component2', t11.[ItemName] 'Description2', T1.[Quantity] as 'Quantity2',

T202.U_PPQT * t0.[Quantity] * t1.[Quantity] as 'ExtQty2',

t11.OnHand as 'OnHand2',
Case when t11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else

-(t11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end as 'Shortage2',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TURNING'),0)'Com2 TURNING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TURNING','QUALITY','ACCOUNTING') And L1.FinalPrCode='TURNING' )) 'Com2 TURNING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HOBBING'),0)'Com2 HOBBING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HOBBING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HOBBING' )) 'Com2 HOBBING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HONNING'),0)'Com2 HONNING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HONNING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HONNING' )) 'Com2 HONNING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='MILLING/SLOTTING'),0)'Com2 MILLING/SLOTTING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('MILLING/SLOTTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='MILLING/SLOTTING' )) 'Com2 MILLING/SLOTTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HEAT TREATMENT'),0)'Com2 HEAT TREATMENT WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HEAT TREATMENT','QUALITY','ACCOUNTING') And L1.FinalPrCode='HEAT TREATMENT' )) 'Com2 HEAT TREATMENT Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TEMPERING'),0)'Com2 TEMPERING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TEMPERING','QUALITY','ACCOUNTING') And L1.FinalPrCode='TEMPERING' )) 'Com2 TEMPERING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CARBURIZING'),0)'Com2 CARBURIZING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CARBURIZING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CARBURIZING' )) 'Com2 CARBURIZING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ANEALING'),0)'Com2 ANEALING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ANEALING','QUALITY','ACCOUNTING') And L1.FinalPrCode='ANEALING' )) 'Com2 ANEALING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='POLISHING'),0)'Com2 POLISHING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('POLISHING','QUALITY','ACCOUNTING') And L1.FinalPrCode='POLISHING' )) 'Com2 POLISHING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SAND BLASTING'),0)'Com2 SAND BLASTING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SAND BLASTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='SAND BLASTING' )) 'Com2 SAND BLASTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LASER MARKING'),0)'Com2 LASER MARKING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LASER MARKING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LASER MARKING' )) 'Com2 LASER MARKING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LASER WELDING'),0)'Com2 LASER WELDING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LASER WELDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LASER WELDING' )) 'Com2 LASER WELDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HUGI/SURFACE GRINDING'),0)'Com2 HUGI/SURFACE GRINDING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HUGI/SURFACE GRINDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HUGI/SURFACE GRINDING' )) 'Com2 HUGI/SURFACE GRINDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LAPPING/TAPPING/BUFFING'),0)'Com2 LAPPING/TAPPING/BUFFING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LAPPING/TAPPING/BUFFING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LAPPING/TAPPING/BUFFING' )) 'Com2 LAPPING/TAPPING/BUFFING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CHAMFERING/PIP REMOVING'),0)'Com2 CHAMFERING/PIP REMOVING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CHAMFERING/PIP REMOVING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CHAMFERING/PIP REMOVING' )) 'Com2 CHAMFERING/PIP REMOVING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CENTRELESS GRINDING'),0)'Com2 CENTRELESS GRINDING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CENTRELESS GRINDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CENTRELESS GRINDING' )) 'Com2 CENTRELESS GRINDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='EDM/WIRE EDM'),0)'Com2 EDM/WIRE EDM WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('EDM/WIRE EDM','QUALITY','ACCOUNTING') And L1.FinalPrCode='EDM/WIRE EDM' )) 'Com2 EDM/WIRE EDM Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='BACK DRILLING/BORING/SLITTING'),0)'Com2 BACK DRILLING/BORING/SLITTING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('BACK DRILLING/BORING/SLITTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='BACK DRILLING/BORING/SLITTING' )) 'Com2 BACK DRILLING/BORING/SLITTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ASSEMBLY/PUNCHING'),0)'Com2 ASSEMBLY/PUNCHING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ASSEMBLY/PUNCHING','QUALITY','ACCOUNTING') And L1.FinalPrCode='ASSEMBLY/PUNCHING' )) 'Com2 ASSEMBLY/PUNCHING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='BURNISHING/SALLAZE'),0)'Com2 BURNISHING/SALLAZE WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('BURNISHING/SALLAZE','QUALITY','ACCOUNTING') And L1.FinalPrCode='BURNISHING/SALLAZE' )) 'Com2 BURNISHING/SALLAZE Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='DRILLING'),0)'Com2 DRILLING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('DRILLING','QUALITY','ACCOUNTING') And L1.FinalPrCode='DRILLING' )) 'Com2 DRILLING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='FINAL ACCOUTING'),0)'Com2 FINAL ACCOUTING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('FINAL ACCOUTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='FINAL ACCOUTING' )) 'Com2 FINAL ACCOUTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='FINAL QUALITY'),0)'Com2 FINAL QUALITY WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('FINAL QUALITY','QUALITY','ACCOUNTING') And L1.FinalPrCode='FINAL QUALITY' )) 'Com2 FINAL QUALITY Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)'),0)'Com2 NICKEL/ELECTROLESS PLATING (JW) WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('NICKEL/ELECTROLESS PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)' )) 'Com2 NICKEL/ELECTROLESS PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TIN PLATING (JW)'),0)'Com2 TIN PLATING (JW) WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TIN PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='TIN PLATING (JW)' )) 'Com2 TIN PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='GOLD PLATING (JW)'),0)'Com2 GOLD PLATING (JW) WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('GOLD PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='GOLD PLATING (JW)' )) 'Com2 GOLD PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CHROME PLATING (JW)'),0)'Com2 CHROME PLATING (JW) WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CHROME PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='CHROME PLATING (JW)' )) 'Com2 CHROME PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PASSIVATION (JW)'),0)'Com2 PASSIVATION (JW) WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PASSIVATION (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PASSIVATION (JW)' )) 'Com2 PASSIVATION (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ANODIZING (JW)'),0)'Com2 ANODIZING (JW) WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ANODIZING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='ANODIZING (JW)' )) 'Com2 ANODIZING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ZINC PLATING (JW)'),0)'Com2 ZINC PLATING (JW) WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ZINC PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='ZINC PLATING (JW)' )) 'Com2 ZINC PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SILVER PLATING (JW)'),0)'Com2 SILVER PLATING (JW) WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SILVER PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='SILVER PLATING (JW)' )) 'Com2 SILVER PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PIERCING (JW)'),0)'Com2 PIERCING (JW) WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PIERCING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PIERCING (JW)' )) 'Com2 PIERCING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PROFILE MILLING (JW)'),0)'Com2 PROFILE MILLING (JW) WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PROFILE MILLING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PROFILE MILLING (JW)' )) 'Com2 PROFILE MILLING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='WIRE CUTTING (JW)'),0)'Com2 WIRE CUTTING (JW) WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('WIRE CUTTING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='WIRE CUTTING (JW)' )) 'Com2 WIRE CUTTING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='STRAIGHT'),0)'Com2 STRAIGHT WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('STRAIGHT','QUALITY','ACCOUNTING') And L1.FinalPrCode='STRAIGHT' )) 'Com2 STRAIGHT Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='DISASSEMBLE'),0)'Com2 DISASSEMBLE WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('DISASSEMBLE','QUALITY','ACCOUNTING') And L1.FinalPrCode='DISASSEMBLE' )) 'Com2 DISASSEMBLE Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SOLDERING'),0)'Com2 SOLDERING WIP Qty',
case when T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity]) > 0 then 0 else
-(T11.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T11.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SOLDERING','QUALITY','ACCOUNTING') And L1.FinalPrCode='SOLDERING' )) 'Com2 SOLDERING Plan',




T2.[Code] as 'Component3', t12.[ItemName] 'Description3', T2.[Quantity] as 'Quantity3',

T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] as 'ExtQty3',

t12.OnHand as 'OnHand3',

case when t12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else

-(t12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end as 'Shortage3',


ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TURNING'),0)'Com3 TURNING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TURNING','QUALITY','ACCOUNTING') And L1.FinalPrCode='TURNING' )) 'Com3 TURNING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HOBBING'),0)'Com3 HOBBING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HOBBING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HOBBING' )) 'Com3 HOBBING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HONNING'),0)'Com3 HONNING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HONNING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HONNING' )) 'Com3 HONNING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='MILLING/SLOTTING'),0)'Com3 MILLING/SLOTTING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('MILLING/SLOTTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='MILLING/SLOTTING' )) 'Com3 MILLING/SLOTTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HEAT TREATMENT'),0)'Com3 HEAT TREATMENT WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HEAT TREATMENT','QUALITY','ACCOUNTING') And L1.FinalPrCode='HEAT TREATMENT' )) 'Com3 HEAT TREATMENT Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TEMPERING'),0)'Com3 TEMPERING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TEMPERING','QUALITY','ACCOUNTING') And L1.FinalPrCode='TEMPERING' )) 'Com3 TEMPERING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CARBURIZING'),0)'Com3 CARBURIZING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CARBURIZING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CARBURIZING' )) 'Com3 CARBURIZING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ANEALING'),0)'Com3 ANEALING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ANEALING','QUALITY','ACCOUNTING') And L1.FinalPrCode='ANEALING' )) 'Com3 ANEALING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='POLISHING'),0)'Com3 POLISHING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('POLISHING','QUALITY','ACCOUNTING') And L1.FinalPrCode='POLISHING' )) 'Com3 POLISHING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SAND BLASTING'),0)'Com3 SAND BLASTING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SAND BLASTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='SAND BLASTING' )) 'Com3 SAND BLASTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LASER MARKING'),0)'Com3 LASER MARKING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LASER MARKING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LASER MARKING' )) 'Com3 LASER MARKING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LASER WELDING'),0)'Com3 LASER WELDING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LASER WELDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LASER WELDING' )) 'Com3 LASER WELDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HUGI/SURFACE GRINDING'),0)'Com3 HUGI/SURFACE GRINDING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HUGI/SURFACE GRINDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HUGI/SURFACE GRINDING' )) 'Com3 HUGI/SURFACE GRINDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LAPPING/TAPPING/BUFFING'),0)'Com3 LAPPING/TAPPING/BUFFING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LAPPING/TAPPING/BUFFING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LAPPING/TAPPING/BUFFING' )) 'Com3 LAPPING/TAPPING/BUFFING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CHAMFERING/PIP REMOVING'),0)'Com3 CHAMFERING/PIP REMOVING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CHAMFERING/PIP REMOVING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CHAMFERING/PIP REMOVING' )) 'Com3 CHAMFERING/PIP REMOVING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CENTRELESS GRINDING'),0)'Com3 CENTRELESS GRINDING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CENTRELESS GRINDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CENTRELESS GRINDING' )) 'Com3 CENTRELESS GRINDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='EDM/WIRE EDM'),0)'Com3 EDM/WIRE EDM WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('EDM/WIRE EDM','QUALITY','ACCOUNTING') And L1.FinalPrCode='EDM/WIRE EDM' )) 'Com3 EDM/WIRE EDM Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='BACK DRILLING/BORING/SLITTING'),0)'Com3 BACK DRILLING/BORING/SLITTING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('BACK DRILLING/BORING/SLITTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='BACK DRILLING/BORING/SLITTING' )) 'Com3 BACK DRILLING/BORING/SLITTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ASSEMBLY/PUNCHING'),0)'Com3 ASSEMBLY/PUNCHING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ASSEMBLY/PUNCHING','QUALITY','ACCOUNTING') And L1.FinalPrCode='ASSEMBLY/PUNCHING' )) 'Com3 ASSEMBLY/PUNCHING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='BURNISHING/SALLAZE'),0)'Com3 BURNISHING/SALLAZE WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('BURNISHING/SALLAZE','QUALITY','ACCOUNTING') And L1.FinalPrCode='BURNISHING/SALLAZE' )) 'Com3 BURNISHING/SALLAZE Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='DRILLING'),0)'Com3 DRILLING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('DRILLING','QUALITY','ACCOUNTING') And L1.FinalPrCode='DRILLING' )) 'Com3 DRILLING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='FINAL ACCOUTING'),0)'Com3 FINAL ACCOUTING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('FINAL ACCOUTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='FINAL ACCOUTING' )) 'Com3 FINAL ACCOUTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='FINAL QUALITY'),0)'Com3 FINAL QUALITY WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('FINAL QUALITY','QUALITY','ACCOUNTING') And L1.FinalPrCode='FINAL QUALITY' )) 'Com3 FINAL QUALITY Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)'),0)'Com3 NICKEL/ELECTROLESS PLATING (JW) WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('NICKEL/ELECTROLESS PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)' )) 'Com3 NICKEL/ELECTROLESS PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TIN PLATING (JW)'),0)'Com3 TIN PLATING (JW) WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TIN PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='TIN PLATING (JW)' )) 'Com3 TIN PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='GOLD PLATING (JW)'),0)'Com3 GOLD PLATING (JW) WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('GOLD PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='GOLD PLATING (JW)' )) 'Com3 GOLD PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CHROME PLATING (JW)'),0)'Com3 CHROME PLATING (JW) WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CHROME PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='CHROME PLATING (JW)' )) 'Com3 CHROME PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PASSIVATION (JW)'),0)'Com3 PASSIVATION (JW) WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PASSIVATION (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PASSIVATION (JW)' )) 'Com3 PASSIVATION (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ANODIZING (JW)'),0)'Com3 ANODIZING (JW) WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ANODIZING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='ANODIZING (JW)' )) 'Com3 ANODIZING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ZINC PLATING (JW)'),0)'Com3 ZINC PLATING (JW) WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ZINC PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='ZINC PLATING (JW)' )) 'Com3 ZINC PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SILVER PLATING (JW)'),0)'Com3 SILVER PLATING (JW) WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SILVER PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='SILVER PLATING (JW)' )) 'Com3 SILVER PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PIERCING (JW)'),0)'Com3 PIERCING (JW) WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PIERCING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PIERCING (JW)' )) 'Com3 PIERCING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PROFILE MILLING (JW)'),0)'Com3 PROFILE MILLING (JW) WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PROFILE MILLING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PROFILE MILLING (JW)' )) 'Com3 PROFILE MILLING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='WIRE CUTTING (JW)'),0)'Com3 WIRE CUTTING (JW) WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('WIRE CUTTING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='WIRE CUTTING (JW)' )) 'Com3 WIRE CUTTING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='STRAIGHT'),0)'Com3 STRAIGHT WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('STRAIGHT','QUALITY','ACCOUNTING') And L1.FinalPrCode='STRAIGHT' )) 'Com3 STRAIGHT Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='DISASSEMBLE'),0)'Com3 DISASSEMBLE WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('DISASSEMBLE','QUALITY','ACCOUNTING') And L1.FinalPrCode='DISASSEMBLE' )) 'Com3 DISASSEMBLE Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SOLDERING'),0)'Com3 SOLDERING WIP Qty',
case when T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity]) > 0 then 0 else
-(T12.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T12.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SOLDERING','QUALITY','ACCOUNTING') And L1.FinalPrCode='SOLDERING' )) 'Com3 SOLDERING Plan',


T3.[Code] as 'Component4', t13.[ItemName] 'Description4', T3.[Quantity] as 'Quantity4',

T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] as 'ExtQty4',

t13.OnHand as 'OnHand4',

case when t13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else

-(t13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end as 'Shortage4',


ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TURNING'),0)'Com4 TURNING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TURNING','QUALITY','ACCOUNTING') And L1.FinalPrCode='TURNING' )) 'Com4 TURNING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HOBBING'),0)'Com4 HOBBING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HOBBING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HOBBING' )) 'Com4 HOBBING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HONNING'),0)'Com4 HONNING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HONNING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HONNING' )) 'Com4 HONNING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='MILLING/SLOTTING'),0)'Com4 MILLING/SLOTTING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('MILLING/SLOTTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='MILLING/SLOTTING' )) 'Com4 MILLING/SLOTTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HEAT TREATMENT'),0)'Com4 HEAT TREATMENT WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HEAT TREATMENT','QUALITY','ACCOUNTING') And L1.FinalPrCode='HEAT TREATMENT' )) 'Com4 HEAT TREATMENT Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TEMPERING'),0)'Com4 TEMPERING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TEMPERING','QUALITY','ACCOUNTING') And L1.FinalPrCode='TEMPERING' )) 'Com4 TEMPERING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CARBURIZING'),0)'Com4 CARBURIZING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CARBURIZING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CARBURIZING' )) 'Com4 CARBURIZING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ANEALING'),0)'Com4 ANEALING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ANEALING','QUALITY','ACCOUNTING') And L1.FinalPrCode='ANEALING' )) 'Com4 ANEALING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='POLISHING'),0)'Com4 POLISHING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('POLISHING','QUALITY','ACCOUNTING') And L1.FinalPrCode='POLISHING' )) 'Com4 POLISHING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SAND BLASTING'),0)'Com4 SAND BLASTING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SAND BLASTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='SAND BLASTING' )) 'Com4 SAND BLASTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LASER MARKING'),0)'Com4 LASER MARKING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LASER MARKING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LASER MARKING' )) 'Com4 LASER MARKING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LASER WELDING'),0)'Com4 LASER WELDING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LASER WELDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LASER WELDING' )) 'Com4 LASER WELDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HUGI/SURFACE GRINDING'),0)'Com4 HUGI/SURFACE GRINDING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HUGI/SURFACE GRINDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HUGI/SURFACE GRINDING' )) 'Com4 HUGI/SURFACE GRINDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LAPPING/TAPPING/BUFFING'),0)'Com4 LAPPING/TAPPING/BUFFING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LAPPING/TAPPING/BUFFING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LAPPING/TAPPING/BUFFING' )) 'Com4 LAPPING/TAPPING/BUFFING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CHAMFERING/PIP REMOVING'),0)'Com4 CHAMFERING/PIP REMOVING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CHAMFERING/PIP REMOVING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CHAMFERING/PIP REMOVING' )) 'Com4 CHAMFERING/PIP REMOVING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CENTRELESS GRINDING'),0)'Com4 CENTRELESS GRINDING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CENTRELESS GRINDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CENTRELESS GRINDING' )) 'Com4 CENTRELESS GRINDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='EDM/WIRE EDM'),0)'Com4 EDM/WIRE EDM WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('EDM/WIRE EDM','QUALITY','ACCOUNTING') And L1.FinalPrCode='EDM/WIRE EDM' )) 'Com4 EDM/WIRE EDM Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='BACK DRILLING/BORING/SLITTING'),0)'Com4 BACK DRILLING/BORING/SLITTING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('BACK DRILLING/BORING/SLITTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='BACK DRILLING/BORING/SLITTING' )) 'Com4 BACK DRILLING/BORING/SLITTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ASSEMBLY/PUNCHING'),0)'Com4 ASSEMBLY/PUNCHING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ASSEMBLY/PUNCHING','QUALITY','ACCOUNTING') And L1.FinalPrCode='ASSEMBLY/PUNCHING' )) 'Com4 ASSEMBLY/PUNCHING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='BURNISHING/SALLAZE'),0)'Com4 BURNISHING/SALLAZE WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('BURNISHING/SALLAZE','QUALITY','ACCOUNTING') And L1.FinalPrCode='BURNISHING/SALLAZE' )) 'Com4 BURNISHING/SALLAZE Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='DRILLING'),0)'Com4 DRILLING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('DRILLING','QUALITY','ACCOUNTING') And L1.FinalPrCode='DRILLING' )) 'Com4 DRILLING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='FINAL ACCOUTING'),0)'Com4 FINAL ACCOUTING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('FINAL ACCOUTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='FINAL ACCOUTING' )) 'Com4 FINAL ACCOUTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='FINAL QUALITY'),0)'Com4 FINAL QUALITY WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('FINAL QUALITY','QUALITY','ACCOUNTING') And L1.FinalPrCode='FINAL QUALITY' )) 'Com4 FINAL QUALITY Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)'),0)'Com4 NICKEL/ELECTROLESS PLATING (JW) WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('NICKEL/ELECTROLESS PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)' )) 'Com4 NICKEL/ELECTROLESS PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TIN PLATING (JW)'),0)'Com4 TIN PLATING (JW) WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TIN PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='TIN PLATING (JW)' )) 'Com4 TIN PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='GOLD PLATING (JW)'),0)'Com4 GOLD PLATING (JW) WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('GOLD PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='GOLD PLATING (JW)' )) 'Com4 GOLD PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CHROME PLATING (JW)'),0)'Com4 CHROME PLATING (JW) WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CHROME PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='CHROME PLATING (JW)' )) 'Com4 CHROME PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PASSIVATION (JW)'),0)'Com4 PASSIVATION (JW) WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PASSIVATION (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PASSIVATION (JW)' )) 'Com4 PASSIVATION (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ANODIZING (JW)'),0)'Com4 ANODIZING (JW) WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ANODIZING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='ANODIZING (JW)' )) 'Com4 ANODIZING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ZINC PLATING (JW)'),0)'Com4 ZINC PLATING (JW) WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ZINC PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='ZINC PLATING (JW)' )) 'Com4 ZINC PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SILVER PLATING (JW)'),0)'Com4 SILVER PLATING (JW) WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SILVER PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='SILVER PLATING (JW)' )) 'Com4 SILVER PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PIERCING (JW)'),0)'Com4 PIERCING (JW) WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PIERCING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PIERCING (JW)' )) 'Com4 PIERCING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PROFILE MILLING (JW)'),0)'Com4 PROFILE MILLING (JW) WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PROFILE MILLING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PROFILE MILLING (JW)' )) 'Com4 PROFILE MILLING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='WIRE CUTTING (JW)'),0)'Com4 WIRE CUTTING (JW) WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('WIRE CUTTING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='WIRE CUTTING (JW)' )) 'Com4 WIRE CUTTING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='STRAIGHT'),0)'Com4 STRAIGHT WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('STRAIGHT','QUALITY','ACCOUNTING') And L1.FinalPrCode='STRAIGHT' )) 'Com4 STRAIGHT Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='DISASSEMBLE'),0)'Com4 DISASSEMBLE WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('DISASSEMBLE','QUALITY','ACCOUNTING') And L1.FinalPrCode='DISASSEMBLE' )) 'Com4 DISASSEMBLE Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SOLDERING'),0)'Com4 SOLDERING WIP Qty',
case when T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity]) > 0 then 0 else
-(T13.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T13.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SOLDERING','QUALITY','ACCOUNTING') And L1.FinalPrCode='SOLDERING' )) 'Com4 SOLDERING Plan',

T4.[Code] as 'Component5', t14.[ItemName] 'Description5', T4.[Quantity] as 'Quantity5',

T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity] as 'ExtQty5',

t14.OnHand as 'OnHand5',

case when t14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else

-(t14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end as 'Shortage5',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TURNING'),0)'Com5 TURNING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TURNING','QUALITY','ACCOUNTING') And L1.FinalPrCode='TURNING' )) 'Com5 TURNING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HOBBING'),0)'Com5 HOBBING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HOBBING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HOBBING' )) 'Com5 HOBBING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HONNING'),0)'Com5 HONNING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HONNING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HONNING' )) 'Com5 HONNING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='MILLING/SLOTTING'),0)'Com5 MILLING/SLOTTING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('MILLING/SLOTTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='MILLING/SLOTTING' )) 'Com5 MILLING/SLOTTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HEAT TREATMENT'),0)'Com5 HEAT TREATMENT WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HEAT TREATMENT','QUALITY','ACCOUNTING') And L1.FinalPrCode='HEAT TREATMENT' )) 'Com5 HEAT TREATMENT Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TEMPERING'),0)'Com5 TEMPERING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TEMPERING','QUALITY','ACCOUNTING') And L1.FinalPrCode='TEMPERING' )) 'Com5 TEMPERING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CARBURIZING'),0)'Com5 CARBURIZING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CARBURIZING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CARBURIZING' )) 'Com5 CARBURIZING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ANEALING'),0)'Com5 ANEALING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ANEALING','QUALITY','ACCOUNTING') And L1.FinalPrCode='ANEALING' )) 'Com5 ANEALING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='POLISHING'),0)'Com5 POLISHING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('POLISHING','QUALITY','ACCOUNTING') And L1.FinalPrCode='POLISHING' )) 'Com5 POLISHING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SAND BLASTING'),0)'Com5 SAND BLASTING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SAND BLASTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='SAND BLASTING' )) 'Com5 SAND BLASTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LASER MARKING'),0)'Com5 LASER MARKING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LASER MARKING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LASER MARKING' )) 'Com5 LASER MARKING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LASER WELDING'),0)'Com5 LASER WELDING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LASER WELDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LASER WELDING' )) 'Com5 LASER WELDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='HUGI/SURFACE GRINDING'),0)'Com5 HUGI/SURFACE GRINDING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('HUGI/SURFACE GRINDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='HUGI/SURFACE GRINDING' )) 'Com5 HUGI/SURFACE GRINDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='LAPPING/TAPPING/BUFFING'),0)'Com5 LAPPING/TAPPING/BUFFING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('LAPPING/TAPPING/BUFFING','QUALITY','ACCOUNTING') And L1.FinalPrCode='LAPPING/TAPPING/BUFFING' )) 'Com5 LAPPING/TAPPING/BUFFING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CHAMFERING/PIP REMOVING'),0)'Com5 CHAMFERING/PIP REMOVING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CHAMFERING/PIP REMOVING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CHAMFERING/PIP REMOVING' )) 'Com5 CHAMFERING/PIP REMOVING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CENTRELESS GRINDING'),0)'Com5 CENTRELESS GRINDING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CENTRELESS GRINDING','QUALITY','ACCOUNTING') And L1.FinalPrCode='CENTRELESS GRINDING' )) 'Com5 CENTRELESS GRINDING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='EDM/WIRE EDM'),0)'Com5 EDM/WIRE EDM WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('EDM/WIRE EDM','QUALITY','ACCOUNTING') And L1.FinalPrCode='EDM/WIRE EDM' )) 'Com5 EDM/WIRE EDM Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='BACK DRILLING/BORING/SLITTING'),0)'Com5 BACK DRILLING/BORING/SLITTING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('BACK DRILLING/BORING/SLITTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='BACK DRILLING/BORING/SLITTING' )) 'Com5 BACK DRILLING/BORING/SLITTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ASSEMBLY/PUNCHING'),0)'Com5 ASSEMBLY/PUNCHING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ASSEMBLY/PUNCHING','QUALITY','ACCOUNTING') And L1.FinalPrCode='ASSEMBLY/PUNCHING' )) 'Com5 ASSEMBLY/PUNCHING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='BURNISHING/SALLAZE'),0)'Com5 BURNISHING/SALLAZE WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('BURNISHING/SALLAZE','QUALITY','ACCOUNTING') And L1.FinalPrCode='BURNISHING/SALLAZE' )) 'Com5 BURNISHING/SALLAZE Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='DRILLING'),0)'Com5 DRILLING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('DRILLING','QUALITY','ACCOUNTING') And L1.FinalPrCode='DRILLING' )) 'Com5 DRILLING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='FINAL ACCOUTING'),0)'Com5 FINAL ACCOUTING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('FINAL ACCOUTING','QUALITY','ACCOUNTING') And L1.FinalPrCode='FINAL ACCOUTING' )) 'Com5 FINAL ACCOUTING Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='FINAL QUALITY'),0)'Com5 FINAL QUALITY WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('FINAL QUALITY','QUALITY','ACCOUNTING') And L1.FinalPrCode='FINAL QUALITY' )) 'Com5 FINAL QUALITY Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)'),0)'Com5 NICKEL/ELECTROLESS PLATING (JW) WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('NICKEL/ELECTROLESS PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='NICKEL/ELECTROLESS PLATING (JW)' )) 'Com5 NICKEL/ELECTROLESS PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='TIN PLATING (JW)'),0)'Com5 TIN PLATING (JW) WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('TIN PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='TIN PLATING (JW)' )) 'Com5 TIN PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='GOLD PLATING (JW)'),0)'Com5 GOLD PLATING (JW) WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('GOLD PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='GOLD PLATING (JW)' )) 'Com5 GOLD PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='CHROME PLATING (JW)'),0)'Com5 CHROME PLATING (JW) WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('CHROME PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='CHROME PLATING (JW)' )) 'Com5 CHROME PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PASSIVATION (JW)'),0)'Com5 PASSIVATION (JW) WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PASSIVATION (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PASSIVATION (JW)' )) 'Com5 PASSIVATION (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ANODIZING (JW)'),0)'Com5 ANODIZING (JW) WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ANODIZING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='ANODIZING (JW)' )) 'Com5 ANODIZING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='ZINC PLATING (JW)'),0)'Com5 ZINC PLATING (JW) WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('ZINC PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='ZINC PLATING (JW)' )) 'Com5 ZINC PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SILVER PLATING (JW)'),0)'Com5 SILVER PLATING (JW) WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SILVER PLATING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='SILVER PLATING (JW)' )) 'Com5 SILVER PLATING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PIERCING (JW)'),0)'Com5 PIERCING (JW) WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PIERCING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PIERCING (JW)' )) 'Com5 PIERCING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='PROFILE MILLING (JW)'),0)'Com5 PROFILE MILLING (JW) WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('PROFILE MILLING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='PROFILE MILLING (JW)' )) 'Com5 PROFILE MILLING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='WIRE CUTTING (JW)'),0)'Com5 WIRE CUTTING (JW) WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('WIRE CUTTING (JW)','QUALITY','ACCOUNTING') And L1.FinalPrCode='WIRE CUTTING (JW)' )) 'Com5 WIRE CUTTING (JW) Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='STRAIGHT'),0)'Com5 STRAIGHT WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('STRAIGHT','QUALITY','ACCOUNTING') And L1.FinalPrCode='STRAIGHT' )) 'Com5 STRAIGHT Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='DISASSEMBLE'),0)'Com5 DISASSEMBLE WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('DISASSEMBLE','QUALITY','ACCOUNTING') And L1.FinalPrCode='DISASSEMBLE' )) 'Com5 DISASSEMBLE Plan',

ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.FinalPrCode='SOLDERING'),0)'Com5 SOLDERING WIP Qty',
case when T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity]) > 0 then 0 else
-(T14.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity])) end -
ISNULL((Select SUM(P1.WIPQTY) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT),0 ) +
(Select ISNULL(SUM(P1.WIPQTY),0.00) From #WIPPPR P1 Where P1.ItemCode1=T14.FrgnName COLLATE DATABASE_DEFAULT And P1.Seq <
(Select Min(L1.Seq) From #WIPPPR L1 Where L1.ItemCode1=P1.ItemCode1 COLLATE DATABASE_DEFAULT And L1.PrCode in ('SOLDERING','QUALITY','ACCOUNTING') And L1.FinalPrCode='SOLDERING' )) 'Com5 SOLDERING Plan',


T5.[Code] as 'Component6', t15.[ItemName] 'Description6', T5.[Quantity] as 'Quantity6',

T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity] * t5.[Quantity] as 'ExtQty6',

t15.OnHand as 'OnHand6',

case when t15.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity] * t5.[Quantity]) > 0 then 0 else

-(t15.OnHand - (T202.U_PPQT * t0.[Quantity] * t1.[Quantity] * t2.[Quantity] * t3.[Quantity] * t4.[Quantity] * t5.[Quantity])) end as 'Shortage6' 

FROM ITT1 T0 
LEFT OUTER JOIN ITT1 T1 on T0.Code = T1.Father
LEFT OUTER JOIN ITT1 T2 on T1.Code = T2.Father
LEFT OUTER JOIN ITT1 T3 on T2.Code = T3.Father
LEFT OUTER JOIN ITT1 T4 on T3.Code = T4.Father
LEFT OUTER JOIN ITT1 T5 on T4.Code = T5.Father
LEFT OUTER JOIN ITT1 T6 on T5.Code = T6.Father
left outer join oitm t20 on t0.father = t20.itemcode
left outer join oitm t10 on t0.code = t10.itemcode
left outer join oitm t11 on t1.code = t11.itemcode
left outer join oitm t12 on t2.code = t12.itemcode
left outer join oitm t13 on t3.code = t13.itemcode
left outer join oitm t14 on t4.code = t14.itemcode
left outer join oitm t15 on t5.code = t15.itemcode 
Left Outer Join [dbo].[@BOMD] T202 on T202.U_PARI =T0.Father 
WHERE T0.[Father] Like '%%%-WIP'---= '20-32-040-01-WIP' 
And T202.DocEntry = @DocEntry ---(Select Max(T21.DocEntry) From [dbo].[@BOMH] T21 ) --And T20.ItmsGrpCod='118'

Drop table #WIPPPR
END;
