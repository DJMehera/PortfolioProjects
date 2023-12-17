-- Taking a look at the data from Nashville Housing Table
SELECT *
FROM housing_db..Nash_Housing


-- Updating SaleDate column datatype from Date-Time to Date

ALTER TABLE Nash_Housing
ALTER COLUMN SaleDate DATE


SELECT SaleDate
FROM housing_db..Nash_Housing


-- Populate PropertyAddress data
SELECT *
FROM housing_db..Nash_Housing
WHERE PropertyAddress IS NULL

-- Figuring out the relationship between ParcelID and PropertyAddress columns

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) AS Updated_Address
FROM housing_db..Nash_Housing AS A
JOIN housing_db..Nash_Housing AS B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

-- Updating PropertyAddress column
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM housing_db..Nash_Housing AS A
JOIN housing_db..Nash_Housing AS B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

SELECT *
FROM housing_db..Nash_Housing
WHERE PropertyAddress IS NULL



-- Updating Owner Address based on Property Address
SELECT [UniqueID ], ParcelID, PropertyAddress, OwnerAddress
FROM housing_db..Nash_Housing

UPDATE Nash_Housing
SET OwnerAddress = CONCAT(PropertyAddress, ', TN')



-- Breaking PropertyAddress column into parts (Address, City) using substring

SELECT PropertyAddress
FROM housing_db..Nash_Housing

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS PropertyAddress_1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS PropertyAddress_2
FROM housing_db..Nash_Housing

ALTER TABLE	Nash_Housing
ADD PropertyAddress_1 NVARCHAR(255)

UPDATE Nash_Housing
SET PropertyAddress_1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE	Nash_Housing
ADD PropertyAddress_2 NVARCHAR(255)

UPDATE Nash_Housing
SET PropertyAddress_2 = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM housing_db..Nash_Housing


-- Breaking OwnerAddress column into parts (Address, City, State) using Parsename

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerAddress_1,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerAddress_2,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerAddress_3
FROM housing_db..Nash_Housing

ALTER TABLE	Nash_Housing
ADD OwnerAddress_1 NVARCHAR(255)

UPDATE Nash_Housing
SET OwnerAddress_1 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE	Nash_Housing
ADD OwnerAddress_2 NVARCHAR(255)

UPDATE Nash_Housing
SET OwnerAddress_2 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE	Nash_Housing
ADD OwnerAddress_3 NVARCHAR(255)

UPDATE Nash_Housing
SET OwnerAddress_3 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM housing_db..Nash_Housing


-- Changing values of SoldAsVacant from Y and N to Yes and No

SELECT DISTINCT	SoldAsVacant, COUNT(SoldAsVacant)
FROM housing_db..Nash_Housing
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END AS Updated_Values
FROM housing_db..Nash_Housing


UPDATE Nash_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
				   END

SELECT *
FROM housing_db..Nash_Housing



-- Finding Duplicates (Criteria: Same ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference)

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 ORDER BY
				UniqueID) AS row_num
FROM housing_db..Nash_Housing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-- Removing Duplicates (Practice)

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 ORDER BY
				UniqueID) AS row_num
FROM housing_db..Nash_Housing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete unused columns(Practice) ** Nothing is unused... don't do it... lol** 

--ALTER TABLE Nash_Housing
--DROP COLUMN PropertyAddress, OwnerAddress