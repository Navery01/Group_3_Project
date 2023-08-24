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
        print(len(result[i]))



    List_of_recipes = []
    for i in result:
        recipe = Recipe(i[0], i[1], i[2], i[3], i[4], i[5], i[6], i[7], i[8], i[9], i[10], i[11], i[12], i[13], i[14], i[15])
        recipe_dict = {'id': recipe.id,
                       'name': recipe.name,
                       'source': recipe.source,
                       'preptime': recipe.preptime,
                       'waittime': recipe.waittime,
                       'cooktime': recipe.cooktime,
                       'servings': recipe.servings,
                       'comments': recipe.comments,
                       'calories': recipe.calories,
                       'fat': recipe.fat,
                       'satfat': recipe.satfat,
                       'carbs': recipe.carbs,
                       'fiber': recipe. fiber,
                       'sugar': recipe.sugar,
                       'protein': recipe.protein,
                       'instructions': recipe.instructions,
                       'ingredients': recipe.ingredients,
                       'tags': recipe.tags
                       }
        List_of_recipes.append(recipe_dict)
    cursor.close()
    conn.close()

    # return jsonify(List_of_recipes)

pullFromDB()
# if __name__ == '__main__':
#     app.run(debug=True)
#     pullFromDB()