
/*   
 	Cleaning Data in SQL Queries
	Skills used : CREATE, UPDATE, SELECT, SUBQUERIES, WINDOW FUNCTIONS, JOINS, OREDR BY, GROUP BY
*/  


SELECT *
FROM sys.Nashville_Housing nh;


--------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDate,
       CONCAT( 
	   		  SUBSTRING_INDEX(SaleDate, '/', -1), 
	   		  '-',
	   		  LPAD(SUBSTRING_INDEX(SaleDate, '/', 1), 2, '0'),
	   		  '-',
	   		  LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SaleDate, '/', 2), '/', -1), 2, '0')
	   		  ) AS converted_date
FROM sys.Nashville_Housing nh;


UPDATE sys.Nashville_Housing 
SET saleDate = CONCAT( 
	   		          SUBSTRING_INDEX(SaleDate, '/', -1), 
	   		          '-',
	   		          LPAD(SUBSTRING_INDEX(SaleDate, '/', 1), 2, '0'),
	   		          '-',
	   		          LPAD(SUBSTRING_INDEX(SUBSTRING_INDEX(SaleDate, '/', 2), '/', -1), 2, '0')
	   		          );
   		         
	   		         
SELECT * 
FROM sys.Nashville_Housing nh;



--------------------------------------------------------------------------------------------

-- Populate Property Address Data


SELECT *
FROM sys.Nashville_Housing nh
WHERE PropertyAddress IS NULL;


SELECT *
FROM sys.Nashville_Housing nh
ORDER BY ParcelID;


SELECT nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress, IFNULL(nh1.PropertyAddress, nh2.PropertyAddress) 
FROM sys.Nashville_Housing nh1
JOIN sys.Nashville_Housing nh2 
	 ON nh1.ParcelID = nh2.ParcelID 
	 AND nh1.UniqueID <> nh2.UniqueID 
WHERE nh1.PropertyAddress IS NULL;


UPDATE sys.Nashville_Housing nh1
JOIN sys.Nashville_Housing nh2 
	 ON nh1.ParcelID = nh2.ParcelID 
	 AND nh1.UniqueID <> nh2.UniqueID
SET nh1.PropertyAddress = IFNULL(nh1.PropertyAddress, nh2.PropertyAddress)
WHERE nh1.PropertyAddress IS NULL;



--------------------------------------------------------------------------------------------

-- Breaking Out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress, 
       SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress,',') - 1) AS Address, 
       SUBSTRING(PropertyAddress, INSTR(PropertyAddress,',') + 1) AS City
FROM sys.Nashville_Housing nh;


ALTER TABLE sys.Nashville_Housing 
ADD COLUMN PropertySplitAddress VARCHAR(255), 
ADD COLUMN PropertySplitCity VARCHAR(255);


UPDATE sys.Nashville_Housing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress,',') - 1);


UPDATE sys.Nashville_Housing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress,',') + 1);


SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM sys.Nashville_Housing nh;


SELECT OwnerAddress, 
	   SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1),
	   SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
	   SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1)
FROM sys.Nashville_Housing nh; 


ALTER TABLE sys.Nashville_Housing 
ADD COLUMN OwnerSplitAddress VARCHAR(255), 
ADD COLUMN OwnerSplitCity VARCHAR(255),
ADD COLUMN OwnerSplitState VARCHAR(255);


UPDATE sys.Nashville_Housing 
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1),
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
	OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1);


SELECT *
FROM sys.Nashville_Housing nh;



--------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field 


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
FROM sys.Nashville_Housing nh
GROUP BY SoldAsVacant;


SELECT SoldAsVacant, 
	   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
       END
FROM sys.Nashville_Housing nh;


UPDATE sys.Nashville_Housing 
SET SoldAsVacant = 	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   				WHEN SoldAsVacant = 'N' THEN 'No'
	   				ELSE SoldAsVacant
       				END;



--------------------------------------------------------------------------------------------

-- Remove Duplicates


SELECT *,
	   ROW_NUMBER () OVER (
	   PARTITION BY ParcelID,
	                PropertyAddress,
	                SaleDate,
	                LegalReference
	                ORDER BY UniqueID
	   ) AS row_num 				
FROM sys.Nashville_Housing nh 
ORDER BY ParcelID;


SELECT *
FROM (
	SELECT *,
		   ROW_NUMBER () OVER (
		   PARTITION BY ParcelID,
		                PropertyAddress,
		                SaleDate,
		                LegalReference
		                ORDER BY UniqueID
		   ) AS row_num 				
	FROM sys.Nashville_Housing 
) AS nh
WHERE row_num > 1
ORDER BY ParcelID;


USE sys;
DELETE nh1
FROM sys.Nashville_Housing nh1
JOIN (
    SELECT ParcelID, PropertyAddress, SaleDate, LegalReference, UniqueID,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM sys.Nashville_Housing
) AS nh2 ON nh1.ParcelID = nh2.ParcelID
        AND nh1.PropertyAddress = nh2.PropertyAddress
        AND nh1.SaleDate = nh2.SaleDate
        AND nh1.LegalReference = nh2.LegalReference
        AND nh1.UniqueID = nh2.UniqueID
WHERE nh2.row_num > 1;


SELECT COUNT(*)
FROM sys.Nashville_Housing nh;


       			
--------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM sys.Nashville_Housing nh;


ALTER TABLE sys.Nashville_Housing
DROP COLUMN PropertyAddress;


ALTER TABLE sys.Nashville_Housing
DROP COLUMN OwnerAddress;


ALTER TABLE sys.Nashville_Housing
DROP COLUMN TaxDistrict;


ALTER TABLE sys.Nashville_Housing
DROP COLUMN SaleDate;



--------------------------------------------------------------------------------------------
