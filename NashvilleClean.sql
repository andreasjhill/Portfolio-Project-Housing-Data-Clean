--cleaning data using sql queries
select * 
from nashvillehousing

--populate property address data 
SELECT * 
from nashvillehousing
order by parcelid

--create join table on itself to see if parcelid and uniqueid are different.
--check to see if property address is null 
select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, Coalesce(a.propertyaddress, b.propertyaddress)
from nashvillehousing as a 
join nashvillehousing as b 
on a.parcelid = b.parcelid 
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null 

--update the table to fill the nulls in propertyaddress 
UPDATE nashvillehousing AS a
SET propertyaddress = b.propertyaddress
FROM nashvillehousing AS b
WHERE a.parcelid = b.parcelid
    AND a.uniqueid <> b.uniqueid
    AND a.propertyaddress IS NULL;
	
--breaking the address column into individual columns(address, city, state)
--option 1: split_part function
SELECT SPLIT_PART(propertyaddress, ',', 1) AS address,
SPLIT_PART(propertyaddress, ',', 2) AS city
FROM nashvillehousing;

--create the columns that this address info will populate 
ALTER TABLE nashvillehousing
ADD COLUMN PropertySplitAddress VARCHAR(255),
ADD COLUMN PropertySplitCity VARCHAR(255);

--option 2: substring function 
SELECT SUBSTRING(propertyaddress FROM 1 for POSITION(',' IN propertyaddress) - 1) AS address,
SUBSTRING(propertyaddress FROM POSITION(',' IN propertyaddress) + 1) AS city
FROM nashvillehousing;

--update it 
UPDATE nashvillehousing
SET PropertySplitAddress = SPLIT_PART(propertyaddress, ',', 1),
    PropertySplitCity = SPLIT_PART(propertyaddress, ',', 2);
	
--do the same with owneraddress using option 1 
SELECT SPLIT_PART(owneraddress, ',', 1) AS Address,
	SPLIT_PART(owneraddress, ',', 2) AS City,
	SPLIT_PART(owneraddress, ',', 3) AS State
	
--create columns for owner address splits
ALTER TABLE nashvillehousing
ADD COLUMN OwnerSplitAddress VARCHAR(255),
ADD COLUMN OwnerSplitCity VARCHAR(255),
ADD COLUMN OwnerSplitState VARCHAR(255);

--update and populate data
UPDATE nashvillehousing
SET OwnerSplitAddress = SPLIT_PART(owneraddress, ',', 1),
    OwnerSplitCity = SPLIT_PART(owneraddress, ',', 2),
	OwnerSplitState = SPLIT_PART(owneraddress, ',', 3);
	
--confrim property and owner addresses are populated 
select * 
from nashvillehousing

--change y and n to yes and no in "sold as vacnt" field
SELECT DISTINCT(SOLDASVACANT),
	COUNT(SOLDASVACANT)
FROM NASHVILLEHOUSING
GROUP BY SOLDASVACANT
ORDER BY 2

--homogenize results to be either yes or no 
SELECT SOLDASVACANT,
	CASE
					WHEN SOLDASVACANT = 'Y' THEN 'Yes'
					WHEN SOLDASVACANT = 'N' THEN 'No'
					ELSE SOLDASVACANT
	END
FROM NASHVILLEHOUSING

--update and set new columns 
update nashvillehousing 
set soldasvacant = CASE
	WHEN SOLDASVACANT = 'Y' THEN 'Yes'
	WHEN SOLDASVACANT = 'N' THEN 'No'
	ELSE SOLDASVACANT
	END
	
--remove duplicates 
--using CTE 
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY parcelid,
                         propertyaddress,
                         saleprice,
                         saledate,
                         legalreference
            ORDER BY uniqueid
        ) AS row_num
    FROM nashvillehousing
)
DELETE FROM nashvillehousing
USING RowNumCTE
WHERE nashvillehousing.uniqueid = RowNumCTE.uniqueid AND RowNumCTE.row_num > 1;
--order by propertyaddress 

--double check duplicates are gone
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY parcelid,
                         propertyaddress,
                         saleprice,
                         saledate,
                         legalreference
            ORDER BY uniqueid
        ) AS row_num
    FROM nashvillehousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;

--delete unused columns (not typically good practice to do unless consulting your lead)
select * 
from nashvillehousing

ALTER TABLE nashvillehousing
DROP COLUMN saledate,
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;
