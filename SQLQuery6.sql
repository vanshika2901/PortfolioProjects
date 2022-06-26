--cleaning the data

select * from project_portfolio.dbo.NashvilleHousing$

--strandadize date format
select saledateconverted from project_portfolio..NashvilleHousing$



Alter table project_portfolio..NashvilleHousing$
add SaleDateConverted date

Update project_portfolio.dbo.NashvilleHousing$
set SaleDateConverted=convert(date,saledate)


--populate property address data 

-- where 2 parcelId are same there the address of one=two
select * from project_portfolio..NashvilleHousing$ order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.propertyaddress,b.PropertyAddress)
from 
project_portfolio..NashvilleHousing$ a join project_portfolio..NashvilleHousing$ b on 
a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ] where a.PropertyAddress is null

update a
set propertyaddress=isnull(a.propertyaddress,b.PropertyAddress)
from 
project_portfolio..NashvilleHousing$ a join project_portfolio..NashvilleHousing$ b on 
a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ] where a.PropertyAddress is null



--Breaking out address into individual columns (Address,city,state)
select PropertyAddress,SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1),
SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress))
from project_portfolio..NashvilleHousing$

alter table project_portfolio..NashvilleHousing$
add propertysplitaddress varchar(250)

update project_portfolio..NashvilleHousing$
set propertysplitaddress = SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) 

alter table project_portfolio..NashvilleHousing$
add propertysplitcity varchar(250)

update project_portfolio..NashvilleHousing$
set propertysplitcity= SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(propertyaddress))

select * from project_portfolio..NashvilleHousing$

-- splitting the owner address
select OwnerAddress from project_portfolio..NashvilleHousing$

-- using parsename to split the owneraddress based on period('.'). The deliminitor it uses is '.'
-- parsename extracts backwards

select parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from project_portfolio..NashvilleHousing$

alter table project_portfolio..NashvilleHousing$
add ownersplitaddress varchar(255);

update project_portfolio..NashvilleHousing$
set ownersplitaddress=parsename(replace(OwnerAddress,',','.'),3);

alter table project_portfolio..NashvilleHousing$
add ownersplitcity varchar(255);

update project_portfolio..NashvilleHousing$
set ownersplitcity=parsename(replace(OwnerAddress,',','.'),2);

alter table project_portfolio..NashvilleHousing$
add ownersplitstate varchar(255);

update project_portfolio..NashvilleHousing$
set ownersplitstate=parsename(replace(OwnerAddress,',','.'),1);


select * from project_portfolio..NashvilleHousing$


-- change y and n to yes or no in the 'Sold as vacant' field

select distinct soldasvacant from project_portfolio..NashvilleHousing$

select soldasvacant,
case when soldasvacant='Y' then 'Yes'
	 when soldasvacant='N' then 'No'
	 else SoldAsVacant end from project_portfolio..NashvilleHousing$;

update project_portfolio..NashvilleHousing$
set soldasvacant=case when soldasvacant='Y' then 'Yes'
	 when soldasvacant='N' then 'No'
	 else SoldAsVacant end from project_portfolio..NashvilleHousing$;


--Remove Duplicates
with rownumcte as(
select *,Row_Number() over(partition by ParcelID, propertyaddress,SalePrice,SaleDate,
LegalReference order by uniqueID) row_num from project_portfolio..NashvilleHousing$)

Delete from rownumcte where row_num>1;



--Delete unused columns
alter table project_portfolio..NashvilleHousing$ 
drop column owneraddress 

alter table project_portfolio..NashvilleHousing$ 
drop column Propertyaddress,TaxDistrict

alter table project_portfolio..NashvilleHousing$ 
drop column saledate

select * from project_portfolio..NashvilleHousing$




