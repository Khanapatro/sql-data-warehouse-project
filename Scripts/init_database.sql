/*
NOTE:
 This script sets up the DataWarehouse database from scratch.
 It drops the existing database if it already exists and then
 recreates it along with the bronze, silver, and gold schemas.

Warning:
  Running this script will permanently delete the existing
  DataWarehouse database. Use only in development or
  controlled environments.
*/

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
