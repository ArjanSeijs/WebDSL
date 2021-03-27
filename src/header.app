module src/header


imports src/search

template myheader() {
		var q : String
		// https://getbootstrap.com/docs/5.0/components/navbar/
		<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
			<div class="container-fluid">
				<button class="navbar-toggler collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      				<span class="navbar-toggler-icon"></span>
    			</button>
				<div class="collapse navbar-collapse" id="navbarSupportedContent">
					<ul class="navbar-nav me-auto mb-2 mb-lg-0">
						item {navigate root()[class="nav-link"] {"Home"}}
						if(loggedIn()) {
							familyTreeList
						}
						elements //extra links for other pages
					</ul>
					<ul class="navbar-nav">
						if(loggedIn()) {
							item[class="nav-link"] {<i class="fa fa-user"></i>" " output( securityContext.principal.username )}
							item {
								logoutcard()
							}
						} else {
							item[class="dropdown"] {
								<a class="nav-link dropdown-toggle" data-bs-toggle="dropdown" href="loginpage">"Login"</a>
	  							<div class="dropdown-menu navbar-dropdown-menu p-2">
									logincard()
								</div>
							}
							item[class="dropdown"] {
								<a class="nav-link dropdown-toggle" data-bs-toggle="dropdown" href="register">"Register"</a>
	  							<div class="dropdown-menu navbar-dropdown-menu p-2">
									registercard()
								</div>
							}	
						}
					</ul>
					
					form[class="d-flex"] {
						<div class="input-group">
						<span class="input-group-text"><i class="fa fa-search"></i></span>
						input(q)[class="form-control me-2", type="search", placeholder="Search", aria-label="Search"]
				        	submit search()[class="btn btn-outline-success"]{"Search"}
				        </div>
					}
				</div>
			</div>
		</nav> 
		
		action search() {
			goto search(q);
		}
	}
 	
 	
	
	template familyTreeList {
		var user := securityContext.principal
		item[class="dropdown"] {
			<a class="dropdown-toggle nav-link hov-pointer" id="nav_family" data-bs-toggle="dropdown" aria-expanded="false">
		    	"My Family Trees"
		  	</a>
		  	<ul class="dropdown-menu" aria-labelledby="dropdownMenuButton1">
		  		for(t : FamilyTree in user.trees) {
					<li>
						navigate family_overview(t)[class="dropdown-item"]{output(t.name)}
					</li>
				}
				if(securityContext.principal.trees.length > 0) {
					<li><hr class="dropdown-divider"></li>	
				}
				
				for(t : FamilyTree in user.canEdit where !(t in user.trees)) {
					<li>
						navigate family_overview(t)[class="dropdown-item"]{output(t.name)}
					</li>
				}
				if(user.canEdit.length > 0) {
					<li><hr class="dropdown-divider"></li>	
				}
				for(t : FamilyTree in securityContext.principal.canSee where !(t in user.canEdit) && !(t in user.trees)) {
					<li>
						navigate family_overview(t)[class="dropdown-item"]{output(t.name)}
					</li>
				}
				if(securityContext.principal.canSee.length > 0) {
					<li><hr class="dropdown-divider"></li>	
				}
				<li>a[class="dropdown-item hov-pointer", onclick=action{
					validate(loggedIn(), "Not logged in");
					var tree := FamilyTree{name := "My Family", owner := securityContext.principal};
					tree.save();
					goto family_overview(tree);
				}]{
						"+ Family Tree"	
					}
				</li>
		  	</ul>
		}
	}
 	
 	function searchtree(q : String) : List<FamilyTree> {
		log(q);
 		var s := search FamilyTree matching escapeQuery(q);
 		var trees := results from s;
 		return [t |t : FamilyTree in trees where canSee(t) limit 10];
 	}
 	
 	function searchperson(q : String) : List<Person> {
		log(q);
 		var s := search Person matching escapeQuery(q);
 		var persons := results from s;
 		return [p |p : Person in persons where canSee(p.family) limit 50];
 	}