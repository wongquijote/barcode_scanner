import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Uncomment this line
import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(CameraApp());
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BarcodeScannerScreen(), // Changed to BarcodeScannerScreen()
    );
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool isScanning = true;
  String scannedCode = '';
  String productName = '';

  final Map<String, String> productDatabase = {'0050000397600': '(2 Pack) NESTLE Mini Marshmallows Hot Cocoa Mix 6-0.71 Oz. Packets', '0076808501087': '(4 Pack) Barilla Pasta Farfalle, 1.0 LB', '0078000052404': '(6 Pack) a&W Root Beer, 20 Fl Oz', '4974152010162': '110g北海道地図布バター飴', '0099482413026': '365 Coarse Sea Salt 24.7 Ounce', '0099482400064': '365 Extra Virgin Mediterranean Olive Oil 33.8 Fl Oz', '0099482412463': '365 Medium Cheddar Cheese 8 Oz', '0099482491017': '365 Mild Cheddar Cheese Shreds 8 Oz', '0099482447045': '365 Semi-Sweet Chocolate Chips 12 Oz', '0099482488673': '365 Sharp Cheddar Cheese Slices 10 Slices', '0078000012194': '7UP Lemon Lime Soda Bottles - 6pk/16.9 fl oz', '0078000052428': 'A&W Root Beer - 16.9 Fl Oz X 6 Pack', '0813267020014': 'A2 Milk 2% Vitamin a & D Ultra-Pasteurized - 59 Fl Oz', '0041570056172': 'Almond Breeze Original Almond Milk 64 Oz', '0646437482202': "Anthony's Erythritol Granules Keto & Paleo Friendly 2.5 Lb", '0033200011309': 'Arm & Hammer Pure Baking Soda 8 Oz Box', '0030000659700': 'Aunt Jemima Original Syrup, 24 Oz', '0033844000011': 'Badia Garlic Powder 10.5 Oz', '4099100178401': "Baker's Corner Funnel Cakes Pitcher and Mix", '0076808535600': 'Barilla Classic Blue Box Pasta Mini Penne 16 Oz', '0076808003918': 'Barilla Gluten Free Elbows Pasta - 12oz', '0076808006254': 'Barilla Gluten Free Fettuccine Pasta - 12oz', '0076808003895': 'Barilla Gluten Free Penne Pasta - 12oz', '0076808003888': 'Barilla Gluten Free Spaghetti Pasta - 12oz', '0076808535570': 'Barilla Pasta Mini Farfalle, 16 Oz', '0076808280739': 'Barilla Penne - 16.0 Oz', '0076808502947': 'Barilla Rigatoni - 16oz', '0076808280081': 'Barilla Spaghetti - 1lbs, Pasta, Rice and Grains', '0076808006520': 'Barilla Whole Grain Elbows Pasta - 12oz', '0076808005844': 'Barilla Whole Grain Spaghetti Pasta - 16oz', '0706010112923': 'Barilla® Classic Marinara Tomato Pasta Sauce 24 Oz', '4099100052060': 'Beaumont Instant Classic Roast', '0031142523850': 'BelGioioso Parmesan Wedge 8 Oz', '4099100025392': 'Berryhill Chocolate Flavored Syrup', '0039978115904': "Bob's Red Mill Honey Almond Granola, 12 Oz", '4061462249167': 'Boulder Aluminum Foil', '4099100188394': 'Boulder Classic Paper Towels (2 Rolls)', '4099100127263': 'Boulder cups (50 count)', '4099100244694': 'Boulder Everyday Plate (50 count)', '4099100013290': 'Boulder freezer quart bags (40 count)', '4099100127096': 'Boulder Premium Napkin (100 count)', '4099100235500': 'Boulder Storage Gallon Bags (40 count)', '4099100085563': 'Boulder Ultra Paper Towels (2 rolls)', '4099100081794': 'Brookdale Premium Quality Corned Beef', '0088194340614': 'Brown Cow Whole Milk Yogurt Vanilla', '0079373000139': 'Bundaberg Ginger Beer - 4pk/375ml Bottles', '4099100111989': "Burman's Honey Mustard", '0015800030621': 'C&H Premium Pure Cane Granulated Sugar 4 LB', '0015800062325': 'C&H Pure Cane Granulated Golden Brown Sugar 2 LB', '0051000212443': "Campbell's Condensed 98% Fat Free Family Size Cream Of Mushroom Soup - 22.6 oz Can", '0051000212436': "Campbell's Condensed Family Size Cream of Chicken Soup - 22.6oz Can", '0051000212399': "Campbell's Condensed Family Size Tomato Soup - 23.2oz", '0051000061973': "Campbell's Condensed Healthy Request Chicken with Rice Soup - 10.5oz", '0051000060075': "Campbell's Condensed Healthy Request Cream of Mushroom Soup - 10.5oz Can", '0051000010315': "Campbell's Cream of Chicken Soup", '0051000149824': "Campbell's Soup at Hand, Chicken Noodle Soup, 10.75 Oz", '0051000012517': "Campbell's Soup, Condensed Chicken Noodle, 10.75 Oz", '0051000115539': "Campbell's® Condensed 98% Fat Free Cream of Chicken Soup, 10.5 oz Can", '0051000015273': "Campbell's® Condensed Condensed Cream of Chicken & Mushroom Soup", '0051000012616': "Campbell's® Condensed Condensed Cream of Mushroom Soup, 10.5 oz Can", '0078000001174': 'Canada Dry Ginger Ale - 16.9 Fl Oz X 6 Pack', '4099100297324': 'Carlini Butter Flavored Spray', '0021908743325': 'Cascadian Farm Organic Maple Brown Sugar Granola 15 Oz', '0024100104451': 'Cheez-It Grooves Crunchy Cheese Snack Crackers Original Cheddar - 9.0 Oz', '0024100594757': 'Cheez-It Grooves, Sharp White Cheddar - 9 Oz', '0024100115761': 'Cheez-it Scorchin Hot Grooves - 9oz', '0024100594733': 'Cheez-It Zesty Cheddar Ranch Grooves Crispy Cracker Chips - 9oz', '0044000030490': 'Chicken in a Biskit Original Baked Snack Crackers, 7.5 Oz', '0044000032234': 'Chips Ahoy! Chewy Chocolate Chip Cookies - 13oz', '4099100141894': 'Choceur Raisin & Nut', '0019900003202': 'Clabber Girl Double Acting Baking Powder 8.1 Oz', '4099100067453': "Clancy's Nacho Cheddar Veggie Straws", '4099100067132': "Clancy's Nacho Cheese Flavored Tortilla Chips", '4099100066661': "Clancy's Ridged Cheddar & Sour Cream Potato Chips", '4099100142037': "Clancy's Snack Combo", '4099100072488': "Clancy's Stackerz Cheddar Cheese Potato Crisps", '0722252187284': 'CLIF Whole Lotta Salted Dark Chocolate Nutrition Bar', '0070852994550': 'Clover Sonoma Organic Eggs Large Brown 18 Eggs', '0070852000091': 'Clover Stornetta Farms Vitamin D Milk Gallon', '0049000005226': 'Coca-Cola Soda Soft Drink - 1 Liter', '0684758408808': 'Coconut Beach 100% Coconut Water 16.5 Fl. Oz. Can', '0196005243952': 'Crisco Pure Vegetable Oil 16 Fl Oz', '4550480196305': 'Daiso Hammock', '0024000010920': 'Del Monte Fruit Cocktail Heavy Syrup Canned Fruit 30 Oz Can', '0024000021421': 'Del Monte Sliced Yellow Cling Peaches in Heavy Syrup, 8.5 Oz', '0850036804734': 'Del Pacifico 31/40 Peeled & Deveined Blue Shrimp 12 Oz', '0064144021833': "Dennison's 98% Fat Free Turkey Chili with Beans - 15oz", '0064144021116': "Dennison's No Beans Chili Con Carne - 15oz", '0064144021178': "Dennison's Original Chili Con Carne with Beans 40 Ounce", '0304067321697': 'Diamond Crystal Kosher Salt Flakes 1 Pound Box', '0038900001438': 'Dole Pineapple Slices in 100% Pineapple Juice 20 Oz. Can', '0786173971155': 'Domino Pure Cane Dark Brown Sugar 1 LB', '0049200902936': 'Domino White Sugar Pure Cane Sugar 12 Oz Flip Top', '0024182002539': 'Eden Foods Organic Black Beans 15 Oz', '0762357990327': 'Evolution Fresh Cold-Pressed Organic Orange Juice 32 Fl. Oz. Bottle', '0762357375209': 'Evolution Fresh Organic Essential Greens Juice, 32 Fl Oz', '0762357059611': 'Evolution Fresh, Cold-pressed High Pressure Processed Organic Apple Juice, Organic Apple', '0613008724221': 'Ferolito Vultaggio & Sons Arizona Green Tea, 16 Oz', '0632565000104': 'FIJI Natural Artesian Water - 6pk/1L Bottles', '0632565000012': 'Fiji Water, 16.9 Oz', '0070690015233': "Fisher Chef's Naturals Chopped Walnuts 2 LB", '0070690023641': "Fisher Chef's Naturals Walnut Halves & Pieces 10 Oz", '0603084294954': 'Garnier Fructis Volume Extend Instant Bodifier Dry Shampoo Orange Citrus & Grape Extract, 3.4 Oz', '0015000020729': 'Gerber 100% White Grape Juice 32 Fl Oz bottle', '0747599619137': 'Ghirardelli 60% Cacao Bittersweet Chocolate Premium Baking Chips 20 Oz Bag', '0688267024160': 'Giant Foods Whole Kernel Golden Corn', '0016000106109': 'Gold medal All Purpose Flour 5 LB', '8809094847186': 'Gosohan Green Tea Roasted Seasoned Seaweed 70g', '4099100184631': 'Great Gherkins Bread & Butter Chips', '0078742434032': 'Great Value Sugar Cannister 20 Oz', '0078742016030': 'Great Value Sweet Cream Salted Butter 16 Oz', '0078742016047': 'Great Value Sweet Cream Unsalted Butter 16 Oz', '0041152102730': 'Grown Right Organic Strawberry Lemonade', '0722430200484': "GT'S Living Foods Organic & Raw Gingerade Kombucha 48 Oz", '0722430210162': "GT's Synergy Organic Kombucha Grape Chia, 16.0 FL OZ", '0722430400167': "GT'S Synergy Organic Strawberry Serenity Kombucha, 16 Fl. Oz.", '4099100134797': 'Happy Harvest Fire Roasted Diced Tomatos', '0034000052011': "Hershey's Natural Unsweetened Cocoa Powder 8 Oz Can", '0034000148301': "Hershey's Semi Sweet Chocolate Baking Chips Bag 12 Oz", '0625691650039': 'Hippie Snacks Avocado Crisps Guacamole 2.5 Oz', '0742365264979': 'Horizon Organic Whole Milk with DHA Omega-3 Half Gallon', '0836093012077': 'IZZE Sparkling Apple Juice Beverage 4-8.4 Fl. Oz. Cans', '0836093011056': 'IZZE Sparkling Juice, Clementine, 8.4 Oz Cans, 24 Count', '0024105511056': 'Just Bare USDA Organic Fresh Chicken Breast Fillets 1.0 LB', '0012822009062': 'Kadoya Pure Sesame Oil 11 Fl Oz', '0038000198861': "Kellogg's Froot Loops, Original - 10.1 Oz", '0041335000983': "Ken's Steak House Lite Northern Italian with Basil and Romano Salad Dressing - 16fl Oz", '0767707002149': 'Kerrygold Grass-Fed Pure Irish Salted Butter Sticks 8 Oz (2 Sticks)', '0041390002953': 'Kikkoman Smooth Aromatic Soy Sauce 6.8 Fl Oz', '0071012010509': 'King Arthur All Purpose Unbleached Flour Certified Kosher 5 LB', '0021000054930': 'Kraft Finely Shredded Natural Parmesan Cheese 6 Oz Pouch', '0021000615414': 'Kraft Parmesan & Romano Grated Cheese 8 Oz Shaker', '0044300125117': 'La Choy Kosher Soy Sauce 15 Oz', '0843076000228': 'Lakanto Classic Monk Fruit Sweetener with Erythritol 1 Lb', '0034500636117': 'Land O Lakes Heavy Whipping Cream 1 Pint', '0028400199636': "Lay's Sour Cream & Onion Flavored Potato Chips - 7.75oz", '0028400043304': "Lay's Wavy Ranch Flavored Potato Chips - 7.75oz", '4099100016796': 'Little Journey Small Strides Diapers Size 6 (21 count)', '0040000497523': "M&M's Milk Chocolate Candy 3.1 Oz", '0017400105136': 'Mahatma Authentic Spanish Rice Mix, 5 Oz', '0074683003283': 'Maple Grove Farms Pure Maple Syrup 8.5 Oz', '0786173761343': 'McCormick All Natural Pure Vanilla Extract 1 Fl Oz', '0052100030654': 'McCormick Black Peppercorn Grinder 2.5 Oz', '0052100038353': 'McCormick Crushed Red Pepper 4.62 Oz', '0052100038209': 'McCormick Dark Chili Powder 7.5 Oz', '0052100043470': 'McCormick Fine Ground Mediterranean Sea Salt 28.25 Oz', '0052100038223': 'McCormick Garlic Powder 8.75 Oz', '0052100038070': 'McCormick Ground Cumin 4.5 Oz', '0052100043463': 'McCormick Organic Pure Ground Black Pepper 12 Oz', '4549131255027': 'Medium Spicy Daiso Select Japanese Curry Tablet 140g', '4099100264029': 'Millville Butter Syrup', '4099100020809': 'Millville Honey Grahams Cereal', '4099100056761': 'Millville Honey Wheat Puffs', '4099100280753': 'Millville Raisin Bran', '0040811070502': 'Molina Mexican Vanilla Blend Extract - Original 8.3 Fl Oz', '0024600010436': 'Morton Iodized Salt Shakers (2 count)', '0014800002300': "Mott's 100% Apple Juice Apple  White Grape 6 pack/8oz bottles", '0014800002294': "Mott's Juice Apple - 8.0 Oz X 6 Pack", '0012000180613': 'MTN DEW AMP GAME FUEL, Charged Original Dew, 16 Oz Can', '0012000204968': 'Mtn Dew Major Melon 12 Oz Can', '4099100150605': "Nature's Nectar Cranberry Pomegranate Juice Cocktail", '4099100171334': "Nature's Nectar Splash Berry Blend", '0068274347351': 'Nestle Pure Life + Revive with Magnesium, Lemon - 20 Fl Oz', '0020662001931': "Newman's Own Dressing Family Recipe Italian 16 Oz", '0020662101280': "Newman's Own Half & Half Lemonade and Iced Tea, 58 Fl. Oz.", '0020662003904': "Newman's Own Organics Pasta Sauce Marinara, 23.5 Oz", '0022014128402': 'North Coast Organic Apple Juice', '0079694222128': 'Old Trapper 10 Oz. Peppered Beef Jerky', '0855432003057': 'Open Water Still Purified Water 12 Oz', '0639266944881': "Organic Oatmeal Raisin Cookies, Gluten Free by Steve and Andy's -- Soft, and Chewy Cookie (Oatmeal Raisin, Pack of 1)", '0099482462055': 'Organic Shelf-Stable Juice, Cranberry Mango - No Sugar Added, 64 fl oz', '0041501800010': 'Ortega Flour Tortillas 12 Tortillas', '0041565140169': 'Pace Chunky Salsa Mild 16 Oz Jar', '4932382900530': 'Peanut Brown Sugar, Processed', '0030000659403': 'Pearl Milling Company Butter Rich Syrup', '0030000050408': 'Pearl Milling Company Original Pancake & Waffle Mix - 2lb', '0030000059708': 'Pearl Milling Company Original Syrup - 24 Fl Oz.', '0185889000560': 'Peeled Snacks Organic Baked Pea Puffs, Butter and Sea Salt, 4 Oz', '0014100077084': 'Pepperidge Farm Chesapeake Crispy Dark Chocolate Pecan Cookies 7.2 Oz', '0014100079521': 'Pepperidge Farm Chessmen Butter Cookies 7.25 Oz', '0012000504051': 'Pepsi Cola Soda - 6pk/16.9 fl oz Bottles', '0029000016132': 'Planters Deluxe Whole Cashews, 8.5 OZ', '0029000072107': 'Planters Heart Healthy Cocktail Peanuts 16 Oz', '0029000016088': 'Planters Lightly Salted Cashews Halves & Pieces, 8 Oz Canister', '0029000027114': 'Planters Pop and Pour Dry Roasted Peanuts - 7 Oz', '4061462564727': 'Priano Conchiglie Authentic Italian Bronze Cut Pasta', '0012000142079': 'Pure Leaf Iced Tea, Sweet Tea, 64 Fl Oz', '0050000350841': 'Purina Mighty Dog Chicken & Smoked Bacon Dog Food - 5.5 Oz', '0030000011904': 'QKR01190 Instant Oatmeal, 10 Packets-BX, Maple Brown Sugar', '0030000067000': 'Quaker Simply Granola Oats Cereal Honey & Almonds 28 Oz', '4099100223354': 'Radiance Cleaning Eraser (2 pads)', '4099100276077': 'Radiance Heavy Duty Scrub Sponges (3 Pack)', '0050428481431': 'Radiance Preservative Free Absorbable Calcium with Vitamin D', '4099100093858': 'Reggano Traditional Pasta Sauce', '0041617002865': 'Rumford Non-Gmo Corn Starch 12 Oz', '0041508800648': 'San Pellegrino Sparkling Lemon Beverage, 11.15 Fl. Oz.', '0035900264429': 'Sanders Dark Chocolate Sea Salt Caramels 36 Ounce', '0078895126396': 'Sauce Soy Premium Case of 6 X 16.9 Oz by Lee Kum Kee', '0854285010656': 'Simply Asian Unsweetened Coconut Milk 13.66 Fl Oz', '4099100300017': 'Simply Nature Freeze Dried Mangos', '4099100195767': 'Simply Nature Organic Tomato & Basil Pasta Sauce', '4099100003864': 'Simply Nature Sweet Potato Chips', '0037600495486': 'Skippy Bites Snacks Double Peanut Butter, 6.0 Oz', '0037600105064': 'Skippy Natural Creamy Peanut Butter Spead, 15 Oz', '0037600880954': 'SKIPPY Peanut Butter Blended with Plant Protein, Creamy, 14 Oz', '0051500006863': 'Smuckers Strawberry Preserves - 18 Oz', '0076183643563': 'Snapple Peach Tea 64 Fl Oz Bottle', '0077975094235': "Snyder's 12 Oz Butter Rounds", '4099100139389': 'Southern Grove Dried Philippine mangoes', '0041498134662': 'Southern Grove On the Go Trail Mix 12 Oz', '0051000233141': 'SpaghettiOs Canned Pasta with Meatballs 15.6 Oz', '0037600138727': 'Spam Classic Lunch Meat 12 Oz', '0016571940348': 'Sparkling Ice Naturally Flavored Sparkling Mineral Spring Water Peach Nectarine - 17.0 Oz', '0016571952105': 'Sparkling Ice Sparkling Water Black Cherry - 17.0 Fl Oz', '0016571910372': 'Sparkling Ice Sparkling Water Pink Grapefruit Pink Grapefruit - 17.0 Fl Oz', '0016571940331': 'Sparkling Ice Sparkling Water, Zero Sugar, Coconut Pineapple Coconut Pineapple - 17.0 Oz', '0722776230015': 'Splenda Low Calorie Sweetener for Baking 32 Oz Resealable Bag', '0041380113058': 'Springfield Chunk Light Tuna in Water', '0078000003697': 'Squirt Caffeine-Free Naturally Flavored Citrus Soda, 0.5 L, 6 Count', '4099100134308': 'Stonemill Brown Gravy Mix', '4099100134315': 'Stonemill Brown Gravy Mix 30% Less Sodium', '4099100246759': 'Stonemill Smoky Dry Rub Seasoning', '0044800003410': 'Sugar In The Raw Organic Granulated White Premium Cane Sugar 24 Oz Bag', '0051000121141': 'Swanson 100% Natural Gluten-Free Chicken Broth 32 Oz Carton', '0051000132796': 'Swanson Natural Goodness 33% Less Sodium Chicken Broth 32 oz Carton', '4549131255010': 'Sweet Daiso Select Japanese Curry Tablet 140g', '4099100133356': 'Sweet Harvest Yellow Cling Peach Slices In Heavy Syrup', '0810291002306': "Tate's Bake Shop Butter Crunch Cookies - 7oz", '0810291001002': "Tate's Bake Shop Chocolate Chip Cookies - 7oz", '0810291001026': "Tate's Bake Shop Oatmeal Raisin Cookies 7 Oz", '0810291001057': "Tate's Bake Shop Walnut Chocolate Chip Cookies - 7oz", '0810291001019': "Tate's Bake Shop White Chocolate Macadamia Nut Cookies - 7oz", '0737628079506': 'Thai Kitchen Organic Unsweetened Coconut Milk 13.66 Fl Oz', '0737628010929': 'Thai Kitchen Unsweetened Coconut Cream 13.66 Fl Oz', '0028400518000': 'Tostitos 12 Oz Light Salt Restaurant Tortilla Chips', '0028400089364': 'Tostitos Rstc Jar Dip 15.5 Oz', '0028400055970': 'Tostitos Salsa Mild Chunky Salsa 15.5 Oz Jar', '0073176001508': 'Tsuru Mai, California Brown Rice, 16 oz', '4099100112184': 'Tuscan Garden Distilled White Vinegar', '0816678020109': "Vegan Rob's Brussel Sprouts Puffs 3.5 Oz", '0041800337118': "Welch's Concord Grape Juice 6 Pack / 10 Fl Oz Bottles", '0074873163216': 'Westbrae Natrual Organic Low Sodium Black Beans 15 Oz', '0079900001219': "Wyman's Triple Berry 48 Oz", '4902201180382': 'いちご お菓子 合格祈願 グッズ 福岡 お土産 キットカット あまおう苺 (ミニ10枚入り)', '4530266000514': 'おうち甘味 抹茶わらび餅', '4902201181747': 'キットカット 富士山パック ストロベリーチーズケーキ 9枚入 ネスレ お菓子 KitKat ご当地 山梨 富士山 お土産 チーズケーキ味 チョコレート', '4972822380966': 'コルク鍋敷 丸', '4948750045796': 'サンコー いかそうめん ブラックペッパー 21g', '4948750045772': 'サンコー するめジャーキー 21g', '4550480215112': 'デジタルキッチンスケール(3kg、ホワイト)', '4902201172875': 'ネスレ キットカット 梅酒', '4550480275642': 'ペーパータオル(120枚)', '4550480155722': 'ペーパーハンカチ(バンブー、30枚、10組、6個)', '4901005561021': 'ポッキー＜宇治抹茶＞', '4549131024616': 'ミトン (鍋つかみ)約30x17cm', '4550480116914': 'ミニルーター(3Vタイプ、交換ビット3本付)', '4903316423760': 'リボン 早乙女檸檬の挑戦状 60g', '4901540417661': '合食 肴selection やわらかするめフライ 16g', '4901540417890': '合食 肴selection 焼きさきあたりめ 12g', '4901540417906': '合食 肴selection 甘のしいか 9g', '4904670489737': '宝 私のりんごサワー 350ml', '4582191132020': '日本橋菓房 寄席の華 72g', '4973107283590': '木粉ねんど', '4902013253250': '筑豊製菓 福岡抹茶キャラメル 65g', '4909411084950': '紅茶 ペットボトル 午後の紅茶', '4945319020461': '軽いねんど 黒', '4902201180368': '雀巢 kitkat 伊藤久右衛門宇治抹茶 威化巧克力餅乾mini 10片入', '4550480199696': '電子レンジでお手軽ラーメン', '4989846001081': '黒胡麻餡入り生八ツ橋'};

  void startScanning() {
    setState(() {
      isScanning = true;
      scannedCode = '';
      productName = '';
    });
  }

  void stopScanning() {
    setState(() {
      isScanning = false;
    });
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Barcode Scan Result"),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onBarcodeDetected(Barcode barcode, MobileScannerArguments? args) {
    if (barcode.rawValue != null) {
      String code = barcode.rawValue!;
      setState(() {
        scannedCode = code;
        if (productDatabase.containsKey(code)) {
          productName = productDatabase[code]!;
        } else {
          productName = '';
          _showDialog('Barcode not found in the database: $scannedCode');
        }
        isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                isScanning
                    ? MobileScanner(
                        allowDuplicates: false,
                        onDetect: onBarcodeDetected,
                      )
                    : Center(child: Text('Press the button to start scanning')),
                if (isScanning)
                  Center(
                    child: Container(
                      width: 300, // Adjust the width of the rectangle
                      height: 200, // Adjust the height of the rectangle
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red, // Color of the border
                          width: 2, // Width of the border
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (scannedCode.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                productName.isNotEmpty
                    ? 'Product: $productName\nBarcode: $scannedCode'
                    : 'Scanned Code: $scannedCode',
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: startScanning,
                  child: Text('Start Scanning'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: stopScanning,
                  child: Text('Stop Scanning'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
