USE [DukeLiveNew]
GO
/****** Object:  StoredProcedure [dbo].[Item_CFL]    Script Date: 02-12-2024 10:17:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure  [dbo].[Item_CFL] 
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


----------------------------------------------------------

IF upper (@mode)='get_ItemGroup'						  
begin 
Select Distinct ItmsGrpCod,ItmsGrpNam from OITB;

end



IF upper (@mode)='getUser'						  
begin 
select  Distinct USER_CODE,U_NAME,GROUPS from OUSR;

end



IF upper (@mode)='getbin'						  
begin 
select Distinct U_BNAME AS BIN,U_SBNAME AS SBName from OITM(nolock) Where ItmsGrpCod =  @parameter5 and U_BNAME is not null;

end

IF upper (@mode)='getsubbin'						  
begin 
select Distinct U_SBNAME AS SBName ,U_BNAME AS BIN from OITM(nolock) Where U_BNAME =  @parameter2   and U_SBNAME is not null;

end

IF upper (@mode)='getItems'						  
begin 
select Distinct ItemCode,ItemName from OITM(nolock) Where U_SBNAME =  @parameter3;

end

IF upper (@mode)='getArticle'						  
begin 
Select Distinct FrgnName Article,U_Color 'Color' from OITM Where ItmsGrpCod = @parameter6 and FrgnName is not null;

end

IF upper (@mode)='getSize'						  
begin 
Select Distinct U_SizeG 'SizeGarment' ,U_Color  from OITM Where U_Color = @parameter7 and U_SizeG is not null ;

end

IF upper (@mode)='getColor'						  
begin 
Select Distinct U_Color AS COLOR,U_SizeG 'SizeGarment'  from OITM Where FrgnName = @parameter8  and U_Color is not null;

end

IF upper (@mode)='getItems2'						  
begin 
select Distinct ItemCode,ItemName from OITM(nolock) Where U_SizeG =  @parameter9;

end


END
