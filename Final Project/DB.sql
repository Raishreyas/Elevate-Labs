-- ######################################################################
-- # FINAL SQL SCRIPT: INVENTORY AND WAREHOUSE MANAGEMENT SYSTEM BACKEND
-- # Designed for use with the Python Flask application interface
-- ######################################################################

-- Ensure proper delimiter setting for creating procedures and triggers
DELIMITER $$

-- 0. DATABASE SETUP
-- ----------------------------------------------------------------------
DROP DATABASE IF EXISTS InventoryManagement;
CREATE DATABASE InventoryManagement;
USE InventoryManagement;

-- 1. MODEL SCHEMA FOR TABLES
-- ----------------------------------------------------------------------

-- Table: Suppliers
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    SupplierName VARCHAR(100) NOT NULL,
    ContactEmail VARCHAR(100) UNIQUE,
    Phone VARCHAR(20)
);

-- Table: Products
CREATE TABLE Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100) NOT NULL,
    SKU VARCHAR(50) UNIQUE NOT NULL,
    SupplierID INT,
    ReorderPoint INT NOT NULL,
    Cost DECIMAL(10, 2),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

-- Table: Warehouses
CREATE TABLE Warehouses (
    WarehouseID INT PRIMARY KEY AUTO_INCREMENT,
    WarehouseName VARCHAR(100) NOT NULL,
    Location VARCHAR(100)
);

-- Table: Stock (Junction table for Products and Warehouses)
CREATE TABLE Stock (
    StockID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    WarehouseID INT NOT NULL,
    Quantity INT NOT NULL,
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY (ProductID, WarehouseID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses(WarehouseID)
);

-- Table: LowStockAlerts (For trigger logging)
CREATE TABLE LowStockAlerts (
    AlertID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    WarehouseID INT NOT NULL,
    CurrentQuantity INT NOT NULL,
    ReorderPoint INT NOT NULL,
    AlertTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 2. INSERT SAMPLE INVENTORY RECORDS
-- ----------------------------------------------------------------------

-- Insert Sample Suppliers
INSERT INTO Suppliers (SupplierName, ContactEmail, Phone) VALUES
('Global Electronics', 'contact@globalelectronics.com', '555-1001'),
('ChemCo Supplies', 'info@chemcosupplies.com', '555-1002'),
('Woodworks Intl', 'sales@woodworks.net', '555-1003');

-- Insert Sample Products
INSERT INTO Products (ProductName, SKU, SupplierID, ReorderPoint, Cost) VALUES
('Laptop Pro X', 'LPX-001', 1, 10, 850.00),
('USB-C Cable (6ft)', 'USBC-06', 1, 50, 5.50),
('Solvent A', 'SLV-A', 2, 20, 15.75),
('Oak Planks (100 pack)', 'OAK-100', 3, 5, 120.00);

-- Insert Sample Warehouses
INSERT INTO Warehouses (WarehouseName, Location) VALUES
('Main Distribution Center', 'New York'),
('Regional Storage North', 'Chicago'),
('Chemical Storage Facility', 'Texas');

-- Insert Sample Stock
INSERT INTO Stock (ProductID, WarehouseID, Quantity) VALUES
(1, 1, 15),  -- Laptop Pro X at Main DC
(2, 1, 150), -- USB-C Cable at Main DC
(2, 2, 80),  -- USB-C Cable at Regional Storage
(3, 3, 25),  -- Solvent A at Chemical Storage
(4, 1, 7),   -- Oak Planks at Main DC
(1, 2, 8);   -- Laptop Pro X at Regional Storage


-- 3. TRIGGERS
-- ----------------------------------------------------------------------

-- Trigger: After a Stock update, check for low stock in the specific warehouse
CREATE TRIGGER trg_low_stock_check
AFTER UPDATE ON Stock
FOR EACH ROW
BEGIN
    DECLARE v_reorder_point INT;

    SELECT ReorderPoint INTO v_reorder_point
    FROM Products
    WHERE ProductID = NEW.ProductID;

    -- Only log if the quantity drops below the reorder point, and wasn't already below it.
    IF NEW.Quantity < v_reorder_point AND OLD.Quantity >= v_reorder_point THEN
        INSERT INTO LowStockAlerts (ProductID, WarehouseID, CurrentQuantity, ReorderPoint)
        VALUES (NEW.ProductID, NEW.WarehouseID, NEW.Quantity, v_reorder_point);
    END IF;
END$$


-- 4. STORED PROCEDURES (CORE INVENTORY FUNCTIONS)
-- ----------------------------------------------------------------------

-- PROCEDURE: sp_transfer_stock (Stock Movement)
CREATE PROCEDURE sp_transfer_stock(
    IN p_product_id INT,
    IN p_source_warehouse_id INT,
    IN p_destination_warehouse_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_source_current_stock INT;

    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer failed: Quantity must be positive.';
    END IF;

    -- Check if source has sufficient stock
    SELECT Quantity INTO v_source_current_stock
    FROM Stock
    WHERE ProductID = p_product_id AND WarehouseID = p_source_warehouse_id;

    IF v_source_current_stock IS NULL OR v_source_current_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transfer failed: Insufficient stock at source warehouse or product not stocked there.';
    ELSE
        START TRANSACTION;
        -- Deduct from source stock
        UPDATE Stock
        SET Quantity = Quantity - p_quantity
        WHERE ProductID = p_product_id AND WarehouseID = p_source_warehouse_id;

        -- Add to destination stock (UPSERT logic)
        INSERT INTO Stock (ProductID, WarehouseID, Quantity)
        VALUES (p_product_id, p_destination_warehouse_id, p_quantity)
        ON DUPLICATE KEY UPDATE Quantity = Quantity + p_quantity;

        COMMIT;
    END IF;
END$$

-- PROCEDURE: sp_ReceiveStock (Stock In)
CREATE PROCEDURE sp_ReceiveStock(
    IN p_ProductID INT,
    IN p_WarehouseID INT,
    IN p_Quantity INT
)
BEGIN
    IF p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Receive quantity must be positive.';
    END IF;

    -- Upsert logic: Insert if (Product, Warehouse) pair doesn't exist, otherwise update quantity
    INSERT INTO Stock (ProductID, WarehouseID, Quantity)
    VALUES (p_ProductID, p_WarehouseID, p_Quantity)
    ON DUPLICATE KEY UPDATE 
        Quantity = Quantity + p_Quantity;
END$$

-- PROCEDURE: sp_DispatchStock (Stock Out - Omitted from Flask, but good for completeness)
CREATE PROCEDURE sp_DispatchStock(
    IN p_ProductID INT,
    IN p_WarehouseID INT,
    IN p_Quantity INT
)
BEGIN
    DECLARE v_current_stock INT;

    IF p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dispatch quantity must be positive.';
    END IF;

    SELECT Quantity INTO v_current_stock
    FROM Stock
    WHERE ProductID = p_ProductID AND WarehouseID = p_WarehouseID;

    IF v_current_stock IS NULL OR v_current_stock < p_Quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dispatch failed: Insufficient stock at source warehouse.';
    ELSE
        UPDATE Stock
        SET Quantity = Quantity - p_Quantity
        WHERE ProductID = p_ProductID AND WarehouseID = p_WarehouseID;
    END IF;
END$$


-- 5. STORED PROCEDURES (CRUD FOR MASTER DATA)
-- ----------------------------------------------------------------------

-- Products CRUD
CREATE PROCEDURE sp_CreateProduct(
    IN p_ProductName VARCHAR(100),
    IN p_SKU VARCHAR(50),
    IN p_SupplierID INT,
    IN p_ReorderPoint INT,
    IN p_Cost DECIMAL(10, 2)
)
BEGIN
    INSERT INTO Products (ProductName, SKU, SupplierID, ReorderPoint, Cost)
    VALUES (p_ProductName, p_SKU, p_SupplierID, p_ReorderPoint, p_Cost);
END$$

CREATE PROCEDURE sp_UpdateProduct(
    IN p_ProductID INT,
    IN p_ProductName VARCHAR(100),
    IN p_SKU VARCHAR(50),
    IN p_SupplierID INT,
    IN p_ReorderPoint INT,
    IN p_Cost DECIMAL(10, 2)
)
BEGIN
    UPDATE Products
    SET 
        ProductName = p_ProductName,
        SKU = p_SKU,
        SupplierID = p_SupplierID,
        ReorderPoint = p_ReorderPoint,
        Cost = p_Cost
    WHERE ProductID = p_ProductID;
END$$

CREATE PROCEDURE sp_DeleteProduct(
    IN p_ProductID INT
)
BEGIN
    -- Deleting stock first maintains foreign key integrity
    DELETE FROM Stock WHERE ProductID = p_ProductID;
    DELETE FROM Products WHERE ProductID = p_ProductID;
END$$

-- Warehouses CRUD
CREATE PROCEDURE sp_CreateWarehouse(
    IN p_WarehouseName VARCHAR(100),
    IN p_Location VARCHAR(100)
)
BEGIN
    INSERT INTO Warehouses (WarehouseName, Location)
    VALUES (p_WarehouseName, p_Location);
END$$

CREATE PROCEDURE sp_UpdateWarehouse(
    IN p_WarehouseID INT,
    IN p_WarehouseName VARCHAR(100),
    IN p_Location VARCHAR(100)
)
BEGIN
    UPDATE Warehouses
    SET 
        WarehouseName = p_WarehouseName,
        Location = p_Location
    WHERE WarehouseID = p_WarehouseID;
END$$

CREATE PROCEDURE sp_DeleteWarehouse(
    IN p_WarehouseID INT
)
BEGIN
    DELETE FROM Stock WHERE WarehouseID = p_WarehouseID;
    DELETE FROM Warehouses WHERE WarehouseID = p_WarehouseID;
END$$

-- Suppliers CRUD
CREATE PROCEDURE sp_CreateSupplier(
    IN p_SupplierName VARCHAR(100),
    IN p_ContactEmail VARCHAR(100),
    IN p_Phone VARCHAR(20)
)
BEGIN
    INSERT INTO Suppliers (SupplierName, ContactEmail, Phone)
    VALUES (p_SupplierName, p_ContactEmail, p_Phone);
END$$

CREATE PROCEDURE sp_UpdateSupplier(
    IN p_SupplierID INT,
    IN p_SupplierName VARCHAR(100),
    IN p_ContactEmail VARCHAR(100),
    IN p_Phone VARCHAR(20)
)
BEGIN
    UPDATE Suppliers
    SET 
        SupplierName = p_SupplierName,
        ContactEmail = p_ContactEmail,
        Phone = p_Phone
    WHERE SupplierID = p_SupplierID;
END$$

CREATE PROCEDURE sp_DeleteSupplier(
    IN p_SupplierID INT
)
BEGIN
    DECLARE product_count INT;

    SELECT COUNT(*) INTO product_count 
    FROM Products 
    WHERE SupplierID = p_SupplierID;

    IF product_count = 0 THEN
        DELETE FROM Suppliers WHERE SupplierID = p_SupplierID;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete supplier. Products are still linked to this supplier. Reassign products first.';
    END IF;
END$$

-- Reset the delimiter
DELIMITER ;