/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProjects.dbo.NashvilleHousing

----------------------------------------------------------------------------------------

-- Standardize Sale Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProjects.dbo.NashvilleHousing


ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProjects.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


----------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From PortfolioProjects.dbo.NashvilleHousing
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
Join PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a
Join PortfolioProjects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------

-- Breaking down Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProjects.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProjects.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProjects.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProjects.dbo.NashvilleHousing



ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProjects.dbo.NashvilleHousing


----------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProjects.dbo.NashvilleHousing


Update PortfolioProjects.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


----------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE AS(
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

From PortfolioProjects.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1 
Order by PropertyAddress



Select *
From PortfolioProjects.dbo.NashvilleHousing


----------------------------------------------------------------------------------------

-- Delete Unused Columns (eg. OwnerAddress, PropertyAddress, TaxDistrict, SaleDate)

Select *
From PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate