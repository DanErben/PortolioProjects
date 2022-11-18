/*
Cleaning Data in SQL Queries
*/

USE PortfolioProject;
Select *  From PortfolioProject.nashvillehousing;

-- ------------------------------------------------------------------------------------------------------------------------
-- Standardize date format.  Convert data type from text to date.

ALTER TABLE nashvillehousing
MODIFY SaleDate date;


-- ------------------------------------------------------------------------------------------------------------------------
-- Split PropertyAddress(Address, City) into individual columns for usability. 

SELECT PropertyAddress  
FROM PortfolioProject.NashvilleHousing;

-- Address
SELECT SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1)  AS Address
FROM PortfolioProject.NashvilleHousing;

-- City
SELECT SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress)+1, LENGTH(PropertyAddress))  AS City
FROM PortfolioProject.NashvilleHousing;


-- Adding split PropertyAddress columns to the table.
-- Address
ALTER TABLE nashvillehousing
ADD COLUMN PropertySplitAddress VARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1);

-- City
ALTER TABLE nashvillehousing
ADD COLUMN PropertySplitCity VARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress)+1, LENGTH(PropertyAddress));



-- ------------------------------------------------------------------------------------------------------------------------
-- Splitting OwnerAddress(Address, City, State) into individual columns for usability. 
SELECT OwnerAddress 
FROM PortfolioProject.NashvilleHousing;

-- Address
SELECT SUBSTRING(OwnerAddress, 1, POSITION(',' IN OwnerAddress)-1) AS OwnerSplitAddress
FROM PortfolioProject.NashvilleHousing;


-- City
SELECT SUBSTRING(
SUBSTRING(OwnerAddress, 1, LENGTH(OwnerAddress)-4),
POSITION(',' IN OwnerAddress)+1,
LENGTH(OwnerAddress)
)  
AS OwnerSplitCity
FROM PortfolioProject.NashvilleHousing; 


-- State
SELECT RIGHT(OwnerAddress,2)  AS OwnerSplitState
FROM PortfolioProject.NashvilleHousing;



-- Adding split OwnerAddress columns to the table.
-- Address
ALTER TABLE nashvillehousing
ADD COLUMN OwnerSplitAddress VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, POSITION(',' IN OwnerAddress)-1);

-- City
ALTER TABLE nashvillehousing
ADD COLUMN OwnerSplitCity VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitCity = 
SUBSTRING(
SUBSTRING(OwnerAddress, 1, LENGTH(OwnerAddress)-4),
POSITION(',' IN OwnerAddress)+1,
LENGTH(OwnerAddress)
);

-- State
ALTER TABLE nashvillehousing
ADD COLUMN OwnerSplitState VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitState = RIGHT(OwnerAddress,2);


-- -------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, DROP COLUMN PropertyAddress;


-- ------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in the "Sold as Vacant" column.

SELECT DISTINCT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END AS Yes_No
FROM nashvillehousing;

--
UPDATE nashvillehousing
SET SoldAsVacant =
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END;


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------
-- Check for duplicate rows using a CTE.

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER(
PARTITION BY UniqueID, 
			 ParcelID, 
			 PropertyAddress, 
             LegalReference
             ORDER BY UniqueID)  AS row_num
 From PortfolioProject.nashvillehousing
				)
SELECT *   
FROM RowNumCTE
WHERE row_num >1;









