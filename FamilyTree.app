application FamilyTree

imports bootstrap
imports entities
imports person
imports authentication
imports tree
imports templates

	init {
		// Demo Data
		var u1 := User{ username := "user1" password := ("abc" as Secret).digest()  };
    	var u2 := User{ username := "user2" password := ("abc" as Secret).digest()  };
    	var u3 := User{ username := "user3" password := ("abc" as Secret).digest()  };
    	var u4 := User{ username := "user4" password := ("abc" as Secret).digest()  };
    	u1.save(); u2.save(); u3.save(); u4.save();
    	
    	var tree := FamilyTree{name := "Family Smith", owner := u1};
    	var tree2 := FamilyTree{name := "Jones", owner := u1, public := false, canSee := {u2, u3}, canEdit := {u2}};
    	tree.save(); tree2.save();
    	
    	var gFatherM := Person{firstname := "gFatherM", birthday := Date("06/01/1930"), passingdate := Date("05/10/2019"), family := tree, gender := Male};
    	var gFatherF := Person{firstname := "gFatherF", birthday := Date("02/07/1943"), passingdate := Date("04/10/2018"), family := tree, gender := Male};
    	var gMotherF := Person{firstname := "gMotherF", birthday := Date("04/09/1950"), family := tree, gender := Female};
    	
    	var father := Person{firstname := "father", birthday := Date("06/09/1968"), parents := {gFatherM}, family := tree, gender := Male};
    	var mother := Person{firstname := "mother", birthday := Date("08/09/1967"), parents := {gFatherF, gMotherF}, family := tree, gender := Female};
    	
    	var uncle := Person{firstname := "uncle", birthday := Date("06/09/1968"), parents := {gFatherM}, family := tree, gender := Male};
    	var aunt := Person{firstname := "aunt", birthday := Date("08/09/1967"), parents := {gFatherF, gMotherF}, family := tree, gender := Female};
    	
    	var fatherL := Person{firstname := "father", middlenames:="in", lastname:="law", birthday := Date("02/02/1967"), family := tree, gender := Male};
    	var motherL := Person{firstname := "mother", middlenames:="in", lastname:="law", birthday := Date("03/04/1967"), family := tree, gender := Female};
    	
    	var me := Person{firstname := "Me", middlenames := "First of His name", lastname := "Breaker of chains", birthday := Date("01/01/1995"), parents := {father, mother}, family := tree, gender := Male};
    	var wife := Person{firstname := "wife", birthday := Date("02/02/1996"), parents := {fatherL, motherL}, family := tree, gender := Female};
    	var ex := Person{firstname := "ex", birthday := Date("02/02/1996"), family := tree, gender := Female};
    	var brother := Person{firstname := "brother", birthday := Date("01/01/1995"), parents := {father, mother}, family := tree, gender := Male, description := ("##Title\n some information" as WikiText)};
    	var sister := Person{firstname := "sister", birthday := Date("12/11/1997"), parents := {father, mother}, family := tree, gender := Female};
    	
    	var son := Person{firstname := "son", birthday := Date("03/03/2020"), parents := {me, wife}, family := tree, gender := Male};
    	var daughter := Person{firstname := "daughter", birthday := Date("05/05/2018"), parents := {me, ex}, family := tree, gender := Female};
    	var daughterL := Person{firstname := "daughter", middlenames := "in", lastname := "law", birthday := Date("05/05/2018"), family := tree, gender := Female};
    	
    	var grandson := Person{firstname := "grandson", birthday := Date("03/03/2020"), parents := {son, daughterL}, family := tree, gender := Male};
    	var grandddaughter := Person{firstname := "granddaughter", birthday := Date("05/05/2018"), parents := {son, daughterL}, family := tree, gender := Female};
    	
    	var niece := Person{firstname := "niece", birthday := Date("07/09/2017"), parents := {sister}, family := tree, gender := Other};
    	
    	var r1 := Person{firstname := "Relative1", birthday := Date("01/01/1995"), family := tree, gender := Male};
    	var r2 := Person{firstname := "Relative2", birthday := Date("01/01/1995"), family := tree, gender := Female};
    	var r3 := Person{firstname := "Relative3", birthday := Date("01/01/1995"), family := tree, gender := Other};
    	var r4 := Person{firstname := "Relative4", birthday := Date("01/01/1995"), family := tree, gender := Male};
    	r1.save(); r2.save(); r3.save(); r4.save();
    	
		gFatherM.save(); gFatherF.save(); gMotherF.save(); 
		father.save(); mother.save();uncle.save(); aunt.save(); fatherL.save(); motherL.save(); 
		me.save();wife.save();brother.save();sister.save();ex.save();
		son.save();daughter.save();daughterL.save();
		grandson.save();grandddaughter.save();niece.save();
    	
		var p1 := Person{firstname := "Relative", birthday := Date("04/09/2009"), family := tree2, gender := Male};
		var p2 := Person{firstname := "Father", birthday := Date("04/09/2009"), family := tree2, gender := Male};
		var p3 := Person{firstname := "Mother", birthday := Date("04/09/2009"), family := tree2, gender := Female};
		var p4 := Person{firstname := "Person", birthday := Date("04/09/2009"), parents := {p2, p3}, family := tree2, gender := Male, description := "Put description here"};
		p1.save(); p2.save(); p3.save(); p4.save();
	}

	page root() {
		title {"Family Tree Home"}
		main {
			myheader
			carousel
		}
	}
	
	template carousel {
		//https://getbootstrap.com/docs/5.0/components/carousel/
		<div class="container">
		<div id="carouselExampleDark" class="carousel carousel-dark slide" data-bs-ride="carousel">
		  <div class="carousel-indicators">
		    <button type="button" data-bs-target="#carouselExampleDark" data-bs-slide-to="0" class="active" aria-current="true" aria-label="Slide 1"></button>
		    <button type="button" data-bs-target="#carouselExampleDark" data-bs-slide-to="1" aria-label="Slide 2"></button>
		  </div>
		  <div class="carousel-inner">
		    <div class="carousel-item active" data-bs-interval="10000">
		      image("/images/skywalkers.png")[class="d-block w-100", alt="Family Overview"]{}
		      <div class="carousel-caption d-none d-md-block">
			    <h5>"The skywalker family"</h5>
		      </div>
		    </div>
		    <div class="carousel-item" data-bs-interval="2000">
		      image("/images/skywalkers-tree.png")[class="d-block w-100", alt="Family Overview"]{}
		      <div class="carousel-caption d-none d-md-block">
			    <h5>"The skywalker family tree"</h5>
		      </div>
		    </div>
		  </div>
		  <button class="carousel-control-prev" type="button" data-bs-target="#carouselExampleDark" data-bs-slide="prev">
		    <span class="carousel-control-prev-icon" aria-hidden="true"></span>
		    <span class="visually-hidden">"Previous"</span>
		  </button>
		  <button class="carousel-control-next" type="button" data-bs-target="#carouselExampleDark" data-bs-slide="next">
		    <span class="carousel-control-next-icon" aria-hidden="true"></span>
		    <span class="visually-hidden">"Next"</span>
		  </button>
		</div>
		</div>
	}
	
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
	
	template familyTreeList {
		var user := securityContext.principal
		item[class="dropdown"] {
			<a class="dropdown-toggle nav-link" id="nav_family" data-bs-toggle="dropdown" aria-expanded="false">
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