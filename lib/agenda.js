var categoryList = [
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
            "id": [106]
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

// http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values-in-javascript
function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}
$(window).load(function(){
	var items = {};       	         
        //$.ajax({url: "http://localhost:4502/Services/agenda.jsonp?jsoncallback=?", async: false, dataType: "jsonp", success: function(json) {console.log(1);items = json;}, error: function(err) {console.log(err);}});       	   
$.ajax({url: "https://oknesset.org/api/v2/agenda/", async: false, dataType: "json", success: function(json) {items = json.objects;}, error: function(err) {console.log(err);}});
// filter the relevants agendas by the category
var categoryDesc = getParameterByName('categoryDesc');

var categoryIds = _.where(categoryList, {category: categoryDesc});
var agenda4category = {};
_.each(categoryIds[0].id, function(id){agenda4category = _.union(agenda4category,_.where(items, {id: id})); });
agenda4category = _.filter(agenda4category, function(a){ return a.id > 0; });
// Render the template with the items data and insert
// the rendered HTML before the "p" in the "div.row" element
var divTemplate = $("#div-data").html();
$("div.row p").before(_.template(divTemplate,{items:agenda4category}));

});
