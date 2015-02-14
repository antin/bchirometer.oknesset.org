$(window).load(function(){
//var items = {};	
var items = [
        {
            "category": "בטחון פנים",
            "id": 115
        }, 
        {
            "category": "כלכלה",
            "id": [92,113,101]
        }, 
		 {
            "category": "הגירה וגבולות",
            "id": [108,107]
        }, 
		 {
            "category": "שקיפות",
            "id": 99
        }, 		 
		 {
            "category": "תחבורה ציבורית",
            "id": 102
        }, 
		 {
            "category": "זכויות",
            "id": 104
        }, 		 
		 {
            "category": "זכויות אדם",
            "id": 105
        }, 
		 {
            "category": "מגדר",
            "id": 106
        }, 
		 {
            "category": "חינוך",
            "id": 109
        }, 		
		 {
            "category": "איכות הסביבה",
            "id": 114
        }, 		
        {
             "category": "זכויות בעלי חיים",
            "id": 93
        }
    ];
	// Render the template with the items data and insert
	// the rendered HTML before the "p" in the "div.row" element
//$.ajax({url: "https://oknesset.org/api/v2/agenda/", async: false, dataType: "json", success: function(json) {console.log(json);items = json.objects;}, error: function(err) {console.log(err);}});     

	var divTemplate = $("#div-data").html();
$("div.row p").before(_.template(divTemplate,{items:items}));

});
