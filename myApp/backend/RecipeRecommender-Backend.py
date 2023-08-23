from flask import Flask, jsonify, request
import mysql.connector

app = Flask(__name__)

class Recipe(id):
    def __init__(self):
        self.id = id

@app.route('/items', methods=['GET'])
def pullFromDB():
    conn = mysql.connector.connect(
    host = 'rds-mysql-reciperecommender.cgbtkemymwhi.us-east-2.rds.amazonaws.com',
    user='admin',
    password='Dallas2011',
    database='Recipes'
    )

    cursor = conn.cursor()
    query = 'SELECT * FROM Recipes'
    cursor.execute(query)
    result = cursor.fetchall()

    query = 'SELECT * FROM ingredients'

    cursor.execute(query)
    result2 = cursor.fetchall()
    ingredientDict = {}
    for i in range(len(result2) - 1):
        group_id = result2[i][0]
        ingredient = result2[i][1]

        if group_id not in ingredientDict:
            ingredientDict[group_id] = []

        ingredientDict[group_id].append(ingredient)

    for i in range(1, len(result)):
        ingTuple = (ingredientDict[i],)
        temp = result[i] + ingTuple
        result[i] = temp


    cursor.close()
    conn.close()
    print(result[1])

    # return jsonify(result)

pullFromDB()
# if __name__ == '__main__':
#     app.run(debug=True)
#     pullFromDB()