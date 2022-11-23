

-- STANDARDIZE DATE FORMAT
SELECT SaleDate, CONVERT(Date,SaleDate) FROM PortfolioProject.dbo.NashvileHousing

ALTER TABLE NashvileHousing
ADD SaleDateConverted Date;

UPDATE NashvileHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- POPULATE PROPERTY ADDRESS DATA
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvileHousing a 
JOIN PortfolioProject.dbo.NashvileHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvileHousing a
JOIN PortfolioProject.dbo.NashvileHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS 
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS ADRESS,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS CITY
FROM PortfolioProject.dbo.NashvileHousing

ALTER TABLE NashvileHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvileHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


 -- BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMNS 
 SELECT OwnerAddress FROM PortfolioProject.dbo.NashvileHousing

 SELECT
 PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
 PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
 PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
 FROM PortfolioProject.dbo.NashvileHousing


ALTER TABLE NashvileHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvileHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvileHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


-- CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvileHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvileHousing

UPDATE NashvileHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvileHousing


-- REMOVE DUPLICATES
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
						
FROM PortfolioProject.dbo.NashvileHousing
)

DELETE FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-- DELETE UNUSED COLUMNS
ALTER TABLE PortfolioProject.dbo.NashvileHousing
DROP CLOUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate