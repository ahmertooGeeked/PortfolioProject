                                                                                  --DATA CLEANING PROJECT--
				                                                    --NASHVILLE HOUSING--

USE PortfolioProjects;
-----------------------------------------
--TABLE:

SELECT * FROM NashvilleHousing;


-----------------------------------------
-- Standardize Date Format

SELECT *
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CAST(SaleDate AS Date)

ALTER TABLE NashvilleHousing
Add SaleDateConvert date;

UPDATE NashvilleHousing
SET SaleDateConvert = CAST(SaleDate AS Date);

--1.
-----------------------------------------
-- Populate Property Address
-- We have some rows where the address isn't mentioned so we need to fill them out

SELECT * FROM NashvilleHousing
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) FROM
NashvilleHousing a
JOIN NashvilleHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;




-------------------------------------------------------------------------------------------
-- We need to apply the address syntax i-e (Address, City)
-- For PropertyAddress we got Address and City
-- We will create separate tables for both to provide meaningfull and easy on the eyes data


Select * FROM NashvilleHousing;

Select 
PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2) ,
PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1) 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySeparatedCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySeparatedCity = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1) 

ALTER TABLE NashvilleHousing
ADD PropertySeparatedAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySeparatedAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2) ;


----------------------------------------------------------
-- We need to apply the address syntax i-e (Address, City, State)
-- For OwnerAddress we got Address ,State and City
-- We will create separate tables for the 3 to provide meaningfull and easy on the eyes data

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM NashvilleHousing
 
 --ParseName technically creates partition with dots but what i did was replace the comma with dot so we could use it according to the data
 -- :))


ALTER TABLE NashvilleHousing
ADD OwnerSeparatedAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSeparatedAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 


ALTER TABLE NashvilleHousing
ADD OwnerSeparatedCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSeparatedCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 

 ALTER TABLE NashvilleHousing
ADD OwnerSeparatedState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSeparatedState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 

Select * from NashvilleHousing;


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT * FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 'No'
Where SoldAsVacant = 'N';

UPDATE NashvilleHousing
SET SoldAsVacant = 'Yes'
Where SoldAsVacant = 'Y';


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicate Rows
-- First of all I counted the rows that were same using some columns
-- If i the columns count were greater than 1, that means its a duplicate!

WITH DuplicatesCTE AS  (
Select           SaleDateConvert
                 LandUse,
                 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference,
				 COUNT(*) AS DUPLICATECOUNT
				 From NashvilleHousing
				 GROUP BY SaleDateConvert,
				 LandUse,
                 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				Having COUNT(*) > 1
				)

-- We could have just deleted the 'Duplicate Count' here but we cannot directly delete from a CTE especially when aggregate functions
-- are involved. Hence we create a new temp table, declare the same columns and insert them(sql automatically fetches the data from the table), we
-- dont need to insert each and every value again. After this we will be able to delete the duplicate records.

	CREATE TABLE #Duplicates (
    SaleDateConvert DATE,
    LandUse VARCHAR(MAX),
    PropertyAddress VARCHAR(MAX),
    SalePrice DECIMAL(18,2),
    SaleDate DATE,
    LegalReference VARCHAR(MAX),
    DUPLICATECOUNT INT
);

INSERT INTO #Duplicates
SELECT
    SaleDateConvert,
    LandUse,
    PropertyAddress,
    SalePrice,
    SaleDate,
    LegalReference,
    COUNT(*) AS DUPLICATECOUNT
FROM NashvilleHousing
GROUP BY SaleDateConvert,
    LandUse,
    PropertyAddress,
    SalePrice,
    SaleDate,
    LegalReference
HAVING COUNT(*) > 1;

DELETE FROM #Duplicates
WHERE DUPLICATECOUNT > 1;

-- No Duplicates Left
SELECT DuplicateCount FROM #Duplicates 
Where DUPLICATECOUNT > 1; 

SELECT * FROM NashvilleHousing;
            
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict

---------------------------------------------------------------------------------------------------------

-- Set the NULL values in 'OwnerName' Column to None because it feels more meaningfull

UPDATE NashvilleHousing
SET OwnerName = 'None'
WHERE OwnerName IS NULL;
SELECT * FROM NashvilleHousing
