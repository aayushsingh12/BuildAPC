-- Add new compatibility checks for RAM
DELIMITER //

DROP FUNCTION IF EXISTS check_compatibility_fnn//
CREATE FUNCTION check_compatibility_fnn(comp1_type VARCHAR(50), comp1_id INT, comp2_type VARCHAR(50), comp2_id INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(50);

    -- CPU and Motherboard compatibility check (based on socket)
    IF (comp1_type = 'cpu' AND comp2_type = 'motherboard') OR (comp1_type = 'motherboard' AND comp2_type = 'cpu') THEN
        SET result = (
            SELECT 
                CASE 
                    WHEN c.socket = m.socket THEN 'Compatible'
                    ELSE 'Socket mismatch'
                END
            FROM cpus c, motherboards m
            WHERE (comp1_type = 'cpu' AND c.id = comp1_id AND m.id = comp2_id)
                OR (comp1_type = 'motherboard' AND m.id = comp1_id AND c.id = comp2_id)
        );
        
    -- GPU and PSU compatibility check (based on TDP)
    ELSEIF (comp1_type = 'gpu' AND comp2_type = 'psu') OR (comp1_type = 'psu' AND comp2_type = 'gpu') THEN
        SET result = (
            SELECT 
                CASE 
                    WHEN p.wattage >= g.tdp_w THEN 'Compatible'
                    ELSE 'Insufficient PSU wattage'
                END
            FROM gpus g, psus p
            WHERE (comp1_type = 'gpu' AND g.id = comp1_id AND p.id = comp2_id)
                OR (comp1_type = 'psu' AND p.id = comp1_id AND g.id = comp2_id)
        );
        
    -- Skip RAM compatibility checks
    ELSEIF (comp1_type = 'ram' AND comp2_type = 'motherboard') OR (comp1_type = 'motherboard' AND comp2_type = 'ram') THEN
        SET result = 'Compatible';

    -- Motherboard and Case compatibility check (based on size)
    ELSEIF (comp1_type = 'motherboard' AND comp2_type = 'case') OR (comp1_type = 'case' AND comp2_type = 'motherboard') THEN
        SET result = (
            SELECT 
                CASE 
                    WHEN m.form_factor = c.size THEN 'Compatible'
                    ELSE 'Size mismatch'
                END
            FROM motherboards m, cases c
            WHERE (comp1_type = 'motherboard' AND m.id = comp1_id AND c.id = comp2_id)
                OR (comp1_type = 'case' AND c.id = comp1_id AND m.id = comp2_id)
        );

    ELSE
        SET result = 'Unknown configuration';
    END IF;

    -- Handle NULL result (which could happen if IDs don't exist)
    RETURN COALESCE(result, 'Unknown configuration');
END//

DELIMITER ;

-- Update the get_compatible_parts stored procedure
DELIMITER //

DROP PROCEDURE IF EXISTS get_compatible_parts//
CREATE PROCEDURE get_compatible_parts(
    IN p_category VARCHAR(50),
    IN p_cpu_id INT,
    IN p_motherboard_id INT,
    IN p_ram_id INT,
    IN p_gpu_id INT,
    IN p_case_id INT,
    IN p_psu_id INT
)
BEGIN
    DECLARE table_name VARCHAR(50);
    DECLARE where_clause VARCHAR(1000) DEFAULT '';
    
    -- Set the table name based on the category
    SET table_name = p_category;
    
    -- Build WHERE clause based on existing components
    IF p_category = 'cpus' AND p_motherboard_id IS NOT NULL THEN
        SET where_clause = CONCAT(where_clause, 
            ' WHERE check_compatibility_fnn("cpu", id, "motherboard", ', p_motherboard_id, ') = "Compatible"');
    END IF;
    
    IF p_category = 'motherboards' THEN
        IF p_cpu_id IS NOT NULL THEN
            SET where_clause = CONCAT(where_clause, 
                IF(where_clause = '', ' WHERE ', ' AND '),
                'check_compatibility_fnn("motherboard", id, "cpu", ', p_cpu_id, ') = "Compatible"');
        END IF;
        IF p_ram_id IS NOT NULL THEN
            SET where_clause = CONCAT(where_clause,
                IF(where_clause = '', ' WHERE ', ' AND '),
                'check_compatibility_fnn("motherboard", id, "ram", ', p_ram_id, ') = "Compatible"');
        END IF;
        IF p_case_id IS NOT NULL THEN
            SET where_clause = CONCAT(where_clause,
                IF(where_clause = '', ' WHERE ', ' AND '),
                'check_compatibility_fnn("motherboard", id, "case", ', p_case_id, ') = "Compatible"');
        END IF;
    END IF;
    
    IF p_category = 'ram' AND p_motherboard_id IS NOT NULL THEN
        SET where_clause = CONCAT(where_clause,
            ' WHERE check_compatibility_fnn("ram", id, "motherboard", ', p_motherboard_id, ') = "Compatible"');
    END IF;
    
    IF p_category = 'gpus' AND p_psu_id IS NOT NULL THEN
        SET where_clause = CONCAT(where_clause,
            ' WHERE check_compatibility_fnn("gpu", id, "psu", ', p_psu_id, ') = "Compatible"');
    END IF;
    
    IF p_category = 'psus' AND p_gpu_id IS NOT NULL THEN
        SET where_clause = CONCAT(where_clause,
            ' WHERE check_compatibility_fnn("psu", id, "gpu", ', p_gpu_id, ') = "Compatible"');
    END IF;
    
    IF p_category = 'cases' AND p_motherboard_id IS NOT NULL THEN
        SET where_clause = CONCAT(where_clause,
            ' WHERE check_compatibility_fnn("case", id, "motherboard", ', p_motherboard_id, ') = "Compatible"');
    END IF;
    
    -- Execute the dynamic SQL
    SET @sql = CONCAT('SELECT * FROM ', table_name, where_clause);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END//

DELIMITER ;
