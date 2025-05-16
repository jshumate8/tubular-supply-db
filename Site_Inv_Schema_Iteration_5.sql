
DROP TABLE IF EXISTS WellOrderLineItems;
DROP TABLE IF EXISTS SiteOrderLineItems;
DROP TABLE IF EXISTS SiteOrderHasWellOrders;
DROP TABLE IF EXISTS WellOrder;
DROP TABLE IF EXISTS SiteOrder;
DROP TABLE IF EXISTS InventoryUpdate;
DROP TABLE IF EXISTS PremiumConnector;
DROP TABLE IF EXISTS WeldedConnector;
DROP TABLE IF EXISTS ThreadedConnector;
DROP TABLE IF EXISTS Casing;
DROP TABLE IF EXISTS Tubing;
DROP TABLE IF EXISTS DrillPipe;
DROP TABLE IF EXISTS Admin;
DROP TABLE IF EXISTS InventoryClerk;
DROP TABLE IF EXISTS Engineer;
DROP TABLE IF EXISTS SiteSupervisor;
DROP TABLE IF EXISTS WellLocation;
DROP TABLE IF EXISTS SiteLocation;
DROP TABLE IF EXISTS WellHasUsers;
DROP TABLE IF EXISTS SiteHasUsers;
DROP TABLE IF EXISTS RolePermission;
DROP TABLE IF EXISTS Well;
DROP TABLE IF EXISTS PipePricing;
DROP TABLE IF EXISTS ConnectorPricing;
DROP TABLE IF EXISTS ConnectorPriceChange;
DROP TABLE IF EXISTS PipePriceChange;
DROP TABLE IF EXISTS Connector;
DROP TABLE IF EXISTS Pipe;
DROP TABLE IF EXISTS Site;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS Permission;
DROP TABLE IF EXISTS Role;
DROP TABLE IF EXISTS SystemUser;

DROP SEQUENCE IF EXISTS SystemUserSeq;
DROP SEQUENCE IF EXISTS RoleSeq;
DROP SEQUENCE IF EXISTS PermissionSeq;
DROP SEQUENCE IF EXISTS SiteSeq;
DROP SEQUENCE IF EXISTS WellSeq;
DROP SEQUENCE IF EXISTS SiteOrderSeq;
DROP SEQUENCE IF EXISTS SiteOrderLineItemsSeq;
DROP SEQUENCE IF EXISTS InventoryUpdateSeq;  
DROP SEQUENCE IF EXISTS WellOrderSeq;
DROP SEQUENCE IF EXISTS WellOrderLineItemsSeq;
DROP SEQUENCE IF EXISTS PipeSeq;
DROP SEQUENCE IF EXISTS ConnectorSeq;
DROP SEQUENCE IF EXISTS PipePricingSeq;  
DROP SEQUENCE IF EXISTS ConnectorPricingSeq;
DROP SEQUENCE IF EXISTS LocationSeq;
DROP SEQUENCE IF EXISTS PermissionSeq;
DROP SEQUENCE IF EXISTS RoleSeq;
DROP SEQUENCE IF EXISTS SystemUserSeq;
DROP SEQUENCE IF EXISTS SiteOrderLineItemsSeq;
DROP SEQUENCE IF EXISTS PipePriceChangeSeq;
DROP SEQUENCE IF EXISTS ConnectorPriceChangeSeq;

CREATE SEQUENCE SystemUserSeq START WITH 1001 INCREMENT BY 1;  
CREATE SEQUENCE RoleSeq START WITH 10 INCREMENT BY 10; 
CREATE SEQUENCE PermissionSeq START WITH 1 INCREMENT BY 1;  
CREATE SEQUENCE SiteSeq START WITH 1 INCREMENT BY 1;  
CREATE SEQUENCE WellSeq START WITH 1 INCREMENT BY 1;  
CREATE SEQUENCE SiteOrderSeq START WITH 101 INCREMENT BY 1;  
CREATE SEQUENCE SiteOrderLineItemsSeq START WITH 1 INCREMENT BY 1; 
CREATE SEQUENCE InventoryUpdateSeq START WITH 1 INCREMENT BY 1; 
CREATE SEQUENCE WellOrderSeq START WITH 101 INCREMENT BY 1;  
CREATE SEQUENCE WellOrderLineItemsSeq START WITH 1 INCREMENT BY 1;  
CREATE SEQUENCE PipeSeq START WITH 1 INCREMENT BY 1;  
CREATE SEQUENCE ConnectorSeq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE PipePricingSeq AS BIGINT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE ConnectorPricingSeq AS BIGINT START WITH 1 INCREMENT BY 1; 
CREATE SEQUENCE LocationSeq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE PipePriceChangeSeq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE ConnectorPriceChangeSeq START WITH 1 INCREMENT BY 1;


DROP PROCEDURE IF EXISTS CreateUserWithSiteAndRole;
DROP PROCEDURE IF EXISTS ViewWellInventory;
DROP PROCEDURE IF EXISTS SubmitWellOrder;
DROP PROCEDURE IF EXISTS CreateSiteOrderFromWellOrders;
DROP PROCEDURE IF EXISTS UpdateInventoryLocation;
DROP PROCEDURE IF EXISTS FulfillWellOrderFromSiteInventory;
DROP PROCEDURE IF EXISTS AddUserWithRoleAssignment

DROP TRIGGER IF EXISTS ConnectorPricingChangeTrigger;
DROP TRIGGER IF EXISTS PipePricingChangeTrigger;



CREATE TABLE SystemUser (
    userID INT PRIMARY KEY DEFAULT NEXT VALUE FOR SystemUserSeq,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    username VARCHAR(50) UNIQUE,
    passwordHash VARCHAR(255),
    isActive BIT
);

CREATE TABLE Role (
    roleID INT PRIMARY KEY,
    roleName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Permission (
    permissionID INT PRIMARY KEY,
    permissionName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Location (
    locationID INT PRIMARY KEY,
    name VARCHAR(100),
    type VARCHAR(10) CHECK (type IN ('Site', 'Well', 'Offsite')),
    is_active BIT,
    notes TEXT
);

CREATE TABLE Site (
    siteID INT PRIMARY KEY,
    site_name VARCHAR(100),
    site_geolocation VARCHAR(100),
    site_region VARCHAR(50),
    operator VARCHAR(100)
);

CREATE TABLE Pipe (
    pipeID INT PRIMARY KEY,
    lengthRange VARCHAR(5) CHECK (lengthRange IN ('R1', 'R2', 'R3')),
    threadType VARCHAR(50),
    pipeType VARCHAR(20) CHECK (pipeType IN ('Casing', 'Tubing', 'DrillPipe')),
    couplingType VARCHAR(50),
    outerDiameter DECIMAL(5,2),
    coatingType VARCHAR(50),
    wallThickness DECIMAL(4,2),
    heatNumber VARCHAR(50),
    weightPerFoot DECIMAL(6,2),
    inspectionStatus VARCHAR(10) CHECK (inspectionStatus IN ('Passed', 'Rejected', 'Pending')),
    grade VARCHAR(10),
    storageLocationID INT REFERENCES Location(locationID),
    material VARCHAR(50),
    quantityAvailable INT
);

CREATE TABLE Connector (
    connectorID INT PRIMARY KEY,
    size DECIMAL(5,2),
    name VARCHAR(100),
    connectionStandard VARCHAR(50),
    material VARCHAR(50),
    manufacturer VARCHAR(100),
    pressureRating DECIMAL(8,2),
    storageLocationID INT REFERENCES Location(locationID),
    coatingType VARCHAR(50)
);

CREATE TABLE PipePricing (
    pricingID INT PRIMARY KEY DEFAULT NEXT VALUE FOR PipePricingSeq,            
    effectiveDate DATE,                                                         
    pipeID INT REFERENCES Pipe(pipeID),                                        
    price DECIMAL(10, 2),                                                      
    createdOn DATETIME,                                                          
    updatedOn DATETIME                                                           
);

CREATE TABLE ConnectorPricing (
    pricingID INT PRIMARY KEY DEFAULT NEXT VALUE FOR ConnectorPricingSeq,      
    effectiveDate DATE,                                                        
    connectorID INT REFERENCES Connector(connectorID),                         
    price DECIMAL(10, 2),                                                        
    createdOn DATETIME,                                                          
    updatedOn DATETIME                                                           
);

CREATE TABLE PipePriceChange (
    priceChangeID INT PRIMARY KEY,
    pipeID INT NOT NULL,
    oldPrice DECIMAL(10, 2) NOT NULL,
    newPrice DECIMAL(10, 2) NOT NULL,
    changeDate DATETIME NOT NULL,
    FOREIGN KEY (pipeID) REFERENCES Pipe(pipeID)
);

CREATE TABLE ConnectorPriceChange (
    priceChangeID INT PRIMARY KEY,
    connectorID INT NOT NULL,
    oldPrice DECIMAL(10, 2) NOT NULL,
    newPrice DECIMAL(10, 2) NOT NULL,
    changeDate DATETIME NOT NULL,
    FOREIGN KEY (connectorID) REFERENCES Connector(connectorID)
);


CREATE TABLE Well (
    wellID INT PRIMARY KEY DEFAULT NEXT VALUE FOR WellSeq,
    siteID INT REFERENCES Site(siteID),
    well_name VARCHAR(100),
    wellType VARCHAR(20) CHECK (wellType IN ('Exploration', 'Production', 'Injection')),
    status VARCHAR(10) CHECK (status IN ('Active', 'Inactive', 'Plugged')),
    depth DECIMAL(8,2)
);

CREATE TABLE RolePermission (
    roleID INT REFERENCES Role(roleID),
    permissionID INT REFERENCES Permission(permissionID),
    PRIMARY KEY (roleID, permissionID)
);

CREATE TABLE SiteHasUsers (
    userID INT REFERENCES SystemUser(userID),
    siteID INT REFERENCES Site(siteID),
    role VARCHAR(50) REFERENCES Role(roleName),
    assigned_on DATETIME,
    isActive BIT,
    PRIMARY KEY (userID, siteID)
);

CREATE TABLE WellHasUsers (
    userID INT REFERENCES SystemUser(userID),
    wellID INT REFERENCES Well(wellID),
    role VARCHAR(50) REFERENCES Role(roleName),
    assigned_on DATETIME,
    isActive BIT,
    PRIMARY KEY (userID, wellID)
);

CREATE TABLE SiteLocation (
    locationID INT PRIMARY KEY REFERENCES Location(locationID),
    siteID INT REFERENCES Site(siteID),
    capacity INT,
    current_inventory INT
);

CREATE TABLE WellLocation (
    locationID INT PRIMARY KEY REFERENCES Location(locationID),
    wellID INT REFERENCES Well(wellID),
    capacity INT,
    current_inventory INT
);

CREATE TABLE Engineer (
    userID INT PRIMARY KEY REFERENCES SystemUser(userID),
    assignedSiteID INT REFERENCES Site(siteID),
    discipline VARCHAR(50)
);

CREATE TABLE InventoryClerk (
    userID INT PRIMARY KEY REFERENCES SystemUser(userID),
    warehouseLocation VARCHAR(100),
    shift VARCHAR(10) CHECK (shift IN ('Day', 'Night'))
);

CREATE TABLE SiteSupervisor (
    userID INT PRIMARY KEY REFERENCES SystemUser(userID),
    supervisorLevel VARCHAR(50) CHECK (supervisorLevel IN ('Lead', 'Senior', 'Standard')),
    assignedRegion VARCHAR(100)
);

CREATE TABLE Admin (
    userID INT PRIMARY KEY REFERENCES SystemUser(userID),
    adminLevel VARCHAR(50) CHECK (adminLevel IN ('Super', 'Standard'))
);

CREATE TABLE DrillPipe (
    pipeID INT PRIMARY KEY REFERENCES Pipe(pipeID),
    maxPressure DECIMAL(8,2),
    linerType VARCHAR(50)
);

CREATE TABLE Tubing (
    pipeID INT PRIMARY KEY REFERENCES Pipe(pipeID),
    maxPressure DECIMAL(8,2),
    linerType VARCHAR(50)
);

CREATE TABLE Casing (
    pipeID INT PRIMARY KEY REFERENCES Pipe(pipeID),
    collapsePressure DECIMAL(8,2),
    cementingSpec VARCHAR(100)
);

CREATE TABLE ThreadedConnector (
    connectorID INT PRIMARY KEY REFERENCES Connector(connectorID),
    threadType VARCHAR(50),
    threadForm VARCHAR(50),
    taper DECIMAL(4,2),
    makeUpTorque DECIMAL(8,2)
);

CREATE TABLE WeldedConnector (
    connectorID INT PRIMARY KEY REFERENCES Connector(connectorID),
    weldType VARCHAR(50),
    weldProcedure VARCHAR(100),
    weldInspectionStatus VARCHAR(10) CHECK (weldInspectionStatus IN ('Passed', 'Rejected', 'Pending')),
    heatAffectedZoneRating VARCHAR(50)
);

CREATE TABLE PremiumConnector (
    connectorID INT PRIMARY KEY REFERENCES Connector(connectorID),
    sealDesign VARCHAR(100),
    torqueShoulder BIT,
    makeUpTorqueRange VARCHAR(50),
    licenseNumber VARCHAR(50),
    performanceGrade VARCHAR(50)
);

CREATE TABLE InventoryUpdate (
    InventoryUpdateID INT PRIMARY KEY DEFAULT NEXT VALUE FOR InventoryUpdateSeq,   
    LocationID INT REFERENCES Location(locationID),                            
    itemType VARCHAR(10) CHECK (itemType IN ('Pipe', 'Connector')),             
    InventoryUpdateReason VARCHAR(20) CHECK (InventoryUpdateReason IN ('Received', 'Used', 'Adjusted', 'Damaged')), 
    InventoryItemID INT,                                                      
    Description TEXT,                                                          
    QuantityBefore INT,                                                       
    QuantityAfter INT,                                                        
    SubmittedBy INT REFERENCES SystemUser(userID),
    submittedByName VARCHAR(100),                            
    Notes TEXT                                                                 
);

CREATE TABLE SiteOrder (
    siteOrderID INT PRIMARY KEY DEFAULT NEXT VALUE FOR SiteOrderSeq,
    siteID INT REFERENCES Site(siteID),
    submittedBy INT REFERENCES SystemUser(userID),
    submittedByName VARCHAR(100),
    submittedOn DATETIME,
    status VARCHAR(10) CHECK (status IN ('Draft', 'Sent', 'Fulfilled')),
    notes TEXT,
    createdOn DATETIME
);

CREATE TABLE WellOrder (
    well_orderID INT PRIMARY KEY DEFAULT NEXT VALUE FOR WellOrderSeq,
    wellID INT REFERENCES Well(wellID),
    submittedBy INT REFERENCES SystemUser(userID),
    submittedByName VARCHAR(100),
    submittedOn DATETIME,
    status VARCHAR(45) CHECK (status IN ('Pending', 'Approved', 'Merged INTO Site Order', 'Fulfilled')),
    notes TEXT,
    createdOn DATETIME
);

CREATE TABLE SiteOrderHasWellOrders (
    siteOrderID INT REFERENCES SiteOrder(siteOrderID),
    well_OrderID INT REFERENCES WellOrder(well_orderID),
    PRIMARY KEY (siteOrderID, well_OrderID)
);

CREATE TABLE SiteOrderLineItems (
    siteOrderLineItemID INT PRIMARY KEY DEFAULT NEXT VALUE FOR SiteOrderLineItemsSeq,
    connectorID INT NULL REFERENCES Connector(connectorID),
    siteOrderID INT REFERENCES SiteOrder(siteOrderID),
    quantityOrdered INT,
    itemType VARCHAR(10) CHECK (itemType IN ('Pipe', 'Connector')),
    unit VARCHAR(20),
    pipeID INT NULL REFERENCES Pipe(pipeID),
    notes TEXT
);

CREATE TABLE WellOrderLineItems (
    wellOrderLineItemID INT PRIMARY KEY DEFAULT NEXT VALUE FOR WellOrderLineItemsSeq,
    connectorID INT NULL REFERENCES Connector(connectorID),
    well_OrderID INT REFERENCES WellOrder(well_orderID),
    quantityRequested INT,
    itemType VARCHAR(10) CHECK (itemType IN ('Pipe', 'Connector')),
    unit VARCHAR(20),
    pipeID INT NULL REFERENCES Pipe(pipeID),
    notes TEXT
);

/*
SQL script to create and populate the RolePermission table in the Tubular Inventory Management database.

This script assumes that the Permission and Role tables already exist in the database.
It inserts predefined permissions and roles, and then assigns permissions to roles based on business requirements.

Sequences are used to generate unique IDs for the Permission and Role tables to avoid hardcoded values.

The RolePermission table maps each role to its respective permissions.
*/


INSERT INTO Permission (permissionID, permissionName)
VALUES 
  (NEXT VALUE FOR PermissionSeq, 'View Inventory'),
  (NEXT VALUE FOR PermissionSeq, 'Create Well Order'),
  (NEXT VALUE FOR PermissionSeq, 'Fulfill Site Order'),
  (NEXT VALUE FOR PermissionSeq, 'Manage Users');

-- Insert roles
-- Assigns a roleID to each role name using a sequence for unique values.
-- The roles are defined as Engineer, Inventory Clerk, Site Supervisor, and Administrator.
INSERT INTO Role (roleID, roleName)
VALUES 
  (NEXT VALUE FOR RoleSeq, 'Engineer'),
  (NEXT VALUE FOR RoleSeq, 'Inventory Clerk'),
  (NEXT VALUE FOR RoleSeq, 'Site Supervisor'),
  (NEXT VALUE FOR RoleSeq, 'Administrator');

-- Engineer: View Inventory, Create Well Order
-- Assigns the permissions 'View Inventory' and 'Create Well Order' to the Engineer role.
-- The roleID is obtained by joining the Role table with the Permission table based on the permission names.
INSERT INTO RolePermission (roleID, permissionID)
SELECT r.roleID, p.permissionID
FROM Role r
JOIN Permission p 
ON p.permissionName IN ('View Inventory', 'Create Well Order')
WHERE r.roleName = 'Engineer';

-- Inventory Clerk: View Inventory
-- Assigns the permission 'View Inventory' to the Inventory Clerk role.
-- The roleID is obtained by joining the Role table with the Permission table based on the permission name.
INSERT INTO RolePermission (roleID, permissionID)
SELECT r.roleID, p.permissionID
FROM Role r
JOIN Permission p 
ON p.permissionName IN ('View Inventory')
WHERE r.roleName = 'Inventory Clerk';

-- Site Supervisor: View Inventory, Fulfill Site Order
-- Assigns the permissions 'View Inventory' and 'Fulfill Site Order' to the Site Supervisor role.
-- The roleID is obtained by joining the Role table with the Permission table based on the permission names.
INSERT INTO RolePermission (roleID, permissionID)
SELECT r.roleID, p.permissionID
FROM Role r
JOIN Permission p 
ON p.permissionName IN ('View Inventory', 'Fulfill Site Order')
WHERE r.roleName = 'Site Supervisor';

-- Administrator: ALL permissions
-- Assigns all permissions to the Administrator role.
-- The roleID is obtained by joining the Role table with the Permission table based on the permission names.
INSERT INTO RolePermission (roleID, permissionID)
SELECT r.roleID, p.permissionID
FROM Role r
CROSS JOIN Permission p
WHERE r.roleName = 'Administrator';

/*
SQL script to create and populate the Site and Well tables in the Tubular Inventory Management database.
This is for USE CASE 1: Engineer Submits a Material Request for a Well
        •	An Engineer logs into the system and views a list of wells they are assigned to.
        •	They select a well and initiate a new material request (well order).
        •	They add line items specifying the type of product (pipe or connector), the requested quantity, and the unit of measure.
        •	The system records the requester, the well, the request date, and the list of requested materials.

*/

/*
SQL script to create and populate the Site and Well tables
*/

INSERT INTO Site (siteID, site_name, site_geolocation, site_region, operator)
VALUES 
(1, 'Westfield Alpha', '29.76N, 95.36W', 'Southwest', 'Alpha Energy'),
(2, 'Clearwater Bravo', '30.22N, 97.75W', 'Midland', 'Bravo Resources'),
(3, 'Falcon Ridge', '31.96N, 102.08W', 'Permian', 'Falcon Oil Co');


-- Wells for Site 1
INSERT INTO Well (wellID, siteID, well_name, wellType, status, depth)
VALUES 
(NEXT VALUE FOR WellSeq, 1, 'Alpha-1H', 'Production', 'Active', 9500.00),
(NEXT VALUE FOR WellSeq, 1, 'Alpha-2H', 'Exploration', 'Active', 8700.50),
(NEXT VALUE FOR WellSeq, 1, 'Alpha-3H', 'Production', 'Active', 9200.00),
(NEXT VALUE FOR WellSeq, 1, 'Alpha-4V', 'Injection', 'Active', 8000.50),
(NEXT VALUE FOR WellSeq, 1, 'Alpha-5H', 'Exploration', 'Inactive', 8700.00);

-- Wells for Site 2
INSERT INTO Well (wellID, siteID, well_name, wellType, status, depth)
VALUES 
(NEXT VALUE FOR WellSeq, 2, 'Bravo-5H', 'Production', 'Inactive', 10125.25),
(NEXT VALUE FOR WellSeq, 2, 'Bravo-6V', 'Injection', 'Active', 7300.75),
(NEXT VALUE FOR WellSeq, 2, 'Bravo-7H', 'Production', 'Active', 10250.00),
(NEXT VALUE FOR WellSeq, 2, 'Bravo-8V', 'Injection', 'Active', 7850.25),
(NEXT VALUE FOR WellSeq, 2, 'Bravo-9X', 'Exploration', 'Plugged', 9500.00);

-- Wells for Site 3
INSERT INTO Well (wellID, siteID, well_name, wellType, status, depth)
VALUES 
(NEXT VALUE FOR WellSeq, 3, 'Falcon-A', 'Production', 'Active', 8800.00),
(NEXT VALUE FOR WellSeq, 3, 'Falcon-B', 'Exploration', 'Plugged', 9400.00),
(NEXT VALUE FOR WellSeq, 3, 'Falcon-C', 'Production', 'Active', 8900.75),
(NEXT VALUE FOR WellSeq, 3, 'Falcon-D', 'Injection', 'Inactive', 9100.00),
(NEXT VALUE FOR WellSeq, 3, 'Falcon-E', 'Exploration', 'Active', 8650.00),
(NEXT VALUE FOR WellSeq, 3, 'Falcon-F', 'Production', 'Plugged', 8800.00);

/* 
SQL script to create and populate the Location table Supertype, SiteLocation and WellLocation subtypes 
*/

INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (1, 'Purpose Site Storage', 'Site', 1, 'Storage area for site 3');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (1, 3, 157, 13);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (2, 'Brother Site Storage', 'Site', 1, 'Storage area for site 3');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (2, 3, 240, 41);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (3, 'Ago Site Storage', 'Site', 1, 'Storage area for site 1');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (3, 1, 171, 23);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (4, 'Site Site Storage', 'Site', 1, 'Storage area for site 3');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (4, 3, 479, 79);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (5, 'Face Site Storage', 'Site', 1, 'Storage area for site 1');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (5, 1, 402, 64);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (6, 'Election Site Storage', 'Site', 1, 'Storage area for site 1');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (6, 1, 115, 21);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (7, 'Dog Site Storage', 'Site', 1, 'Storage area for site 1');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (7, 1, 219, 74);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (8, 'Chair Site Storage', 'Site', 1, 'Storage area for site 3');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (8, 3, 113, 81);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (9, 'Since Site Storage', 'Site', 1, 'Storage area for site 1');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (9, 1, 466, 93);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (10, 'Blue Site Storage', 'Site', 1, 'Storage area for site 3');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (10, 3, 379, 63);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (11, 'Require Site Storage', 'Site', 1, 'Storage area for site 1');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (11, 1, 329, 85);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (12, 'Sit Site Storage', 'Site', 1, 'Storage area for site 2');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (12, 2, 103, 30);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (13, 'Wait Site Storage', 'Site', 1, 'Storage area for site 3');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (13, 3, 316, 53);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (14, 'Offer Site Storage', 'Site', 1, 'Storage area for site 2');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (14, 2, 179, 37);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (15, 'Begin Site Storage', 'Site', 1, 'Storage area for site 2');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (15, 2, 152, 21);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (16, 'Performance Site Storage', 'Site', 1, 'Storage area for site 2');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (16, 2, 149, 55);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (17, 'Knowledge Site Storage', 'Site', 1, 'Storage area for site 2');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (17, 2, 409, 43);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (18, 'Almost Site Storage', 'Site', 1, 'Storage area for site 1');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (18, 1, 473, 68);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (19, 'All Site Storage', 'Site', 1, 'Storage area for site 3');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (19, 3, 163, 58);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (20, 'Better Site Storage', 'Site', 1, 'Storage area for site 1');
INSERT INTO SiteLocation (locationID, siteID, capacity, current_inventory) VALUES (20, 1, 382, 47);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (100, 'WellStorage-100', 'Well', 1, 'Auto-generated location for well 23');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (100, 8, 78, 42);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (101, 'WellStorage-101', 'Well', 1, 'Auto-generated location for well 24');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (101, 9, 161, 45);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (102, 'WellStorage-102', 'Well', 1, 'Auto-generated location for well 25');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (102, 10, 166, 5);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (103, 'WellStorage-103', 'Well', 1, 'Auto-generated location for well 26');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (103, 11, 294, 139);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (104, 'WellStorage-104', 'Well', 1, 'Auto-generated location for well 27');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (104, 12, 298, 261);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (105, 'WellStorage-105', 'Well', 1, 'Auto-generated location for well 28');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (105, 13, 245, 50);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (106, 'WellStorage-106', 'Well', 1, 'Auto-generated location for well 29');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (106, 14, 179, 32);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (107, 'WellStorage-107', 'Well', 1, 'Auto-generated location for well 30');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (107, 15, 272, 157);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (108, 'WellStorage-108', 'Well', 1, 'Auto-generated location for well 31');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (108, 16, 265, 264);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (109, 'WellStorage-109', 'Well', 1, 'Auto-generated location for well 32');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (109, 1, 205, 55);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (110, 'WellStorage-110', 'Well', 1, 'Auto-generated location for well 33');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (110, 2, 89, 52);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (111, 'WellStorage-111', 'Well', 1, 'Auto-generated location for well 34');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (111, 3, 245, 46);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (112, 'WellStorage-112', 'Well', 1, 'Auto-generated location for well 35');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (112, 4, 188, 140);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (113, 'WellStorage-113', 'Well', 1, 'Auto-generated location for well 36');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (113, 5, 285, 5);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (114, 'WellStorage-114', 'Well', 1, 'Auto-generated location for well 37');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (114, 6, 203, 87);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (115, 'WellStorage-115', 'Well', 1, 'Auto-generated location for well 38');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (115, 7, 175, 9);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (116, 'WellStorage-116', 'Well', 1, 'Auto-generated location for well 23');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (116, 8, 78, 51);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (117, 'WellStorage-117', 'Well', 1, 'Auto-generated location for well 24');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (117, 9, 274, 162);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (118, 'WellStorage-118', 'Well', 1, 'Auto-generated location for well 25');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (118, 10, 111, 12);
INSERT INTO Location (locationID, name, type, is_active, notes) VALUES (119, 'WellStorage-119', 'Well', 1, 'Auto-generated location for well 26');
INSERT INTO WellLocation (locationID, wellID, capacity, current_inventory) VALUES (119, 11, 111, 77);

/*
SQL script to create and populate the Pipe and Connector tables in the Tubular Inventory Management database.
*/

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (1, 'R3', 'PH6', 'Casing', 'PH6', 3.09, 'Galvanized', 0.411,
    'HTN101', 6.55, 'Rejected', 'S135', 16, 'Carbon Steel', 166);

INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (1, 1828.88, 'CementSpec-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (2, 'R3', 'API LTC', 'DrillPipe', 'API LTC', 4.48, 'None', 0.389,
    'HTN102', 8.93, 'Pending', 'L80', 10, 'Carbon Steel', 249);

INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (2, 5275.44, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (3, 'R3', 'VAM TOP', 'DrillPipe', 'VAM TOP', 6.17, 'Fusion Bond', 0.361,
    'HTN103', 7.46, 'Passed', 'G105', 18, 'High Alloy', 185);

INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (3, 6963.68, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (4, 'R2', 'XT39', 'Tubing', 'XT39', 4.21, 'None', 0.428,
    'HTN104', 16.88, 'Rejected', 'N80', 11, 'High Alloy', 270);

INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (4, 5424.02, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (5, 'R3', 'PH6', 'Casing', 'PH6', 3.46, 'Zinc Coated', 0.347,
    'HTN105', 11.28, 'Pending', 'P110', 20, 'Carbon Steel', 119);

INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (5, 1671.7, 'CementSpec-5');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (6, 'R1', 'API LTC', 'DrillPipe', 'API LTC', 5.28, 'Galvanized', 0.296,
    'HTN106', 14.48, 'Passed', 'G105', 8, 'Alloy Steel', 134);

INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (6, 5627.83, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (7, 'R1', 'VAM TOP', 'Casing', 'VAM TOP', 4.84, 'Ceramic', 0.431,
    'HTN107', 14.35, 'Pending', 'G105', 103, 'Alloy Steel', 51);

INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (7, 2885.48, 'CementSpec-7');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (8, 'R2', 'VAM TOP', 'Tubing', 'VAM TOP', 4.68, 'Zinc Coated', 0.4,
    'HTN108', 13.24, 'Passed', 'G105', 113, 'Carbon Steel', 119);

INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (8, 5307.51, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (9, 'R2', 'VAM TOP', 'Tubing', 'VAM TOP', 4.37, 'None', 0.283,
    'HTN109', 7.53, 'Pending', 'S135', 117, 'Carbon Steel', 282);

INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (9, 5182.06, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (10, 'R1', 'API BTC', 'DrillPipe', 'API BTC', 5.97, 'None', 0.336,
    'HTN110', 8.18, 'Rejected', 'G105', 12, 'Alloy Steel', 104);

INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (10, 5364.1, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (11, 'R2', 'VAM TOP', 'Tubing', 'VAM TOP', 4.38, 'Black Oxide', 0.417,
    'HTN111', 14.99, 'Passed', 'P110', 102, 'Carbon Steel', 216);

INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (11, 4205.86, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (12, 'R1', 'API LTC', 'Casing', 'API LTC', 4.99, 'Galvanized', 0.418,
    'HTN112', 8.86, 'Rejected', 'L80', 111, 'High Alloy', 292);

INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (12, 1435.93, 'CementSpec-12');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (13, 'R2', 'PH6', 'DrillPipe', 'PH6', 6.35, 'Galvanized', 0.371,
    'HTN113', 14.62, 'Passed', 'P110', 13, 'Carbon Steel', 198);

INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (13, 4077.04, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (14, 'R3', 'VAM TOP', 'DrillPipe', 'VAM TOP', 3.29, 'Ceramic', 0.438,
    'HTN114', 13.11, 'Pending', 'N80', 19, 'Carbon Steel', 228);

INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (14, 6317.44, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (15, 'R1', 'XT39', 'DrillPipe', 'XT39', 4.21, 'Fusion Bond', 0.319,
    'HTN115', 10.45, 'Pending', 'P110', 9, 'Carbon Steel', 267);

INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (15, 5260.18, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (16, 'R2', 'PH6', 'Casing', 'PH6', 4.34, 'None', 0.428,
    'HTN116', 7.84, 'Passed', 'S135', 17, 'High Alloy', 119);

INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (16, 2231.82, 'CementSpec-16');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (17, 'R2', 'VAM TOP', 'DrillPipe', 'VAM TOP', 4.87, 'Ceramic', 0.415,
    'HTN117', 9.87, 'Passed', 'L80', 2, 'Alloy Steel', 275);

INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (17, 5352.41, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (18, 'R3', 'VAM TOP', 'DrillPipe', 'VAM TOP', 5.9, 'Black Oxide', 0.256,
    'HTN118', 8.18, 'Passed', 'P110', 119, 'Alloy Steel', 137);

INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (18, 4838.98, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (19, 'R2', 'XT39', 'DrillPipe', 'XT39', 3.26, 'Fusion Bond', 0.353,
    'HTN119', 8.9, 'Rejected', 'G105', 106, 'High Alloy', 244);

INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (19, 4720.97, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (20, 'R3', 'VAM TOP', 'DrillPipe', 'VAM TOP', 2.87, 'Ceramic', 0.409,
    'HTN120', 8.66, 'Pending', 'N80', 105, 'Alloy Steel', 219);

INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (20, 5744.67, 'Liner-3');

INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (101, 6.09, 'Connector 101', 'XT39', 'Alloy Steel', 'Tenaris', 6163.87, 13, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (102, 4.02, 'Connector 102', 'XT39', 'High Alloy', 'Vallourec', 4861.11, 119, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (103, 5.24, 'Connector 103', 'XT39', 'High Alloy', 'NOV', 4523.66, 113, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (104, 6.12, 'Connector 104', 'NC38', 'Carbon Steel', 'Tenaris', 6442.55, 7, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (105, 5.01, 'Connector 105', 'XT39', 'High Alloy', 'TMK', 5843.34, 5, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (106, 4.49, 'Connector 106', 'API 5CT', 'Carbon Steel', 'NOV', 4148.99, 6, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (107, 4.35, 'Connector 107', 'API 5CT', 'Carbon Steel', 'Tenaris', 6147.4, 107, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (108, 4.75, 'Connector 108', 'API 5CT', 'Alloy Steel', 'NOV', 4433.78, 11, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (109, 5.68, 'Connector 109', 'API 5CT', 'Carbon Steel', 'TMK', 5722.38, 12, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (110, 4.59, 'Connector 110', 'XT39', 'Carbon Steel', 'Nippon Steel', 6439.29, 107, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (111, 3.54, 'Connector 111', 'API 5CT', 'High Alloy', 'Vallourec', 4104.48, 11, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (112, 3.29, 'Connector 112', 'NC38', 'High Alloy', 'Vallourec', 5638.93, 6, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (113, 5.29, 'Connector 113', 'API 5CT', 'Carbon Steel', 'Nippon Steel', 5967.0, 109, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (114, 3.87, 'Connector 114', 'XT39', 'High Alloy', 'NOV', 6277.3, 112, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (115, 5.3, 'Connector 115', 'NC38', 'Alloy Steel', 'NOV', 4151.39, 102, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (116, 3.57, 'Connector 116', 'NC38', 'Alloy Steel', 'TMK', 4383.41, 109, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (117, 6.06, 'Connector 117', 'NC38', 'High Alloy', 'Vallourec', 5330.43, 109, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (118, 3.34, 'Connector 118', 'NC38', 'High Alloy', 'TMK', 4101.19, 9, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (119, 6.4, 'Connector 119', 'API 5CT', 'Carbon Steel', 'Tenaris', 5731.13, 102, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (120, 5.85, 'Connector 120', 'API 5CT', 'Carbon Steel', 'Vallourec', 6175.55, 11, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (121, 5.41, 'Connector 121', 'XT39', 'High Alloy', 'NOV', 4480.98, 7, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (122, 4.45, 'Connector 122', 'XT39', 'Carbon Steel', 'NOV', 4961.92, 109, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (123, 5.96, 'Connector 123', 'XT39', 'High Alloy', 'TMK', 5909.02, 16, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (124, 6.11, 'Connector 124', 'API 5CT', 'High Alloy', 'Nippon Steel', 5110.02, 111, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (125, 3.19, 'Connector 125', 'XT39', 'High Alloy', 'NOV', 4960.38, 20, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (126, 3.55, 'Connector 126', 'XT39', 'High Alloy', 'Nippon Steel', 5629.44, 112, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (127, 3.62, 'Connector 127', 'NC38', 'Carbon Steel', 'Tenaris', 4739.4, 106, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (128, 3.75, 'Connector 128', 'API 5CT', 'Alloy Steel', 'Tenaris', 4159.86, 110, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (129, 4.09, 'Connector 129', 'XT39', 'High Alloy', 'Nippon Steel', 5526.14, 101, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (130, 4.12, 'Connector 130', 'API 5CT', 'Alloy Steel', 'Vallourec', 4825.24, 108, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (131, 5.94, 'Connector 131', 'XT39', 'Carbon Steel', 'Tenaris', 4136.36, 118, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (132, 4.26, 'Connector 132', 'NC38', 'Alloy Steel', 'TMK', 5351.55, 12, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (133, 5.01, 'Connector 133', 'XT39', 'Carbon Steel', 'TMK', 6280.03, 12, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (134, 6.43, 'Connector 134', 'XT39', 'Alloy Steel', 'TMK', 5470.21, 6, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (135, 5.68, 'Connector 135', 'API 5CT', 'High Alloy', 'Vallourec', 4280.49, 119, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (136, 4.62, 'Connector 136', 'NC38', 'High Alloy', 'Vallourec', 5811.83, 119, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (137, 6.18, 'Connector 137', 'XT39', 'Alloy Steel', 'NOV', 6183.28, 5, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (138, 6.49, 'Connector 138', 'API 5CT', 'Alloy Steel', 'TMK', 5674.75, 16, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (139, 6.25, 'Connector 139', 'API 5CT', 'Alloy Steel', 'Tenaris', 4460.53, 12, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (140, 3.02, 'Connector 140', 'API 5CT', 'High Alloy', 'Nippon Steel', 4970.95, 13, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (141, 5.19, 'Connector 141', 'API 5CT', 'High Alloy', 'Nippon Steel', 4992.98, 119, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (142, 4.64, 'Connector 142', 'XT39', 'Alloy Steel', 'TMK', 5452.92, 8, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (143, 3.45, 'Connector 143', 'API 5CT', 'Carbon Steel', 'Vallourec', 5079.81, 5, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (144, 6.18, 'Connector 144', 'NC38', 'Alloy Steel', 'NOV', 4614.04, 9, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (145, 5.3, 'Connector 145', 'XT39', 'Carbon Steel', 'Vallourec', 5015.31, 12, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (146, 5.29, 'Connector 146', 'XT39', 'High Alloy', 'Nippon Steel', 5049.94, 3, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (147, 3.96, 'Connector 147', 'XT39', 'Carbon Steel', 'Tenaris', 4914.64, 9, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (148, 5.46, 'Connector 148', 'XT39', 'Carbon Steel', 'TMK', 6168.7, 10, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (149, 5.3, 'Connector 149', 'API 5CT', 'Carbon Steel', 'Tenaris', 4953.69, 2, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (150, 6.41, 'Connector 150', 'API 5CT', 'High Alloy', 'Vallourec', 4690.46, 8, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (151, 5.66, 'Connector 151', 'API 5CT', 'Alloy Steel', 'TMK', 5153.6, 7, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (152, 4.35, 'Connector 152', 'API 5CT', 'High Alloy', 'TMK', 5554.88, 101, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (153, 6.28, 'Connector 153', 'NC38', 'Carbon Steel', 'Vallourec', 4549.26, 114, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (154, 4.76, 'Connector 154', 'XT39', 'High Alloy', 'Tenaris', 4560.16, 112, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (155, 3.24, 'Connector 155', 'XT39', 'Carbon Steel', 'TMK', 4224.32, 20, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (156, 4.19, 'Connector 156', 'API 5CT', 'Alloy Steel', 'NOV', 4667.42, 19, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (157, 5.89, 'Connector 157', 'API 5CT', 'High Alloy', 'NOV', 5634.72, 10, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (158, 5.77, 'Connector 158', 'NC38', 'High Alloy', 'TMK', 5647.48, 12, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (159, 4.36, 'Connector 159', 'NC38', 'Alloy Steel', 'Nippon Steel', 5524.6, 118, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (160, 4.93, 'Connector 160', 'API 5CT', 'High Alloy', 'Vallourec', 5278.56, 110, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (161, 3.19, 'Connector 161', 'API 5CT', 'High Alloy', 'Vallourec', 5619.06, 13, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (162, 4.15, 'Connector 162', 'API 5CT', 'Carbon Steel', 'Nippon Steel', 6304.16, 3, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (163, 6.26, 'Connector 163', 'NC38', 'Alloy Steel', 'Tenaris', 5652.32, 6, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (164, 3.62, 'Connector 164', 'API 5CT', 'Alloy Steel', 'TMK', 5249.66, 100, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (165, 3.65, 'Connector 165', 'XT39', 'High Alloy', 'NOV', 5937.78, 6, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (166, 4.76, 'Connector 166', 'API 5CT', 'Carbon Steel', 'Nippon Steel', 4727.95, 4, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (167, 4.38, 'Connector 167', 'XT39', 'Alloy Steel', 'NOV', 5505.11, 108, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (168, 3.41, 'Connector 168', 'API 5CT', 'Alloy Steel', 'NOV', 5385.17, 19, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (169, 5.0, 'Connector 169', 'NC38', 'Alloy Steel', 'Nippon Steel', 4355.19, 111, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (170, 4.63, 'Connector 170', 'API 5CT', 'High Alloy', 'NOV', 4106.05, 10, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (171, 4.18, 'Connector 171', 'API 5CT', 'Alloy Steel', 'Nippon Steel', 4516.2, 112, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (172, 5.56, 'Connector 172', 'NC38', 'Alloy Steel', 'NOV', 4692.19, 11, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (173, 5.72, 'Connector 173', 'XT39', 'Alloy Steel', 'TMK', 6183.55, 12, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (174, 3.38, 'Connector 174', 'API 5CT', 'Carbon Steel', 'Vallourec', 4385.94, 12, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (175, 3.41, 'Connector 175', 'XT39', 'High Alloy', 'Nippon Steel', 4266.78, 10, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (176, 4.47, 'Connector 176', 'API 5CT', 'Alloy Steel', 'TMK', 5573.97, 20, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (177, 3.67, 'Connector 177', 'XT39', 'High Alloy', 'Tenaris', 6157.02, 7, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (178, 3.21, 'Connector 178', 'NC38', 'Carbon Steel', 'TMK', 6141.18, 105, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (179, 4.02, 'Connector 179', 'NC38', 'Carbon Steel', 'NOV', 4399.1, 101, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (180, 3.04, 'Connector 180', 'XT39', 'Alloy Steel', 'NOV', 5072.88, 8, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (181, 5.81, 'Connector 181', 'API 5CT', 'Alloy Steel', 'Tenaris', 5625.05, 109, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (182, 3.61, 'Connector 182', 'API 5CT', 'Alloy Steel', 'TMK', 5747.8, 115, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (183, 3.74, 'Connector 183', 'API 5CT', 'High Alloy', 'TMK', 4585.52, 100, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (184, 5.08, 'Connector 184', 'XT39', 'Alloy Steel', 'Tenaris', 5245.64, 14, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (185, 3.96, 'Connector 185', 'NC38', 'High Alloy', 'Tenaris', 5380.82, 9, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (186, 5.42, 'Connector 186', 'NC38', 'Carbon Steel', 'Nippon Steel', 5875.72, 115, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (187, 3.42, 'Connector 187', 'NC38', 'High Alloy', 'Nippon Steel', 5127.2, 108, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (188, 4.63, 'Connector 188', 'API 5CT', 'Alloy Steel', 'TMK', 5390.34, 100, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (189, 5.43, 'Connector 189', 'XT39', 'Carbon Steel', 'NOV', 5506.56, 118, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (190, 3.19, 'Connector 190', 'NC38', 'Carbon Steel', 'Tenaris', 6085.1, 103, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (191, 5.16, 'Connector 191', 'XT39', 'Alloy Steel', 'NOV', 6254.31, 3, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (192, 6.49, 'Connector 192', 'NC38', 'Alloy Steel', 'NOV', 6451.24, 4, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (193, 5.49, 'Connector 193', 'NC38', 'High Alloy', 'TMK', 5813.53, 3, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (194, 5.85, 'Connector 194', 'NC38', 'Alloy Steel', 'Tenaris', 6342.74, 118, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (195, 6.25, 'Connector 195', 'XT39', 'Carbon Steel', 'Nippon Steel', 4431.98, 111, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (196, 3.93, 'Connector 196', 'API 5CT', 'High Alloy', 'Nippon Steel', 5967.58, 106, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (197, 4.4, 'Connector 197', 'API 5CT', 'Alloy Steel', 'NOV', 5225.91, 112, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (198, 5.51, 'Connector 198', 'XT39', 'Carbon Steel', 'TMK', 6391.68, 6, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (199, 5.86, 'Connector 199', 'XT39', 'Alloy Steel', 'NOV', 5972.15, 15, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (200, 3.19, 'Connector 200', 'NC38', 'Alloy Steel', 'NOV', 4468.21, 116, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (201, 6.04, 'Connector 201', 'API 5CT', 'Carbon Steel', 'Tenaris', 6070.21, 101, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (202, 5.36, 'Connector 202', 'XT39', 'High Alloy', 'Nippon Steel', 6174.66, 104, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (203, 5.03, 'Connector 203', 'XT39', 'Alloy Steel', 'Tenaris', 6286.21, 107, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (204, 3.01, 'Connector 204', 'NC38', 'Carbon Steel', 'Vallourec', 4300.11, 13, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (205, 4.13, 'Connector 205', 'NC38', 'High Alloy', 'Vallourec', 6368.87, 11, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (206, 3.97, 'Connector 206', 'API 5CT', 'Carbon Steel', 'TMK', 4042.03, 7, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (207, 3.46, 'Connector 207', 'XT39', 'Alloy Steel', 'NOV', 6070.65, 2, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (208, 3.03, 'Connector 208', 'XT39', 'High Alloy', 'TMK', 4894.26, 7, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (209, 3.88, 'Connector 209', 'API 5CT', 'Carbon Steel', 'Tenaris', 5978.19, 116, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (210, 4.96, 'Connector 210', 'NC38', 'Alloy Steel', 'Tenaris', 4290.33, 106, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (211, 4.69, 'Connector 211', 'NC38', 'High Alloy', 'TMK', 5012.02, 3, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (212, 4.16, 'Connector 212', 'NC38', 'High Alloy', 'TMK', 4845.63, 10, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (213, 4.54, 'Connector 213', 'API 5CT', 'Carbon Steel', 'Tenaris', 6373.61, 110, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (214, 5.79, 'Connector 214', 'XT39', 'Alloy Steel', 'NOV', 6154.25, 16, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (215, 3.95, 'Connector 215', 'NC38', 'Carbon Steel', 'TMK', 5123.91, 106, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (216, 4.1, 'Connector 216', 'API 5CT', 'Alloy Steel', 'Nippon Steel', 5669.52, 15, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (217, 3.64, 'Connector 217', 'XT39', 'Alloy Steel', 'Tenaris', 6180.94, 100, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (218, 5.52, 'Connector 218', 'NC38', 'Alloy Steel', 'TMK', 6205.19, 16, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (219, 3.64, 'Connector 219', 'NC38', 'Alloy Steel', 'TMK', 4395.36, 118, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (220, 4.04, 'Connector 220', 'API 5CT', 'High Alloy', 'Tenaris', 5665.37, 13, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (221, 4.51, 'Connector 221', 'API 5CT', 'Alloy Steel', 'NOV', 5354.67, 6, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (222, 4.46, 'Connector 222', 'NC38', 'Carbon Steel', 'Tenaris', 5913.08, 16, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (223, 6.08, 'Connector 223', 'XT39', 'Alloy Steel', 'Nippon Steel', 6065.43, 9, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (224, 4.54, 'Connector 224', 'NC38', 'Alloy Steel', 'TMK', 5426.74, 110, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (225, 3.5, 'Connector 225', 'XT39', 'Carbon Steel', 'NOV', 6056.29, 5, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (226, 4.22, 'Connector 226', 'NC38', 'Carbon Steel', 'Vallourec', 4706.93, 8, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (227, 5.66, 'Connector 227', 'API 5CT', 'High Alloy', 'Nippon Steel', 5644.61, 108, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (228, 3.82, 'Connector 228', 'NC38', 'High Alloy', 'Vallourec', 4199.96, 20, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (229, 6.5, 'Connector 229', 'XT39', 'Carbon Steel', 'Tenaris', 6046.88, 11, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (230, 3.64, 'Connector 230', 'NC38', 'Carbon Steel', 'Nippon Steel', 5454.28, 13, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (231, 4.04, 'Connector 231', 'XT39', 'High Alloy', 'Vallourec', 6395.54, 108, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (232, 3.34, 'Connector 232', 'XT39', 'Alloy Steel', 'Nippon Steel', 5820.0, 108, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (233, 6.03, 'Connector 233', 'API 5CT', 'High Alloy', 'NOV', 5466.36, 20, 'Fusion Bond');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (234, 4.03, 'Connector 234', 'API 5CT', 'Carbon Steel', 'NOV', 4872.29, 1, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (235, 4.87, 'Connector 235', 'NC38', 'Carbon Steel', 'TMK', 5684.9, 104, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (236, 4.3, 'Connector 236', 'XT39', 'High Alloy', 'TMK', 4893.92, 117, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (237, 4.3, 'Connector 237', 'API 5CT', 'Carbon Steel', 'Vallourec', 4021.93, 9, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (238, 4.39, 'Connector 238', 'API 5CT', 'High Alloy', 'TMK', 5263.91, 14, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (239, 3.01, 'Connector 239', 'API 5CT', 'High Alloy', 'TMK', 6153.73, 117, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (240, 6.41, 'Connector 240', 'API 5CT', 'Alloy Steel', 'Tenaris', 4473.26, 3, 'None');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (241, 5.77, 'Connector 241', 'NC38', 'High Alloy', 'TMK', 4642.23, 113, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (242, 5.34, 'Connector 242', 'NC38', 'Carbon Steel', 'Nippon Steel', 4418.74, 1, 'Ceramic');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (243, 4.85, 'Connector 243', 'API 5CT', 'Carbon Steel', 'Vallourec', 4163.57, 111, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (244, 4.06, 'Connector 244', 'XT39', 'High Alloy', 'Tenaris', 4186.95, 13, 'Black Oxide');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (245, 4.08, 'Connector 245', 'API 5CT', 'Alloy Steel', 'Nippon Steel', 6375.04, 7, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (246, 4.98, 'Connector 246', 'API 5CT', 'High Alloy', 'NOV', 4929.19, 114, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (247, 3.98, 'Connector 247', 'NC38', 'Alloy Steel', 'Vallourec', 4397.78, 15, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (248, 4.63, 'Connector 248', 'NC38', 'Carbon Steel', 'Tenaris', 5108.1, 111, 'Zinc Coated');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (249, 6.38, 'Connector 249', 'API 5CT', 'Alloy Steel', 'TMK', 5968.82, 102, 'Galvanized');
INSERT INTO Connector (connectorID, size, name, connectionStandard, material, manufacturer, pressureRating, storageLocationID, coatingType) VALUES (250, 4.02, 'Connector 250', 'XT39', 'Alloy Steel', 'NOV', 4221.18, 20, 'Black Oxide');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (101, 'API LTC', 'Round', 1.4, 1175.9);
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (102, 'XT39', 'Buttress', 0.73, 880.65);
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (103, 'API LTC', 'Buttress', 1.26, 1112.0);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (104, 'Design-Y', 1, '2815-psi', 'LIC-0104', 'B');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (105, 'XT39', 'Trapezoidal', 0.74, 871.4);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (106, 'Design-Y', 1, '1688-psi', 'LIC-0106', 'A');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (107, 'Design-Z', 0, '1783-psi', 'LIC-0107', 'A');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (108, 'XT39', 'Trapezoidal', 0.74, 796.88);
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (109, 'XT39', 'Round', 0.93, 727.81);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (110, 'Design-Z', 0, '1768-psi', 'LIC-0110', 'B');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (111, 'API BTC', 'Trapezoidal', 1.46, 1186.12);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (112, 'Design-Y', 1, '2977-psi', 'LIC-0112', 'A');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (113, 'Design-X', 0, '1509-psi', 'LIC-0113', 'C');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (114, 'Design-X', 0, '2053-psi', 'LIC-0114', 'B');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (115, 'Socket Weld', 'WPS-115', 'Passed', 'High');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (116, 'Socket Weld', 'WPS-116', 'Pending', 'Medium');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (117, 'XT39', 'Round', 1.1, 830.78);
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (118, 'API BTC', 'Trapezoidal', 1.28, 1188.71);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (119, 'Design-X', 1, '2117-psi', 'LIC-0119', 'C');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (120, 'Design-X', 1, '2859-psi', 'LIC-0120', 'C');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (121, 'XT39', 'Trapezoidal', 1.38, 651.73);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (122, 'Butt Weld', 'WPS-122', 'Rejected', 'Low');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (123, 'Design-X', 1, '2975-psi', 'LIC-0123', 'B');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (124, 'API BTC', 'Trapezoidal', 0.87, 1403.79);
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (125, 'API BTC', 'Buttress', 1.24, 1238.1);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (126, 'Design-X', 1, '1775-psi', 'LIC-0126', 'C');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (127, 'Design-X', 0, '1805-psi', 'LIC-0127', 'B');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (128, 'Butt Weld', 'WPS-128', 'Rejected', 'High');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (129, 'Design-X', 1, '2725-psi', 'LIC-0129', 'A');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (130, 'Socket Weld', 'WPS-130', 'Rejected', 'Low');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (131, 'Butt Weld', 'WPS-131', 'Passed', 'Low');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (132, 'API BTC', 'Trapezoidal', 1.26, 1333.49);
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (133, 'XT39', 'Trapezoidal', 1.48, 838.58);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (134, 'Design-Z', 1, '1867-psi', 'LIC-0134', 'C');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (135, 'XT39', 'Buttress', 0.89, 630.21);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (136, 'Design-Y', 0, '1673-psi', 'LIC-0136', 'B');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (137, 'Butt Weld', 'WPS-137', 'Pending', 'Medium');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (138, 'Design-Y', 1, '2291-psi', 'LIC-0138', 'B');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (139, 'Design-Z', 0, '2720-psi', 'LIC-0139', 'A');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (140, 'Design-Y', 1, '2746-psi', 'LIC-0140', 'C');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (141, 'Design-X', 1, '1827-psi', 'LIC-0141', 'C');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (142, 'API BTC', 'Trapezoidal', 0.99, 1046.5);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (143, 'Socket Weld', 'WPS-143', 'Passed', 'Medium');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (144, 'Design-Y', 1, '2573-psi', 'LIC-0144', 'A');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (145, 'Design-Z', 1, '2309-psi', 'LIC-0145', 'A');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (146, 'Socket Weld', 'WPS-146', 'Pending', 'Low');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (147, 'Socket Weld', 'WPS-147', 'Rejected', 'Low');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (148, 'API LTC', 'Buttress', 1.4, 1250.19);
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (149, 'API BTC', 'Trapezoidal', 1.48, 739.39);
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (150, 'XT39', 'Buttress', 0.84, 1446.3);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (151, 'Design-X', 0, '2174-psi', 'LIC-0151', 'B');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (152, 'Butt Weld', 'WPS-152', 'Passed', 'Medium');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (153, 'API BTC', 'Trapezoidal', 1.2, 755.31);
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (154, 'API LTC', 'Buttress', 0.86, 731.0);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (155, 'Socket Weld', 'WPS-155', 'Rejected', 'Medium');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (156, 'Socket Weld', 'WPS-156', 'Rejected', 'Medium');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (157, 'Design-Y', 1, '2879-psi', 'LIC-0157', 'A');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (158, 'Design-Y', 0, '2849-psi', 'LIC-0158', 'A');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (159, 'Butt Weld', 'WPS-159', 'Passed', 'High');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (160, 'Design-X', 0, '2532-psi', 'LIC-0160', 'C');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (161, 'Socket Weld', 'WPS-161', 'Passed', 'Medium');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (162, 'API LTC', 'Trapezoidal', 0.53, 1111.48);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (163, 'Design-Y', 1, '2546-psi', 'LIC-0163', 'B');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (164, 'API LTC', 'Round', 0.98, 636.06);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (165, 'Design-Y', 0, '2540-psi', 'LIC-0165', 'B');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (166, 'API BTC', 'Trapezoidal', 0.96, 948.43);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (167, 'Design-Y', 0, '1508-psi', 'LIC-0167', 'C');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (168, 'XT39', 'Round', 0.61, 765.63);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (169, 'Socket Weld', 'WPS-169', 'Pending', 'Low');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (170, 'Butt Weld', 'WPS-170', 'Pending', 'High');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (171, 'API BTC', 'Round', 1.15, 914.62);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (172, 'Design-Y', 1, '1871-psi', 'LIC-0172', 'A');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (173, 'Design-Z', 0, '2301-psi', 'LIC-0173', 'C');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (174, 'Butt Weld', 'WPS-174', 'Rejected', 'Medium');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (175, 'Design-Z', 1, '2812-psi', 'LIC-0175', 'A');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (176, 'Design-Z', 1, '2608-psi', 'LIC-0176', 'C');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (177, 'Socket Weld', 'WPS-177', 'Passed', 'Medium');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (178, 'XT39', 'Buttress', 0.56, 877.53);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (179, 'Design-Y', 0, '2919-psi', 'LIC-0179', 'A');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (180, 'API LTC', 'Buttress', 1.27, 934.24);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (181, 'Butt Weld', 'WPS-181', 'Pending', 'Low');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (182, 'API BTC', 'Round', 0.7, 1489.57);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (183, 'Butt Weld', 'WPS-183', 'Pending', 'Low');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (184, 'Design-X', 0, '2599-psi', 'LIC-0184', 'A');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (185, 'Design-Y', 1, '2941-psi', 'LIC-0185', 'C');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (186, 'Design-Y', 0, '1699-psi', 'LIC-0186', 'C');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (187, 'Butt Weld', 'WPS-187', 'Rejected', 'Low');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (188, 'Design-Z', 0, '2387-psi', 'LIC-0188', 'A');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (189, 'Socket Weld', 'WPS-189', 'Rejected', 'Medium');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (190, 'Design-Y', 0, '2769-psi', 'LIC-0190', 'C');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (191, 'Design-Y', 0, '2025-psi', 'LIC-0191', 'B');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (192, 'Butt Weld', 'WPS-192', 'Passed', 'Medium');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (193, 'Design-Z', 0, '1868-psi', 'LIC-0193', 'C');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (194, 'API LTC', 'Trapezoidal', 0.75, 1251.58);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (195, 'Socket Weld', 'WPS-195', 'Rejected', 'Medium');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (196, 'Design-Z', 1, '2252-psi', 'LIC-0196', 'B');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (197, 'Design-Z', 1, '1948-psi', 'LIC-0197', 'B');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (198, 'Socket Weld', 'WPS-198', 'Pending', 'Medium');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (199, 'API BTC', 'Trapezoidal', 0.56, 1262.33);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (200, 'Butt Weld', 'WPS-200', 'Rejected', 'Low');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (201, 'Socket Weld', 'WPS-201', 'Passed', 'High');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (202, 'Design-X', 0, '1704-psi', 'LIC-0202', 'C');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (203, 'Socket Weld', 'WPS-203', 'Passed', 'Medium');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (204, 'API LTC', 'Trapezoidal', 1.39, 520.74);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (205, 'Socket Weld', 'WPS-205', 'Passed', 'Medium');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (206, 'Butt Weld', 'WPS-206', 'Pending', 'Low');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (207, 'Butt Weld', 'WPS-207', 'Passed', 'High');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (208, 'API BTC', 'Trapezoidal', 1.08, 1084.49);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (209, 'Design-Y', 1, '2985-psi', 'LIC-0209', 'C');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (210, 'Butt Weld', 'WPS-210', 'Passed', 'Low');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (211, 'API BTC', 'Buttress', 1.17, 1451.36);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (212, 'Design-Y', 0, '2703-psi', 'LIC-0212', 'A');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (213, 'Design-X', 0, '2423-psi', 'LIC-0213', 'B');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (214, 'Socket Weld', 'WPS-214', 'Pending', 'Medium');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (215, 'Design-X', 0, '2933-psi', 'LIC-0215', 'C');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (216, 'Butt Weld', 'WPS-216', 'Passed', 'Medium');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (217, 'API LTC', 'Buttress', 1.03, 761.33);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (218, 'Design-X', 0, '2341-psi', 'LIC-0218', 'A');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (219, 'API LTC', 'Round', 1.03, 662.53);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (220, 'Design-X', 0, '1968-psi', 'LIC-0220', 'B');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (221, 'Socket Weld', 'WPS-221', 'Pending', 'Medium');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (222, 'API LTC', 'Buttress', 1.28, 715.76);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (223, 'Socket Weld', 'WPS-223', 'Rejected', 'Low');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (224, 'API BTC', 'Round', 1.05, 1347.2);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (225, 'Socket Weld', 'WPS-225', 'Passed', 'Medium');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (226, 'API BTC', 'Trapezoidal', 0.72, 1200.44);
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (227, 'API LTC', 'Round', 0.77, 827.52);
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (228, 'XT39', 'Trapezoidal', 0.61, 1032.08);
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (229, 'API BTC', 'Trapezoidal', 0.52, 876.88);
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (230, 'API LTC', 'Trapezoidal', 0.89, 705.44);
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (231, 'Design-Z', 1, '2359-psi', 'LIC-0231', 'B');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (232, 'API BTC', 'Buttress', 0.87, 1067.55);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (233, 'Socket Weld', 'WPS-233', 'Passed', 'Medium');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (234, 'Butt Weld', 'WPS-234', 'Passed', 'Low');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (235, 'Butt Weld', 'WPS-235', 'Pending', 'Low');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (236, 'Socket Weld', 'WPS-236', 'Rejected', 'High');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (237, 'XT39', 'Trapezoidal', 1.12, 995.79);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (238, 'Socket Weld', 'WPS-238', 'Rejected', 'High');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (239, 'Design-Z', 0, '2460-psi', 'LIC-0239', 'B');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (240, 'Design-Z', 1, '1644-psi', 'LIC-0240', 'C');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (241, 'XT39', 'Round', 0.66, 532.85);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (242, 'Butt Weld', 'WPS-242', 'Rejected', 'Low');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (243, 'API LTC', 'Buttress', 1.42, 721.29);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (244, 'Butt Weld', 'WPS-244', 'Rejected', 'High');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (245, 'Butt Weld', 'WPS-245', 'Pending', 'Low');
INSERT INTO ThreadedConnector (connectorID, threadType, threadForm, taper, makeUpTorque) VALUES (246, 'XT39', 'Buttress', 1.42, 558.39);
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (247, 'Butt Weld', 'WPS-247', 'Passed', 'High');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (248, 'Design-X', 0, '2678-psi', 'LIC-0248', 'B');
INSERT INTO WeldedConnector (connectorID, weldType, weldProcedure, weldInspectionStatus, heatAffectedZoneRating) VALUES (249, 'Butt Weld', 'WPS-249', 'Pending', 'High');
INSERT INTO PremiumConnector (connectorID, sealDesign, torqueShoulder, makeUpTorqueRange, licenseNumber, performanceGrade) VALUES (250, 'Design-Z', 0, '1541-psi', 'LIC-0250', 'B');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (21, 'R1', 'PH6', 'Casing', 'VAM TOP',
    2.86, 'Fusion Bond', 0.41,
    'HTN021', 14.69, 'Passed',
    'L80', 9, 'Carbon Steel', 87);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (21, 2453.8, 'CementSpec-21');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (22, 'R1', 'API BTC', 'Tubing', 'XT39',
    5.64, 'Ceramic', 0.31,
    'HTN022', 6.63, 'Rejected',
    'G105', 101, 'High Alloy', 271);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (22, 4781.78, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (23, 'R2', 'VAM TOP', 'Tubing', 'PH6',
    3.24, 'Ceramic', 0.375,
    'HTN023', 8.33, 'Rejected',
    'P110', 4, 'Carbon Steel', 191);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (23, 5832.08, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (24, 'R2', 'XT39', 'Casing', 'API LTC',
    4.2, 'Fusion Bond', 0.287,
    'HTN024', 6.32, 'Passed',
    'N80', 18, 'High Alloy', 144);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (24, 1806.77, 'CementSpec-24');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (25, 'R1', 'VAM TOP', 'DrillPipe', 'API BTC',
    3.31, 'Black Oxide', 0.462,
    'HTN025', 11.2, 'Rejected',
    'P110', 110, 'High Alloy', 90);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (25, 6179.95, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (26, 'R3', 'API LTC', 'Tubing', 'VAM TOP',
    2.6, 'Ceramic', 0.356,
    'HTN026', 6.21, 'Rejected',
    'N80', 14, 'Alloy Steel', 103);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (26, 4015.64, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (27, 'R1', 'API BTC', 'DrillPipe', 'API LTC',
    5.7, 'None', 0.318,
    'HTN027', 8.96, 'Pending',
    'P110', 11, 'Carbon Steel', 243);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (27, 4880.91, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (28, 'R3', 'API BTC', 'Casing', 'PH6',
    2.99, 'Zinc Coated', 0.342,
    'HTN028', 15.83, 'Pending',
    'S135', 113, 'High Alloy', 292);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (28, 2059.51, 'CementSpec-28');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (29, 'R2', 'API LTC', 'DrillPipe', 'XT39',
    3.56, 'None', 0.418,
    'HTN029', 10.17, 'Rejected',
    'S135', 108, 'High Alloy', 240);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (29, 4329.36, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (30, 'R3', 'VAM TOP', 'Tubing', 'VAM TOP',
    2.56, 'Black Oxide', 0.358,
    'HTN030', 13.16, 'Passed',
    'N80', 101, 'Alloy Steel', 218);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (30, 5155.64, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (31, 'R3', 'PH6', 'Casing', 'PH6',
    5.01, 'None', 0.384,
    'HTN031', 10.05, 'Passed',
    'L80', 16, 'Alloy Steel', 296);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (31, 1919.46, 'CementSpec-31');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (32, 'R1', 'XT39', 'DrillPipe', 'VAM TOP',
    3.8, 'None', 0.27,
    'HTN032', 13.24, 'Rejected',
    'L80', 19, 'Carbon Steel', 65);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (32, 6106.58, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (33, 'R3', 'PH6', 'Tubing', 'PH6',
    2.77, 'None', 0.272,
    'HTN033', 13.99, 'Pending',
    'L80', 9, 'Alloy Steel', 290);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (33, 5805.33, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (34, 'R1', 'XT39', 'DrillPipe', 'VAM TOP',
    5.87, 'Galvanized', 0.281,
    'HTN034', 8.36, 'Pending',
    'L80', 119, 'High Alloy', 75);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (34, 6467.89, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (35, 'R2', 'API BTC', 'DrillPipe', 'VAM TOP',
    5.32, 'Black Oxide', 0.314,
    'HTN035', 11.16, 'Rejected',
    'P110', 9, 'Carbon Steel', 285);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (35, 6769.19, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (36, 'R2', 'XT39', 'Casing', 'API LTC',
    3.05, 'Ceramic', 0.409,
    'HTN036', 7.46, 'Passed',
    'N80', 4, 'Alloy Steel', 290);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (36, 1546.96, 'CementSpec-36');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (37, 'R1', 'API LTC', 'DrillPipe', 'PH6',
    4.6, 'Fusion Bond', 0.492,
    'HTN037', 8.04, 'Pending',
    'S135', 110, 'Alloy Steel', 250);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (37, 4309.89, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (38, 'R1', 'API LTC', 'Tubing', 'API BTC',
    5.49, 'Galvanized', 0.485,
    'HTN038', 10.99, 'Passed',
    'S135', 112, 'High Alloy', 167);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (38, 4599.58, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (39, 'R1', 'API LTC', 'Casing', 'API LTC',
    2.51, 'None', 0.27,
    'HTN039', 6.5, 'Pending',
    'L80', 113, 'Carbon Steel', 56);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (39, 2413.78, 'CementSpec-39');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (40, 'R2', 'API LTC', 'DrillPipe', 'PH6',
    5.08, 'Black Oxide', 0.334,
    'HTN040', 10.62, 'Pending',
    'N80', 112, 'Carbon Steel', 285);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (40, 6854.95, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (41, 'R1', 'VAM TOP', 'Tubing', 'VAM TOP',
    4.17, 'Ceramic', 0.337,
    'HTN041', 14.3, 'Pending',
    'G105', 18, 'High Alloy', 123);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (41, 6609.88, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (42, 'R1', 'PH6', 'Tubing', 'API LTC',
    5.85, 'Black Oxide', 0.393,
    'HTN042', 6.41, 'Pending',
    'S135', 101, 'Alloy Steel', 273);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (42, 4248.9, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (43, 'R1', 'XT39', 'Casing', 'XT39',
    4.61, 'Zinc Coated', 0.499,
    'HTN043', 8.18, 'Rejected',
    'N80', 3, 'Alloy Steel', 170);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (43, 2914.59, 'CementSpec-43');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (44, 'R1', 'PH6', 'DrillPipe', 'API LTC',
    2.52, 'Zinc Coated', 0.484,
    'HTN044', 13.95, 'Pending',
    'S135', 10, 'Alloy Steel', 163);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (44, 5287.38, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (45, 'R2', 'XT39', 'Casing', 'PH6',
    5.71, 'Ceramic', 0.453,
    'HTN045', 12.35, 'Pending',
    'N80', 116, 'Carbon Steel', 274);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (45, 1675.91, 'CementSpec-45');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (46, 'R2', 'API BTC', 'Tubing', 'XT39',
    2.52, 'Zinc Coated', 0.358,
    'HTN046', 12.77, 'Passed',
    'S135', 1, 'High Alloy', 144);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (46, 4938.39, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (47, 'R1', 'API BTC', 'DrillPipe', 'VAM TOP',
    6.49, 'Galvanized', 0.289,
    'HTN047', 11.89, 'Rejected',
    'P110', 2, 'Carbon Steel', 272);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (47, 5438.95, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (48, 'R1', 'VAM TOP', 'DrillPipe', 'XT39',
    5.12, 'Galvanized', 0.465,
    'HTN048', 7.79, 'Pending',
    'L80', 16, 'Carbon Steel', 288);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (48, 4981.43, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (49, 'R1', 'PH6', 'DrillPipe', 'API BTC',
    4.05, 'Black Oxide', 0.257,
    'HTN049', 15.96, 'Pending',
    'N80', 6, 'Alloy Steel', 225);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (49, 6235.97, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (50, 'R3', 'XT39', 'DrillPipe', 'VAM TOP',
    2.64, 'Galvanized', 0.357,
    'HTN050', 8.22, 'Passed',
    'N80', 119, 'Alloy Steel', 109);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (50, 4358.66, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (51, 'R1', 'PH6', 'Tubing', 'XT39',
    3.93, 'Galvanized', 0.367,
    'HTN051', 12.16, 'Pending',
    'L80', 116, 'Alloy Steel', 166);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (51, 5907.3, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (52, 'R2', 'API BTC', 'Tubing', 'API LTC',
    4.65, 'Zinc Coated', 0.368,
    'HTN052', 14.69, 'Pending',
    'P110', 6, 'Carbon Steel', 285);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (52, 5787.58, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (53, 'R2', 'XT39', 'DrillPipe', 'XT39',
    5.09, 'None', 0.304,
    'HTN053', 7.65, 'Passed',
    'P110', 102, 'Alloy Steel', 133);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (53, 6588.88, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (54, 'R2', 'VAM TOP', 'DrillPipe', 'PH6',
    4.97, 'Zinc Coated', 0.301,
    'HTN054', 12.19, 'Rejected',
    'L80', 114, 'Carbon Steel', 192);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (54, 5766.11, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (55, 'R1', 'API BTC', 'Tubing', 'PH6',
    4.51, 'Galvanized', 0.33,
    'HTN055', 9.83, 'Rejected',
    'L80', 5, 'High Alloy', 59);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (55, 5344.98, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (56, 'R3', 'PH6', 'Tubing', 'VAM TOP',
    2.59, 'Ceramic', 0.252,
    'HTN056', 12.52, 'Passed',
    'N80', 2, 'Carbon Steel', 278);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (56, 4727.8, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (57, 'R3', 'VAM TOP', 'Tubing', 'API LTC',
    2.94, 'Fusion Bond', 0.436,
    'HTN057', 8.62, 'Pending',
    'S135', 1, 'High Alloy', 65);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (57, 6374.25, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (58, 'R1', 'PH6', 'Casing', 'XT39',
    5.03, 'Black Oxide', 0.423,
    'HTN058', 10.11, 'Pending',
    'L80', 10, 'Carbon Steel', 242);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (58, 1919.02, 'CementSpec-58');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (59, 'R1', 'XT39', 'Tubing', 'API BTC',
    4.07, 'None', 0.487,
    'HTN059', 7.89, 'Passed',
    'P110', 14, 'Alloy Steel', 140);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (59, 4560.16, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (60, 'R3', 'XT39', 'Casing', 'API BTC',
    4.88, 'Fusion Bond', 0.377,
    'HTN060', 11.27, 'Passed',
    'L80', 8, 'High Alloy', 187);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (60, 1664.34, 'CementSpec-60');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (61, 'R1', 'PH6', 'Tubing', 'XT39',
    3.06, 'None', 0.307,
    'HTN061', 10.28, 'Passed',
    'S135', 19, 'Alloy Steel', 145);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (61, 6491.67, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (62, 'R3', 'API BTC', 'Tubing', 'API BTC',
    3.49, 'Fusion Bond', 0.332,
    'HTN062', 9.69, 'Passed',
    'S135', 103, 'Carbon Steel', 127);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (62, 5763.71, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (63, 'R1', 'API BTC', 'DrillPipe', 'API BTC',
    4.95, 'Fusion Bond', 0.318,
    'HTN063', 11.49, 'Pending',
    'N80', 109, 'Carbon Steel', 129);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (63, 5517.47, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (64, 'R1', 'API LTC', 'Casing', 'PH6',
    4.38, 'Galvanized', 0.376,
    'HTN064', 14.34, 'Passed',
    'S135', 109, 'Carbon Steel', 218);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (64, 2997.81, 'CementSpec-64');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (65, 'R3', 'XT39', 'DrillPipe', 'API BTC',
    4.01, 'Fusion Bond', 0.424,
    'HTN065', 13.98, 'Passed',
    'P110', 113, 'High Alloy', 188);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (65, 6767.45, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (66, 'R2', 'PH6', 'Casing', 'VAM TOP',
    4.63, 'Zinc Coated', 0.454,
    'HTN066', 15.63, 'Passed',
    'L80', 5, 'Alloy Steel', 222);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (66, 1904.93, 'CementSpec-66');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (67, 'R2', 'VAM TOP', 'Casing', 'XT39',
    4.93, 'Ceramic', 0.48,
    'HTN067', 7.23, 'Passed',
    'N80', 6, 'High Alloy', 132);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (67, 2477.49, 'CementSpec-67');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (68, 'R1', 'VAM TOP', 'DrillPipe', 'VAM TOP',
    3.76, 'None', 0.486,
    'HTN068', 10.69, 'Pending',
    'L80', 11, 'Carbon Steel', 124);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (68, 5257.46, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (69, 'R1', 'API BTC', 'DrillPipe', 'API LTC',
    6.49, 'Black Oxide', 0.479,
    'HTN069', 13.42, 'Pending',
    'S135', 103, 'High Alloy', 97);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (69, 6044.99, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (70, 'R2', 'VAM TOP', 'Casing', 'XT39',
    6.17, 'Galvanized', 0.457,
    'HTN070', 13.12, 'Pending',
    'S135', 108, 'Carbon Steel', 201);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (70, 1857.48, 'CementSpec-70');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (71, 'R1', 'XT39', 'Tubing', 'API LTC',
    5.5, 'Zinc Coated', 0.278,
    'HTN071', 10.83, 'Pending',
    'G105', 9, 'High Alloy', 289);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (71, 4988.18, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (72, 'R3', 'API BTC', 'Tubing', 'API LTC',
    3.47, 'Galvanized', 0.293,
    'HTN072', 13.28, 'Rejected',
    'N80', 109, 'Alloy Steel', 110);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (72, 4822.73, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (73, 'R3', 'VAM TOP', 'Tubing', 'API LTC',
    6.42, 'None', 0.308,
    'HTN073', 12.99, 'Rejected',
    'P110', 102, 'Alloy Steel', 81);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (73, 6463.14, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (74, 'R1', 'API LTC', 'Casing', 'XT39',
    4.92, 'Ceramic', 0.372,
    'HTN074', 15.55, 'Pending',
    'G105', 5, 'High Alloy', 132);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (74, 2277.71, 'CementSpec-74');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (75, 'R3', 'API BTC', 'DrillPipe', 'API LTC',
    4.21, 'Galvanized', 0.318,
    'HTN075', 9.84, 'Rejected',
    'G105', 118, 'Carbon Steel', 152);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (75, 4840.28, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (76, 'R2', 'PH6', 'DrillPipe', 'PH6',
    5.55, 'Zinc Coated', 0.486,
    'HTN076', 14.64, 'Passed',
    'L80', 20, 'High Alloy', 68);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (76, 6193.48, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (77, 'R3', 'XT39', 'DrillPipe', 'VAM TOP',
    6.25, 'Ceramic', 0.401,
    'HTN077', 14.9, 'Rejected',
    'S135', 106, 'Alloy Steel', 183);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (77, 4296.38, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (78, 'R2', 'PH6', 'Casing', 'API BTC',
    4.32, 'Zinc Coated', 0.353,
    'HTN078', 7.01, 'Passed',
    'L80', 104, 'Alloy Steel', 118);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (78, 2641.19, 'CementSpec-78');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (79, 'R2', 'XT39', 'Tubing', 'VAM TOP',
    5.32, 'Fusion Bond', 0.351,
    'HTN079', 10.56, 'Passed',
    'N80', 9, 'Alloy Steel', 226);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (79, 4514.07, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (80, 'R2', 'PH6', 'Casing', 'API LTC',
    6.17, 'Galvanized', 0.345,
    'HTN080', 6.95, 'Pending',
    'N80', 116, 'Alloy Steel', 172);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (80, 1750.28, 'CementSpec-80');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (81, 'R3', 'PH6', 'Casing', 'VAM TOP',
    2.86, 'Galvanized', 0.294,
    'HTN081', 13.15, 'Pending',
    'S135', 112, 'High Alloy', 199);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (81, 2967.26, 'CementSpec-81');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (82, 'R3', 'XT39', 'DrillPipe', 'VAM TOP',
    6.02, 'Fusion Bond', 0.287,
    'HTN082', 12.61, 'Pending',
    'P110', 114, 'Carbon Steel', 159);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (82, 6888.03, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (83, 'R2', 'VAM TOP', 'Tubing', 'API LTC',
    4.28, 'Black Oxide', 0.473,
    'HTN083', 8.92, 'Pending',
    'N80', 18, 'High Alloy', 193);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (83, 6701.6, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (84, 'R2', 'PH6', 'Tubing', 'XT39',
    3.05, 'Galvanized', 0.445,
    'HTN084', 16.0, 'Pending',
    'G105', 118, 'High Alloy', 182);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (84, 6923.33, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (85, 'R3', 'API LTC', 'Casing', 'API BTC',
    5.17, 'None', 0.374,
    'HTN085', 15.09, 'Pending',
    'L80', 116, 'Alloy Steel', 273);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (85, 2873.53, 'CementSpec-85');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (86, 'R2', 'PH6', 'Casing', 'XT39',
    3.62, 'Ceramic', 0.336,
    'HTN086', 13.06, 'Passed',
    'S135', 117, 'Carbon Steel', 150);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (86, 1785.46, 'CementSpec-86');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (87, 'R3', 'VAM TOP', 'DrillPipe', 'XT39',
    3.56, 'Galvanized', 0.321,
    'HTN087', 7.69, 'Passed',
    'L80', 19, 'Alloy Steel', 280);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (87, 5330.24, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (88, 'R2', 'API LTC', 'DrillPipe', 'API LTC',
    3.2, 'Zinc Coated', 0.337,
    'HTN088', 14.2, 'Rejected',
    'G105', 115, 'Alloy Steel', 238);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (88, 4872.52, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (89, 'R1', 'API BTC', 'Tubing', 'PH6',
    2.92, 'Ceramic', 0.295,
    'HTN089', 12.63, 'Rejected',
    'N80', 106, 'High Alloy', 91);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (89, 4708.95, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (90, 'R3', 'XT39', 'Casing', 'API LTC',
    5.51, 'Black Oxide', 0.444,
    'HTN090', 9.49, 'Pending',
    'L80', 113, 'Alloy Steel', 68);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (90, 2801.12, 'CementSpec-90');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (91, 'R3', 'XT39', 'Tubing', 'API BTC',
    3.01, 'Black Oxide', 0.311,
    'HTN091', 13.05, 'Passed',
    'N80', 107, 'Carbon Steel', 114);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (91, 5264.19, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (92, 'R2', 'PH6', 'Tubing', 'API LTC',
    3.13, 'Ceramic', 0.428,
    'HTN092', 9.74, 'Passed',
    'P110', 105, 'Alloy Steel', 183);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (92, 6721.38, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (93, 'R1', 'API LTC', 'Tubing', 'VAM TOP',
    5.14, 'None', 0.314,
    'HTN093', 6.24, 'Rejected',
    'G105', 4, 'Alloy Steel', 68);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (93, 4688.16, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (94, 'R1', 'VAM TOP', 'Tubing', 'API BTC',
    6.03, 'Fusion Bond', 0.452,
    'HTN094', 6.12, 'Passed',
    'L80', 12, 'Alloy Steel', 143);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (94, 6355.44, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (95, 'R2', 'XT39', 'DrillPipe', 'API BTC',
    3.68, 'Ceramic', 0.387,
    'HTN095', 8.43, 'Passed',
    'G105', 8, 'High Alloy', 66);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (95, 4676.52, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (96, 'R3', 'XT39', 'DrillPipe', 'PH6',
    5.0, 'None', 0.496,
    'HTN096', 13.83, 'Passed',
    'S135', 103, 'Alloy Steel', 183);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (96, 5146.31, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (97, 'R3', 'API BTC', 'Casing', 'VAM TOP',
    3.15, 'Fusion Bond', 0.493,
    'HTN097', 9.95, 'Pending',
    'S135', 2, 'Carbon Steel', 137);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (97, 2584.8, 'CementSpec-97');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (98, 'R1', 'VAM TOP', 'DrillPipe', 'API BTC',
    3.14, 'Fusion Bond', 0.292,
    'HTN098', 14.93, 'Passed',
    'P110', 104, 'Alloy Steel', 74);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (98, 5199.12, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (99, 'R3', 'API LTC', 'Tubing', 'VAM TOP',
    3.25, 'Zinc Coated', 0.381,
    'HTN099', 6.9, 'Passed',
    'G105', 110, 'High Alloy', 287);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (99, 6127.59, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (100, 'R2', 'XT39', 'Casing', 'API LTC',
    5.41, 'Ceramic', 0.49,
    'HTN100', 8.05, 'Passed',
    'G105', 10, 'High Alloy', 164);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (100, 2285.71, 'CementSpec-100');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (101, 'R3', 'API LTC', 'Tubing', 'XT39',
    5.17, 'Zinc Coated', 0.258,
    'HTN101', 11.02, 'Pending',
    'G105', 2, 'Alloy Steel', 50);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (101, 5132.89, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (102, 'R2', 'PH6', 'Tubing', 'XT39',
    3.99, 'Ceramic', 0.477,
    'HTN102', 7.11, 'Rejected',
    'S135', 3, 'Alloy Steel', 59);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (102, 5252.64, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (103, 'R1', 'XT39', 'DrillPipe', 'API BTC',
    6.47, 'Ceramic', 0.261,
    'HTN103', 9.88, 'Rejected',
    'G105', 11, 'Alloy Steel', 217);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (103, 6698.77, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (104, 'R3', 'XT39', 'DrillPipe', 'PH6',
    3.53, 'Zinc Coated', 0.468,
    'HTN104', 6.9, 'Passed',
    'S135', 105, 'Carbon Steel', 51);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (104, 6091.1, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (105, 'R2', 'XT39', 'Tubing', 'PH6',
    4.47, 'Ceramic', 0.419,
    'HTN105', 15.31, 'Pending',
    'P110', 115, 'High Alloy', 239);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (105, 4632.88, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (106, 'R2', 'VAM TOP', 'Tubing', 'API LTC',
    3.33, 'Fusion Bond', 0.407,
    'HTN106', 7.34, 'Pending',
    'L80', 13, 'High Alloy', 184);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (106, 4215.21, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (107, 'R3', 'API BTC', 'Tubing', 'API BTC',
    3.36, 'Black Oxide', 0.5,
    'HTN107', 10.19, 'Pending',
    'P110', 100, 'Alloy Steel', 99);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (107, 6422.21, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (108, 'R1', 'PH6', 'Casing', 'XT39',
    4.06, 'None', 0.46,
    'HTN108', 11.36, 'Rejected',
    'L80', 18, 'Carbon Steel', 297);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (108, 2878.9, 'CementSpec-108');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (109, 'R1', 'VAM TOP', 'Casing', 'VAM TOP',
    4.78, 'None', 0.371,
    'HTN109', 13.61, 'Rejected',
    'G105', 101, 'Alloy Steel', 81);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (109, 2189.28, 'CementSpec-109');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (110, 'R1', 'API BTC', 'Tubing', 'XT39',
    5.06, 'Black Oxide', 0.334,
    'HTN110', 12.63, 'Pending',
    'P110', 6, 'Carbon Steel', 225);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (110, 4080.16, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (111, 'R2', 'XT39', 'DrillPipe', 'API LTC',
    4.33, 'Zinc Coated', 0.252,
    'HTN111', 12.4, 'Rejected',
    'N80', 8, 'Alloy Steel', 118);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (111, 4724.55, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (112, 'R3', 'XT39', 'DrillPipe', 'PH6',
    2.81, 'Galvanized', 0.468,
    'HTN112', 7.17, 'Passed',
    'L80', 11, 'Carbon Steel', 129);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (112, 4762.56, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (113, 'R1', 'PH6', 'DrillPipe', 'API LTC',
    6.1, 'Fusion Bond', 0.367,
    'HTN113', 6.88, 'Pending',
    'N80', 4, 'High Alloy', 135);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (113, 5119.7, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (114, 'R1', 'API LTC', 'Casing', 'XT39',
    3.61, 'Ceramic', 0.333,
    'HTN114', 7.13, 'Rejected',
    'S135', 4, 'Alloy Steel', 250);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (114, 2938.33, 'CementSpec-114');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (115, 'R2', 'VAM TOP', 'DrillPipe', 'PH6',
    4.24, 'Fusion Bond', 0.419,
    'HTN115', 9.66, 'Rejected',
    'P110', 8, 'Alloy Steel', 197);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (115, 4410.5, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (116, 'R3', 'VAM TOP', 'DrillPipe', 'API BTC',
    3.47, 'Black Oxide', 0.344,
    'HTN116', 12.88, 'Pending',
    'L80', 20, 'High Alloy', 92);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (116, 6034.93, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (117, 'R3', 'VAM TOP', 'Casing', 'VAM TOP',
    3.22, 'Fusion Bond', 0.272,
    'HTN117', 11.98, 'Pending',
    'N80', 11, 'High Alloy', 131);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (117, 1802.58, 'CementSpec-117');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (118, 'R2', 'PH6', 'Tubing', 'API LTC',
    6.34, 'Black Oxide', 0.273,
    'HTN118', 8.17, 'Passed',
    'S135', 13, 'Alloy Steel', 279);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (118, 6354.28, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (119, 'R3', 'VAM TOP', 'Casing', 'PH6',
    3.73, 'None', 0.366,
    'HTN119', 7.63, 'Rejected',
    'G105', 107, 'Alloy Steel', 55);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (119, 2072.49, 'CementSpec-119');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (120, 'R1', 'VAM TOP', 'Casing', 'API BTC',
    4.37, 'Fusion Bond', 0.324,
    'HTN120', 9.0, 'Passed',
    'G105', 101, 'Carbon Steel', 191);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (120, 2305.07, 'CementSpec-120');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (121, 'R2', 'XT39', 'DrillPipe', 'PH6',
    4.7, 'Galvanized', 0.327,
    'HTN121', 11.36, 'Rejected',
    'G105', 2, 'High Alloy', 87);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (121, 6907.77, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (122, 'R2', 'API BTC', 'Tubing', 'VAM TOP',
    3.13, 'None', 0.381,
    'HTN122', 11.84, 'Passed',
    'N80', 115, 'High Alloy', 113);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (122, 6108.84, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (123, 'R3', 'API LTC', 'Casing', 'API LTC',
    4.94, 'Fusion Bond', 0.28,
    'HTN123', 7.3, 'Passed',
    'S135', 101, 'Carbon Steel', 139);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (123, 1661.75, 'CementSpec-123');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (124, 'R2', 'API LTC', 'DrillPipe', 'XT39',
    4.54, 'None', 0.291,
    'HTN124', 15.31, 'Rejected',
    'P110', 106, 'High Alloy', 281);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (124, 6545.66, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (125, 'R3', 'PH6', 'Tubing', 'API BTC',
    4.82, 'Ceramic', 0.4,
    'HTN125', 9.77, 'Rejected',
    'N80', 110, 'Alloy Steel', 75);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (125, 4375.44, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (126, 'R1', 'API LTC', 'Casing', 'XT39',
    2.64, 'Ceramic', 0.401,
    'HTN126', 12.6, 'Passed',
    'N80', 15, 'High Alloy', 94);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (126, 2321.93, 'CementSpec-126');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (127, 'R3', 'API LTC', 'DrillPipe', 'API LTC',
    3.55, 'Fusion Bond', 0.403,
    'HTN127', 9.23, 'Passed',
    'N80', 109, 'Carbon Steel', 54);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (127, 5436.55, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (128, 'R3', 'PH6', 'Tubing', 'XT39',
    4.93, 'Ceramic', 0.499,
    'HTN128', 8.59, 'Pending',
    'G105', 7, 'Alloy Steel', 265);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (128, 5980.91, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (129, 'R2', 'VAM TOP', 'Casing', 'API BTC',
    4.76, 'None', 0.376,
    'HTN129', 13.34, 'Rejected',
    'P110', 100, 'High Alloy', 241);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (129, 1524.48, 'CementSpec-129');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (130, 'R1', 'API BTC', 'Tubing', 'PH6',
    3.39, 'Ceramic', 0.28,
    'HTN130', 10.77, 'Rejected',
    'N80', 13, 'Carbon Steel', 114);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (130, 5287.95, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (131, 'R1', 'VAM TOP', 'DrillPipe', 'API BTC',
    2.63, 'Zinc Coated', 0.417,
    'HTN131', 10.06, 'Rejected',
    'N80', 106, 'High Alloy', 211);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (131, 6333.04, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (132, 'R1', 'API BTC', 'DrillPipe', 'XT39',
    3.42, 'Ceramic', 0.354,
    'HTN132', 6.8, 'Pending',
    'G105', 19, 'Carbon Steel', 76);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (132, 5185.35, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (133, 'R2', 'XT39', 'Tubing', 'API BTC',
    3.37, 'Zinc Coated', 0.462,
    'HTN133', 7.23, 'Rejected',
    'G105', 20, 'High Alloy', 97);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (133, 6681.48, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (134, 'R3', 'VAM TOP', 'DrillPipe', 'API LTC',
    5.65, 'None', 0.456,
    'HTN134', 7.14, 'Passed',
    'L80', 15, 'Carbon Steel', 248);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (134, 5557.53, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (135, 'R2', 'VAM TOP', 'Tubing', 'API BTC',
    3.78, 'Black Oxide', 0.473,
    'HTN135', 9.35, 'Pending',
    'P110', 20, 'Alloy Steel', 207);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (135, 5545.54, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (136, 'R1', 'VAM TOP', 'DrillPipe', 'PH6',
    5.68, 'Black Oxide', 0.333,
    'HTN136', 13.88, 'Pending',
    'L80', 18, 'Carbon Steel', 146);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (136, 4624.32, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (137, 'R1', 'PH6', 'Casing', 'VAM TOP',
    2.66, 'Galvanized', 0.452,
    'HTN137', 12.25, 'Pending',
    'G105', 105, 'Carbon Steel', 297);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (137, 2826.5, 'CementSpec-137');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (138, 'R2', 'API LTC', 'Tubing', 'API BTC',
    4.39, 'None', 0.411,
    'HTN138', 6.16, 'Passed',
    'N80', 118, 'Carbon Steel', 104);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (138, 6017.36, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (139, 'R3', 'PH6', 'DrillPipe', 'API LTC',
    3.44, 'None', 0.272,
    'HTN139', 14.25, 'Rejected',
    'S135', 101, 'High Alloy', 187);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (139, 6452.51, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (140, 'R1', 'XT39', 'DrillPipe', 'PH6',
    4.49, 'Black Oxide', 0.304,
    'HTN140', 13.79, 'Passed',
    'L80', 5, 'Alloy Steel', 225);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (140, 6743.87, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (141, 'R1', 'XT39', 'Casing', 'API BTC',
    5.16, 'Zinc Coated', 0.487,
    'HTN141', 10.85, 'Rejected',
    'G105', 17, 'Alloy Steel', 278);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (141, 2234.45, 'CementSpec-141');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (142, 'R3', 'PH6', 'Tubing', 'VAM TOP',
    5.14, 'Ceramic', 0.492,
    'HTN142', 12.98, 'Rejected',
    'L80', 119, 'High Alloy', 126);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (142, 4244.72, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (143, 'R3', 'XT39', 'Casing', 'PH6',
    6.08, 'Fusion Bond', 0.47,
    'HTN143', 11.12, 'Rejected',
    'G105', 103, 'Carbon Steel', 214);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (143, 1910.24, 'CementSpec-143');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (144, 'R1', 'API LTC', 'DrillPipe', 'PH6',
    3.0, 'None', 0.395,
    'HTN144', 6.78, 'Rejected',
    'G105', 11, 'Alloy Steel', 106);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (144, 6224.63, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (145, 'R1', 'VAM TOP', 'DrillPipe', 'API LTC',
    4.45, 'Fusion Bond', 0.443,
    'HTN145', 10.23, 'Pending',
    'G105', 17, 'Carbon Steel', 114);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (145, 6518.18, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (146, 'R2', 'XT39', 'DrillPipe', 'API BTC',
    6.07, 'Galvanized', 0.346,
    'HTN146', 11.09, 'Rejected',
    'G105', 107, 'High Alloy', 218);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (146, 6209.85, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (147, 'R3', 'API LTC', 'DrillPipe', 'API LTC',
    3.57, 'Galvanized', 0.287,
    'HTN147', 9.23, 'Pending',
    'L80', 110, 'High Alloy', 67);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (147, 6703.32, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (148, 'R1', 'VAM TOP', 'Tubing', 'API BTC',
    3.11, 'Fusion Bond', 0.487,
    'HTN148', 11.74, 'Rejected',
    'L80', 15, 'Carbon Steel', 208);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (148, 5505.61, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (149, 'R3', 'XT39', 'Tubing', 'PH6',
    5.59, 'Ceramic', 0.477,
    'HTN149', 6.01, 'Passed',
    'L80', 12, 'High Alloy', 155);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (149, 6814.3, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (150, 'R3', 'API LTC', 'DrillPipe', 'XT39',
    3.58, 'Black Oxide', 0.374,
    'HTN150', 10.69, 'Passed',
    'S135', 106, 'Carbon Steel', 71);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (150, 4321.65, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (151, 'R1', 'API BTC', 'Tubing', 'API LTC',
    4.18, 'None', 0.434,
    'HTN151', 13.24, 'Rejected',
    'P110', 1, 'High Alloy', 293);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (151, 5588.14, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (152, 'R2', 'API BTC', 'Casing', 'API LTC',
    6.41, 'Zinc Coated', 0.448,
    'HTN152', 10.17, 'Pending',
    'G105', 20, 'Carbon Steel', 200);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (152, 2883.16, 'CementSpec-152');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (153, 'R1', 'VAM TOP', 'Casing', 'XT39',
    3.57, 'Fusion Bond', 0.32,
    'HTN153', 7.03, 'Pending',
    'G105', 17, 'Carbon Steel', 70);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (153, 1561.8, 'CementSpec-153');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (154, 'R3', 'XT39', 'DrillPipe', 'VAM TOP',
    3.54, 'Ceramic', 0.287,
    'HTN154', 14.88, 'Pending',
    'P110', 13, 'High Alloy', 73);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (154, 4032.22, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (155, 'R2', 'PH6', 'DrillPipe', 'XT39',
    3.32, 'None', 0.457,
    'HTN155', 14.71, 'Pending',
    'P110', 101, 'Alloy Steel', 237);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (155, 6949.66, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (156, 'R1', 'API LTC', 'DrillPipe', 'PH6',
    4.34, 'Zinc Coated', 0.27,
    'HTN156', 12.9, 'Rejected',
    'G105', 20, 'Carbon Steel', 201);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (156, 5186.62, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (157, 'R3', 'API BTC', 'Tubing', 'API BTC',
    6.18, 'None', 0.459,
    'HTN157', 6.97, 'Passed',
    'S135', 10, 'Alloy Steel', 157);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (157, 4388.86, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (158, 'R3', 'API LTC', 'Casing', 'API BTC',
    4.75, 'Black Oxide', 0.384,
    'HTN158', 12.22, 'Pending',
    'N80', 105, 'Carbon Steel', 266);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (158, 2294.47, 'CementSpec-158');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (159, 'R2', 'API LTC', 'DrillPipe', 'VAM TOP',
    2.66, 'Galvanized', 0.255,
    'HTN159', 9.87, 'Pending',
    'P110', 7, 'High Alloy', 89);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (159, 5413.82, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (160, 'R2', 'XT39', 'DrillPipe', 'API BTC',
    5.55, 'None', 0.47,
    'HTN160', 8.41, 'Passed',
    'S135', 13, 'Carbon Steel', 232);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (160, 4728.78, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (161, 'R2', 'API BTC', 'Tubing', 'API BTC',
    3.46, 'Black Oxide', 0.43,
    'HTN161', 10.26, 'Rejected',
    'P110', 104, 'Carbon Steel', 299);
INSERT INTO Tubing (pipeID, maxPressure, linerType) VALUES (161, 5651.25, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (162, 'R1', 'API LTC', 'DrillPipe', 'API LTC',
    5.04, 'Ceramic', 0.454,
    'HTN162', 15.5, 'Passed',
    'P110', 4, 'Alloy Steel', 108);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (162, 4693.03, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (163, 'R2', 'PH6', 'DrillPipe', 'API BTC',
    5.04, 'None', 0.363,
    'HTN163', 13.64, 'Passed',
    'S135', 107, 'Carbon Steel', 274);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (163, 6240.69, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (164, 'R3', 'PH6', 'DrillPipe', 'XT39',
    3.13, 'Fusion Bond', 0.303,
    'HTN164', 10.57, 'Rejected',
    'G105', 105, 'High Alloy', 116);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (164, 4000.17, 'Liner-3');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (165, 'R1', 'API BTC', 'Casing', 'API LTC',
    3.11, 'Galvanized', 0.278,
    'HTN165', 15.53, 'Passed',
    'L80', 15, 'High Alloy', 93);
INSERT INTO Casing (pipeID, collapsePressure, cementingSpec) VALUES (165, 2670.43, 'CementSpec-165');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (166, 'R1', 'XT39', 'DrillPipe', 'VAM TOP',
    3.31, 'Ceramic', 0.437,
    'HTN166', 9.65, 'Rejected',
    'G105', 114, 'Alloy Steel', 134);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (166, 4779.77, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (167, 'R3', 'API LTC', 'DrillPipe', 'API BTC',
    3.8, 'Ceramic', 0.351,
    'HTN167', 9.7, 'Pending',
    'G105', 106, 'High Alloy', 151);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (167, 6056.65, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (168, 'R2', 'PH6', 'DrillPipe', 'XT39',
    5.32, 'Ceramic', 0.494,
    'HTN168', 11.39, 'Passed',
    'S135', 106, 'Carbon Steel', 89);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (168, 5456.12, 'Liner-2');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (169, 'R2', 'API BTC', 'DrillPipe', 'API BTC',
    3.23, 'Fusion Bond', 0.465,
    'HTN169', 14.88, 'Passed',
    'S135', 3, 'Carbon Steel', 265);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (169, 5014.7, 'Liner-1');

INSERT INTO Pipe (pipeID, lengthRange, threadType, pipeType, couplingType, outerDiameter,
    coatingType, wallThickness, heatNumber, weightPerFoot, inspectionStatus,
    grade, storageLocationID, material, quantityAvailable)
VALUES (170, 'R2', 'API LTC', 'DrillPipe', 'PH6',
    5.12, 'Zinc Coated', 0.254,
    'HTN170', 7.58, 'Passed',
    'L80', 118, 'Carbon Steel', 60);
INSERT INTO DrillPipe (pipeID, maxPressure, linerType) VALUES (170, 4210.35, 'Liner-3');

/*
    PipePricing table
    This table contains the pricing information for each pipe and connector.
    This is for USE CASE 2: Site Supervisor Creates a Site-Level Order from Well Requests
        •	A Site Supervisor reviews open material requests for wells at their site.
        •	They aggregate multiple well-level requests into a site-level order.
        •	They add line items detailing what materials need to be ordered and in what quantities.
        •	Each well order included in the site order is linked for traceability.

*/


INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-11-26', 106, 1204.39, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-12-28', 31, 2294.03, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-12-31', 85, 2218.74, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-11-30', 165, 1763.52, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-12-07', 2, 2763.34, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2025-03-19', 145, 730.75, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-09-10', 136, 2573.37, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2025-03-23', 100, 508.86, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2025-02-07', 147, 2092.78, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-12-01', 155, 903.95, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-08-31', 108, 1879.2, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-09-08', 95, 1902.27, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2025-02-16', 80, 688.11, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-04-26', 98, 2759.82, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-07-09', 88, 590.07, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-10-07', 112, 1956.27, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2025-01-29', 30, 1574.47, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2025-03-24', 95, 1270.65, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2025-03-25', 40, 2747.31, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-12-28', 32, 2205.17, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-05-08', 50, 756.98, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-07-02', 26, 2710.34, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-09-18', 60, 2934.59, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2025-01-25', 70, 2814.41, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-12-14', 71, 2661.51, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2025-01-14', 72, 2703.54, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2025-04-02', 81, 948.4, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-10-26', 73, 2455.97, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-09-16', 42, 2505.59, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-12-08', 96, 1167.01, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-04-20', 36, 770.24, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2025-03-26', 74, 2646.48, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-12-22', 35, 998.93, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-08-22', 121, 1374.15, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-12-19', 75, 1057.31, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-05-12', 62, 982.82, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-10-28', 86, 1196.51, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2025-03-10', 127, 2917.22, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-11-23', 21, 1377.87, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO PipePricing (effectiveDate, pipeID, price, createdOn, updatedOn) VALUES ('2024-07-28', 87, 1499.2, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-07-14', 120, 1327.87, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2025-03-31', 215, 788.35, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-12-02', 201, 946.42, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-11-30', 220, 595.64, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-06-13', 125, 1586.41, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-11-05', 162, 1590.98, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-07-27', 134, 789.11, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-06-23', 105, 975.2, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2025-03-23', 161, 2271.96, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2025-04-14', 123, 1799.8, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-07-13', 136, 2217.14, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-05-06', 203, 992.59, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-09-06', 168, 674.93, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-05-09', 154, 2801.93, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-05-30', 235, 1284.79, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2025-02-10', 154, 2299.39, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-11-12', 116, 1767.81, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-05-08', 200, 1520.98, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-09-20', 104, 2243.02, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-07-05', 118, 818.22, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-09-11', 247, 2162.32, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-10-02', 110, 2193.29, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2025-01-15', 156, 2038.79, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-11-11', 179, 1515.19, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2025-04-14', 115, 1259.69, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-12-28', 126, 1574.72, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-06-22', 190, 2016.65, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-11-01', 146, 1662.47, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-08-31', 136, 2189.07, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-07-27', 225, 1682.97, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2025-01-18', 227, 2147.13, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-11-20', 155, 1788.63, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-05-25', 214, 2048.15, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2025-02-26', 208, 2546.06, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-12-15', 184, 2181.99, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-12-20', 154, 2516.41, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2025-01-29', 112, 561.06, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-12-10', 103, 2959.84, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2024-06-06', 203, 2624.34, '2025-04-14 01:13:03', '2025-04-14 01:13:03');
INSERT INTO ConnectorPricing (effectiveDate, connectorID, price, createdOn, updatedOn) VALUES ('2025-03-08', 109, 1638.54, '2025-04-14 01:13:03', '2025-04-14 01:13:03');

/*
This section creates my indexes for my table for all foreign keys and three queries that will be used in the application.
    The first query is to get all the pipe pricing for a specific pipeID.
    The second query is to get all the connector pricing for a specific connectorID.

*/

--These indexes are my query indexes. 
CREATE INDEX idx_pipeID
    ON PipePricing (pipeID); --This index retrieves all pricing for a specific pipe.

CREATE INDEX idx_connectorID
    ON ConnectorPricing (connectorID); --This index retrieves all pricing for a specific connector.

CREATE INDEX idx_wellorder_submittedon
    ON WellOrder(submittedOn); --This index retrieves all well orders submitted on a specific date.

CREATE INDEX idx_siteorder_submittedon
    ON SiteOrder(submittedOn); --This index retrieves all site orders submitted on a specific date.

CREATE INDEX idx_inventoryupdate_reason
    ON InventoryUpdate(InventoryUpdateReason);--This index retrieves all inventory updates for a specific reason.


--These indexes are for foreign keys in the tables. They help look up users by role assignment faster.
CREATE INDEX idx_admin_userid 
    ON Admin(userID);
CREATE INDEX idx_engineer_userid 
    ON Engineer(userID);
CREATE INDEX idx_engineer_assignedsiteid 
    ON Engineer(assignedSiteID); --Filters engineers by site assignment.
CREATE INDEX idx_inventory_clerk_userid 
    ON InventoryClerk(userID);

--This index is for a foreign key in the table. It retrieves all wells at a specific site.
CREATE INDEX idx_well_siteid 
    ON WELL(siteID);

--These indexes are for foreign keys in the tables. These help look up roles and permissions.
CREATE INDEX idx_rolepermission_roleid 
    ON RolePermission(roleID); --Permissions for a given role
CREATE INDEX idx_rolepermission_permissionid 
    ON RolePermission(permissionID); --Roles assigned to a given permission

--These indexes are for foreign keys in the tables. These help look up who is assigned to each well or site.
CREATE INDEX idx_well_users_userid 
    ON WellHasUsers(userID); --wells assigned to a specific user
CREATE INDEX idx_well_users_wellid 
    ON WellHasUsers(wellID); --all users assigned to a well
CREATE INDEX idx_well_users_role 
    ON WellHasUsers(role); --users assigned to a well by role
CREATE INDEX idx_site_users_userid 
    ON SiteHasUsers(userID); --sites assigned to a user
CREATE INDEX idx_site_users_siteid 
    ON SiteHasUsers(siteID); --all users assigned to a site
CREATE INDEX idx_site_users_role 
    ON SiteHasUsers(role); --users assigned to a site by role

--These indexes are for foreign keys in the tables. These help look up order information.
CREATE INDEX idx_site_order_siteid 
    ON SiteOrder(siteID); --orders by site
CREATE INDEX idx_site_order_submittedby 
    ON SiteOrder(submittedBy); --who submitted a site order
CREATE INDEX idx_site_order_has_well_orders_siteorderid 
    ON SiteOrderHasWellOrders(siteOrderID); -- well orders for a site order
CREATE INDEX idx_well_order_wellid 
    ON WellOrder(wellID); --orders placed for a well
CREATE INDEX idx_well_order_submittedby 
    ON WellOrder(submittedBy); --who submitted a well order

--These indexes are for foreign keys in the tables. They assist in looking up details of orders and line items. 
CREATE INDEX idx_well_order_line_items_well_OrderID 
    ON WellOrderLineItems(well_OrderID); -- all items associated with a well order
CREATE INDEX idx_well_order_line_items_pipeid 
    ON WellOrderLineItems(pipeID); --which orders are associated with a pipe
CREATE INDEX idx_well_order_line_items_connectorid 
    ON WellOrderLineItems(connectorID); --which orders are associated with a connector
CREATE INDEX idx_site_order_line_items_siteorderid 
    ON SiteOrderLineItems(siteOrderID); -- all items associated with a site order
CREATE INDEX idx_site_order_line_items_well_OrderID 
    ON SiteOrderLineItems(siteOrderID); -- all items associated with a well order
CREATE INDEX idx_site_order_line_items_pipeid 
    ON SiteOrderLineItems(pipeID); --line items associated with a pipe
CREATE INDEX idx_site_order_line_items_connectorid 
    ON SiteOrderLineItems(connectorID); --line items associated with a connector

--These indexes are for foreign keys in the tables. They assist in looking up details of storage locations.
CREATE INDEX idx_connector_storagelocationid 
    ON Connector(storageLocationID); --all connectors stored at a location
CREATE INDEX idx_pipe_storagelocationid 
    ON Pipe(storageLocationID); --all pipes stored at a location
CREATE INDEX idx_well_location_wellid 
    ON WellLocation(wellID); --all locations associated with a well
CREATE INDEX idx_site_location_siteid 
    ON SiteLocation(siteID); --all locations associated with a site

--These indexes are for foreign keys in the tables. They assist in looking up details of pricing.
CREATE INDEX idx_pipepricing_pipeid 
    ON PipePricing(pipeID); --all pricing for a pipe
CREATE INDEX idx_connectorpricing_connectorid 
    ON ConnectorPricing(connectorID); --all pricing for a connector

--These indexes are for foreign keys in the tables. They assist in looking up information about connector and pipe subtypes.
CREATE INDEX idx_threaded_connector_connectorid 
    ON ThreadedConnector(connectorID); --all threaded connectors associated with a connector
CREATE INDEX idx_welded_connector_connectorid 
    ON WeldedConnector(connectorID); --all welded connectors associated with a connector
CREATE INDEX idx_premium_connector_connectorid 
    ON PremiumConnector(connectorID); --all premium connectors associated with a connector
CREATE INDEX idx_casing_pipeid 
    ON Casing(pipeID); --all casing associated with a pipe
CREATE INDEX idx_tubing_pipeid 
    ON Tubing(pipeID); --all tubing associated with a pipe
CREATE INDEX idx_drillpipe_pipeid 
    ON DrillPipe(pipeID); --all drill pipe associated with a pipe

--These indexes are for foreign keys in the tables. They assist in looking up details of inventory updates.
CREATE INDEX idx_inventory_update_locationid 
    ON InventoryUpdate(LocationID); --all inventory updates associated with a location
CREATE INDEX idx_inventory_update_submittedby 
    ON InventoryUpdate(SubmittedBy); --who submitted an inventory update

-- Stored Procedure 1: Admin creates a new user with site and role assignment
IF OBJECT_ID('CreateUserWithSiteAndRole', 'P') IS NOT NULL DROP PROCEDURE CreateUserWithSiteAndRole;
GO
CREATE PROCEDURE CreateUserWithSiteAndRole
    @username VARCHAR(50),
    @name VARCHAR(100),
    @email VARCHAR(100),
    @hashedPassword VARCHAR(255),
    @siteID INT,
    @roleName VARCHAR(50),
    @isActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM SystemUser WHERE username = @username OR email = @email)
    BEGIN
        RAISERROR('Username or email already exists.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Site WHERE siteID = @siteID)
    BEGIN
        RAISERROR('Invalid site ID.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Role WHERE roleName = @roleName)
    BEGIN
        RAISERROR('Invalid role name.', 16, 1);
        RETURN;
    END

    DECLARE @userID INT = NEXT VALUE FOR SystemUserSeq;
    DECLARE @assignedOn DATETIME = GETDATE();

    INSERT INTO SystemUser (userID, username, name, email, passwordHash, isActive)
    VALUES (@userID, @username, @name, @email, @hashedPassword, @isActive);

    INSERT INTO SiteHasUsers (userID, siteID, role, assigned_on, isActive)
    VALUES (@userID, @siteID, @roleName, @assignedOn, @isActive);
END;
GO

-- Stored Procedure 2: Engineer views inventory at a well
IF OBJECT_ID('ViewWellInventory', 'P') IS NOT NULL DROP PROCEDURE ViewWellInventory;
GO
CREATE PROCEDURE ViewWellInventory
    @userID INT,
    @wellID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Well WHERE wellID = @wellID)
    BEGIN
        RAISERROR('Well does not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM WellHasUsers WHERE wellID = @wellID AND userID = @userID)
    BEGIN
        RAISERROR('User is not assigned to this well.', 16, 1);
        RETURN;
    END

    SELECT WL.locationID, L.name AS locationName, 'Pipe' AS itemType, WL.current_inventory AS quantity
    FROM WellLocation WL
    JOIN Location L ON WL.locationID = L.locationID
    WHERE WL.wellID = @wellID

    UNION

    SELECT WL.locationID, L.name AS locationName, 'Connector' AS itemType, WL.current_inventory AS quantity
    FROM WellLocation WL
    JOIN Location L ON WL.locationID = L.locationID
    WHERE WL.wellID = @wellID;
END;
GO

-- Stored Procedure 3: Engineer submits a material request for a well (single item)
IF OBJECT_ID('SubmitWellOrderItem', 'P') IS NOT NULL DROP PROCEDURE SubmitWellOrderItem;
GO

CREATE PROCEDURE SubmitWellOrderItem
    @wellID INT,
    @submittedBy INT,
    @pipeID INT = NULL,
    @connectorID INT = NULL,
    @quantityRequested INT,
    @itemType VARCHAR(10),
    @unit VARCHAR(20),
    @notes TEXT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Well WHERE wellID = @wellID)
    BEGIN
        RAISERROR('Invalid well ID.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM SystemUser WHERE userID = @submittedBy)
    BEGIN
        RAISERROR('Invalid submittedBy user ID.', 16, 1);
        RETURN;
    END

    IF @itemType NOT IN ('Pipe', 'Connector')
    BEGIN
        RAISERROR('Invalid item type.', 16, 1);
        RETURN;
    END

    IF @quantityRequested <= 0
    BEGIN
        RAISERROR('Quantity must be positive.', 16, 1);
        RETURN;
    END

    DECLARE @well_OrderID INT = NEXT VALUE FOR WellOrderSeq;
    DECLARE @createdOn DATETIME = GETDATE();
    DECLARE @submittedByName VARCHAR(100);

    SELECT @submittedByName = name FROM SystemUser WHERE userID = @submittedBy;

    INSERT INTO WellOrder (
        well_orderID, wellID, submittedBy, submittedByName,
        submittedOn, status, notes, createdOn
    )
    VALUES (
        @well_OrderID, @wellID, @submittedBy, @submittedByName,
        @createdOn, 'Pending', @notes, @createdOn
    );

    INSERT INTO WellOrderLineItems (
        well_OrderID, pipeID, connectorID, quantityRequested, itemType, unit, notes
    )
    VALUES (
        @well_OrderID, @pipeID, @connectorID, @quantityRequested, @itemType, @unit, @notes
    );
END;
GO

CREATE TRIGGER PipePricingChangeTrigger
ON PipePricing
AFTER UPDATE
AS
BEGIN
    DECLARE @OldPrice DECIMAL(10, 2) = (SELECT price FROM DELETED);
    DECLARE @NewPrice DECIMAL(10, 2) = (SELECT price FROM INSERTED);
    DECLARE @PipeID INT = (SELECT pipeID FROM INSERTED);

    IF (@OldPrice <> @NewPrice)
    BEGIN
        INSERT INTO PipePriceChange(priceChangeID, pipeID, oldPrice, newPrice, changeDate)
        VALUES (
            NEXT VALUE FOR PipePriceChangeSeq,  -- Make sure you create this sequence
            @PipeID,
            @OldPrice,
            @NewPrice,
            GETDATE()
        );
    END
END;
GO

CREATE TRIGGER ConnectorPricingChangeTrigger
ON ConnectorPricing
AFTER UPDATE
AS
BEGIN
    DECLARE @OldPrice DECIMAL(10, 2) = (SELECT price FROM DELETED);
    DECLARE @NewPrice DECIMAL(10, 2) = (SELECT price FROM INSERTED);
    DECLARE @ConnectorID INT = (SELECT connectorID FROM INSERTED);

    IF (@OldPrice <> @NewPrice)
    BEGIN
        INSERT INTO ConnectorPriceChange(priceChangeID, connectorID, oldPrice, newPrice, changeDate)
        VALUES (
            NEXT VALUE FOR ConnectorPriceChangeSeq,  -- Make sure you create this sequence
            @ConnectorID,
            @OldPrice,
            @NewPrice,
            GETDATE()
        );
    END
END;
GO

-- Admin creates a new user with site and role assignment
EXEC CreateUserWithSiteAndRole 'bwayne', 'Bruce Wayne', 'bwayne@tubinv.com', 'hashedpw123', 1, 'Engineer', 1;
EXEC CreateUserWithSiteAndRole 'ckent', 'Clark Kent', 'ckent@tubinv.com', 'hashedpw456', 2, 'Inventory Clerk', 1;
EXEC CreateUserWithSiteAndRole 'pparker', 'Peter Parker', 'pparker@tubinv.com', 'hashedpw789', 3, 'Site Supervisor', 1;
EXEC CreateUserWithSiteAndRole 'tstark', 'Tony Stark', 'tstark@tubinv.com', 'hashedpw000', 1, 'Engineer', 1;
EXEC CreateUserWithSiteAndRole 'dprince', 'Diana Prince', 'dprince@tubinv.com', 'hashedpw999', 2, 'Administrator', 1;
EXEC CreateUserWithSiteAndRole 'srogers', 'Steve Rogers', 'srogers@tubinv.com', 'hashedpw111', 1, 'Engineer', 1;
EXEC CreateUserWithSiteAndRole 'nsummers', 'Nathan Summers', 'nsummers@tubinv.com', 'hashedpw222', 2, 'Engineer', 1;
EXEC CreateUserWithSiteAndRole 'bbaner', 'Bruce Banner', 'bbaner@tubinv.com', 'hashedpw333', 3, 'Engineer', 1;
EXEC CreateUserWithSiteAndRole 'hquinn', 'Harleen Quinn', 'hquinn@tubinv.com', 'hashedpw444', 1, 'Engineer', 1;

--Need to add Engineers to wellhasuserstable for next procedure
INSERT INTO WellHasUsers (wellID, userID) VALUES (1, 1001); 
INSERT INTO WellHasUsers (wellID, userID) VALUES (1, 1004);
INSERT INTO WellHasUsers (wellID, userID) VALUES (2, 1006);
INSERT INTO WellHasUsers (wellID, userID) VALUES (3, 1007); 
INSERT INTO WellHasUsers (wellID, userID) VALUES (4, 1008);
INSERT INTO WellHasUsers (wellID, userID) VALUES (5, 1009); 

-- Stored Procedure 2: Engineer views inventory at a well
EXEC ViewWellInventory 1001, 1;
EXEC ViewWellInventory 1004, 1;
EXEC ViewWellInventory 1006, 2;
EXEC ViewWellInventory 1007, 3;
EXEC ViewWellInventory 1008, 4;

-- Stored Procedure 3: Engineer submits a material request for a well
EXEC SubmitWellOrderItem 1, 1001, 10, NULL, 15, 'Pipe', 'ft', 'Requesting pipe for casing';
EXEC SubmitWellOrderItem 2, 1006, NULL, 205, 172, 'Connector', 'unit', 'Requesting connectors for maintenance'; 
EXEC SubmitWellOrderItem 3, 1007, 12, NULL, 10, 'Pipe', 'm', 'Additional pipe needed for extension'; 
EXEC SubmitWellOrderItem 2, 1008, NULL, 123, 208, 'Connector', 'unit', 'Backup connectors';
EXEC SubmitWellOrderItem 1, 1004, 14, NULL, 25, 'Pipe', 'ft', 'Initial setup'; 

/*
-- Stored Procedure 4: Site Supervisor creates a site-level order from a single well request
EXEC CreateSiteOrderFromSingleWellOrder 1, 1003, 101, 10, NULL, 15, 'Pipe', 'ft', 'Aggregated pipe order';
EXEC CreateSiteOrderFromSingleWellOrder 2, 1003, 102, NULL, 123, 172, 'Connector', 'unit', 'Connector group order';
EXEC CreateSiteOrderFromSingleWellOrder 3, 1003, 103, 11, NULL, 10, 'Pipe', 'm', 'Top off pipe request';
EXEC CreateSiteOrderFromSingleWellOrder 1, 1003, 104, NULL, 123, 208, 'Connector', 'unit', 'Add-on order';
EXEC CreateSiteOrderFromSingleWellOrder 2, 1003, 105, 14, NULL, 25, 'Pipe', 'ft', 'Cumulative pipe request';

 
QUERY 1: Which materials were requested for each well order,
including the engineer’s name, well name, and the quantity of each item?

WO = "WellOrder"
SU = "SystemUser"
W = "Well"
WOLI = "WellOrderLineItems"
*/

SELECT 
    WO.well_orderID,
    SU.name AS EngineerName,
    W.well_name AS WellName,
    WOLI.itemType,
    WOLI.quantityRequested,
    WOLI.unit
FROM WellOrder WO
JOIN SystemUser SU ON WO.submittedBy = SU.userID
JOIN Well W ON WO.wellID = W.wellID
JOIN WellOrderLineItems WOLI ON WO.well_orderID = WOLI.well_OrderID
ORDER BY WO.well_orderID;



/*
Query 2: Show inventory at each site and well location.
L = "Location"
SL = "SiteLocation"
WL = "WellLocation"
P = "Pipe" 
C = "Connector"  
*/

-- Pipes at Site Locations
SELECT
    L.locationID,
    L.name AS locationName,
    'Site' AS locationType,
    'Pipe' AS itemType,
    P.pipeID AS itemID,
    SL.current_inventory AS quantity
FROM Pipe P
JOIN Location L ON P.storageLocationID = L.locationID
JOIN SiteLocation SL ON L.locationID = SL.locationID

UNION ALL

-- Connectors at Site Locations
SELECT
    L.locationID,
    L.name AS locationName,
    'Site' AS locationType,
    'Connector' AS itemType,
    C.connectorID AS itemID,
    SL.current_inventory AS quantity
FROM Connector C
JOIN Location L ON C.storageLocationID = L.locationID
JOIN SiteLocation SL ON L.locationID = SL.locationID

UNION ALL

-- Pipes at Well Locations
SELECT
    L.locationID,
    L.name AS locationName,
    'Well' AS locationType,
    'Pipe' AS itemType,
    P.pipeID AS itemID,
    WL.current_inventory AS quantity
FROM Pipe P
JOIN Location L ON P.storageLocationID = L.locationID
JOIN WellLocation WL ON L.locationID = WL.locationID

UNION ALL

-- Connectors at Well Locations
SELECT
    L.locationID,
    L.name AS locationName,
    'Well' AS locationType,
    'Connector' AS itemType,
    C.connectorID AS itemID,
    WL.current_inventory AS quantity
FROM Connector C
JOIN Location L ON C.storageLocationID = L.locationID
JOIN WellLocation WL ON L.locationID = WL.locationID

ORDER BY locationID, itemType, itemID;


/*
Query 3: Current prices for connectors and pipes.
*/

SELECT 
    'Pipe' AS itemType,
    pipeID AS itemID,
    FORMAT(price, 'C', 'en-us') AS priceUSD,
    effectiveDate
FROM PipePricing

UNION

SELECT 
    'Connector' AS itemType,
    connectorID AS itemID,
    FORMAT(price, 'C', 'en-us') AS priceUSD,
    effectiveDate
FROM ConnectorPricing

ORDER BY itemType, itemID;

--ONLY TO VALIDATE TRIGGER OTHERWISE LEAVE COMMENTED OUT
/*
UPDATE PipePricing SET price = 1300.00 WHERE pipeID = 106;
UPDATE PipePricing SET price = 1350.00 WHERE pipeID = 106;
UPDATE PipePricing SET price = 2400.00 WHERE pipeID = 31;
UPDATE PipePricing SET price = 2500.00 WHERE pipeID = 31;
UPDATE PipePricing SET price = 2250.00 WHERE pipeID = 85;
UPDATE PipePricing SET price = 2300.00 WHERE pipeID = 85;
UPDATE PipePricing SET price = 1800.00 WHERE pipeID = 165;
UPDATE PipePricing SET price = 2800.00 WHERE pipeID = 2;
UPDATE PipePricing SET price = 1900.00 WHERE pipeID = 106;  
UPDATE PipePricing SET price = 2600.00 WHERE pipeID = 85;   
UPDATE ConnectorPricing SET price = 1400.00 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 1450.00 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 800.00 WHERE connectorID = 215;
UPDATE ConnectorPricing SET price = 820.00 WHERE connectorID = 215;
UPDATE ConnectorPricing SET price = 950.00 WHERE connectorID = 201;
UPDATE ConnectorPricing SET price = 975.00 WHERE connectorID = 201;
UPDATE ConnectorPricing SET price = 610.00 WHERE connectorID = 220;
UPDATE ConnectorPricing SET price = 1600.00 WHERE connectorID = 125;
UPDATE ConnectorPricing SET price = 1500.00 WHERE connectorID = 120; 
UPDATE ConnectorPricing SET price = 990.00 WHERE connectorID = 201;   
UPDATE PipePricing SET price = 2902.92 WHERE pipeID = 2;
UPDATE PipePricing SET price = 1721.85 WHERE pipeID = 165;
UPDATE PipePricing SET price = 1932.92 WHERE pipeID = 165;
UPDATE PipePricing SET price = 1369.09 WHERE pipeID = 106;
UPDATE PipePricing SET price = 2111.01 WHERE pipeID = 31;
UPDATE PipePricing SET price = 2708.39 WHERE pipeID = 2;
UPDATE PipePricing SET price = 2646.35 WHERE pipeID = 2;
UPDATE PipePricing SET price = 2254.52 WHERE pipeID = 85;
UPDATE PipePricing SET price = 1162.74 WHERE pipeID = 106;
UPDATE PipePricing SET price = 2255.67 WHERE pipeID = 85;
UPDATE PipePricing SET price = 1480.58 WHERE pipeID = 165;
UPDATE PipePricing SET price = 1134.38 WHERE pipeID = 106;
UPDATE PipePricing SET price = 2457.45 WHERE pipeID = 31;
UPDATE PipePricing SET price = 2136.46 WHERE pipeID = 31;
UPDATE PipePricing SET price = 2726.89 WHERE pipeID = 2;
UPDATE PipePricing SET price = 2155.38 WHERE pipeID = 85;
UPDATE PipePricing SET price = 2022.55 WHERE pipeID = 165;
UPDATE PipePricing SET price = 1144.34 WHERE pipeID = 106;
UPDATE PipePricing SET price = 2641.77 WHERE pipeID = 2;
UPDATE PipePricing SET price = 2509.16 WHERE pipeID = 31;
UPDATE PipePricing SET price = 1265.22 WHERE pipeID = 106;
UPDATE PipePricing SET price = 2433.26 WHERE pipeID = 31;
UPDATE PipePricing SET price = 2579.95 WHERE pipeID = 2;
UPDATE PipePricing SET price = 2170.11 WHERE pipeID = 85;
UPDATE PipePricing SET price = 1311.62 WHERE pipeID = 106;
UPDATE PipePricing SET price = 2547.15 WHERE pipeID = 2;
UPDATE PipePricing SET price = 2277.73 WHERE pipeID = 31;
UPDATE PipePricing SET price = 1731.92 WHERE pipeID = 165;
UPDATE PipePricing SET price = 2483.34 WHERE pipeID = 31;
UPDATE PipePricing SET price = 1275.06 WHERE pipeID = 106;
UPDATE PipePricing SET price = 2299.89 WHERE pipeID = 85;
UPDATE PipePricing SET price = 1585.82 WHERE pipeID = 165;
UPDATE PipePricing SET price = 2383.51 WHERE pipeID = 31;
UPDATE PipePricing SET price = 2713.42 WHERE pipeID = 2;
UPDATE PipePricing SET price = 2325.04 WHERE pipeID = 85;
UPDATE PipePricing SET price = 1212.89 WHERE pipeID = 106;
UPDATE PipePricing SET price = 1885.18 WHERE pipeID = 165;
UPDATE PipePricing SET price = 2768.78 WHERE pipeID = 2;
UPDATE PipePricing SET price = 2369.42 WHERE pipeID = 85;
UPDATE PipePricing SET price = 1473.52 WHERE pipeID = 165;
UPDATE PipePricing SET price = 2202.97 WHERE pipeID = 85;
UPDATE PipePricing SET price = 1282.07 WHERE pipeID = 106;
UPDATE PipePricing SET price = 2552.44 WHERE pipeID = 2;
UPDATE PipePricing SET price = 2281.87 WHERE pipeID = 31;
UPDATE PipePricing SET price = 2396.68 WHERE pipeID = 31;
UPDATE PipePricing SET price = 1924.56 WHERE pipeID = 165;
UPDATE PipePricing SET price = 1185.43 WHERE pipeID = 106;
UPDATE PipePricing SET price = 2706.33 WHERE pipeID = 2;
UPDATE PipePricing SET price = 2168.35 WHERE pipeID = 85;

UPDATE ConnectorPricing SET price = 1453.81 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 1275.58 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 744.15 WHERE connectorID = 215;
UPDATE ConnectorPricing SET price = 1041.26 WHERE connectorID = 201;
UPDATE ConnectorPricing SET price = 661.76 WHERE connectorID = 220;
UPDATE ConnectorPricing SET price = 1217.24 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 1524.17 WHERE connectorID = 125;
UPDATE ConnectorPricing SET price = 866.32 WHERE connectorID = 215;
UPDATE ConnectorPricing SET price = 1531.53 WHERE connectorID = 125;
UPDATE ConnectorPricing SET price = 891.07 WHERE connectorID = 215;
UPDATE ConnectorPricing SET price = 1441.38 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 837.29 WHERE connectorID = 215;
UPDATE ConnectorPricing SET price = 1582.3 WHERE connectorID = 125;
UPDATE ConnectorPricing SET price = 969.33 WHERE connectorID = 201;
UPDATE ConnectorPricing SET price = 1594.89 WHERE connectorID = 125;
UPDATE ConnectorPricing SET price = 1044.62 WHERE connectorID = 201;
UPDATE ConnectorPricing SET price = 1363.55 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 987.91 WHERE connectorID = 201;
UPDATE ConnectorPricing SET price = 687.93 WHERE connectorID = 220;
UPDATE ConnectorPricing SET price = 1152.93 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 1053.26 WHERE connectorID = 201;
UPDATE ConnectorPricing SET price = 796.84 WHERE connectorID = 215;
UPDATE ConnectorPricing SET price = 1406.93 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 649.48 WHERE connectorID = 220;
UPDATE ConnectorPricing SET price = 1523.39 WHERE connectorID = 125;
UPDATE ConnectorPricing SET price = 1014.52 WHERE connectorID = 201;
UPDATE ConnectorPricing SET price = 869.7 WHERE connectorID = 215;
UPDATE ConnectorPricing SET price = 1367.89 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 1535.21 WHERE connectorID = 125;
UPDATE ConnectorPricing SET price = 684.11 WHERE connectorID = 220;
UPDATE ConnectorPricing SET price = 1072.89 WHERE connectorID = 201;
UPDATE ConnectorPricing SET price = 1244.98 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 1603.08 WHERE connectorID = 125;
UPDATE ConnectorPricing SET price = 753.17 WHERE connectorID = 215;
UPDATE ConnectorPricing SET price = 1496.47 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 628.92 WHERE connectorID = 220;
UPDATE ConnectorPricing SET price = 842.38 WHERE connectorID = 215;
UPDATE ConnectorPricing SET price = 1622.67 WHERE connectorID = 125;
UPDATE ConnectorPricing SET price = 1025.48 WHERE connectorID = 201;
UPDATE ConnectorPricing SET price = 943.99 WHERE connectorID = 201;
UPDATE ConnectorPricing SET price = 1356.85 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 710.25 WHERE connectorID = 220;
UPDATE ConnectorPricing SET price = 950.63 WHERE connectorID = 201;
UPDATE ConnectorPricing SET price = 787.94 WHERE connectorID = 215;
UPDATE ConnectorPricing SET price = 1278.42 WHERE connectorID = 120;
UPDATE ConnectorPricing SET price = 670.31 WHERE connectorID = 220;
UPDATE ConnectorPricing SET price = 1507.29 WHERE connectorID = 125;
UPDATE ConnectorPricing SET price = 977.15 WHERE connectorID = 201;
UPDATE ConnectorPricing SET price = 738.46 WHERE connectorID = 215;
UPDATE ConnectorPricing SET price = 1488.91 WHERE connectorID = 120;
*/

--DATA TO RUN THE QUERY FOR VISUALIZATION
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (1, 106, 1204.39, 1250.61, '2025-02-11');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (2, 2, 2763.34, 2804.54, '2024-12-03');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (3, 2, 2804.54, 2927.74, '2025-04-17');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (4, 2, 2927.74, 2963.79, '2025-03-23');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (5, 2, 2963.79, 2905.49, '2025-01-04');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (6, 85, 2218.74, 2083.16, '2025-02-22');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (7, 31, 2294.03, 2214.35, '2024-10-29');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (8, 165, 1763.52, 1793.63, '2025-04-03');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (9, 165, 1793.63, 1745.98, '2025-01-17');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (10, 165, 1745.98, 1766.09, '2024-12-03');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (11, 2, 2905.49, 3097.12, '2025-04-09');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (12, 85, 2083.16, 2179.14, '2025-03-14');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (13, 31, 2214.35, 2145.87, '2025-04-15');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (14, 165, 1766.09, 1907.17, '2024-11-12');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (15, 165, 1907.17, 2085.22, '2025-01-08');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (16, 85, 2179.14, 2355.44, '2025-03-05');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (17, 106, 1250.61, 1086.63, '2025-03-03');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (18, 31, 2145.87, 2243.07, '2024-12-09');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (19, 165, 2085.22, 2252.93, '2024-12-04');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (20, 85, 2355.44, 2219.72, '2024-12-12');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (21, 106, 1086.63, 1150.24, '2025-01-10');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (22, 106, 1150.24, 1287.18, '2025-02-18');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (23, 2, 3097.12, 3190.24, '2025-04-17');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (24, 165, 2252.93, 2170.36, '2025-03-30');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (25, 2, 3190.24, 3177.03, '2025-01-14');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (26, 85, 2219.72, 2115.04, '2025-03-08');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (27, 31, 2243.07, 2215.25, '2024-12-17');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (28, 165, 2170.36, 2072.08, '2025-02-14');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (29, 106, 1287.18, 1182.88, '2024-11-05');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (30, 2, 3177.03, 3263.23, '2024-11-16');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (31, 31, 2215.25, 2058.53, '2025-01-30');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (32, 2, 3263.23, 3158.44, '2025-01-15');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (33, 106, 1182.88, 1154.95, '2024-12-20');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (34, 85, 2115.04, 1934.13, '2024-10-27');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (35, 31, 2058.53, 1988.63, '2024-12-08');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (36, 165, 2072.08, 2029.8, '2025-04-06');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (37, 31, 1988.63, 2020.98, '2025-02-17');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (38, 85, 1934.13, 2034.17, '2025-02-20');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (39, 2, 3158.44, 3242.1, '2025-01-17');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (40, 31, 2020.98, 1911.85, '2024-11-01');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (41, 106, 1154.95, 1259.27, '2024-11-25');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (42, 85, 2034.17, 1986.42, '2025-03-14');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (43, 165, 2029.8, 2217.17, '2024-12-25');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (44, 106, 1259.27, 1242.94, '2025-02-23');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (45, 31, 1911.85, 1737.28, '2025-02-24');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (46, 165, 2217.17, 2258.99, '2024-12-18');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (47, 85, 1986.42, 1973.38, '2025-01-16');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (48, 165, 2258.99, 2440.41, '2025-01-12');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (49, 2, 3242.1, 3168.58, '2025-01-06');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (50, 2, 3168.58, 3155.36, '2025-04-18');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (51, 85, 1973.38, 2029.6, '2025-04-07');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (52, 106, 1242.94, 1344.61, '2024-11-08');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (53, 106, 1344.61, 1220.7, '2025-04-07');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (54, 31, 1737.28, 1838.51, '2025-02-23');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (55, 106, 1220.7, 1293.23, '2025-02-08');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (56, 31, 1838.51, 1926.61, '2025-04-05');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (57, 2, 3155.36, 2977.83, '2024-11-12');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (58, 2, 2977.83, 3038.76, '2024-12-16');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (59, 165, 2440.41, 2544.66, '2025-04-01');
INSERT INTO PipePriceChange (priceChangeID, pipeID, oldPrice, newPrice, changeDate) VALUES (60, 31, 1926.61, 1973.8, '2025-01-21');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (1, 215, 788.35, 714.15, '2024-10-26');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (2, 120, 1327.87, 1187.61, '2025-02-08');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (3, 125, 1586.41, 1643.38, '2024-11-24');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (4, 120, 1187.61, 1092.11, '2024-12-20');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (5, 120, 1092.11, 1002.55, '2024-12-16');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (6, 220, 595.64, 544.7, '2024-10-30');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (7, 215, 714.15, 863.47, '2025-02-11');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (8, 120, 1002.55, 1018.85, '2024-12-23');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (9, 220, 544.7, 685.45, '2024-11-24');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (10, 215, 863.47, 924.07, '2025-02-03');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (11, 120, 1018.85, 1051.75, '2025-02-07');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (12, 120, 1051.75, 902.77, '2025-02-03');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (13, 120, 902.77, 898.52, '2025-03-07');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (14, 201, 946.42, 1017.78, '2025-03-30');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (15, 120, 898.52, 830.49, '2025-01-19');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (16, 120, 830.49, 894.66, '2024-12-11');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (17, 201, 1017.78, 973.53, '2025-01-26');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (18, 125, 1643.38, 1706.06, '2024-12-30');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (19, 120, 894.66, 949.09, '2024-12-22');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (20, 201, 973.53, 966.0, '2025-04-09');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (21, 125, 1706.06, 1792.43, '2024-11-22');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (22, 125, 1792.43, 1772.23, '2025-01-07');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (23, 120, 949.09, 1000.17, '2025-03-02');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (24, 215, 924.07, 802.28, '2025-03-11');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (25, 201, 966.0, 837.21, '2025-04-22');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (26, 215, 802.28, 866.83, '2024-12-01');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (27, 120, 1000.17, 883.06, '2025-03-28');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (28, 201, 837.21, 746.44, '2024-12-30');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (29, 201, 746.44, 894.93, '2024-11-22');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (30, 201, 894.93, 917.92, '2024-12-09');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (31, 201, 917.92, 1013.99, '2025-03-19');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (32, 201, 1013.99, 931.07, '2025-04-08');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (33, 201, 931.07, 975.7, '2025-04-13');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (34, 120, 883.06, 865.23, '2024-10-27');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (35, 120, 865.23, 822.91, '2025-01-14');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (36, 125, 1772.23, 1730.97, '2025-04-08');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (37, 120, 822.91, 679.16, '2025-01-06');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (38, 125, 1730.97, 1707.89, '2025-02-11');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (39, 120, 679.16, 676.11, '2025-02-26');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (40, 125, 1707.89, 1656.66, '2024-12-29');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (41, 125, 1656.66, 1519.6, '2025-01-11');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (42, 125, 1519.6, 1573.54, '2025-03-28');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (43, 120, 676.11, 645.19, '2024-12-10');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (44, 125, 1573.54, 1692.24, '2025-02-01');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (45, 120, 645.19, 610.33, '2024-12-16');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (46, 215, 866.83, 838.07, '2025-04-10');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (47, 201, 975.7, 920.91, '2024-11-02');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (48, 220, 685.45, 685.13, '2024-11-06');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (49, 220, 685.13, 560.76, '2025-01-03');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (50, 125, 1692.24, 1751.06, '2024-11-20');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (51, 220, 560.76, 662.64, '2024-12-13');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (52, 215, 838.07, 804.97, '2024-11-09');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (53, 215, 804.97, 830.92, '2025-04-13');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (54, 125, 1751.06, 1848.93, '2025-01-29');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (55, 201, 920.91, 810.43, '2024-12-01');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (56, 215, 830.92, 772.49, '2024-12-02');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (57, 120, 610.33, 717.74, '2024-11-08');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (58, 220, 662.64, 731.43, '2025-04-02');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (59, 215, 772.49, 673.74, '2025-03-16');
INSERT INTO ConnectorPriceChange (priceChangeID, connectorID, oldPrice, newPrice, changeDate) VALUES (60, 201, 810.43, 699.08, '2024-11-01');


INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41000, 9, 1006, 'Steve Rogers', '2023-05-07', 'Approved', 'Auto-generated', '2023-05-07');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41001, 5, 1008, 'Bruce Banner', '2023-06-04', 'Merged INTO Site Order', 'Auto-generated', '2023-06-04');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41002, 1, 1001, 'Bruce Wayne', '2022-07-22', 'Fulfilled', 'Auto-generated', '2022-07-22');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41003, 13, 1009, 'Harleen Quinn', '2022-05-13', 'Approved', 'Auto-generated', '2022-05-13');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41004, 11, 1007, 'Nathan Summers', '2023-10-12', 'Pending', 'Auto-generated', '2023-10-12');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41005, 16, 1004, 'Tony Stark', '2023-02-19', 'Fulfilled', 'Auto-generated', '2023-02-19');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41006, 4, 1006, 'Steve Rogers', '2022-01-29', 'Pending', 'Auto-generated', '2022-01-29');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41007, 10, 1007, 'Nathan Summers', '2023-01-17', 'Fulfilled', 'Auto-generated', '2023-01-17');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41008, 15, 1007, 'Nathan Summers', '2024-01-09', 'Merged INTO Site Order', 'Auto-generated', '2024-01-09');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41009, 11, 1007, 'Nathan Summers', '2023-07-30', 'Fulfilled', 'Auto-generated', '2023-07-30');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41010, 15, 1001, 'Bruce Wayne', '2023-08-06', 'Fulfilled', 'Auto-generated', '2023-08-06');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41011, 15, 1006, 'Steve Rogers', '2024-07-03', 'Fulfilled', 'Auto-generated', '2024-07-03');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41012, 12, 1009, 'Harleen Quinn', '2024-07-23', 'Approved', 'Auto-generated', '2024-07-23');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41013, 14, 1009, 'Harleen Quinn', '2023-08-08', 'Pending', 'Auto-generated', '2023-08-08');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41014, 4, 1004, 'Tony Stark', '2023-03-21', 'Approved', 'Auto-generated', '2023-03-21');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41015, 15, 1009, 'Harleen Quinn', '2022-01-04', 'Approved', 'Auto-generated', '2022-01-04');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41016, 14, 1004, 'Tony Stark', '2023-06-15', 'Approved', 'Auto-generated', '2023-06-15');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41017, 5, 1007, 'Nathan Summers', '2022-11-07', 'Fulfilled', 'Auto-generated', '2022-11-07');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41018, 9, 1004, 'Tony Stark', '2024-06-17', 'Pending', 'Auto-generated', '2024-06-17');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41019, 14, 1007, 'Nathan Summers', '2024-07-09', 'Approved', 'Auto-generated', '2024-07-09');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41020, 3, 1006, 'Steve Rogers', '2024-04-08', 'Fulfilled', 'Auto-generated', '2024-04-08');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41021, 8, 1006, 'Steve Rogers', '2022-08-19', 'Approved', 'Auto-generated', '2022-08-19');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41022, 7, 1008, 'Bruce Banner', '2023-03-19', 'Fulfilled', 'Auto-generated', '2023-03-19');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41023, 15, 1004, 'Tony Stark', '2022-10-27', 'Approved', 'Auto-generated', '2022-10-27');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41024, 11, 1009, 'Harleen Quinn', '2023-03-01', 'Approved', 'Auto-generated', '2023-03-01');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41025, 11, 1009, 'Harleen Quinn', '2022-02-09', 'Fulfilled', 'Auto-generated', '2022-02-09');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41026, 5, 1006, 'Steve Rogers', '2023-08-07', 'Approved', 'Auto-generated', '2023-08-07');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41027, 2, 1007, 'Nathan Summers', '2022-03-16', 'Pending', 'Auto-generated', '2022-03-16');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41028, 13, 1008, 'Bruce Banner', '2022-08-02', 'Fulfilled', 'Auto-generated', '2022-08-02');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41029, 13, 1008, 'Bruce Banner', '2023-03-01', 'Pending', 'Auto-generated', '2023-03-01');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41030, 16, 1007, 'Nathan Summers', '2022-06-17', 'Pending', 'Auto-generated', '2022-06-17');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41031, 14, 1001, 'Bruce Wayne', '2023-09-20', 'Fulfilled', 'Auto-generated', '2023-09-20');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41032, 6, 1004, 'Tony Stark', '2023-06-03', 'Approved', 'Auto-generated', '2023-06-03');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41033, 14, 1004, 'Tony Stark', '2024-08-01', 'Merged INTO Site Order', 'Auto-generated', '2024-08-01');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41034, 13, 1009, 'Harleen Quinn', '2022-03-04', 'Approved', 'Auto-generated', '2022-03-04');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41035, 9, 1007, 'Nathan Summers', '2022-03-25', 'Merged INTO Site Order', 'Auto-generated', '2022-03-25');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41036, 13, 1009, 'Harleen Quinn', '2024-11-26', 'Fulfilled', 'Auto-generated', '2024-11-26');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41037, 13, 1008, 'Bruce Banner', '2022-10-06', 'Approved', 'Auto-generated', '2022-10-06');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41038, 15, 1008, 'Bruce Banner', '2023-05-18', 'Approved', 'Auto-generated', '2023-05-18');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41039, 14, 1007, 'Nathan Summers', '2022-07-11', 'Fulfilled', 'Auto-generated', '2022-07-11');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41040, 5, 1006, 'Steve Rogers', '2024-11-03', 'Merged INTO Site Order', 'Auto-generated', '2024-11-03');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41041, 14, 1004, 'Tony Stark', '2023-09-01', 'Approved', 'Auto-generated', '2023-09-01');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41042, 16, 1001, 'Bruce Wayne', '2023-07-05', 'Fulfilled', 'Auto-generated', '2023-07-05');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41043, 5, 1008, 'Bruce Banner', '2023-06-07', 'Pending', 'Auto-generated', '2023-06-07');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41044, 10, 1008, 'Bruce Banner', '2023-11-19', 'Fulfilled', 'Auto-generated', '2023-11-19');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41045, 1, 1007, 'Nathan Summers', '2022-05-15', 'Pending', 'Auto-generated', '2022-05-15');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41046, 8, 1007, 'Nathan Summers', '2022-04-01', 'Approved', 'Auto-generated', '2022-04-01');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41047, 8, 1008, 'Bruce Banner', '2023-09-23', 'Merged INTO Site Order', 'Auto-generated', '2023-09-23');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41048, 16, 1009, 'Harleen Quinn', '2023-01-25', 'Pending', 'Auto-generated', '2023-01-25');
INSERT INTO WellOrder (well_OrderID, wellID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (41049, 2, 1008, 'Bruce Banner', '2023-12-19', 'Pending', 'Auto-generated', '2023-12-19');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51000, 1, 1003, 'Peter Parker', '2022-06-16', 'Sent', 'Auto-generated', '2022-06-16');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51001, 1, 1003, 'Peter Parker', '2023-01-07', 'Draft', 'Auto-generated', '2023-01-07');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51002, 1, 1003, 'Peter Parker', '2023-11-03', 'Sent', 'Auto-generated', '2023-11-03');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51003, 2, 1005, 'Diana Prince', '2024-04-10', 'Sent', 'Auto-generated', '2024-04-10');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51004, 1, 1003, 'Peter Parker', '2024-08-13', 'Sent', 'Auto-generated', '2024-08-13');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51005, 1, 1005, 'Diana Prince', '2024-07-24', 'Draft', 'Auto-generated', '2024-07-24');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51006, 2, 1003, 'Peter Parker', '2023-04-17', 'Draft', 'Auto-generated', '2023-04-17');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51007, 3, 1003, 'Peter Parker', '2023-07-30', 'Fulfilled', 'Auto-generated', '2023-07-30');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51008, 3, 1005, 'Diana Prince', '2022-08-11', 'Fulfilled', 'Auto-generated', '2022-08-11');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51009, 1, 1003, 'Peter Parker', '2023-05-07', 'Draft', 'Auto-generated', '2023-05-07');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51010, 2, 1005, 'Diana Prince', '2022-11-24', 'Sent', 'Auto-generated', '2022-11-24');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51011, 2, 1005, 'Diana Prince', '2024-01-15', 'Sent', 'Auto-generated', '2024-01-15');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51012, 3, 1005, 'Diana Prince', '2023-04-02', 'Sent', 'Auto-generated', '2023-04-02');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51013, 1, 1005, 'Diana Prince', '2023-05-15', 'Fulfilled', 'Auto-generated', '2023-05-15');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51014, 2, 1003, 'Peter Parker', '2024-07-18', 'Draft', 'Auto-generated', '2024-07-18');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51015, 1, 1005, 'Diana Prince', '2022-08-10', 'Draft', 'Auto-generated', '2022-08-10');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51016, 3, 1003, 'Peter Parker', '2024-12-15', 'Draft', 'Auto-generated', '2024-12-15');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51017, 3, 1005, 'Diana Prince', '2023-06-30', 'Fulfilled', 'Auto-generated', '2023-06-30');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51018, 3, 1005, 'Diana Prince', '2022-05-06', 'Sent', 'Auto-generated', '2022-05-06');
INSERT INTO SiteOrder (siteOrderID, siteID, submittedBy, submittedByName, submittedOn, status, notes, createdOn) VALUES (51019, 2, 1003, 'Peter Parker', '2023-05-16', 'Fulfilled', 'Auto-generated', '2023-05-16');
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51009, 41048);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51000, 41041);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51019, 41024);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51008, 41012);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51002, 41036);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51018, 41045);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51019, 41016);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51014, 41015);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51009, 41043);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51006, 41006);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51018, 41039);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51006, 41000);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51004, 41032);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51003, 41013);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51019, 41025);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51004, 41043);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51001, 41026);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51002, 41007);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51013, 41012);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51008, 41039);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51003, 41007);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51003, 41031);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51000, 41040);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51003, 41004);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51013, 41016);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51010, 41007);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51000, 41009);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51012, 41023);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51004, 41024);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51011, 41004);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51007, 41012);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51002, 41025);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51005, 41000);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51015, 41000);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51016, 41020);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51016, 41021);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51011, 41036);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51018, 41014);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51004, 41034);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51010, 41015);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51001, 41031);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51013, 41023);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51013, 41038);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51001, 41038);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51011, 41034);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51013, 41037);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51007, 41037);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51005, 41034);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51011, 41011);
INSERT INTO SiteOrderHasWellOrders (siteOrderID, well_OrderID) VALUES (51010, 41025);
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51009, 57, 'Pipe', 'ft', 31, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (201, 51013, 35, 'Connector', 'ft', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (215, 51011, 16, 'Connector', 'ft', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51017, 17, 'Pipe', 'each', 2, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51008, 60, 'Pipe', 'each', 2, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51009, 41, 'Pipe', 'ft', 165, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51014, 70, 'Pipe', 'each', 106, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51006, 24, 'Pipe', 'ft', 2, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51018, 53, 'Pipe', 'each', 106, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (125, 51006, 73, 'Connector', 'each', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (125, 51016, 75, 'Connector', 'ft', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (215, 51009, 99, 'Connector', 'each', NULL, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51000, 38, 'Pipe', 'each', 106, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51004, 16, 'Pipe', 'each', 85, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51014, 48, 'Pipe', 'ft', 2, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (120, 51015, 20, 'Connector', 'ft', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51014, 19, 'Pipe', 'ft', 85, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51014, 74, 'Pipe', 'each', 31, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51008, 25, 'Pipe', 'each', 85, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51004, 87, 'Pipe', 'each', 2, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (120, 51017, 69, 'Connector', 'ft', NULL, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51002, 67, 'Pipe', 'ft', 2, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51018, 61, 'Pipe', 'each', 106, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51010, 17, 'Pipe', 'each', 106, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51004, 53, 'Pipe', 'ft', 165, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51004, 44, 'Pipe', 'ft', 85, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51019, 75, 'Pipe', 'each', 2, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (215, 51019, 82, 'Connector', 'each', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51018, 70, 'Pipe', 'each', 106, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51002, 87, 'Pipe', 'each', 165, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (215, 51019, 53, 'Connector', 'each', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51003, 35, 'Pipe', 'each', 2, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51000, 27, 'Pipe', 'each', 31, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (120, 51007, 24, 'Connector', 'ft', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51007, 66, 'Pipe', 'each', 2, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51015, 52, 'Pipe', 'ft', 85, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51003, 83, 'Pipe', 'ft', 106, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (125, 51000, 30, 'Connector', 'ft', NULL, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (220, 51013, 86, 'Connector', 'ft', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (201, 51017, 48, 'Connector', 'ft', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (201, 51009, 15, 'Connector', 'ft', NULL, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (220, 51011, 35, 'Connector', 'ft', NULL, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51006, 99, 'Pipe', 'each', 85, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (125, 51010, 59, 'Connector', 'each', NULL, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (215, 51011, 20, 'Connector', 'ft', NULL, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51016, 89, 'Pipe', 'each', 165, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (201, 51019, 33, 'Connector', 'ft', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51017, 34, 'Pipe', 'ft', 85, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (220, 51001, 70, 'Connector', 'ft', NULL, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (215, 51012, 18, 'Connector', 'ft', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51016, 25, 'Pipe', 'ft', 2, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (220, 51015, 69, 'Connector', 'ft', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51017, 54, 'Pipe', 'ft', 31, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (201, 51018, 98, 'Connector', 'ft', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51017, 67, 'Pipe', 'ft', 31, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51019, 62, 'Pipe', 'each', 106, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (201, 51008, 25, 'Connector', 'ft', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (215, 51000, 31, 'Connector', 'each', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (125, 51013, 11, 'Connector', 'ft', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (201, 51019, 38, 'Connector', 'ft', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (215, 51010, 52, 'Connector', 'ft', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (220, 51012, 65, 'Connector', 'ft', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51008, 48, 'Pipe', 'ft', 2, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (220, 51000, 68, 'Connector', 'ft', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51000, 85, 'Pipe', 'each', 165, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (201, 51017, 47, 'Connector', 'ft', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51006, 97, 'Pipe', 'each', 165, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (215, 51008, 98, 'Connector', 'ft', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (220, 51008, 24, 'Connector', 'ft', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (215, 51006, 32, 'Connector', 'each', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (120, 51018, 16, 'Connector', 'ft', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51013, 100, 'Pipe', 'ft', 165, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51019, 70, 'Pipe', 'each', 165, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51017, 59, 'Pipe', 'each', 85, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (120, 51018, 21, 'Connector', 'each', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (215, 51013, 28, 'Connector', 'ft', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51010, 70, 'Pipe', 'ft', 2, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51016, 88, 'Pipe', 'each', 165, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51016, 26, 'Pipe', 'ft', 31, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (120, 51003, 23, 'Connector', 'ft', NULL, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (120, 51004, 26, 'Connector', 'each', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (201, 51003, 68, 'Connector', 'each', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (120, 51013, 12, 'Connector', 'each', NULL, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51014, 12, 'Pipe', 'each', 165, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (220, 51013, 81, 'Connector', 'each', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51019, 37, 'Pipe', 'ft', 165, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (220, 51011, 94, 'Connector', 'each', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (125, 51004, 18, 'Connector', 'ft', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (120, 51015, 85, 'Connector', 'ft', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51008, 28, 'Pipe', 'each', 2, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (215, 51017, 58, 'Connector', 'each', NULL, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (201, 51011, 47, 'Connector', 'ft', NULL, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (215, 51000, 100, 'Connector', 'each', NULL, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51002, 55, 'Pipe', 'ft', 85, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (201, 51004, 66, 'Connector', 'each', NULL, 'Standard');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51013, 67, 'Pipe', 'each', 165, 'Urgent');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51018, 24, 'Pipe', 'ft', 85, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (NULL, 51006, 70, 'Pipe', 'ft', 85, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (120, 51008, 59, 'Connector', 'ft', NULL, 'Backorder');
INSERT INTO SiteOrderLineItems (connectorID, siteOrderID, quantityOrdered, itemType, unit, pipeID, notes) VALUES (125, 51010, 31, 'Connector', 'each', NULL, 'Standard');



SELECT * FROM PipePriceChange;
SELECT * FROM ConnectorPriceChange;

SELECT
    so.siteOrderID,
    so.submittedOn AS siteOrderDate,
    so.siteID,
    swo.well_OrderID,
    wo.submittedOn AS wellOrderDate,
    wo.wellID,
    soli.pipeID,
    soli.connectorID,
    soli.itemType,
    soli.quantityOrdered,
    soli.unit,
    soli.notes
FROM SiteOrder so
JOIN SiteOrderHasWellOrders swo ON so.siteOrderID = swo.siteOrderID
JOIN WellOrder wo ON swo.well_OrderID = wo.well_OrderID
JOIN SiteOrderLineItems soli ON so.siteOrderID = soli.siteOrderID
WHERE so.submittedOn BETWEEN '2022-01-01' AND '2024-12-31'
ORDER BY so.submittedOn, so.siteOrderID;




