import pymysql

# Connect to the database
conn = pymysql.connect(
    host='127.0.0.1',
    port=3306,
    user='ibmroot',
    password='your_password',
    database='ibmSLG'
)

cursor = conn.cursor()

# Fetch data
cursor.execute("SELECT * FROM MCQ")
rows = cursor.fetchall()

# Print data
for row in rows:
    print(row)

# Close connection
conn.close()
