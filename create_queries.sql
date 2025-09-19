-- Create database
CREATE DATABASE IF NOT EXISTS BuildAPC;

-- Switch to database
USE BuildAPC;


-- MOTHERBOARD table
CREATE TABLE MOTHERBOARD (
    motherboard_id VARCHAR(50) PRIMARY KEY,
    motherboard_name VARCHAR(100),
    motherboard_price DECIMAL(10,2),
    color VARCHAR(50),
    memory_slots INT
);

-- CASE table (escaped since CASE is reserved)
CREATE TABLE `CASE` (
    case_id VARCHAR(50) PRIMARY KEY,
    case_name VARCHAR(100),
    case_price DECIMAL(10,2),
    case_color VARCHAR(50),
    side_panel VARCHAR(50)
);

-- Form_Factor table (bridge between CASE and MOTHERBOARD)
CREATE TABLE Form_Factor (
    case_id VARCHAR(50),
    motherboard_id VARCHAR(50),
    form_factor_type VARCHAR(50),
    PRIMARY KEY (case_id, motherboard_id),
    FOREIGN KEY (case_id) REFERENCES `CASE`(case_id),
    FOREIGN KEY (motherboard_id) REFERENCES MOTHERBOARD(motherboard_id)
);

-- CPU table
CREATE TABLE CPU (
    cpu_id VARCHAR(50) PRIMARY KEY,
    cpu_name VARCHAR(100),
    cpu_price DECIMAL(10,2),
    clock DECIMAL(5,2),
    threads INT
);

-- Socket table (bridge between CPU and MOTHERBOARD)
CREATE TABLE Socket (
    cpu_id VARCHAR(50),
    motherboard_id VARCHAR(50),
    socket_type VARCHAR(50),
    PRIMARY KEY (cpu_id, motherboard_id),
    FOREIGN KEY (cpu_id) REFERENCES CPU(cpu_id),
    FOREIGN KEY (motherboard_id) REFERENCES MOTHERBOARD(motherboard_id)
);

-- GPU table
CREATE TABLE GPU (
    gpu_id VARCHAR(50) PRIMARY KEY,
    gpu_name VARCHAR(100),
    gpu_price DECIMAL(10,2),
    gpu_color VARCHAR(50),
    vram VARCHAR(50)
);

-- PSU table
CREATE TABLE PSU (
    psu_id VARCHAR(50) PRIMARY KEY,
    psu_name VARCHAR(100),
    psu_color VARCHAR(50),
    efficiency VARCHAR(50)
);

-- Wattage table (bridge between GPU and PSU)
CREATE TABLE Wattage (
    gpu_id VARCHAR(50),
    psu_id VARCHAR(50),
    wattage_value DECIMAL(10,2),
    PRIMARY KEY (gpu_id, psu_id),
    FOREIGN KEY (gpu_id) REFERENCES GPU(gpu_id),
    FOREIGN KEY (psu_id) REFERENCES PSU(psu_id)
);

-- RAM table
CREATE TABLE RAM (
    ram_id VARCHAR(50) PRIMARY KEY,
    ram_name VARCHAR(100),
    ram_price DECIMAL(10,2),
    ram_speed INT
);

-- SSD table
CREATE TABLE SSD (
    ssd_id VARCHAR(50) PRIMARY KEY,
    ssd_name VARCHAR(100),
    protocol VARCHAR(50),
    ssd_form VARCHAR(50)
);

-- MONITOR table
CREATE TABLE MONITOR (
    monitor_id VARCHAR(50) PRIMARY KEY,
    monitor_name VARCHAR(100),
    refresh_rate INT
);
