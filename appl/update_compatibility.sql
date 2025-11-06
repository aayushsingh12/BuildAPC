-- Drop the existing function
DROP FUNCTION IF EXISTS check_compatibility_fnn;

DELIMITER $$

-- Create the updated function
CREATE FUNCTION `check_compatibility_fnn`(
    comp1 VARCHAR(50),
    id1 INT,
    comp2 VARCHAR(50),
    id2 INT
) RETURNS varchar(50) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
    DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(50);

    IF comp1 = 'cpu' AND comp2 = 'motherboard' THEN
        SELECT 
            CASE 
                WHEN c.socket = m.socket THEN 'Compatible' 
                ELSE 'Incompatible' 
            END INTO result
        FROM cpus c
        JOIN motherboards m ON m.id = id2
        WHERE c.id = id1;

    ELSEIF comp1 = 'gpu' AND comp2 = 'psu' THEN
        SELECT 
            CASE 
                -- Changed logic: PSU wattage just needs to be >= GPU TDP
                WHEN p.watt >= g.tdp_w THEN 'Compatible' 
                ELSE 'Insufficient Power' 
            END INTO result
        FROM gpus g
        JOIN psus p ON p.id = id2
        WHERE g.id = id1;

    ELSEIF comp1 = 'motherboard' AND comp2 = 'case' THEN
        SELECT 
            CASE
                WHEN m.size = 'E-ATX' AND cs.size IN ('E-ATX') THEN 'Compatible'
                WHEN m.size = 'ATX' AND cs.size IN ('E-ATX','ATX') THEN 'Compatible'
                WHEN m.size = 'Micro-ATX' AND cs.size IN ('E-ATX','ATX','Micro-ATX') THEN 'Compatible'
                WHEN m.size = 'Mini-ITX' AND cs.size IN ('E-ATX','ATX','Micro-ATX','Mini-ITX') THEN 'Compatible'
                ELSE 'Incompatible'
            END INTO result
        FROM motherboards m
        JOIN cases cs ON cs.id = id2
        WHERE m.id = id1;
    END IF;

    RETURN COALESCE(result, 'Incompatible');
END$$

DELIMITER ;
