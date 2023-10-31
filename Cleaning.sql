-- Cleaing theh data using sql queries 
select * from HosuingData

--Change the date format excluding the time beacsue it's irrelvlant
select SaleDate,convert(Date,SaleDate) as FormatDate from HosuingData
update HosuingData 
Set SaleDate= Convert(Date,SaleDate)

-- when update is not working create a new column
alter table HosuingData
add SalesConvertedDate Date;

update HosuingData
set SalesConvertedDate= Convert(Date,SaleDate)
---------------------------------------------------------------------------------------------------------------
--popluate the address data
select a.ParcelID,a.[UniqueID ],a.PropertyAddress,b.ParcelID,b.[UniqueID ] , b.PropertyAddress , isnull(a.PropertyAddress,b.PropertyAddress) as tada
from HosuingData a join HosuingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is  null


update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from HosuingData a join HosuingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------

--Breaking Address into columns (Address,City,State)
select * from HosuingData
-- FOUND ADDRESS BEFORE COMMA 
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)
from HosuingData
-- FOUND ADDRESS AFTER COMMA 
select 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
from HosuingData

--adding columns for splitadress & city

alter table HosuingData
add PropertySplitAddress nvarchar(255);

update HosuingData
set PropertySplitAddress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

alter table HosuingData
add PropertySplitCity nvarchar(255);
update HosuingData
set PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select * from HosuingData

-----------------------------------otherway to spilt address,city & state-------------------------------------------------------------------

select  
ParseName(Replace(OwnerAddress,',','.'),1) as OwnerAddressState, --parsename find backwards the the first period, replace is used to , to .
ParseName(Replace(OwnerAddress,',','.'),2) as OwnerAddressCity, --parsename find backwards the the first period, replace is used to , to .
ParseName(Replace(OwnerAddress,',','.'),3) as OwnerAddress--parsename find backwards the the first period, replace is used to , to .
from HosuingData


alter table HosuingData
add OnwerSplitAddress nvarchar(255);
update HosuingData
set OnwerSplitAddress= ParseName(Replace(OwnerAddress,',','.'),3)

alter table HosuingData
add OnwerSplitCity nvarchar(255),
add OnwerSplitState nvarchar(255);

update HosuingData
set OnwerSplitCity= ParseName(Replace(OwnerAddress,',','.'),2)
update HosuingData
set OnwerSplitState= ParseName(Replace(OwnerAddress,',','.'),1)

select * from HosuingData

-------Change Y or N to Yes & NO-------------------------------------------------------
select Distinct(SoldAsVacant),count(SoldAsVacant) from HosuingData
group by SoldAsVacant
order by 2

select SoldAsVacant,
case 
	when SoldAsVacant ='Y' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	Else SoldAsVacant
end
from HosuingData

Update HosuingData
set SoldAsVacant=
case 
	when SoldAsVacant ='Y' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	Else SoldAsVacant
end

-------------------------------Remove Duplicates-----------------------------------------------------

with RowNum as(
Select * ,
	ROW_NUMBER() over (
	partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	order by UniqueId
	) as row_num
	from PortfolioProject.dbo.HosuingData
--order by ParcelID
)
delete from RowNum
where row_num > 1
--order by PropertyAddress

----------------------------------------------Delete Unused Columns-------------------
Alter Table PortfolioProject.dbo.HosuingData
drop column OwnerAddress,TaxDistrict,PropertyAddress

select * from HosuingData