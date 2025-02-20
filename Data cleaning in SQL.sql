-- CLeaning DATA in SQL


SELECT *
FROM housing
;

-- Standardazie Date Format

SELECT saledate, date_format(saledate, '%Y-%m-%d')
FROM housing;

ALTER TABLE housing
Add SaleDateConverted Date;

UPDATE housing
SET  SaleDateConverted = date_format(saledate, '%Y-%m-%d')
;

SELECT SaleDateConverted
FROM housing;

-- Populate Property Address Data

SELECT *
FROM housing
ORDER BY ParcelID
;

SELECT h1.ParcelID, h1.PropertyAddress, h2.ParcelID, h2.PropertyAddress, ifnull(h1.propertyaddress, h2.propertyaddress)
FROM housing h1
JOIN housing h2
on h1.ParcelID = h2.ParcelID
AND h1.UniqueID <> h2.UniqueID
WHERE h1.PropertyAddress IS NULL
;

SELECT ifnull(h1.propertyaddress, h2.propertyaddress)
FROM housing h1
JOIN housing h2
on h1.ParcelID = h2.ParcelID
AND h1.UniqueID <> h2.UniqueID
WHERE h1.PropertyAddress IS NULL
;

-- Breaking out Address into Address, City, State

SELECT
substr(PropertyAddress, 1, position(',' in PropertyAddress) -1) as Address,
substr(PropertyAddress, position(',' in PropertyAddress)+1, length(propertyaddress)) as Address

FROM housing;

ALTER TABLE housing
ADD PropertySplitAddress varchar(255);

UPDATE housing
SET PropertySplitAddress = substr(PropertyAddress, 1, position(',' in PropertyAddress) -1);

ALTER TABLE housing
ADD PropertySplitCity varchar(255);

UPDATE housing
SET PropertySplitCity = substr(PropertyAddress, position(',' in PropertyAddress)+1, length(propertyaddress));

SELECT substring_index(OwnerAddress, ',', -1),
substring_index(OwnerAddress, ',', 2)
FROM housing;

ALTER TABLE housing
ADD OwnerSplitStateAddress varchar(255);

UPDATE housing
SET OwnerSplitStateAddress = substring_index(OwnerAddress, ',', -1);

ALTER TABLE housing
ADD OwnerSplitAddress varchar(255);

UPDATE housing
SET OwnerSplitAddress = substring_index(OwnerAddress, ',', 2);

SELECT substring_index(OwnerSplitAddress, ',', -1),
substring_index(OwnerSplitAddress, ',', 1)
FROM housing;

ALTER TABLE housing
ADD OwnerSplitCity varchar(255);

UPDATE housing
SET OwnerSplitCity = substring_index(OwnerSplitAddress, ',', -1);

ALTER TABLE housing
ADD OwnerSplitStreet varchar(255);

UPDATE housing
SET OwnerSplitStreet = substring_index(OwnerSplitAddress, ',', 1);

SELECT OwnerSplitStateAddress, OwnerSplitCity, OwnerSplitStreet
FROM housing
;

-- Replace Y and N as Yes and No

SELECT SoldAsVacant, COUNT(soldasvacant)
FROM housing
GROUP BY SoldAsVacant
ORDER BY 2
;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM housing
;

UPDATE housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END;
    
    
    
    -- Removing duplicates


WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY
				UniqueID
                ) row_num
FROM housing
-- ORDER BY ParcelID
)
DELETE
FROM housing
USING housing
JOIN RowNumCTE ON housing.UniqueID = RowNumCTE.UniqueID
WHERE row_num > 1
;

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY
				UniqueID
                ) row_num
FROM housing
-- ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
;

-- Delete unused columns

SELECT *
FROM housing
;

ALTER TABLE housing
DROP COLUMN PropertyAddress,
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN OwnerSplitAddress
;

ALTER TABLE housing
DROP COLUMN SaleDate
;

