/*
Cleaning Data in SQL Queries
*/

select *
from NashvilleHousing

-- Standardize Date Format

select saledate
from NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

-- Bcz it didn't Update properly

alter table nashvillehousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

select saledate
from NashvilleHousing


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


select *
from NashvilleHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from NashvilleHousing

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address1
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as address2
from NashvilleHousing

alter table nashvillehousing
add PropertySplitAddress Nvarchar(255);

alter table nashvillehousing
add PropertysplitCity Nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

update NashvilleHousing
SET PropertysplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select *
from NashvilleHousing

select
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from NashvilleHousing

alter table nashvillehousing
add OwnerSplitAddress Nvarchar(255);

alter table nashvillehousing
add OwnerSplitCity Nvarchar(255);

alter table nashvillehousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3)

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(owneraddress,',','.'),2)

update NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(owneraddress,',','.'),1)

select *
from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant) , COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant , 
Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as(
select *,
ROW_NUMBER() Over (
	Partition by	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by UniqueID
					) row_num
from NashvilleHousing
--order by ParcelID
)

delete
from RowNumCTE
where row_num >1
--order by PropertyAddress


with RowNumCTE as(
select *,
ROW_NUMBER() Over (
	Partition by	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by UniqueID
					) row_num
from NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE
where row_num >1
order by PropertyAddress

select *
from NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate