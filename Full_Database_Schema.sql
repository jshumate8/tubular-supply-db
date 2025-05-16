
-- User Table
CREATE TABLE User (
    userID DECIMAL(12,0) PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    username VARCHAR(50) UNIQUE,
    passwordHash VARCHAR(255),
    isActive BOOLEAN
);

-- Role Table
CREATE TABLE Role (
    roleID DECIMAL(12,0) PRIMARY KEY,
    roleName VARCHAR(50) UNIQUE NOT NULL
);

-- Permission Table
CREATE TABLE Permission (
    permissionID DECIMAL(12,0) PRIMARY KEY,
    permissionName VARCHAR(100) UNIQUE NOT NULL
);

-- RolePermission Table
CREATE TABLE RolePermission (
    roleID DECIMAL(12,0),
    permissionID DECIMAL(12,0),
    isGranted BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (roleID, permissionID),
    FOREIGN KEY (roleID) REFERENCES Role(roleID),
    FOREIGN KEY (permissionID) REFERENCES Permission(permissionID)
);

-- Site Table
CREATE TABLE Site (
    siteID DECIMAL(12,0) PRIMARY KEY,
    site_name VARCHAR(100),
    site_geolocation VARCHAR(100),
    site_region VARCHAR(50),
    operator VARCHAR(100)
);

-- Well Table
CREATE TABLE Well (
    wellID DECIMAL(12,0) PRIMARY KEY,
    siteID DECIMAL(12,0),
    well_name VARCHAR(100),
    wellType ENUM('Exploration', 'Production', 'Injection'),
    status ENUM('Active', 'Inactive', 'Plugged'),
    depth DECIMAL(8,2),
    FOREIGN KEY (siteID) REFERENCES Site(siteID)
);

-- SiteHasUsers Table
CREATE TABLE SiteHasUsers (
    siteID DECIMAL(12,0),
    userID DECIMAL(12,0),
    roleID DECIMAL(12,0),
    assignedOn DATETIME,
    isActive BOOLEAN,
    PRIMARY KEY (siteID, userID),
    FOREIGN KEY (siteID) REFERENCES Site(siteID),
    FOREIGN KEY (userID) REFERENCES User(userID),
    FOREIGN KEY (roleID) REFERENCES Role(roleID)
);

-- WellHasUsers Table
CREATE TABLE WellHasUsers (
    wellID DECIMAL(12,0),
    userID DECIMAL(12,0),
    roleID DECIMAL(12,0),
    assignedOn DATETIME,
    isActive BOOLEAN,
    PRIMARY KEY (wellID, userID),
    FOREIGN KEY (wellID) REFERENCES Well(wellID),
    FOREIGN KEY (userID) REFERENCES User(userID),
    FOREIGN KEY (roleID) REFERENCES Role(roleID)
);

-- Pipe Table
CREATE TABLE Pipe (
    pipeID DECIMAL(12,0) PRIMARY KEY,
    productID DECIMAL(12,0),
    pipeType ENUM('Casing', 'Tubing', 'DrillPipe'),
    outerDiameter DECIMAL(5,2),
    wallThickness DECIMAL(4,2),
    weightPerFoot DECIMAL(6,2),
    lengthRange ENUM('R1', 'R2', 'R3'),
    threadType VARCHAR(50),
    coatingType VARCHAR(50),
    heatNumber VARCHAR(50),
    inspectionStatus ENUM('Passed', 'Rejected', 'Pending'),
    storageLocationID DECIMAL(12,0),
    quantityAvailable INT,
    grade VARCHAR(10),
    material VARCHAR(100)
);

-- Connector Table
CREATE TABLE Connector (
    connectorID DECIMAL(12,0) PRIMARY KEY,
    name VARCHAR(100),
    size DECIMAL(5,2),
    material VARCHAR(100),
    pressureRating DECIMAL(8,2),
    coatingType VARCHAR(50),
    connectionStandard VARCHAR(50),
    manufacture VARCHAR(100),
    storageLocationID DECIMAL(12,0)
);

-- Well Order Table
CREATE TABLE WellOrder (
    wellOrderID DECIMAL(12,0) PRIMARY KEY,
    wellID DECIMAL(12,0),
    userID DECIMAL(12,0),
    submittedOn DATETIME,
    status ENUM('Draft', 'Approved', 'Merged into Site Order', 'Fulfilled'),
    notes TEXT,
    FOREIGN KEY (wellID) REFERENCES Well(wellID),
    FOREIGN KEY (userID) REFERENCES User(userID)
);

-- Well Order Line Items
CREATE TABLE WellOrderLineItems (
    wellOrderLineItemID DECIMAL(12,0) PRIMARY KEY,
    wellOrderID DECIMAL(12,0),
    connectorID DECIMAL(12,0),
    pipeID DECIMAL(12,0),
    quantityRequested DECIMAL(10,2),
    unit VARCHAR(20),
    notes TEXT,
    FOREIGN KEY (wellOrderID) REFERENCES WellOrder(wellOrderID),
    FOREIGN KEY (connectorID) REFERENCES Connector(connectorID),
    FOREIGN KEY (pipeID) REFERENCES Pipe(pipeID)
);

-- Site Order Table
CREATE TABLE SiteOrder (
    siteOrderID DECIMAL(12,0) PRIMARY KEY,
    siteID DECIMAL(12,0),
    submittedBy DECIMAL(12,0),
    submittedOn DATETIME,
    status ENUM('Draft', 'Sent', 'Fulfilled'),
    notes TEXT,
    FOREIGN KEY (siteID) REFERENCES Site(siteID),
    FOREIGN KEY (submittedBy) REFERENCES User(userID)
);

-- Site Order Line Items
CREATE TABLE SiteOrderLineItems (
    siteOrderLineItemID DECIMAL(12,0) PRIMARY KEY,
    siteOrderID DECIMAL(12,0),
    connectorID DECIMAL(12,0),
    pipeID DECIMAL(12,0),
    quantityOrdered DECIMAL(10,2),
    unit VARCHAR(20),
    notes TEXT,
    FOREIGN KEY (siteOrderID) REFERENCES SiteOrder(siteOrderID),
    FOREIGN KEY (connectorID) REFERENCES Connector(connectorID),
    FOREIGN KEY (pipeID) REFERENCES Pipe(pipeID)
);

-- Inventory Transaction Table
CREATE TABLE InventoryTransaction (
    transactionID DECIMAL(12,0) PRIMARY KEY,
    toLocationID DECIMAL(12,0),
    fromLocationID DECIMAL(12,0),
    itemType ENUM('Pipe', 'Connector'),
    pipeID DECIMAL(12,0),
    connectorID DECIMAL(12,0),
    quantityMoved DECIMAL(10,2),
    performedBy DECIMAL(12,0),
    transferDate DATETIME,
    notes TEXT,
    FOREIGN KEY (pipeID) REFERENCES Pipe(pipeID),
    FOREIGN KEY (connectorID) REFERENCES Connector(connectorID),
    FOREIGN KEY (performedBy) REFERENCES User(userID)
);
