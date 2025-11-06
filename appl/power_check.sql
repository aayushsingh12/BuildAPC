-- Drop existing functions and triggers
DROP FUNCTION IF EXISTS check_power_compatibility;
DROP FUNCTION IF EXISTS check_compatibility_fnn;
DROP TRIGGER IF EXISTS trg_validate_build_compatibilityy;

DELIMITER $$

CREATE FUNCTION check_power_compatibility(
    gpu_id INT,
    psu_id INT
) RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE gpu_power INT;
    DECLARE psu_power INT;
    DECLARE result VARCHAR(255);

    -- Get GPU power requirement
    SELECT tdp_w INTO gpu_power
    FROM gpus
    WHERE id = gpu_id;

    -- Get PSU wattage
    SELECT watt INTO psu_power
    FROM psus
    WHERE id = psu_id;

    -- Check compatibility and return appropriate message
    IF gpu_power IS NULL OR psu_power IS NULL THEN
        RETURN 'Error: Missing power information';
    END IF;

    IF psu_power >= gpu_power THEN
        SET result = CONCAT('Compatible: PSU (', psu_power, 'W) is sufficient for GPU (', gpu_power, 'W)');
    ELSE
        SET result = CONCAT('Insufficient Power: GPU requires ', gpu_power, 'W but PSU only provides ', psu_power, 'W');
    END IF;

    RETURN result;
END$$

DELIMITER ;

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS check_compatibility_fnn;

DELIMITER $$

CREATE FUNCTION `check_compatibility_fnn`(
    comp1 VARCHAR(50),
    id1 INT,
    comp2 VARCHAR(50),
    id2 INT
) RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
    DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(255);

    IF comp1 = 'cpu' AND comp2 = 'motherboard' THEN
        SELECT 
            CASE 
                WHEN c.socket = m.socket THEN 'Compatible' 
                ELSE CONCAT('Incompatible: CPU socket ', c.socket, ' does not match motherboard socket ', m.socket)
            END INTO result
        FROM cpus c
        JOIN motherboards m ON m.id = id2
        WHERE c.id = id1;

    ELSEIF comp1 = 'gpu' AND comp2 = 'psu' THEN
        -- Use our new power check function
        SELECT check_power_compatibility(id1, id2) INTO result;

    ELSEIF comp1 = 'motherboard' AND comp2 = 'case' THEN
        SELECT 
            CASE
                WHEN m.size = 'E-ATX' AND cs.size IN ('E-ATX') THEN 'Compatible'
                WHEN m.size = 'ATX' AND cs.size IN ('E-ATX','ATX') THEN 'Compatible'
                WHEN m.size = 'Micro-ATX' AND cs.size IN ('E-ATX','ATX','Micro-ATX') THEN 'Compatible'
                WHEN m.size = 'Mini-ITX' AND cs.size IN ('E-ATX','ATX','Micro-ATX','Mini-ITX') THEN 'Compatible'
                ELSE CONCAT('Incompatible: ', m.size, ' motherboard does not fit in ', cs.size, ' case')
            END INTO result
        FROM motherboards m
        JOIN cases cs ON cs.id = id2
        WHERE m.id = id1;
    END IF;

    RETURN COALESCE(result, 'Incompatible: Unknown configuration');
END$$

DELIMITER ;
