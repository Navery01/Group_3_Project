import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'recipes.dart';
import 'dart:convert';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        var appState = MyAppState();
        return appState;
      },
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Recipe Recommender',
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
            scaffoldBackgroundColor: const Color.fromRGBO(255, 255, 255, 0)),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List inventoryList = <Ingredient>[];
  Map<String, dynamic> recipeLibrary =
      {}; //access with AppState.recipeLibrary["id"].attribute
  List<String> filters = [];

  Future<void> writeToFile(String name, DateTime date) async {
    final file = File("lib/Ingredients.txt");
    if (await file.exists()) {
      var contents = await file.readAsLines();

      if (contents.last != "") {
        await file.writeAsString('\n', mode: FileMode.append);
      }
    }
    await file.writeAsString('$name,${date.toString()}\n',
        mode: FileMode.append);
    notifyListeners();
  }

  void deleteFromFile(int index) async {
    final file = File("lib/Ingredients.txt");
    List<String> lines = await file.readAsLines();

    if (index >= 0 && index < lines.length) {
      lines.removeAt(index);
      await file.writeAsString(lines.join('\n'));
      print('Line deleted successfully.');
    } else {
      print('Invalid line index.');
    }
  }

  void readFile() async {
    try {
      final file = File("lib/ingredients.txt");
      if (await file.exists()) {
        var contents = await file.readAsLines();
        if (contents.isNotEmpty) {
          inventoryList = contents.map((ingredientName) {
            var ingredient = Ingredient();
            var ingredientData = ingredientName.split(",");
            ingredient.name = ingredientData[0];
            ingredient.date = DateTime.parse(ingredientData[1]);
            return ingredient;
          }).toList();
        }
      }
    } catch (e) {
      print("Error reading file: $e");
    }
    notifyListeners();
  }

  void readRecipes() async {
    //fills a map (recipeLibrary) with recipes from the JSON database
    try {
      var file = File("jsonfile/db-recipes.json");

      if (await file.exists()) {
        String parseJSON = await file.readAsString();
        Map<String, dynamic> jsonMap = jsonDecode(parseJSON);

        jsonMap.keys.forEach((key) {
          recipes recipe = recipes.fromJSON(jsonMap[key]);
          recipeLibrary[key] = recipe;
        });
      }
      recipeLibrary.forEach((key, value) async {
        for (String tag in value.tags) {
          if (filters.contains(tag)) {
            continue;
          } else {
            filters.add(tag);
          }
        }
      });
    } catch (e) {
      print("error reading JSON file");
    }
    filters.sort(
      (a, b) => a.toString().compareTo(b.toString()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = RecipesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Recipe List'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: IngredientInputBox(),
          ),
          SizedBox(height: 10),
          SizedBox(
            child: IngredientShowcase(appState),
            height: MediaQuery.of(context).size.height - 66,
          ),
        ],
      ),
    );
  }

  Widget IngredientShowcase(MyAppState appState) {
    appState.readFile();
    if (appState.inventoryList.isEmpty) {
      return Center(
        child: Text(
          "You have no ingredients",
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      setState(() {});
      DateTime today = DateTime.now();
      List<Widget> ingredientListTiles = [];

      for (var ingredient in appState.inventoryList) {
        var formattedName = ingredient.name[0].toString().toUpperCase() +
            ingredient.name.toString().substring(1).toLowerCase();
        DateTime expirationDate = ingredient.date;
        Duration difference = expirationDate.difference(today);
        int expireDays = difference.inDays;
        bool isExpired = expirationDate.isBefore(DateTime.now());
        String expirationText =
            isExpired ? 'Expired' : 'Expires on ${expirationDate.toString()}';

        Widget ingredientTile = GestureDetector(
          onTap: () async {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "Delete ingredient?",
                      style: TextStyle(color: Colors.black),
                    ),
                    content: ElevatedButton(
                      child: Text("DELETE"),
                      onPressed: () async {
                        String delete = ingredient.name;
                        appState.deleteFromFile(appState.inventoryList
                            .indexWhere(
                                (ingredient) => ingredient.name == delete));
                        Navigator.pop(context);
                      },
                    ),
                  );
                });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              visualDensity: VisualDensity(horizontal: .5),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: getColor(expireDays),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              textColor: Color.fromRGBO(255, 255, 255, 1),
              title: Text(formattedName),
              subtitle: Text(expirationText),
            ),
          ),
        );
        ingredientListTiles.add(ingredientTile);
      }

      return Container(
        height: MediaQuery.of(context).size.height - 66,
        child: SingleChildScrollView(
          child: Column(
            children: ingredientListTiles,
          ),
        ),
      );
    }
  }

  Color getColor(int number) {
    if (number <= 0) {
      return Colors.red;
    } else if (number < 7) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }
}

class IngredientInputBox extends StatefulWidget {
  const IngredientInputBox({
    super.key,
  });

  @override
  State<IngredientInputBox> createState() => _IngredientInputBoxState();
}

class _IngredientInputBoxState extends State<IngredientInputBox> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    DateTime? selectedDate;
    return Container(
      color: Colors.black,
      width: 260,
      child: TextField(
        style: TextStyle(
          color: Color.fromRGBO(255, 255, 255, 1),
        ),
        autocorrect: true,
        decoration: InputDecoration(
            border: OutlineInputBorder(), labelText: "Enter Ingredients"),
        onSubmitted: (String ingredientName) async {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('When does the ${ingredientName} expire?'),
                  content: ElevatedButton(
                    child: Text('Select expiration date'),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      setState(() {
                        selectedDate = pickedDate;
                      });
                      DateTime? expirationDate = pickedDate;
                      appState.writeToFile(ingredientName, expirationDate!);

                      Navigator.of(context).pop();
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        appState.writeToFile(ingredientName, DateTime(2200));
                      },
                      child: const Text('No expiration'),
                    ),
                  ],
                );
              });
        },
      ),
    );
  }
} //Ingredientinput box

class RecipesPage extends StatefulWidget {
  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    appState.readFile();
    appState.readRecipes();

    if (appState.recipeLibrary.isEmpty) {
      return Center(
        child: Text(
          "You have no recipes",
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      List<Widget> recipeListTiles = [];

      appState.recipeLibrary.forEach((key, value) {
        String ing = value.ingredients.join(", ");

        Widget recipeTiles = GestureDetector(
          onTap: () async {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: Text(value.name),
                      content: SingleChildScrollView(
                        child: ListBody(children: [
                          RichText(
                            text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                    text: "Ingredients\n",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  TextSpan(
                                    text:
                                        "${value.ingredients.toString().substring(1, value.ingredients.toString().length - 1).replaceAll(",", "\n")} \n",
                                  ),
                                  TextSpan(
                                      text: "Instructions\n",
                                      style: TextStyle(fontSize: 20)),
                                  TextSpan(
                                      text:
                                          "${value.instructions.toString().replaceAll(",", "\n")} \n"),
                                  TextSpan(
                                      text: "Nutrition Facts\n",
                                      style: TextStyle(fontSize: 20)),
                                  TextSpan(
                                      text:
                                          "Servings: ${value.servings.toString()} \n"
                                          "Calories: ${value.calories.toString()} \n"
                                          "Fat: ${value.fat.toString()}g \n"
                                          "Saturated Fat: ${value.satfat.toString()}g \n"
                                          "Carbohydrates: ${value.carbs.toString()}g \n"
                                          "Fiber: ${value.fiber.toString()}g \n"
                                          "Sugar: ${value.sugar.toString()}g \n"
                                          "Protein: ${value.protein.toString()}g \n"),
                                ]),
                          )
                        ]),
                      ));
                });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              visualDensity: VisualDensity(horizontal: .5),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              textColor: Color.fromRGBO(255, 255, 255, 1),
              title: Text(value.name),
              subtitle: Text(ing),
            ),
          ),
        );
        if (checkIngredients(
            value.ingredients, appState, selectedOption, value.tags)) {
          recipeListTiles.add(recipeTiles);
        }
      });

      List<DropdownMenuItem<String>> dropdownItems = [];
      for (String tag in appState.filters) {
        var newItem = DropdownMenuItem(
          value: tag,
          child: Text(
            tag,
            style: TextStyle(color: Colors.white),
          ),
        );
        dropdownItems.add(newItem);
      }

      return Column(
        children: [
          Center(
            child: DropdownButton<String>(
              dropdownColor: Colors.black,
              items: dropdownItems,
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                });
              },
              value: selectedOption,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: recipeListTiles,
              ),
            ),
          ),
        ],
      );
    }
  }

  bool checkIngredients(List<dynamic> Ilist, MyAppState appState,
      String? currentTag, List<dynamic> tags) {
    bool hasTag = currentTag == null || tags.contains(currentTag);
    int matches = 0;

    for (String recipeItem in Ilist) {
      for (var kitchenItem in appState.inventoryList) {
        if (recipeItem
            .toUpperCase()
            .contains(kitchenItem.name.toString().toUpperCase())) {
          matches += 1;
          break;
        }
      }
    }

    return matches >= Ilist.length && hasTag;
  }
}

class Ingredient {
  String _name = "";

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  DateTime _date = DateTime.now();

  DateTime get date => _date;

  set date(DateTime value) {
    _date = value;
  }

  int _quantity = 0;

  int get quantity => _quantity;

  set quantity(int value) {
    _quantity = value;
  }
}
