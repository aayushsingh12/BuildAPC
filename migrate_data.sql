-- Data Migration Script for BuildAPC Database
-- This script populates all tables with data from CSV files

USE BuildAPC;

-- Disable foreign key checks during migration
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- POPULATE MAIN TABLES
-- ============================================

-- 1. MOTHERBOARD Table
-- Source: data/csv/motherboard.csv
INSERT IGNORE INTO MOTHERBOARD (motherboard_id, motherboard_name, motherboard_price, color, memory_slots) VALUES
('MB_001', 'Asus PRIME B650-PLUS WIFI', 159.99, 'Black / Silver', 4),
('MB_002', 'MSI B650 GAMING PLUS WIFI', 169.99, 'Black', 4),
('MB_003', 'MSI MAG B650 TOMAHAWK WIFI', 189.42, 'Black', 4),
('MB_004', 'Gigabyte X870E AORUS ELITE WIFI7', 325.31, 'Black', 4),
('MB_005', 'Asus PRIME B550M-A WIFI II', 99.99, 'Blue / Silver', 4),
('MB_006', 'Gigabyte B650 EAGLE AX', 157.99, 'Gray / Black', 4),
('MB_007', 'Asus TUF GAMING B850-PLUS WIFI', 217.99, 'Black / Silver', 4),
('MB_008', 'ASRock B650M Pro RS WiFi', 139.99, 'Black / Silver', 4),
('MB_009', 'MSI MAG X870 TOMAHAWK WIFI', 269.99, 'Black', 4),
('MB_010', 'Gigabyte A520M K V2', 68.47, 'Brown / Black', 2);

-- 2. CASE Table
-- Source: data/csv/case.csv
INSERT IGNORE INTO `CASE` (case_id, case_name, case_price, case_color, side_panel) VALUES
('CASE_001', 'Montech XR', 83.59, 'Black', 'Tempered Glass'),
('CASE_002', 'Phanteks XT PRO', 67.98, 'Black', 'Tempered Glass'),
('CASE_003', 'NZXT H5 Flow (2024)', 84.99, 'Black', 'Tempered Glass'),
('CASE_004', 'Corsair 3500X ARGB', 115.99, 'White', 'Tempered Glass'),
('CASE_005', 'Cooler Master MasterBox Q300L', 45.98, 'Black', 'Acrylic'),
('CASE_006', 'Corsair 4000D Airflow', 94.99, 'Black', 'Tinted Tempered Glass'),
('CASE_007', 'Lian Li Lancool 207', 81.99, 'Blue', 'Tempered Glass'),
('CASE_008', 'NZXT H9 Flow (2023)', 119.99, 'Black', 'Tempered Glass'),
('CASE_009', 'Lian Li O11 VISION COMPACT', 124.99, 'White', 'Tempered Glass'),
('CASE_010', 'Corsair 3500X ARGB', 115.99, 'Black', 'Tempered Glass');

-- 3. CPU Table
-- Source: data/csv/cpu.csv
INSERT IGNORE INTO CPU (cpu_id, cpu_name, cpu_price, clock, threads) VALUES
('CPU_001', 'AMD Ryzen 7 9800X3D', 451.50, 4.7, 16),
('CPU_002', 'AMD Ryzen 7 7800X3D', 340.05, 4.2, 16),
('CPU_003', 'AMD Ryzen 5 7600X', 170.49, 4.7, 12),
('CPU_004', 'AMD Ryzen 5 9600X', 204.99, 3.9, 12),
('CPU_005', 'AMD Ryzen 7 7700X', 242.98, 4.5, 16),
('CPU_006', 'AMD Ryzen 9 9950X3D', 649.99, 4.3, 32),
('CPU_007', 'AMD Ryzen 5 5500', 74.22, 3.6, 12),
('CPU_008', 'AMD Ryzen 7 9700X', 305.89, 3.8, 16),
('CPU_009', 'AMD Ryzen 5 5600X', 158.99, 3.7, 12),
('CPU_010', 'AMD Ryzen 5 5600', 125.61, 3.5, 12);

-- 4. GPU Table
-- Source: data/csv/video-card.csv
INSERT IGNORE INTO GPU (gpu_id, gpu_name, gpu_price, gpu_color, vram) VALUES
('GPU_001', 'MSI GeForce RTX 3060 Ventus 2X 12G', 299.97, 'Black', '12GB'),
('GPU_002', 'Sapphire PULSE RX 9060 XT', 379.99, 'Black', '16GB'),
('GPU_003', 'MSI SHADOW 3X OC RTX 5070 Ti', 829.99, 'Black', '16GB'),
('GPU_004', 'Gigabyte WINDFORCE OC SFF RTX 5070', 549.99, 'Black', '12GB'),
('GPU_005', 'Sapphire PULSE RX 9070 XT', 749.99, 'Black', '16GB'),
('GPU_006', 'ASRock Challenger OC RX 9060 XT', 369.99, 'Black / Silver', '16GB'),
('GPU_007', 'Gigabyte GAMING OC RX 9070 XT', 729.99, 'Black', '16GB'),
('GPU_008', 'Gigabyte GAMING OC RX 7600 XT', 359.97, 'Black / Gray', '16GB'),
('GPU_009', 'Asus ROG Astral OC RTX 5090', 3359.99, 'Black / Silver', '32GB'),
('GPU_010', 'ASRock Challenger D RX 6600', 219.99, 'Black', '8GB');

-- 5. PSU Table
-- Source: data/csv/power-supply.csv
INSERT IGNORE INTO PSU (psu_id, psu_name, psu_color, efficiency) VALUES
('PSU_001', 'MSI MAG A750GL PCIE5', 'Black', 'gold'),
('PSU_002', 'MSI MAG A850GL PCIE5', 'Black', 'gold'),
('PSU_003', 'MSI MAG A650BN', 'Black', 'bronze'),
('PSU_004', 'Corsair RM1000e (2023)', 'Black', 'gold'),
('PSU_005', 'Corsair RM750e (2025)', 'Black', NULL),
('PSU_006', 'Corsair RM850e (2025)', 'Black', NULL),
('PSU_007', 'MSI MAG A550BN', 'Black', 'bronze'),
('PSU_008', 'Corsair RM850x (2024)', 'Black', NULL),
('PSU_009', 'Corsair SF1000 (2024)', 'Black', 'platinum'),
('PSU_010', 'MSI MAG A650GL', 'Black', 'gold');

-- 6. RAM Table
-- Source: data/csv/memory.csv
INSERT IGNORE INTO RAM (ram_id, ram_name, ram_price, ram_speed) VALUES
('RAM_001', 'Corsair Vengeance RGB 32 GB', 94.99, 5600),
('RAM_002', 'G.Skill Flare X5 32 GB', 89.99, 5600),
('RAM_003', 'Corsair Vengeance LPX 16 GB', 45.99, 3200),
('RAM_004', 'Corsair Vengeance 32 GB', 129.99, 5600),
('RAM_005', 'TEAMGROUP T-Create Expert 32 GB', 98.99, 5600),
('RAM_006', 'Corsair Vengeance LPX 32 GB', 77.98, 3600),
('RAM_007', 'Crucial Pro Overclocking 32 GB', 84.99, 5600),
('RAM_008', 'G.Skill Trident Z5 RGB 64 GB', 234.99, 6400),
('RAM_009', 'Corsair Vengeance RGB 64 GB', 229.99, 5600),
('RAM_010', 'TEAMGROUP T-Force Delta RGB 32 GB', 105.99, 5600);

-- 7. SSD Table (using some sample data - you may need to add more from your CSV files)
INSERT IGNORE INTO SSD (ssd_id, ssd_name, protocol, ssd_form) VALUES
('SSD_001', 'Samsung 980 PRO 1TB', 'NVMe', 'M.2'),
('SSD_002', 'WD Black SN850X 2TB', 'NVMe', 'M.2'),
('SSD_003', 'Crucial MX4 1TB', 'SATA', '2.5"'),
('SSD_004', 'Samsung 990 EVO 1TB', 'NVMe', 'M.2'),
('SSD_005', 'Kingston NV2 500GB', 'NVMe', 'M.2');

-- 8. MONITOR Table (using sample data)
INSERT IGNORE INTO MONITOR (monitor_id, monitor_name, refresh_rate) VALUES
('MON_001', 'ASUS TUF Gaming VG27AQ', 165),
('MON_002', 'LG 27GP850-B', 165),
('MON_003', 'Samsung Odyssey G7', 240),
('MON_004', 'Dell S2721DGF', 165),
('MON_005', 'AOC 24G2', 144);

-- ============================================
-- POPULATE RELATIONSHIP TABLES
-- ============================================

-- Socket Table (CPU-Motherboard compatibility)
-- Based on socket types: AM4, AM5
INSERT IGNORE INTO Socket (cpu_id, motherboard_id, socket_type) VALUES
-- AM5 CPUs with AM5 Motherboards
('CPU_001', 'MB_001', 'AM5'), -- Ryzen 7 9800X3D with B650-PLUS
('CPU_001', 'MB_002', 'AM5'), -- Ryzen 7 9800X3D with B650 GAMING
('CPU_001', 'MB_003', 'AM5'), -- Ryzen 7 9800X3D with B650 TOMAHAWK
('CPU_002', 'MB_001', 'AM5'), -- Ryzen 7 7800X3D with B650-PLUS
('CPU_002', 'MB_002', 'AM5'), -- Ryzen 7 7800X3D with B650 GAMING
('CPU_003', 'MB_001', 'AM5'), -- Ryzen 5 7600X with B650-PLUS
('CPU_004', 'MB_002', 'AM5'), -- Ryzen 5 9600X with B650 GAMING
('CPU_005', 'MB_003', 'AM5'), -- Ryzen 7 7700X with B650 TOMAHAWK
-- AM4 CPUs with AM4 Motherboards
('CPU_007', 'MB_005', 'AM4'), -- Ryzen 5 5500 with B550M-A
('CPU_009', 'MB_005', 'AM4'), -- Ryzen 5 5600X with B550M-A
('CPU_010', 'MB_010', 'AM4'); -- Ryzen 5 5600 with A520M

-- Form_Factor Table (Case-Motherboard compatibility)
-- ATX cases support ATX, Micro-ATX, Mini-ITX
-- Micro-ATX cases support Micro-ATX, Mini-ITX
INSERT IGNORE INTO Form_Factor (case_id, motherboard_id, form_factor_type) VALUES
-- ATX Cases with ATX Motherboards
('CASE_001', 'MB_001', 'ATX'), -- Montech XR with B650-PLUS
('CASE_001', 'MB_002', 'ATX'), -- Montech XR with B650 GAMING
('CASE_002', 'MB_003', 'ATX'), -- Phanteks XT PRO with B650 TOMAHAWK
('CASE_003', 'MB_004', 'ATX'), -- NZXT H5 Flow with X870E AORUS
('CASE_006', 'MB_006', 'ATX'), -- Corsair 4000D with B650 EAGLE
-- ATX Cases with Micro-ATX Motherboards
('CASE_001', 'MB_005', 'Micro ATX'), -- Montech XR with B550M-A
('CASE_001', 'MB_008', 'Micro ATX'), -- Montech XR with B650M Pro RS
('CASE_002', 'MB_010', 'Micro ATX'), -- Phanteks XT PRO with A520M
-- Micro-ATX Case with Micro-ATX Motherboards
('CASE_005', 'MB_005', 'Micro ATX'), -- MasterBox Q300L with B550M-A
('CASE_005', 'MB_008', 'Micro ATX'), -- MasterBox Q300L with B650M Pro RS
('CASE_005', 'MB_010', 'Micro ATX'); -- MasterBox Q300L with A520M

-- Wattage Table (GPU-PSU compatibility)
-- Ensure PSU wattage is sufficient for GPU requirements
INSERT IGNORE INTO Wattage (gpu_id, psu_id, wattage_value) VALUES
-- High-end GPUs with high-wattage PSUs
('GPU_009', 'PSU_004', 1000), -- RTX 5090 with 1000W PSU
('GPU_009', 'PSU_009', 1000), -- RTX 5090 with SF1000
('GPU_003', 'PSU_002', 850),  -- RTX 5070 Ti with 850W PSU
('GPU_003', 'PSU_004', 1000), -- RTX 5070 Ti with 1000W PSU
('GPU_005', 'PSU_001', 750),  -- RX 9070 XT with 750W PSU
('GPU_005', 'PSU_002', 850),  -- RX 9070 XT with 850W PSU
-- Mid-range GPUs with various PSUs
('GPU_001', 'PSU_001', 750),  -- RTX 3060 with 750W PSU
('GPU_001', 'PSU_003', 650),  -- RTX 3060 with 650W PSU
('GPU_002', 'PSU_001', 750),  -- RX 9060 XT with 750W PSU
('GPU_004', 'PSU_002', 850),  -- RTX 5070 with 850W PSU
('GPU_006', 'PSU_001', 750),  -- RX 9060 XT with 750W PSU
('GPU_010', 'PSU_007', 550);  -- RX 6600 with 550W PSU

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check row counts for all tables
SELECT 'MOTHERBOARD' as TableName, COUNT(*) as RowCount FROM MOTHERBOARD
UNION ALL
SELECT 'CASE' as TableName, COUNT(*) as RowCount FROM `CASE`
UNION ALL
SELECT 'CPU' as TableName, COUNT(*) as RowCount FROM CPU
UNION ALL
SELECT 'GPU' as TableName, COUNT(*) as RowCount FROM GPU
UNION ALL
SELECT 'PSU' as TableName, COUNT(*) as RowCount FROM PSU
UNION ALL
SELECT 'RAM' as TableName, COUNT(*) as RowCount FROM RAM
UNION ALL
SELECT 'SSD' as TableName, COUNT(*) as RowCount FROM SSD
UNION ALL
SELECT 'MONITOR' as TableName, COUNT(*) as RowCount FROM MONITOR
UNION ALL
SELECT 'Socket' as TableName, COUNT(*) as RowCount FROM Socket
UNION ALL
SELECT 'Form_Factor' as TableName, COUNT(*) as RowCount FROM Form_Factor
UNION ALL
SELECT 'Wattage' as TableName, COUNT(*) as RowCount FROM Wattage;

-- Sample compatibility queries
SELECT 'CPU-Motherboard Compatibility' as QueryType;
SELECT c.cpu_name, m.motherboard_name, s.socket_type
FROM CPU c
JOIN Socket s ON c.cpu_id = s.cpu_id
JOIN MOTHERBOARD m ON s.motherboard_id = m.motherboard_id
LIMIT 5;

SELECT 'Case-Motherboard Compatibility' as QueryType;
SELECT ca.case_name, m.motherboard_name, f.form_factor_type
FROM `CASE` ca
JOIN Form_Factor f ON ca.case_id = f.case_id
JOIN MOTHERBOARD m ON f.motherboard_id = m.motherboard_id
LIMIT 5;

SELECT 'GPU-PSU Compatibility' as QueryType;
SELECT g.gpu_name, p.psu_name, w.wattage_value
FROM GPU g
JOIN Wattage w ON g.gpu_id = w.gpu_id
JOIN PSU p ON w.psu_id = p.psu_id
LIMIT 5;

SELECT 'Data migration completed successfully!' as Status;