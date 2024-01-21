-- DATA CLEANING
Select * FROM Portfolio..NashvilleHousing$
-----------------------------------------------------------------------------------------------------------------------------

-- Standardize date format

Select SaleDate FROM Portfolio..NashvilleHousing$


Alter table NashvilleHousing$
add SaleDateConverted Date;


update NashvilleHousing$
set SaleDateConverted = CONVERT(date, SaleDate)

Select SaleDateConverted FROM Portfolio..NashvilleHousing$





--Populate property adress data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing$ a
join Portfolio..NashvilleHousing$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a 
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing$ a
join Portfolio..NashvilleHousing$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--Breaking out Address into individual columns
Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1), SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, len(PropertyAddress))
FROM Portfolio..NashvilleHousing$

Alter table NashvilleHousing$
add PropertySplitAddress Nvarchar(255);


update NashvilleHousing$
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


alter table NashvilleHousing$
add PropertySplitCity Nvarchar(255);


update NashvilleHousing$
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, len(PropertyAddress))

Select * FROM Portfolio..NashvilleHousing$

--Owner Address
Select Parsename(replace(OwnerAddress,',','.'),3) as OwnerStreet, Parsename(replace(OwnerAddress,',','.'),2) as OwnerCity, Parsename(replace(OwnerAddress,',','.'),1) as OwnerState
FROM Portfolio..NashvilleHousing$

alter table NashvilleHousing$
add OwnerSplitStreet Nvarchar(255);


update NashvilleHousing$
set OwnerSplitStreet = Parsename(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing$
add OwnerSplitCity Nvarchar(255);


update NashvilleHousing$
set OwnerSplitCity = Parsename(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing$
add OwnerSplitState Nvarchar(255);


update NashvilleHousing$
set OwnerSplitState = Parsename(replace(OwnerAddress,',','.'),1)


--Change "Y" and "N" to "Yes" and "No" in "Sold as vacant" field
Select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes' 
	 when SoldAsVacant = 'N' then 'No' 
	 else SoldAsVacant
	 END
From Portfolio..NashvilleHousing$


update NashvilleHousing$
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' 
						when SoldAsVacant = 'N' then 'No' 
						else SoldAsVacant
						END

Select distinct(SoldAsVacant), Count(SoldAsVacant) as countSoldAsVacant
FROM Portfolio..NashvilleHousing$
group by SoldAsVacant
Order by 2

--Remove duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio..NashvilleHousing$
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1


--Check if the duplicates were deleted
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio..NashvilleHousing$
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1





--Delete unused columns
Select *
From Portfolio..NashvilleHousing$


ALTER TABLE Portfolio..NashvilleHousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
