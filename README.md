# Tubular Supply Chain Tracking Database

This repository contains the schema and sample data for a **relational database system designed to track tubular pipe and connector inventory** across oil and gas drilling sites, staging areas, and well locations. The system was developed as a graduate project for a database design and implementation course at Boston University.

## 📌 Project Overview

This project models a simplified but realistic supply chain scenario for managing oilfield inventory such as **casing, tubing, drill pipe, and connectors**. The database supports role-based access, inventory movement tracking, well-level order submission, and site-level procurement workflows.

The schema was implemented using **Microsoft SQL Server**, with features focused on performance, data integrity, and normalized design.

---

## ⚙️ Features

- **Normalized Entity Structure**  
  - Generalization-specialization for `Pipe`, `Connector`, and `Location` entities  
  - Supertype: `Location`; Subtypes: `SiteLocation`, `WellLocation`  
  - Supertype: `Pipe` with subtypes `DrillPipe`, `Casing`, `Tubing`  
  - Supertype: `Connector` with subtypes `Threaded`, `Welded`, `Premium`

- **Order Management Workflow**  
  - Engineers create **WellOrders**  
  - Site Supervisors aggregate into **SiteOrders**  
  - Orders include line items for pipes and connectors

- **Role-Based Access Control (RBAC)**  
  - `SystemUser` + `Role` + `Permission` with many-to-many mapping  
  - Custom roles: Engineer, Inventory Clerk, Site Supervisor, Administrator

- **Historical Pricing and Audit Logging**  
  - `PipePricing` and `ConnectorPricing` with change tracking  
  - Trigger-ready architecture for auditability

- **Inventory Updates**  
  - Logged events for receiving, using, adjusting, or damaging inventory  
  - Captures before/after quantities and user who submitted the change

---

## 🛠️ How to Use

1. Clone the repo or download the SQL file:
