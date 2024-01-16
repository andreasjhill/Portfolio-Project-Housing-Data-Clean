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
	
--do the same with owneraddress
