from flask import Flask, jsonify
import mysql.connector
import os 

app = Flask(__name__)

# MariaDB Configuration
db_config = {
    "host": "localhost",  # Keeping it as 'localhost' based on your Node.js app
    "user": os.getenv("DB_ROOT_USERNAME"),
    "password": os.getenv("DB_ROOT_PWORD"),
    "database": os.getenv("DB_DB")   # Change this
}

# Function to connect to the database
def get_db_connection():
    return mysql.connector.connect(**db_config)

# API Route to fetch player data
@app.route('/players', methods=['GET'])
def get_players():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)  # Returns rows as dicts
    cursor.execute("SELECT * FROM players")
    players = cursor.fetchall()
    conn.close()
    
    return jsonify(players)  # Returns JSON

# Run the Flask server
if __name__ == '__main__':
    app.run(debug=True, port=5000)  # Runs on http://localhost:5000
