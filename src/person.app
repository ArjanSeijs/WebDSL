module src/person

imports FamilyTree
imports src/entities
imports src/tree
imports src/templates
imports src/editmenu
imports src/header



page person_edit(p : Person) {
	title {"Editing " output(p.fullname())}
	main {
		myheader
		if(p != null) {
			personedit(p)
		}
	}
}

page person(p : Person) {
	var siblings := p.siblings()
	template person_info_extra_top {
		person_item("First Name"){output(p.firstname)}
		person_item("Middle Name(s)"){output(p.middlenames)}
		person_item("Last Name"){output(p.lastname)}
		
	}
	template person_info_extra_bot {
		if(p.children.length > 0) {
			<li class="list-group-item"></li>
		}
		for(child : Person in p.children) {
			person_item_link(child, "fas fa-baby", "child")//{navigate person(child){output(child.fullname())}}
		}
		
		if(siblings.length > 0) {
			<li class="list-group-item"></li>
		}
		for(s : Person in siblings) {
			person_item_link(s, "fas fa-user-friends", "sibling")//{navigate person(s){output(s.fullname())}}
			
		}
	}
	
	title {output(p.fullname())}
	main {
		myheader
		if(p != null) {
			personcard(p)
		}
	}
	
}

// Form with all user inputs
template personedit(p : Person) {
	//https://getbootstrap.com/docs/5.0/forms/layout/
	
	//Set the two parent fields
	var parent1 : Person
	var parent2 : Person
	init {
		if(p.parents.length >= 1) {
			parent1 := p.parents[0];
		}
		if(p.parents.length >= 2) {
			parent2 := p.parents[1];
		}
	}
	
	div[class="container p-2"] {
		div[class="card"] {
			h4[class="card-title text-center mb-4 mt-1"] {"Edit Person"}
			<article class="card-body">
				form[class="row g-3"] {
					div[class="col-md-4"] {
						label("Firstname: ")[class="form-label"] { 
						    inputajax(p.firstname)[class="form-control w-100"]
						}
					}
					div[class="col-md-4"] {
						label("Middlename(s): ")[class="form-label"] { 
						    input(p.middlenames)[class="form-control w-100"]
						}
					}
					div[class="col-md-3"] {
						label("Lastname: ")[class="form-label"] { 
						    input(p.lastname)[class="form-control w-100"]
						}
					}
					div[class="col-md-1"] {
						label("Gender: ")[class="form-label"] { 
						    input(p.gender)[class="form-control w-100"]
						}
					}
					
					// Next row
					div[class="col-md-3"] {
						label("Date of birth: ")[class="form-label"] {
							dateinput(p.birthday)[class="form-control w-100"]
						}
					}
					div[class="col-md-3"] {
						label("Date of passing: ")[class="form-label"] {
							dateinput(p.passingdate)[class="form-control w-100"]
						}
					}
					div[class="col-md-6"] {
						label("Birth place: ")[class="form-label"] {
							input(p.birthplace)[class="form-control w-100"]
						}
					}
					
					// Next row
					
					div[class="col-md-4"] {
						label("Parent 1: ")[class="form-label"] {
							selectajax(parent1, p.validAllowedParents())[class="form-control w-100"]
						}
					}
					div[class="col-md-4"] {
						label("Parent 2: ")[class="form-label"] {
							selectajax(parent2, p.validAllowedParents())[class="form-control w-100"]
						}
					}
					
					div[class="col-md-4"] {
						label("Upload Image: ")[class="form-label"] {
							input(p.icon)[class="form-control w-100", id="image-upload"]
						}
					}
					
					//Next row
					div[class="col-md-8"] {
						label("Description: ")[class="form-label"] {
							input(p.description)[class="form-control w-100 h-75", onkeyup:=update()] //Update preview of description
						}
					}
					div[class="col-md-4"] {
						userImage(p)[id="image-preview"]
					}
					
					//next row
					div[class="col-md-12"] {
						placeholder preview descpreview(p) //Preview to update
						
					}
					div[class="col-md-12", align="center"] {
						submit save()[class="btn btn-primary"] {"Save "}
						button[class="btn btn-danger", data-bs-toggle="modal", data-bs-target="#confirm_delete"] {"Delete "}
					}
				}
			</article>
		}
	}	
	confirm_modal(p.name){submit delete()[class="btn btn-primary"]{<i class="fa fa-check-square hov-pointer"></i>}}
	
	action delete() {
		validate(canEdit(p.family), "Not allowed to edit");
		var t := p.family;
		Person.delete(p);
		goto family_overview(t);
	}
	
	// Update preview
	action update() {
		replace(preview, descpreview(p));
	}
	
	action save() {
		validate(canEdit(p.family), "Not allowed to edit");
		p.parents.clear();
		if(parent1 != null) {
			p.parents.add(parent1);
		}
		if(parent2 != null) {
			p.parents.add(parent2);
		}
		p.save();
		goto person(p);
	}
}


define ajax descpreview(p : Person) {
	<div class="card">
	  <div class="card-body">
	    output(p.description)
	  </div>
	</div>						
}

// Person card for used in the overview
template personcardsmall(p : Person) {
	card {
		userImage(p)[class="small"]
		div[class="card-body p-0"] {
			h5[class="p-2"] {output(p.fullname())}
			person_info(p)
		}
		navigate person(p)[class="stretched-link person-link"]{}
		edit_buttons(p) // Add invisible buttons to this person for use in the selector.
		
	}
}

// Links to the different pages of this user.
template personNavigation(p : Person) {
	<ul class="pagination pagination-lg" all attributes>
	    <li class="page-item text-center">
	       navigate person_edit(p)[class="page-link"]{<i class="fas fa-3x fa-user-edit"></i>}
	    </li>
	    <li class="page-item text-center">
	    	navigate direct_family_tree(p)[class="page-link"]{<i class="fa fa-3x fa-tree"></i>} 
	    </li>
	    <li class="page-item text-center">
	    	navigate family_tree_canvas(p)[class="page-link"]{<i class="fas fa-3x fa-project-diagram"></i>} 
	    </li>
	    <li class="page-item text-center">
	    	navigate family_overview(p.family)[class="page-link"]{<i class="fas fa-3x fa-users"></i>} 
	    </li>
	 </ul>
}

// Person card that shows all information.
template personcard(p : Person) {
	//https://getbootstrap.com/docs/5.0/layout/grid/
	//https://getbootstrap.com/docs/5.0/layout/containers/
	//https://getbootstrap.com/docs/5.0/components/list-group/	
	div[class="container card-container"] {
		div[class="card"] {
			div[class="row gx-0"]  {
				div[class="col col-md-3"]  {
					userImage(p)
				}
				div[class="col col-md-7", align="center"]  {
					<h1>output(p.fullname()) </h1>
				}
				div[class="col-md-2 text-end"]  {
					personNavigation(p)[style="vertical-align: top;display: inline;"]
	            }
			}
			div[class="row gx-0"]  {
				div[class="col col-md-3"]  {
					div[class="card rounded-0"]  {
						div[class="card-header"]  {
							"Information"
						}
						div[class="card-body p-0"]  {
							person_info(p)
						}
					}
				}
				div[class="col col-md-9"]  {
					div[class="card rounded-0 h-100"]  {
						div[class="card-header"] {
							"About " output(p.fullname())
						}
						div[class="card-body"]  {
							output(p.description)
						}
					}
				}
			}
		}
	}
}

template sibling(p : Person) {
	case(p.gender) {
		Male {
			person_item("Brother"){navigate person(p){output(p.fullname())}}
		}
		Female {
			person_item("Sister"){navigate person(p){output(p.fullname())}}
		}
		Other {
			person_item("Sibling"){navigate person(p){output(p.fullname())}}
		}
	}
}

//User image or default image
template userImage(p : Person) {
	if(p.icon != null) {
		output(p.icon)[class="user-image", all attributes]
	} else {
		image("/images/user-default.png")[class="user-image", all attributes]
	}
}

template person_info_extra_top {
	// Override this template to insert extra information into person info on top.
}

template person_info_extra_bot {
	// Override this template to insert extra information into person info below.
}

// List with all data about a user for use in the overview or search results.
template person_info(p : Person) {
	ul[class="list-group list-group-flush"] {
		person_info_extra_top
		person_item("fas fa-venus-mars", "Gender", true){output( p.gender)}
		person_item("fas fa-birthday-cake", "Birthday", true){output( p.birthday)}
		person_item("fas fa-city", "Birth Place", p.birthplace != null && p.birthplace.length() > 0){output( p.birthplace)}
		person_item("fas fa-cross", "Alive", p.passingdate != null){output(p.passingdate)}
		person_item("fas fa-birthday-cake", "Age", true){output(p.getAge() + " years")}
		for(parent : Person in p.parents) {
			person_item_link(parent, "fas fa-user", "Parent")
		}
		if(p.parents.length < 2) {
			person_item("fas fa-user", "Parent", false)
		}
		if(p.parents.length < 1) {
			person_item("fas fa-user", "Parent", false)
		}
		person_info_extra_bot
	}
}

// Display children prepended with a prepended font-awesome class
// value should be an boolean expression to check if the children should be used
// or the place holder.
template person_item(symbol : String, placehold : String, value : Bool) {
	li[class="list-group-item"] {
		div[class="float-start"] {
			faIcon[class=symbol]
		}
		div[class="float-end"] {
			if(value) {
				elements				
			} else {
				<span class="text-muted">output(placehold)</span>
			}
			
		}
	}
}

// Display a url to this person prepended with a symbol 
template person_item_link(p : Person, symbol : String, placehold : String) {
	if (p != null) {
		navigate person(p)[class="list-group-item", style="z-index:2; position:'inherit'"] {
			div[class="float-start"] {
				faIcon[class=symbol]
			}
			div[class="float-end"] {
				output(p.fullname())
			}
		}
	} else {
		person_item(symbol, placehold, false)
	}
}

// Display children prepended with a string.
template person_item(key : String) {
	li[class="list-group-item"] {
		div[class="float-start"] {
			output(key)
		}
		div[class="float-end"] {
			elements
		}
	}
}