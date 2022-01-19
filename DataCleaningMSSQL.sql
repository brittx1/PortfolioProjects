
/* 
Cleaning Data In SQL Queries
*/

select SaleDate
from [sql tutorial].[dbo].[Sheet1$]

Alter Table Sheet1$
Add ConvertedDate Date --- Date column w/o timestamp 


Update Sheet1$
set ConvertedDate = Convert(date,SaleDate) 


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.propertyAddress,b.PropertyAddress) 
from [sql tutorial].[dbo].[Sheet1$] as a
join [sql tutorial].[dbo].[Sheet1$] as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress) --- Fill Null Address 
from dbo.Sheet1$ as a
join dbo.Sheet1$ as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

Select PropertyAddress
from [sql tutorial].[dbo].[Sheet1$]
where PropertyAddress is null --- Double check Nulls are gone

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City 
from [sql tutorial].[dbo].[Sheet1$]

Alter Table [sql tutorial].[dbo].[Sheet1$]
Add PropertySplitAddress nvarchar(255)


----Split Addresses w/ States and Cities Attached 
Update [sql tutorial].[dbo].[Sheet1$]
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table [sql tutorial].[dbo].[Sheet1$]
Add PropertySplitCity nvarchar(255)

Update [sql tutorial].[dbo].[Sheet1$]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

Select PARSENAME(Replace(OwnerAddress, ',','.'),3),
PARSENAME(Replace(OwnerAddress, ',','.'),2),
PARSENAME(Replace(OwnerAddress, ',','.'),1)
from [sql tutorial].[dbo].[Sheet1$]

Alter Table [sql tutorial].[dbo].[Sheet1$]
Add OwnerAddressSplit nvarchar(255)

Update [sql tutorial].[dbo].[Sheet1$]
set OwnerAddressSplit = PARSENAME(Replace(OwnerAddress, ',','.'),3)

Alter Table [sql tutorial].[dbo].[Sheet1$]
Add OwnerCity nvarchar(255)

Update [sql tutorial].[dbo].[Sheet1$]
set OwnerCity = PARSENAME(Replace(OwnerAddress, ',','.'),2)

Alter Table [sql tutorial].[dbo].[Sheet1$]
Add OwnerState nvarchar(255)

Update [sql tutorial].[dbo].[Sheet1$]
set OwnerState = PARSENAME(Replace(OwnerAddress, ',','.'),1)

select distinct(SoldAsVacant), count(*)
from [sql tutorial].[dbo].[Sheet1$]
group by SoldAsVacant


select SoldAsVacant,                           ---- Changed all Y and N to Yes and No's to all be consistent 
(Case when SoldAsVacant = 'Y' then 'Yes',
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant)
from [sql tutorial].[dbo].[Sheet1$]

Update [sql tutorial].[dbo].[Sheet1$]
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end


---Removing Duplicates 
With New as (Select *,
ROW_NUMBER() over (partition by ParcelID, 
								PropertySplitAddress,
								SalePrice,
								LegalReference
								Order by UniqueID
								) as RowNum
from [sql tutorial].[dbo].[Sheet1$]
)

Delete
from New 
Where RowNum >1



Alter table [sql tutorial].[dbo].[Sheet1$] ---Drop Unneeded columns after cleaning 
drop column SaleDate

Alter table [sql tutorial].[dbo].[Sheet1$]
drop column PropertyAddress

Alter table [sql tutorial].[dbo].[Sheet1$]
drop column OwnerAddress