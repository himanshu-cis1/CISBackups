USE [DukeLiveNew]
GO
/****** Object:  StoredProcedure [dbo].[DUKE_MATERIAL_CFL]    Script Date: 02-12-2024 10:14:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER procedure  [dbo].[DUKE_MATERIAL_CFL] 
(
@mode	varchar(40),
@parameter1	nvarchar(40)=null,
@parameter2	nvarchar(40)=null,
@parameter3	nvarchar(40)=null,
@parameter4	nvarchar(40)=null,
@parameter5	nvarchar(40)=null,
@parameter6	nvarchar(40)=null,
@parameter7	nvarchar(40)=null,
@parameter8	nvarchar(40)=null,
@parameter9	nvarchar(40)=null,
@parameter10	nvarchar(40)=null,
@parameter11	nvarchar(40)=null,
@ColumnName nvarchar(60)=null,
@order  nvarchar(60)=null , 
@DOC  nvarchar(60)=null 
)
as
BEGIN

if(@parameter2)=''
begin
set @parameter2=NULL
end
IF (@parameter3)=''
begin
set @parameter3=NULL
end
IF (@parameter4)=''
begin
set @parameter4=NULL
end
IF (@parameter5)=''
begin
set @parameter5=NULL
end

IF (@parameter6)=''
begin
set @parameter6=NULL
end

IF (@parameter7)=''
begin
set @parameter7=NULL
end

IF (@parameter8)=''
begin
set @parameter8=NULL
end

IF (@parameter9)=''
begin
set @parameter9=NULL
end

IF (@parameter10)=''
begin
set @parameter10=NULL
end
IF (@parameter11)=''
begin
set @parameter11=NULL
end


----------------------------------------------------------

IF upper (@mode)='get_ItemGroup'						  
begin 
Select ItmsGrpCod,ItmsGrpNam from OITB;

end



IF upper (@mode)='getUser'						  
begin 
select USER_CODE,U_NAME,GROUPS from OUSR;

end



IF upper (@mode)='getbin'						  
begin 
select  Distinct U_BNAME AS BIN,U_SBNAME AS SBName from OITM(nolock) Where ItmsGrpCod =  @parameter5  AND U_BNAME is not null;


end

IF upper (@mode)='getsubbin'						  
begin 
select Distinct U_SBNAME AS SBName ,U_BNAME AS BIN from OITM(nolock) Where U_BNAME =  @parameter2   AND U_SBName is not null;

end

IF upper (@mode)='getItems'						  
begin 
--select  Distinct T0.ItemCode,T0.ItemName,T1.OnHand from  OITM(nolock) T0 INNER JOIN OITW(nolock) T1 ON T0.[ItemCode] = T1.[ItemCode] Where U_SBNAME =  @parameter3 AND T1.WhsCode= @parameter10 ;

select  Distinct T0.ItemCode,T0.ItemName from  OITM(nolock) T0  Where T0.U_SBNAME =  @parameter3  ;
end





IF upper (@mode)='getArticle'						  
begin 
Select Distinct FrgnName Article,U_SizeG 'SizeGarment' from OITM Where ItmsGrpCod = @parameter6   AND FrgnName is not null;

end

IF upper (@mode)='getSize'						  
begin 
Select  Distinct U_SizeG 'SizeGarment' ,U_Color  from OITM Where FrgnName = @parameter7   AND U_SizeG is not null;

end

IF upper (@mode)='getColor'						  
begin 
Select  Distinct U_Color,U_SizeG 'SizeGarment'  from OITM Where U_SizeG = @parameter8   AND U_Color is not null;

end

IF upper (@mode)='getItems2'						  
begin 
select Distinct  T0.ItemCode,T0.ItemName from  OITM T0  Where T0.U_Color =  @parameter9;

end


IF upper (@mode)='warehouse'						  
begin 
select Distinct WhsCode, WhsName from OWHS(nolock) ;

end


IF upper (@mode)='BpCode'						  
begin 
select Distinct CardCode, CardName from OCRD(nolock) ;


end



IF upper (@mode)='getUsertwo'						  
begin 
select Distinct U_USERC AS Usercod, U_USERN AS UserName from [@USERH] ;


end





IF upper (@mode)='getsendor'						  
begin 
select Distinct U_SENDC AS Sendorcod, U_SENDN AS SendorName from [@SENDH] ;


end



END
