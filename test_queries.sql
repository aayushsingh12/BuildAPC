-- BuildAPC Database Test Queries
-- This file contains various queries to test and explore the database functionality

USE BuildAPC;

-- ============================================
-- BASIC TABLE EXPLORATION QUERIES
-- ============================================

-- 1. Show all tables and their row counts
SELECT '=== DATABASE OVERVIEW ===' as Info;
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

-- 2. Most expensive components by category
SELECT '=== MOST EXPENSIVE COMPONENTS ===' as Info;

(SELECT 'CPU' as ComponentType, cpu_name as ComponentName, cpu_price as Price
FROM CPU ORDER BY cpu_price DESC LIMIT 3)
UNION ALL
(SELECT 'GPU' as ComponentType, gpu_name as ComponentName, gpu_price as Price
FROM GPU ORDER BY gpu_price DESC LIMIT 3)
UNION ALL
(SELECT 'Motherboard' as ComponentType, motherboard_name as ComponentName, motherboard_price as Price
FROM MOTHERBOARD ORDER BY motherboard_price DESC LIMIT 3);

-- 3. Budget-friendly options (under $100)
SELECT '=== BUDGET OPTIONS (Under $100) ===' as Info;

SELECT * FROM (
    SELECT 'CPU' as ComponentType, cpu_name as ComponentName, cpu_price as Price
    FROM CPU WHERE cpu_price < 100
    UNION ALL
    SELECT 'Motherboard' as ComponentType, motherboard_name as ComponentName, motherboard_price as Price
    FROM MOTHERBOARD WHERE motherboard_price < 100
    UNION ALL
    SELECT 'Case' as ComponentType, case_name as ComponentName, case_price as Price
    FROM `CASE` WHERE case_price < 100
) as BudgetOptions
ORDER BY Price ASC;

-- ============================================
-- COMPATIBILITY TESTING QUERIES
-- ============================================

-- 4. CPU-Motherboard Socket Compatibility
SELECT '=== CPU-MOTHERBOARD SOCKET COMPATIBILITY ===' as Info;
SELECT 
    c.cpu_name,
    m.motherboard_name,
    s.socket_type,
    c.cpu_price,
    m.motherboard_price,
    (c.cpu_price + m.motherboard_price) as CombinedPrice
FROM CPU c
JOIN Socket s ON c.cpu_id = s.cpu_id
JOIN MOTHERBOARD m ON s.motherboard_id = m.motherboard_id
ORDER BY CombinedPrice ASC
LIMIT 10;

-- 5. Case-Motherboard Form Factor Compatibility
SELECT '=== CASE-MOTHERBOARD FORM FACTOR COMPATIBILITY ===' as Info;
SELECT 
    ca.case_name,
    m.motherboard_name,
    f.form_factor_type,
    ca.case_price,
    m.motherboard_price,
    ca.side_panel
FROM `CASE` ca
JOIN Form_Factor f ON ca.case_id = f.case_id
JOIN MOTHERBOARD m ON f.motherboard_id = m.motherboard_id
ORDER BY ca.case_price ASC
LIMIT 10;

-- 6. GPU-PSU Power Compatibility
SELECT '=== GPU-PSU POWER COMPATIBILITY ===' as Info;
SELECT 
    g.gpu_name,
    p.psu_name,
    w.wattage_value as RequiredWattage,
    g.gpu_price,
    g.vram,
    p.efficiency
FROM GPU g
JOIN Wattage w ON g.gpu_id = w.gpu_id
JOIN PSU p ON w.psu_id = p.psu_id
ORDER BY g.gpu_price DESC
LIMIT 10;

-- ============================================
-- BUILD RECOMMENDATION QUERIES
-- ============================================

-- 7. Complete Budget Build (Under $800 total)
SELECT '=== COMPLETE BUDGET BUILD RECOMMENDATIONS ===' as Info;
SELECT 
    'Budget Gaming Build' as BuildName,
    c.cpu_name,
    c.cpu_price,
    m.motherboard_name,
    m.motherboard_price,
    g.gpu_name,
    g.gpu_price,
    r.ram_name,
    r.ram_price,
    (c.cpu_price + m.motherboard_price + g.gpu_price + r.ram_price) as TotalPrice
FROM CPU c
JOIN Socket s ON c.cpu_id = s.cpu_id
JOIN MOTHERBOARD m ON s.motherboard_id = m.motherboard_id
CROSS JOIN GPU g
CROSS JOIN RAM r
WHERE c.cpu_price < 200 
    AND m.motherboard_price < 150 
    AND g.gpu_price < 400
    AND r.ram_price < 100
    AND (c.cpu_price + m.motherboard_price + g.gpu_price + r.ram_price) < 800
ORDER BY TotalPrice ASC
LIMIT 5;

-- 8. High-End Gaming Build Recommendations
SELECT '=== HIGH-END GAMING BUILD RECOMMENDATIONS ===' as Info;
SELECT 
    'High-End Gaming Build' as BuildName,
    c.cpu_name,
    c.cpu_price,
    g.gpu_name,
    g.gpu_price,
    g.vram,
    r.ram_name,
    r.ram_speed,
    (c.cpu_price + g.gpu_price + r.ram_price) as CoreComponentsPrice
FROM CPU c
CROSS JOIN GPU g
CROSS JOIN RAM r
WHERE c.cpu_price > 300 
    AND g.gpu_price > 700
    AND r.ram_speed >= 5600
ORDER BY CoreComponentsPrice DESC
LIMIT 5;

-- ============================================
-- COMPONENT ANALYSIS QUERIES
-- ============================================

-- 9. RAM Performance Analysis
SELECT '=== RAM PERFORMANCE ANALYSIS ===' as Info;
SELECT 
    ram_name,
    ram_speed,
    ram_price,
    ROUND(ram_price / (ram_speed / 1000), 2) as PricePerGHz,
    CASE 
        WHEN ram_speed >= 6000 THEN 'High Performance'
        WHEN ram_speed >= 4000 THEN 'Mid Performance'
        ELSE 'Budget Performance'
    END as PerformanceCategory
FROM RAM
ORDER BY ram_speed DESC;

-- 10. GPU Value Analysis (Price per GB of VRAM)
SELECT '=== GPU VALUE ANALYSIS ===' as Info;
SELECT 
    gpu_name,
    gpu_price,
    vram,
    CAST(SUBSTRING(vram, 1, LENGTH(vram)-2) AS UNSIGNED) as VRAM_GB,
    ROUND(gpu_price / CAST(SUBSTRING(vram, 1, LENGTH(vram)-2) AS UNSIGNED), 2) as PricePerGB_VRAM,
    gpu_color
FROM GPU
WHERE vram REGEXP '^[0-9]+GB$'
ORDER BY PricePerGB_VRAM ASC;

-- 11. CPU Performance per Dollar
SELECT '=== CPU PERFORMANCE PER DOLLAR ===' as Info;
SELECT 
    cpu_name,
    cpu_price,
    clock as BaseClock,
    threads,
    ROUND(threads * clock / cpu_price, 3) as PerformancePerDollar,
    CASE 
        WHEN threads >= 16 THEN 'Workstation Class'
        WHEN threads >= 12 THEN 'Gaming/Content Creation'
        ELSE 'Budget Gaming'
    END as UsageCategory
FROM CPU
ORDER BY PerformancePerDollar DESC;

-- ============================================
-- INVENTORY AND STATISTICS QUERIES
-- ============================================

-- 12. Component Color Distribution
SELECT '=== COMPONENT COLOR DISTRIBUTION ===' as Info;
SELECT 'Motherboard' as ComponentType, color, COUNT(*) as Count
FROM MOTHERBOARD GROUP BY color
UNION ALL
SELECT 'Case' as ComponentType, case_color, COUNT(*) as Count
FROM `CASE` GROUP BY case_color
UNION ALL
SELECT 'GPU' as ComponentType, gpu_color, COUNT(*) as Count
FROM GPU GROUP BY gpu_color
ORDER BY ComponentType, Count DESC;

-- 13. Price Range Distribution
SELECT '=== PRICE RANGE DISTRIBUTION ===' as Info;
SELECT 
    ComponentType,
    PriceRange,
    COUNT(*) as Count,
    ROUND(AVG(Price), 2) as AvgPrice
FROM (
    SELECT 'CPU' as ComponentType, cpu_price as Price,
        CASE 
            WHEN cpu_price < 100 THEN 'Under $100'
            WHEN cpu_price < 300 THEN '$100-$299'
            WHEN cpu_price < 500 THEN '$300-$499'
            ELSE '$500+'
        END as PriceRange
    FROM CPU
    UNION ALL
    SELECT 'GPU' as ComponentType, gpu_price as Price,
        CASE 
            WHEN gpu_price < 300 THEN 'Under $300'
            WHEN gpu_price < 600 THEN '$300-$599'
            WHEN gpu_price < 1000 THEN '$600-$999'
            ELSE '$1000+'
        END as PriceRange
    FROM GPU
    UNION ALL
    SELECT 'Motherboard' as ComponentType, motherboard_price as Price,
        CASE 
            WHEN motherboard_price < 100 THEN 'Under $100'
            WHEN motherboard_price < 200 THEN '$100-$199'
            WHEN motherboard_price < 300 THEN '$200-$299'
            ELSE '$300+'
        END as PriceRange
    FROM MOTHERBOARD
) as PriceAnalysis
GROUP BY ComponentType, PriceRange
ORDER BY ComponentType, AvgPrice ASC;

-- 14. PSU Efficiency Rating Analysis
SELECT '=== PSU EFFICIENCY ANALYSIS ===' as Info;
SELECT 
    efficiency,
    COUNT(*) as Count,
    GROUP_CONCAT(psu_name SEPARATOR ', ') as PSU_Models
FROM PSU
WHERE efficiency IS NOT NULL
GROUP BY efficiency
ORDER BY 
    CASE efficiency
        WHEN 'platinum' THEN 1
        WHEN 'gold' THEN 2
        WHEN 'bronze' THEN 3
        ELSE 4
    END;

-- ============================================
-- ADVANCED COMPATIBILITY QUERIES
-- ============================================

-- 15. Find Complete Compatible Builds
SELECT '=== COMPLETE COMPATIBLE BUILD FINDER ===' as Info;
SELECT 
    c.cpu_name,
    m.motherboard_name,
    ca.case_name,
    g.gpu_name,
    p.psu_name,
    s.socket_type,
    f.form_factor_type,
    w.wattage_value,
    (c.cpu_price + m.motherboard_price + ca.case_price + g.gpu_price) as EstimatedPrice
FROM CPU c
JOIN Socket s ON c.cpu_id = s.cpu_id
JOIN MOTHERBOARD m ON s.motherboard_id = m.motherboard_id
JOIN Form_Factor f ON m.motherboard_id = f.motherboard_id
JOIN `CASE` ca ON f.case_id = ca.case_id
JOIN GPU g ON g.gpu_id IN (SELECT gpu_id FROM Wattage)
JOIN Wattage w ON g.gpu_id = w.gpu_id
JOIN PSU p ON w.psu_id = p.psu_id
ORDER BY EstimatedPrice ASC
LIMIT 5;

-- 16. Component Compatibility Summary
SELECT '=== COMPATIBILITY SUMMARY ===' as Info;
SELECT 
    'Socket Compatibility' as CompatibilityType,
    COUNT(DISTINCT CONCAT(cpu_id, '-', motherboard_id)) as CompatiblePairs
FROM Socket
UNION ALL
SELECT 
    'Form Factor Compatibility' as CompatibilityType,
    COUNT(DISTINCT CONCAT(case_id, '-', motherboard_id)) as CompatiblePairs
FROM Form_Factor
UNION ALL
SELECT 
    'Power Compatibility' as CompatibilityType,
    COUNT(DISTINCT CONCAT(gpu_id, '-', psu_id)) as CompatiblePairs
FROM Wattage;

SELECT '=== TEST QUERIES COMPLETED SUCCESSFULLY! ===' as Status;