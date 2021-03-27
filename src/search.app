module src/search


	
	
 	
	page search(q : String) {
		// var resulsts := Entry completions matching codeIdentifiers, fileName: q in namespace namespace limit 20
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
	
	template personresult(p : Person) {
		// https://getbootstrap.com/docs/5.0/components/card/#horizontal
		<div class="col col-md-4 mb-3">
			<div class="card mb-3 h-100">
			  <div class="row g-0">
			    <div class="col-md-4">
			      userImage(p)
			    </div>
			    <div class="col-md-8">
			      <div class="card-body">
			        <h5 class="card-title">output(p.fullname())</h5>
			        <h6 class="card-subtitle mb-2 text-muted"> "in " output(p.family.name)</h6>
			        <ul class="list-group list-group-flush">
						person_item("Gender"){output( p.gender)}
						
						<li class="list-group-item"></li>
						person_item("Birthday"){output( p.birthday)}
						person_item("Birth Place"){output( p.birthplace)}
						person_item("Day of passing"){output(p.passingdate)}
						person_item("Age"){output(p.getAge() + " years")}
						
						if(p.parents.length > 0) {
							<li class="list-group-item"></li>
						}
						for(parent : Person in p.parents) {
							person_item("Parent"){navigate person(parent){output(parent.fullname())}}
						}
						
						if(p.children.length > 0) {
							<li class="list-group-item"></li>
						}
						for(child : Person in p.children) {
							person_item("Child"){navigate person(child){output(child.fullname())}}
						}
						</ul>
			      </div>
			    </div>
			  </div>
			  navigate person(p)[class="stretched-link"]{}
			</div>
		</div>
	}