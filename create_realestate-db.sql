

use Eyouth(databasedemo/Eyouth);


CREATE TABLE Properties(
parcelid INT NOT NULL,
airconditioningtypeid varchar(50),
architecturalstyletypeid varchar(50),
basementsqft varchar(50),
bathroomcnt varchar(50),
bedroomcnt varchar(50),
buildingclasstypeid varchar(50),
buildingqualitytypeid varchar(50),
calculatedbathnbr varchar(50),
decktypeid varchar(50),
finishedfloor1squarefeet varchar(50),
calculatedfinishedsquarefeet varchar(50),
finishedsquarefeet12 varchar(50),
finishedsquarefeet13 varchar(50),
finishedsquarefeet15 varchar(50),
finishedsquarefeet50 varchar(50),
finishedsquarefeet6 varchar(50),
fips varchar(50),
fireplacecnt varchar(50),
fullbathcnt varchar(50),
garagecarcnt varchar(50),
garagetotalsqft varchar(50),
hashottuborspa varchar(50),
heatingorsystemtypeid varchar(50),
latitude varchar(50),
longitude varchar(50),
lotsizesquarefeet varchar(50),
poolcnt varchar(50),
poolsizesum varchar(50),
pooltypeid10 varchar(50),
pooltypeid2 varchar(50),
pooltypeid7 varchar(50),
propertycountylandusecode varchar(50),
propertylandusetypeid varchar(50),
propertyzoningdesc varchar(50),
rawcensustractandblock varchar(50),
regionidcity varchar(50),
regionidcounty varchar(50),
regionidneighborhood varchar(50),
regionidzip varchar(50),
roomcnt varchar(50),
storytypeid varchar(50),
threequarterbathnbr varchar(50),
typeconstructiontypeid varchar(50),
unitcnt  varchar(50),
yardbuildingsqft17 varchar(50),
yardbuildingsqft26 varchar(50),
yearbuilt varchar(50),
numberofstories varchar(50),
fireplaceflag varchar(50),
structuretaxvaluedollarcnt varchar(50),
taxvaluedollarcnt varchar(50),
assessmentyear varchar(50),
landtaxvaluedollarcnt varchar(50),
taxamount varchar(50),
taxdelinquencyflag varchar(50),
taxdelinquencyyear varchar(50),
censustractandblock varchar(50)
PRIMARY KEY(parcelid)
);

CREATE TABLE Clients(
ClientID INT NOT NULL,
FirstName VARCHAR(50),
LastName VARCHAR(50),
Phone VARCHAR(100),
Email VARCHAR(100)
PRIMARY KEY(ClientID)
);

CREATE TABLE Agents(
AgentID INT NOT NULL,
FirstName VARCHAR(50),
LastName VARCHAR(50),
Phone VARCHAR(100),
Email VARCHAR(100)
PRIMARY KEY(AgentID)
);

CREATE TABLE Visits(
VisitID INT NOT NULL,
PropertyID int not null ,
ClientID int not null ,
AgentID int not null , 
VisitDate DATE
PRIMARY KEY(VisitID)
CONSTRAINT FK_Visits_Properties FOREIGN KEY(PropertyID)
REFERENCES Properties(parcelid),
CONSTRAINT FK_Visits_Clints FOREIGN KEY(ClientID) 
REFERENCES Clients(ClientID),
CONSTRAINT FK_Visits_Agents FOREIGN KEY(AgentID) 
REFERENCES Agents(AgentID)
);


create table Sales (
SaleID int not null ,
PropertyID int not null ,
ClientID int not null ,
AgentID int not null , 
SaleDate DATE,
SalePrice decimal(20,4)
PRIMARY KEY(SaleID)
CONSTRAINT FK_Sales_Properties FOREIGN KEY(PropertyID)
REFERENCES Properties(parcelid),
CONSTRAINT FK_Sales_Clints FOREIGN KEY(ClientID) 
REFERENCES Clients(ClientID),
CONSTRAINT FK_Sales_Agents FOREIGN KEY(AgentID) 
REFERENCES Agents(AgentID)
);

--importing data into Properties table
BULK INSERT Properties
FROM 'D:\Ai\DA Projects\Real Estate (bootcamp)\Data\sample_properties_2017.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
);

--importing data into Clients table
BULK INSERT Clients
FROM 'D:\Ai\DA Projects\Real Estate (bootcamp)\Data\clients.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
);

--importing data into Agents table
BULK INSERT Agents
FROM 'D:\Ai\DA Projects\Real Estate (bootcamp)\Data\agents.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
);

--importing data into Visits table
BULK INSERT Visits
FROM 'D:\Ai\DA Projects\Real Estate (bootcamp)\Data\visits.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
);

--importing data into Sales  table
BULK INSERT Sales 
FROM 'D:\Ai\DA Projects\Real Estate (bootcamp)\Data\sales.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
);

--Data preprocessing
--Add PropertyType column into table Proberties based on the values of  column propertylandusetypeid
ALTER TABLE Properties
ADD  PropertyType VARCHAR(50);

UPDATE Properties
SET PropertyType=
CASE
when propertylandusetypeid='31' then 'Commercial/Office/Residential Mixed Used'
when propertylandusetypeid='46' then 'Multi-Story Store'
when propertylandusetypeid='47' then 'Store/Office (Mixed Use)'
when propertylandusetypeid='246' then 'Duplex (2 Units, Any Combination)'
when propertylandusetypeid='247' then 'Triplex (3 Units, Any Combination)'
when propertylandusetypeid='248' then 'Quadruplex (4 Units, Any Combination)'
when propertylandusetypeid='260' then 'Residential General'
when propertylandusetypeid='261' then 'Single Family Residential'
when propertylandusetypeid='262' then 'Rural Residence'
when propertylandusetypeid='263' then 'Mobile Home'
when propertylandusetypeid='264' then 'Townhouse'
when propertylandusetypeid='265' then 'Cluster Home'
when propertylandusetypeid='266' then 'Condominium'
when propertylandusetypeid='267' then 'Cooperative'
when propertylandusetypeid='268' then 'Row House'
when propertylandusetypeid='269' then 'Planned Unit Development'
when propertylandusetypeid='270' then 'Residential Common Area'
when propertylandusetypeid='271' then 'Timeshare'
when propertylandusetypeid='273' then 'Bungalow	'
when propertylandusetypeid='274' then 'Zero Lot Line'
when propertylandusetypeid='275' then 'Manufactured, Modular, Prefabricated Homes'
when propertylandusetypeid='276' then 'Patio Home'
when propertylandusetypeid='279' then 'Inferred Single Family Residential	'
when propertylandusetypeid='290' then 'Vacant Land - General'
when propertylandusetypeid='291' then 'Residential Vacant Land'
ELSE ' '  
END;





	

		

