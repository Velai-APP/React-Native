import 'package:flutter/material.dart';
import 'ai_processing_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CompetitorHomeScreen extends StatefulWidget {
  const CompetitorHomeScreen({super.key});

  @override
  State<CompetitorHomeScreen> createState() =>
      _CompetitorHomeScreenState();
}


class _CompetitorHomeScreenState
    extends State<CompetitorHomeScreen> {


  final companyController = TextEditingController();


  String selectedIndustry = "Retail";


  final industries = [
    "Retail",
    "Automobile",
    "Technology",
    "Finance",
    "Healthcare",
    "Manufacturing"
  ];


  final analysisModules = [

    {
      "icon": Icons.business_rounded,
      "title":"Company Profile",
      "subtitle":"History, products & growth"
    },

    {
      "icon": Icons.sentiment_satisfied_alt_rounded,
      "title":"Customer Reviews",
      "subtitle":"Google reviews & sentiment"
    },

    {
      "icon": Icons.compare_arrows_rounded,
      "title":"Competitors",
      "subtitle":"Market comparison"
    },

    {
      "icon": Icons.trending_up_rounded,
      "title":"Growth Ideas",
      "subtitle":"AI recommendations"
    }

  ];


  final selectedModules = <String>{};


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
          const Color(0xffF7F8FC),


      body: SafeArea(

        child: SingleChildScrollView(

           padding: const EdgeInsets.only(
    left:20,
    right:20,
    top:20,
    bottom:100,   // add this
  ),


          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,


            children: [


              _header(),


              const SizedBox(height:25),


              _companySearch(),


              const SizedBox(height:25),


              _industry(),


              const SizedBox(height:25),


              Text(
                "Select Analysis",
                style: TextStyle(
                  fontSize:20,
                  fontWeight:FontWeight.bold
                ),
              ),


              const SizedBox(height:15),


              _analysisCards(),


              const SizedBox(height:30),


              _analyseButton(),


              const SizedBox(height:35),

             _recentReportsFromFirestore(), 
            ],

          ),

        ),

      ),

    );

  }

  Widget _recentReportsFromFirestore() {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return const Center(
      child: Text(
        "Please login to view your reports",
      ),
    );
  }

  return StreamBuilder<QuerySnapshot>(
    stream:FirebaseFirestore.instance
    .collection("competitorReports")
    .where(
      "userId",
      isEqualTo: user.uid,
    )
        .limit(5)
        .snapshots(),

    builder: (context, snapshot) {
      // --------------------------------------------
      // LOADING
      // --------------------------------------------

      if (snapshot.connectionState ==
          ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(30),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // --------------------------------------------
      // ERROR
      // --------------------------------------------

  if (snapshot.hasError) {
  debugPrint("====================================");
  debugPrint("FIRESTORE RECENT REPORT ERROR");
  debugPrint(snapshot.error.toString());
  debugPrint("====================================");

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      snapshot.error.toString(),
      style: const TextStyle(
        color: Colors.red,
        fontSize: 12,
      ),
    ),
  );
}

      // --------------------------------------------
      // DATA
      // --------------------------------------------

final docs = snapshot.data?.docs
        .where((doc) {
          final data =
              doc.data() as Map<String, dynamic>;

          return data["status"] == "completed";
        })
        .toList() ??
    [];

// Sort newest first
docs.sort((a, b) {
  final aData =
      a.data() as Map<String, dynamic>;

  final bData =
      b.data() as Map<String, dynamic>;

  final aTime =
      aData["createdAt"] as Timestamp?;

  final bTime =
      bData["createdAt"] as Timestamp?;

  if (aTime == null && bTime == null) {
    return 0;
  }

  if (aTime == null) {
    return 1;
  }

  if (bTime == null) {
    return -1;
  }

  return bTime.compareTo(aTime);
});

final recentDocs =
    docs.take(5).toList();

      // --------------------------------------------
      // EMPTY
      // --------------------------------------------

      if (docs.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),

          child: const Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 38,
                color: Colors.grey,
              ),

              SizedBox(height: 10),

              Text(
                "No reports yet",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 4),

              Text(
                "Your completed AI reports will appear here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }

      // --------------------------------------------
      // DISPLAY REPORTS
      // --------------------------------------------

      return Column(
        children:recentDocs.map((doc) {
          final data =
              doc.data()
                  as Map<String, dynamic>;

          final companyName =
              data["companyName"]
                  ?.toString() ??
              "Unknown Company";

          final industry =
              data["industry"]
                  ?.toString() ??
              "Unknown Industry";

          return _recentReport(
            companyName,
            industry,
            "Completed",
          );
        }).toList(),
      );
    },
  );
}




// HEADER

Widget _header() {

return Stack(

children: [

Container(

margin: const EdgeInsets.only(top: 20),

padding: const EdgeInsets.fromLTRB(
20,
35,
20,
25
),

decoration: BoxDecoration(

gradient: const LinearGradient(

begin: Alignment.topLeft,

end: Alignment.bottomRight,

colors: [

Color(0xff7C3AED),
Color(0xff4F46E5),
Color(0xff2563EB),

],

),

borderRadius:
BorderRadius.circular(30),


boxShadow: [

BoxShadow(

color:
const Color(0xff4F46E5)
.withOpacity(0.35),

blurRadius:25,

offset:
const Offset(0,12),

)

],

),


child: Column(

crossAxisAlignment:
CrossAxisAlignment.start,


children: [


const SizedBox(height:25),



Row(

children: [


Container(

padding:
const EdgeInsets.all(12),

decoration:

BoxDecoration(

color:
Colors.white.withOpacity(.15),

borderRadius:
BorderRadius.circular(16),

),


child:

const Icon(

Icons.auto_awesome_rounded,

color: Colors.white,

size:32,

),

),



const SizedBox(width:15),



Expanded(

child:

Column(

crossAxisAlignment:
CrossAxisAlignment.start,


children:[


const Text(

"AI BUSINESS\nINTELLIGENCE",

style:

TextStyle(

color:Colors.white,

fontSize:23,

height:1.1,

fontWeight:
FontWeight.w800,

letterSpacing:.5

),

),



const SizedBox(height:8),



Text(

"Your AI powered market analyst",

style:

TextStyle(

color:
Colors.white.withOpacity(.85),

fontSize:14,

),

),


]

),

)

],

),



const SizedBox(height:25),



Container(

padding:
const EdgeInsets.symmetric(
horizontal:12,
vertical:7
),

decoration:

BoxDecoration(

color:
Colors.white.withOpacity(.18),

borderRadius:
BorderRadius.circular(20),

border:

Border.all(

color:
Colors.white.withOpacity(.25)

)

),


child:

const Row(

mainAxisSize:
MainAxisSize.min,

children:[


Icon(

Icons.bolt_rounded,

color:
Colors.yellow,

size:16,

),


SizedBox(width:5),


Text(

"Powered by AI Agents",

style:

TextStyle(

color:Colors.white,

fontSize:12,

fontWeight:
FontWeight.w600

),

)


],

),

)



],

),


),



// BACK BUTTON

Positioned(

top:0,

left:0,


child:

GestureDetector(

onTap:(){

Navigator.pop(context);

},


child:

Container(

height:48,

width:48,


decoration:

BoxDecoration(

color:
Colors.white,

shape:
BoxShape.circle,


boxShadow:[

BoxShadow(

color:
Colors.black.withOpacity(.12),

blurRadius:15,

offset:
const Offset(0,5)

)

]

),


child:

const Icon(

Icons.arrow_back_ios_new_rounded,

size:20,

color:
Color(0xff4F46E5),

),

),

),

),



// AI FLOATING BADGE

Positioned(

right:20,

top:5,


child:

Container(

padding:
const EdgeInsets.all(10),


decoration:

BoxDecoration(

gradient:

const LinearGradient(

colors:[

Color(0xffFDE68A),

Color(0xffF59E0B)

]

),

shape:
BoxShape.circle,


boxShadow:[

BoxShadow(

color:
Colors.orange.withOpacity(.4),

blurRadius:15,

)

]

),


child:

const Icon(

Icons.psychology_alt_rounded,

color:
Colors.white,

size:25,

),

),

),


],

);

}



// SEARCH CARD

Widget _companySearch(){


return Container(

padding:
const EdgeInsets.all(18),

decoration:
_boxDecoration(),


child:

Column(

crossAxisAlignment:
CrossAxisAlignment.start,


children:[


const Text(
"Analyse Company",
style:
TextStyle(
fontSize:18,
fontWeight:FontWeight.bold
),
),


const SizedBox(height:15),



TextField(

controller:
companyController,


decoration:

InputDecoration(

hintText:
"Example: Chennai Silks",

prefixIcon:
const Icon(Icons.search),


filled:true,

fillColor:
const Color(0xffF5F6FA),


border:
OutlineInputBorder(

borderRadius:
BorderRadius.circular(15),

borderSide:
BorderSide.none

)

),

)

]

),

);

}





Widget _industry(){


return Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children:[


const Text(

"Industry",

style:
TextStyle(

fontSize:18,

fontWeight:
FontWeight.bold

),

),


const SizedBox(height:12),



Wrap(

spacing:10,

runSpacing:10,


children:

industries.map((item){


bool active =
selectedIndustry==item;


return GestureDetector(

onTap:(){

setState((){

selectedIndustry=item;

});

},


child:

Container(

padding:
const EdgeInsets.symmetric(
horizontal:18,
vertical:10
),


decoration:

BoxDecoration(

color:
active
?
const Color(0xff6C63FF)
:
Colors.white,


borderRadius:
BorderRadius.circular(30)

),


child:

Text(

item,

style:

TextStyle(

color:
active
?
Colors.white
:
Colors.black,

fontWeight:
FontWeight.w600

),

),

),

);



}).toList(),


)

]

);

}




Widget _analysisCards(){


return GridView.builder(

shrinkWrap:true,

physics:
const NeverScrollableScrollPhysics(),


itemCount:
analysisModules.length,


gridDelegate:

const SliverGridDelegateWithFixedCrossAxisCount(

crossAxisCount:2,

crossAxisSpacing:12,

mainAxisSpacing:12,

childAspectRatio:1.1

),


itemBuilder:(context,index){


var item =
analysisModules[index];


bool selected =
selectedModules.contains(item["title"]);



return GestureDetector(

onTap:(){

setState((){

if(selected){

selectedModules.remove(
item["title"]
);

}

else{

selectedModules.add(
  item["title"] as String
);

}

});

},


child:

Container(

padding:
const EdgeInsets.all(15),


decoration:

_boxDecoration(
selected
?
const Color(0xffEDE9FE)
:
Colors.white
),


child:

Column(

crossAxisAlignment:
CrossAxisAlignment.start,


children:[


Icon(
item["icon"] as IconData,
color:
const Color(0xff6C63FF),
size:30
),


const Spacer(),


Text(

item["title"].toString(),

style:
const TextStyle(
fontWeight:
FontWeight.bold
),

),


const SizedBox(height:5),


Text(

item["subtitle"].toString(),

style:
const TextStyle(

fontSize:12,

color:
Colors.grey

),

)


]

),

),

);



}

);

}



Widget _analyseButton() {
  return Container(
    width: double.infinity,
    height: 60,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xff6C63FF),
          Color(0xff4F46E5),
        ],
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      icon: const Icon(
        Icons.auto_awesome,
        color: Colors.white,
      ),
      label: const Text(
        "Start AI Analysis",
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        // Get company name from TextField
        final String companyName =
            companyController.text.trim();

        // Validate company name
        if (companyName.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Please enter a company name",
              ),
            ),
          );
          return;
        }

        // Validate analysis selection
        if (selectedModules.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Please select at least one analysis",
              ),
            ),
          );
          return;
        }

        // Open AI Processing Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AIProcessingScreen(
              companyName: companyName,
              industry: selectedIndustry,
              selectedModules:
                  selectedModules.toList(),
            ),
          ),
        );
      },
    ),
  );
}



Widget _recentReport(
String name,
String industry,
String score
){


return Container(

margin:
const EdgeInsets.only(bottom:15),


padding:
const EdgeInsets.all(18),


decoration:
_boxDecoration(),


child:

Row(

children:[


const CircleAvatar(

radius:25,

child:
Icon(Icons.business),

),


const SizedBox(width:15),


Expanded(

child:

Column(

crossAxisAlignment:
CrossAxisAlignment.start,


children:[

Text(

name,

style:
const TextStyle(

fontWeight:
FontWeight.bold,

fontSize:17

),

),


Text(industry),


Text(
"AI Score $score",
style:
const TextStyle(
color:Colors.green
),
)

]

),

)

]

),

);

}




BoxDecoration _boxDecoration(
[
Color color = Colors.white
]
){

return BoxDecoration(

color:color,

borderRadius:
BorderRadius.circular(20),

boxShadow:[

BoxShadow(

color:
Colors.black.withOpacity(.05),

blurRadius:15,

offset:
const Offset(0,5)

)

]

);

}



}