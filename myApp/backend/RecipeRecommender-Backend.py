from flask import Flask, jsonify, request
import mysql.connector

app = Flask(__name__)

class Recipe:
    def __init__(self,id, name, source, preptime, waittime, cooktime, servings, comments, calories, fat, satfat, carbs, fiber, sugar, protein, instructions, ingredients, tags):
        self.tags = tags
        self.ingredients = ingredients
        self.instructions = instructions
        self.protein = protein
        self.sugar = sugar
        self.fiber = fiber
        self.carbs = carbs
        self.satfat = satfat
        self.fat = fat
        self.calories = calories
        self.comments = comments
        self.servings = servings
        self.cooktime = cooktime
        self.waittime = waittime
        self.preptime = preptime
        self.source = source
        self.id = id
        self.name = name

@app.route('/items', methods=['GET'])
def pullFromDB():
    conn = mysql.connector.connect(
    host = 'rds-mysql-reciperecommender.cgbtkemymwhi.us-east-2.rds.amazonaws.com',
    user='admin',
    password='Dallas2011',
    database='Recipes'
    )

    cursor = conn.cursor()
    query = '''
    SELECT 
        r.*,
        GROUP_CONCAT(DISTINCT i.ingredient) AS ingredients,
        GROUP_CONCAT(DISTINCT t.tag) AS tags
    FROM Recipes r
    LEFT JOIN ingredients i ON r.id = i.recipeId
    LEFT JOIN tags t ON r.id = t.recipeId
    GROUP BY r.id;
    '''
    cursor.execute(query)
    result = cursor.fetchall()

    List_of_recipes = [
        {'id': row[0],
         'name': row[1],
         'source': row[2],
         'preptime': row[3],
         'waittime': row[4],
         'cooktime': row[5],
         'servings': row[6],
         'comments': row[7],
         'calories': row[8],
         'fat': row[9],
         'satfat': row[10],
         'carbs': row[11],
         'fiber': row[12],
         'sugar': row[13],
         'protein': row[14],
         'instructions': row[15],
         'ingredients': row[16].split(","),
         'tags': row[17] if row[16] else []} for row in result]

    cursor.close()
    conn.close()

    return jsonify(List_of_recipes)

if __name__ == '__main__':
    app.run(debug=True)