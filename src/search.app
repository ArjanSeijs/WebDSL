module src/search

imports src/person
 
 
 //Search using the queries
function searchtree(q : String) : List<FamilyTree> {
	var s := search FamilyTree matching escapeQuery(q);
	var trees := results from s;
	return [t |t : FamilyTree in trees where canSee(t) limit 10];
}

function searchperson(q : String) : List<Person> {
	var s := search Person matching escapeQuery(q);
	var persons := results from s;
	return [p |p : Person in persons where canSee(p) limit 50];
}

page search(q : String) {
	var persons := searchperson(q)
	var tree := searchtree(q)
	
	title {"Searching"}
	main {
		myheader
		div[class="container"] {
			div[class="row"] {
				if(tree.length != 0) {
					h1 {"Found families: "}
				}
				
				for(t : FamilyTree in tree) {
					div[class="col col-md-3"] {
						navigate family_overview(t){output(t.name)}		
										
					}
				}
			}
			div[class="row"] {
				if(persons.length != 0) {
					h1 {"People found: "}
				}
				for(p : Person in persons) {
					personresult(p)
				}
			}
			if(persons.length == 0 && tree.length == 0 ) {
				h1 {"No search results"}
			}
		}
	}
}

// Search result card
template personresult(p : Person) {
	// https://getbootstrap.com/docs/5.0/components/card/#horizontal
	<div class="col col-md-4 mb-3">
		<div class="card mb-3 h-100">
		  <div class="row g-0 h-100">
		    <div class="col-md-4 border border-secondary rounded">
		      userImage(p)
		    </div>
		    <div class="col-md-8 border border-secondary rounded">
		      <div class="card-body">
		        <h5 class="card-title">output(p.fullname())</h5>
		        <h6 class="card-subtitle mb-2 text-muted"> "in " output(p.family.name)</h6>
		        person_info(p)
		      </div>
		    </div>
		  </div>
		  navigate person(p)[class="stretched-link"]{}
		</div>
	</div>
}