import psycopg2


def connect_to_postgres():
    """ Connects to the PostgreSQL database running in the 'db' container """
    try:
        # Connect to the PostgreSQL database
        connection = psycopg2.connect(
            host="db",           
            database="postgres",
            user="postgres",     
            password="postgres"  
        )

        # Create a cursor object
        cursor = connection.cursor()

        return connection, cursor

    except Exception as error:
        print(f"Error connecting to PostgreSQL: {error}")
        return None, None


def create_table(cursor):
    """ Creates a 'users' table in the connected PostgreSQL database """
    try:
        # SQL command to create a new table
        create_table_query = '''
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            email VARCHAR(100),
            age INT
        );
        '''
        cursor.execute(create_table_query)
        print("Table 'users' created successfully!")

    except Exception as error:
        print(f"Error creating table: {error}")


def insert_data(cursor, connection):
    """ Inserts sample data into the 'users' table """
    try:
        # SQL command to insert data
        insert_query = '''
        INSERT INTO users (name, email, age)
        VALUES
        ('Alice', 'alice@example.com', 30),
        ('Bob', 'bob@example.com', 25),
        ('Charlie', 'charlie@example.com', 35);
        '''
        cursor.execute(insert_query)
        connection.commit()  # Commit the transaction
        print("Data inserted successfully!")

    except Exception as error:
        print(f"Error inserting data: {error}")


def query_data(cursor):
    """ Queries and prints the data from the 'users' table """
    try:
        # SQL command to fetch all rows from the table
        query = "SELECT * FROM users;"
        cursor.execute(query)
        rows = cursor.fetchall()

        print("\nData from 'users' table:")
        print("ID | Name    | Email               | Age")
        print("-----------------------------------------")
        for row in rows:
            print(f"{row[0]}  | {row[1]:<8} | {row[2]:<20} | {row[3]}")

    except Exception as error:
        print(f"Error querying data: {error}")


def check_postgres_version():
    """ Checks and prints the PostgreSQL version """
    connection, cursor = connect_to_postgres()

    if connection is None or cursor is None:
        print("Failed to connect to the database.")
        return

    try:
        # Execute a query to get the PostgreSQL version
        cursor.execute("SELECT version();")

        # Fetch and display the version
        version = cursor.fetchone()
        print(f"PostgreSQL version: {version[0]}")

    except Exception as error:
        print(f"Error checking PostgreSQL version: {error}")

    finally:
        # Close the cursor and connection
        if cursor:
            cursor.close()
        if connection:
            connection.close()


def main():
    # Step 1: Connect to PostgreSQL
    connection, cursor = connect_to_postgres()
    if connection is None or cursor is None:
        return

    # Step 1.5: Check PostgreSQL's version:
    check_postgres_version()
    # Step 2: Create table
    create_table(cursor)

    # Step 3: Insert data into the table
    insert_data(cursor, connection)

    # Step 4: Query and display the data
    query_data(cursor)

    # Step 5: Close the connection
    cursor.close()
    connection.close()
    print("\nConnection closed.")


if __name__ == "__main__":
    main()
