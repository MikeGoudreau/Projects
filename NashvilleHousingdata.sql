Select *
From PortfolioProject.dbo.NashvilleHousing


-------- Changing Saledate \/

Select SaleDateConverted, CONVERT(Date,saleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,saleDate)


Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,saleDate)



-- Filling in property Address data \/

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress in null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


----- Change Addresses to individual columns \/


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress in null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing




---- Creating new columns for PropertyAddress / city \/


ALTER Table NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


Select*
From PortfolioProject.dbo.NashvilleHousing




--- New Address split for OwnerAddress (Address / City / State) \/

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER Table NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter Table NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter Table NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select*
From PortfolioProject.dbo.NashvilleHousing




--- Changing sold as vacant y=yes n=no

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant


Select SoldAsVacant
,  Case When SoldAsVacant  = 'y' THEN 'Yes'
		When SoldAsVacant  = 'n' THEN 'No'
		Else SoldAsVacant
		End
from PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant  = 'y' THEN 'Yes'
		When SoldAsVacant  = 'n' THEN 'No'
		Else SoldAsVacant
		End
from PortfolioProject.dbo.NashvilleHousing



----- Removing duplicates \/


WITH RowNumCTE AS(
Select*, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order BY
					UniqueID
					) Row_num
from PortfolioProject.dbo.NashvilleHousing
--Order By ParcelID
)
Select *
From RowNumCTE
Where Row_num > 1
--Order by PropertyAddress



------- Delete Columns that aren't being used



Select*
from PortfolioProject.dbo.NashvilleHousing


ALTER Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



ALTER Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate


-------------------- Querys \/ #1


Select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing