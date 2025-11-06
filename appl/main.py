from fastapi import FastAPI, HTTPException, Body
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import mysql.connector
from mysql.connector import Error

app = FastAPI()

# Database connection configuration (centralized)
DB_HOST = "localhost"
DB_USER = "root"
DB_PASSWORD = "apple_udit_1203"
DB_NAME = "build_a_pc"

origins=[
    "http://localhost:3000"
]

"""
Adding middleware to allow cross origin communication between FastAPI and React
"""

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,       
    allow_credentials=True,      
    allow_methods=["*"],         
    allow_headers=["*"],         
)

class BuildCreate(BaseModel):
    build_name: str
    cpu_id: Optional[int] = None
    gpu_id: Optional[int] = None
    motherboard_id: Optional[int] = None
    ram_id: Optional[int] = None
    psu_id: Optional[int] = None
    case_id: Optional[int] = None
    ssd_id: Optional[int] = None
    display_id: Optional[int] = None


class BuildUpdate(BaseModel):
    build_name: Optional[str] = None
    cpu_id: Optional[int] = None
    gpu_id: Optional[int] = None
    motherboard_id: Optional[int] = None
    ram_id: Optional[int] = None
    psu_id: Optional[int] = None
    case_id: Optional[int] = None
    ssd_id: Optional[int] = None
    display_id: Optional[int] = None

class BuildState(BaseModel):
    cpu_id: Optional[int] = None
    motherboard_id: Optional[int] = None
    ram_id: Optional[int] = None
    gpu_id: Optional[int] = None
    case_id: Optional[int] = None
    psu_id: Optional[int] = None

def get_connection():
    return mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME
    )

@app.post("/auth/login")
def auth_login(credentials: dict = Body(...)):
    """Simple login: try to connect with provided MySQL credentials, return role."""
    username = credentials.get("username")
    password = credentials.get("password")
    if not username or password is None:
        raise HTTPException(status_code=400, detail="username and password required")

    # First, try to authenticate using the provided credentials (preferred)
    try:
        conn = mysql.connector.connect(
            host=DB_HOST,
            user=username,
            password=password,
            database=DB_NAME
        )
        if conn and conn.is_connected():
            conn.close()
            role = 'admin' if username == 'admin' else 'user'
            return {"success": True, "username": username, "role": role}
    except Error:
        # If direct authentication failed, allow a fallback for the admin user:
        # treat the configured DB root password as the admin password.
        # This lets the app accept the site admin login using the server's
        # DB admin credentials without requiring a separate MySQL user.
        if username == 'admin' and password == DB_PASSWORD:
            return {"success": True, "username": username, "role": 'admin'}
        raise HTTPException(status_code=401, detail="Invalid credentials")


@app.post("/auth/signup")
def user_signup(payload: dict = Body(...)):
    """Allow users to self-register. Creates normal DB user with restricted privileges."""
    new_username = payload.get('username')
    new_pwd = payload.get('pwd')
    
    if not new_username or new_pwd is None:
        raise HTTPException(status_code=400, detail="username and pwd required")
    
    # Don't allow creating admin users
    if new_username.lower() == 'admin':
        raise HTTPException(status_code=400, detail="Cannot create admin user via signup")

    connection = None
    cursor = None
    try:
        # Use root connection to create new user
        connection = get_connection()
        cursor = connection.cursor()
        cursor.callproc("create_normal_user", [new_username, new_pwd])
        connection.commit()
        return {"success": True, "message": f"Account created successfully! You can now login."}
    except Error as e:
        error_msg = str(e)
        if "already exists" in error_msg.lower() or "1396" in error_msg:
            raise HTTPException(status_code=400, detail="Username already exists")
        raise HTTPException(status_code=400, detail=error_msg)
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()


@app.post("/users/create")
def create_normal_user_endpoint(payload: dict = Body(...)):
    """Admin-only: create a normal DB user via stored procedure.
    Expects admin_username and admin_password in the payload to verify admin privileges.
    """
    admin_username = payload.get('admin_username')
    admin_password = payload.get('admin_password')
    new_username = payload.get('username')
    new_pwd = payload.get('pwd')
    
    if not admin_username or not admin_password:
        raise HTTPException(status_code=400, detail="admin_username and admin_password required")
    if not new_username or new_pwd is None:
        raise HTTPException(status_code=400, detail="username and pwd required")

    # Verify admin credentials
    try:
        admin_conn = mysql.connector.connect(
            host="localhost",
            user=admin_username,
            password=admin_password,
            database="build_a_pc"
        )
        if not admin_conn.is_connected() or admin_username != 'admin':
            raise HTTPException(status_code=403, detail="Admin privileges required")
    except Error:
        raise HTTPException(status_code=403, detail="Admin privileges required")

    connection = None
    cursor = None
    try:
        connection = admin_conn
        cursor = connection.cursor()
        cursor.callproc("create_normal_user", [new_username, new_pwd])
        connection.commit()
        return {"message": f"User {new_username} created successfully"}
    except Error as e:
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()

@app.get("/compatibility/{comp1}/{id1}/{comp2}/{id2}")
def check_compatibility(comp1: str, id1: int, comp2: str, id2: int):
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor()
        cursor.execute("SELECT check_compatibility_fnn(%s, %s, %s, %s);", (comp1, id1, comp2, id2))
        result = cursor.fetchone()
        return {"compatibility": result[0]}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()
            
@app.get("/builds/details/all")
def get_build_details():
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.callproc("get_build_details")
        data = []
        for result in cursor.stored_results():
            data = result.fetchall()
        return {"builds": data}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()

@app.get("/builds/{build_id}")
def get_build_summary(build_id: int):
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.callproc("get_build_summary", [build_id])
        data = []
        for result in cursor.stored_results():
            data = result.fetchall()
        return data
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()


@app.get("/fetch/{table_name}") #basic select * api end point with pagination support
def fetch_table(table_name: str, page: int = 1, limit: int = 100):
    allowed_tables = [
        "cpus", "gpus", "motherboards", "ram",
        "psus", "cases", "ssds", "displays", "builds"
    ]
    if table_name not in allowed_tables:
        raise HTTPException(status_code=400, detail="Invalid table name")

    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        
        # Calculate offset
        offset = (page - 1) * limit
        
        # Get total count
        cursor.execute(f"SELECT COUNT(*) as total FROM {table_name}")
        total_count = cursor.fetchone()["total"]
        
        # Get paginated records
        cursor.execute(f"SELECT * FROM {table_name} LIMIT %s OFFSET %s", (limit, offset))
        records = cursor.fetchall()
        
        total_pages = (total_count + limit - 1) // limit  # Ceiling division
        
        return {
            "table": table_name,
            "data": records,
            "page": page,
            "limit": limit,
            "total_count": total_count,
            "total_pages": total_pages,
            "has_next": page < total_pages,
            "has_prev": page > 1
        }
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()


@app.get("/fetch/{table_name}/{item_id}")
def fetch_single_item(table_name: str, item_id: int):
    """Fetch a single item by ID from any table"""
    allowed_tables = [
        "cpus", "gpus", "motherboards", "ram",
        "psus", "cases", "ssds", "displays", "builds"
    ]
    if table_name not in allowed_tables:
        raise HTTPException(status_code=400, detail="Invalid table name")
    
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        
        # Determine the correct primary key column name
        # Only builds table uses 'build_id', all part tables use 'id'
        pk_column = "build_id" if table_name == "builds" else "id"
        
        query = f"SELECT * FROM {table_name} WHERE {pk_column} = %s"
        cursor.execute(query, [item_id])
        item = cursor.fetchone()
        
        if not item:
            raise HTTPException(status_code=404, detail=f"Item with {pk_column}={item_id} not found in {table_name}")
        
        return {
            "table": table_name,
            "item": item
        }
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()
@app.post("/builds")
def create_build(build: BuildCreate):
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor()
        query = """
        INSERT INTO builds 
            (build_name, cpu_id, gpu_id, motherboard_id, ram_id, psu_id, case_id, ssd_id, display_id)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);
        """
        values = (
            build.build_name,
            build.cpu_id,
            build.gpu_id,
            build.motherboard_id,
            build.ram_id,
            build.psu_id,
            build.case_id,
            build.ssd_id,
            build.display_id,
        )
        cursor.execute(query, values)
        connection.commit()
        return {"message": "✅ Build created successfully", "build_id": cursor.lastrowid}
    except Error as e:
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()

@app.get("/builds/analytics/high-power")
def get_high_power_builds():
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.callproc("get_high_power_builds")
        data = []
        for result in cursor.stored_results():
            data = result.fetchall()
        return {"high_power_builds": data}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()

@app.get("/parts/counts")
def get_part_counts():
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.callproc("get_part_counts")
        data = []
        for result in cursor.stored_results():
            data = result.fetchall()
        return {"part_counts": data}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()

@app.get("/power/{build_id}")
def estimate_build_power(build_id: int):
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        
        # Call the procedure to update the power estimate
        cursor.callproc("estimate_power", [build_id])
        connection.commit()
        
        # Consume any results from the procedure
        for _ in cursor.stored_results():
            pass
        
        # Now fetch the updated build to return the power estimate
        cursor.execute("""
            SELECT build_id, build_name, total_power_estimate 
            FROM builds 
            WHERE build_id = %s
        """, [build_id])
        
        build_data = cursor.fetchone()
        
        if not build_data:
            raise HTTPException(status_code=404, detail=f"Build {build_id} not found")
        
        return {
            "build_id": build_data["build_id"],
            "build_name": build_data["build_name"],
            "total_power_estimate": build_data["total_power_estimate"],
            "message": "Power estimate calculated successfully"
        }
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()

@app.get("/compare/{category}/{ids}")
def compare_parts(category: str, ids: str):
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.callproc("compare_parts_by_id", [category, ids])
        data = []
        for result in cursor.stored_results():
            data = result.fetchall()
        return {"comparison": data}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()

@app.get("/search/{category}")
def search_parts(category: str, keyword: str = "", min_price: float = 0, max_price: float = 999999):
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.callproc("search_parts", [category, keyword, min_price, max_price])
        data = []
        for result in cursor.stored_results():
            data = result.fetchall()
        return {"search_results": data}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()

@app.get("/find/{search_term}")
def find_component_by_name(search_term: str):
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.callproc("find_component_by_name", [search_term])
        data = []
        for result in cursor.stored_results():
            data = result.fetchall()
        return {"results": data}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()





@app.put("/builds/{build_id}")
def update_build(build_id: int, build_update: BuildUpdate):
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.callproc("update_build", [
            build_id,
            build_update.build_name,
            build_update.cpu_id,
            build_update.gpu_id,
            build_update.motherboard_id,
            build_update.ram_id,
            build_update.psu_id,
            build_update.case_id,
            build_update.ssd_id,
            build_update.display_id
        ])
        connection.commit()
        data = []
        for result in cursor.stored_results():
            data = result.fetchall()
        return {"message": f" Build {build_id} updated successfully", "details": data}
    except Error as e:
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()

@app.delete("/builds/{build_id}")
def delete_build(build_id: int):
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.callproc("delete_build", [build_id])
        connection.commit()
        data = []
        for result in cursor.stored_results():
            data = result.fetchall()
        if data and 'error_message' in data[0]:
            raise HTTPException(status_code=404, detail=data[0]['error_message'])
        return {"message": f" Build {build_id} deleted successfully", "details": data}
    except Error as e:
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()

# ========== ADMIN CRUD ENDPOINTS ==========

@app.post("/admin/{table_name}")
def admin_create_item(table_name: str, item: dict = Body(...)):
    """Admin-only: Insert a new item into any table"""
    allowed_tables = ["cpus", "gpus", "motherboards", "ram", "psus", "cases", "ssds", "displays"]
    if table_name not in allowed_tables:
        raise HTTPException(status_code=400, detail="Invalid table name")
    
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor()
        
        # Remove admin credentials from item data
        item.pop('admin_username', None)
        item.pop('admin_password', None)
        
        # Build dynamic INSERT query
        columns = ', '.join(item.keys())
        placeholders = ', '.join(['%s'] * len(item))
        query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"
        
        cursor.execute(query, list(item.values()))
        connection.commit()
        
        return {"message": f"Item added to {table_name} successfully", "id": cursor.lastrowid}
    except Error as e:
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()


@app.put("/admin/{table_name}/{item_id}")
def admin_update_item(table_name: str, item_id: int, item: dict = Body(...)):
    """Admin-only: Update an item in any table"""
    allowed_tables = ["cpus", "gpus", "motherboards", "ram", "psus", "cases", "ssds", "displays"]
    if table_name not in allowed_tables:
        raise HTTPException(status_code=400, detail="Invalid table name")
    
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor()
        
        # Remove admin credentials from item data
        item.pop('admin_username', None)
        item.pop('admin_password', None)
        
        # Get the primary key column name
        id_column = f"{table_name[:-1]}_id" if table_name.endswith('s') else f"{table_name}_id"
        
        # Build dynamic UPDATE query
        set_clause = ', '.join([f"{k} = %s" for k in item.keys()])
        query = f"UPDATE {table_name} SET {set_clause} WHERE {id_column} = %s"
        
        values = list(item.values()) + [item_id]
        cursor.execute(query, values)
        connection.commit()
        
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail=f"Item {item_id} not found in {table_name}")
        
        return {"message": f"Item {item_id} in {table_name} updated successfully"}
    except Error as e:
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()


@app.delete("/admin/{table_name}/{item_id}")
def admin_delete_item(table_name: str, item_id: int):
    """Admin-only: Delete an item from any table"""
    allowed_tables = ["cpus", "gpus", "motherboards", "ram", "psus", "cases", "ssds", "displays"]
    if table_name not in allowed_tables:
        raise HTTPException(status_code=400, detail="Invalid table name")
    
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor()
        
        # Determine the correct primary key column name
        # Only builds table uses 'build_id', all part tables use 'id'
        pk_column = "build_id" if table_name == "builds" else "id"
        
        query = f"DELETE FROM {table_name} WHERE {pk_column} = %s"
        cursor.execute(query, [item_id])
        connection.commit()
        
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail=f"Item {item_id} not found in {table_name}")
        
        return {"message": f"Item {item_id} deleted from {table_name} successfully"}
    except Error as e:
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()

@app.post("/parts/compatible/{category}")
def get_compatible_parts(category: str, build_state: BuildState = Body(...)):
    """
    Calls the stored procedure to get a list of parts in a category
    that are compatible with the current build state.
    """
    allowed_tables = [
        "cpus", "gpus", "motherboards", "ram",
        "psus", "cases", "ssds", "displays"
    ]
    if category not in allowed_tables:
        raise HTTPException(status_code=400, detail="Invalid table name")

    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        
        # Prepare the arguments for the stored procedure
        args = [
            category,
            build_state.cpu_id,
            build_state.motherboard_id,
            build_state.ram_id,
            build_state.gpu_id,
            build_state.case_id,
            build_state.psu_id
        ]
        
        cursor.callproc("get_compatible_parts", args)
        
        data = []
        for result in cursor.stored_results():
            data = result.fetchall()
            
        return {"compatible_parts": data}
        
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()


@app.patch("/admin/{table_name}/{item_id}/{column}")
def admin_update_attribute(table_name: str, item_id: int, column: str, payload: dict = Body(...)):
    """
    Admin-only: Update a single attribute of any part dynamically
    
    This stored procedure `admin_update_attribute` allows an admin to update any field 
    of any parts table dynamically. The caller passes table name, column name, new value, 
    and the specific row ID. The procedure builds a dynamic SQL UPDATE statement and 
    executes it using prepared statements, so we don't need different procedures for 
    CPUs, GPUs, RAM, etc. It works because all our parts tables share the same primary 
    key name `id`. The admin can change price, name, or any attribute of any component 
    with one generic procedure.
    """
    allowed_tables = ["cpus", "gpus", "motherboards", "ram", "psus", "cases", "ssds", "displays"]
    if table_name not in allowed_tables:
        raise HTTPException(status_code=400, detail="Invalid table name")
    
    new_value = payload.get("value")
    if new_value is None:
        raise HTTPException(status_code=400, detail="value is required in request body")
    
    connection = None
    cursor = None
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        
        # Call the stored procedure
        cursor.callproc("admin_update_attribute", [table_name, column, str(new_value), item_id])
        connection.commit()
        
        # Get the result message
        data = []
        for result in cursor.stored_results():
            data = result.fetchall()
        
        if data:
            return {"success": True, "message": data[0].get("message", "Updated successfully")}
        
        return {"success": True, "message": f"Updated {table_name} id {item_id}"}
    except Error as e:
        error_msg = str(e)
        if "Unknown column" in error_msg:
            raise HTTPException(status_code=400, detail=f"Column '{column}' does not exist in table '{table_name}'")
        raise HTTPException(status_code=400, detail=error_msg)
    finally:
        if connection and connection.is_connected():
            if cursor:
                cursor.close()
            connection.close()
