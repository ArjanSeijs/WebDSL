module person

imports FamilyTree
imports entities
imports tree
imports templates
imports editmenu



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
	title {output(p.fullname())}
	main {
		myheader
		if(p != null) {
			personcard(p)
		}
	}
	
}

page family_overview(t : FamilyTree) {
	title {"Family: " output(t.name)}
	main {
		myheader
		div[class="container p-2"] {
			family_overview_header(t)
			div[class="row"] {
				if(canEdit(t)) {
					div[class="col col-md-9"] {
						family_overview_cards(t)
					}
					div[class="col col-md-3"] {
						family_edit_menu(t)
					}
				} else {
					family_overview_cards(t)
				}
			}
		}
	}
	if(loggedIn() && securityContext.principal == t.owner){
		<script>
		function toggle() {
			$('#name').toggleClass('d-none');
			$('#edit_name').toggleClass('d-none');
		}
		</script>
	}
	if(loggedIn() && securityContext.principal == t.owner) {
		confirm_delete(t)	
	}
	
}

template family_overview_cards(t : FamilyTree) {
	div[class="row"] {
		for(p : Person in t.people order by p.fullname().toLowerCase().trim()) {
			div[class="col-md-3 p-1"] {
				personcardsmall(p)					
			}
		}
	}
}

template family_overview_header(t : FamilyTree) {
	h1[id="name"] {
		output(t.name)	" " 
		if(loggedIn() && securityContext.principal == t.owner){
			<i class="fas fa-edit hov-pointer" onclick="toggle()"></i>	
		}
	}
	if(loggedIn() && securityContext.principal == t.owner){
		div[id="edit_name", class="bg-white d-none"] {
			form {
				div[class="input-group mb-3"] {
					inputajax(t.name)[class="form-control", aria-label="Family Name"]
					div[class="input-group-append"] {
						submit save()[class="btn btn-outline-secondary"]{<i class="far fa-save hov-pointer"></i>}
					}
					div[class="input-group-append"] {
						button[class="btn btn-primary", data-bs-toggle="modal", data-bs-target="#confirm_delete"] {
								<i class="fa fa-trash hov-pointer"></i>
						}
					}
				}
			}
		}
	}
	action save() {
		validate(loggedIn() && securityContext.principal == t.owner, "Only owner can edit");
		t.save();
	}
}

template confirm_modal(name : String) {
	<div class="modal fade" id="confirm_delete" tabindex="-1" aria-labelledby="confirmDelete" aria-hidden="true">
	  <div class="modal-dialog">
	    <div class="modal-content">
	      <div class="modal-header">
	        <h5 class="modal-title">"Deleting " output(name)</h5>
	        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
	      </div>
	      <div class="modal-body">
                <p>"Are you sure? "</p>
	      </div>
	      <div class="modal-footer">
	        elements
	      </div>
	    </div>
	  </div>
	</div>
}

template confirm_delete(t : FamilyTree) {
	//https://getbootstrap.com/docs/5.0/components/modal/
	confirm_modal(t.name){submit delete()[class="btn btn-primary"]{<i class="fa fa-check-square hov-pointer"></i>}}
	action delete() {
		validate(loggedIn() && securityContext.principal == t.owner, "Only owner can delete");
		FamilyTree.delete(t);
		goto root();
	}
}

template personedit(p : Person) {
	//https://getbootstrap.com/docs/5.0/forms/layout/
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
							input(p.icon)[class="form-control w-100"]
						}
					}
					
					//Next row
					div[class="col-md-8"] {
						label("Description: ")[class="form-label"] {
							input(p.description)[class="form-control w-100 h-75", onkeyup:=update()]
						}
					}
					div[class="col-md-4"] {
						userImage(p)
					}
					
					//next row
					div[class="col-md-12"] {
						placeholder preview descpreview(p)
						
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

template personcardsmall(p : Person) {
	card {
		userImage(p)[class="small"]
		div[class="card-body"] {
			h5 {output(p.fullname())}
			ul[class="list-group list-group-flush"] {
				person_item("Gender"){output( p.gender)}
				person_item("Birthday"){output( p.birthday)}
				person_item("Birth Place"){output( p.birthplace)}
				person_item("Day of passing"){output(p.passingdate)}
				person_item("Age"){output(p.getAge() + " years")}
				for(parent : Person in p.parents) {
					person_item("Parent"){output(parent.fullname())}
				}
			}
		}
		navigate person(p)[class="stretched-link person-link"]{}
		if(canEdit(p.family)) {
			button[onclick := edit_new_sibling(p), class="d-none", name="edit-new-sibling"]
		
			button[onclick := edit_add_sibling_p(p), class="d-none", name="edit-add-sibling-p"]
			button[onclick := edit_add_sibling_s(p), class="d-none", name="edit-add-sibling-s"]
			
			button[onclick := edit_new_child_p1(p), class="d-none", name="edit-new-child-p1"]
			button[onclick := edit_new_child_p2(p), class="d-none", name="edit-new-child-p2"]
			
			button[onclick := edit_add_child_p1(p), class="d-none", name="edit-add-child-p1"]
			button[onclick := edit_add_child_p2(p), class="d-none", name="edit-add-child-p2"]
			button[onclick := edit_add_child_c(p), class="d-none", name="edit-add-child-c"]
			
			button[onclick := edit_new_parent(p), class="d-none", name="edit-new-parent"]
		}
		
	}
	
	action edit_new_sibling(person : Person) {
		validate(canEdit(p.family), "Not allowed to edit");
		edit_new_sibling.p := person;
	}
	
	
	
	action edit_add_sibling_p(person : Person) {
		validate(canEdit(p.family), "Not allowed to edit");
		edit_add_sibling.p := person;
	}
	
	action edit_add_sibling_s(person : Person) {
		validate(canEdit(p.family), "Not allowed to edit");
		edit_add_sibling.sibling := person;
	}
	
	
	
	action edit_new_child_p1(person : Person) {
		validate(canEdit(p.family), "Not allowed to edit");
		edit_new_child.p1 := person;
	}
	
	action edit_new_child_p2(person : Person) {
		validate(canEdit(p.family), "Not allowed to edit");
		edit_new_child.p2 := person;
	}
	
	
	
	action edit_add_child_p1(person : Person) {
		validate(canEdit(p.family), "Not allowed to edit");
		edit_add_child.p1 := person;
	}
	
	action edit_add_child_p2(person : Person) {
		validate(canEdit(p.family), "Not allowed to edit");
		edit_add_child.p2 := person;
	}
	
	action edit_add_child_c(person : Person) {
		validate(canEdit(p.family), "Not allowed to edit");
		edit_add_child.child := person;
	}
	
	
	
	action edit_new_parent(person : Person) {
		validate(canEdit(p.family), "Not allowed to edit");
		edit_new_parent.p := person;
	}
}

template personcard(p : Person) {
	//https://getbootstrap.com/docs/5.0/layout/grid/
	//https://getbootstrap.com/docs/5.0/layout/containers/
	//https://getbootstrap.com/docs/5.0/components/list-group/
	var siblings := p.siblings()
	
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
					<ul class="pagination pagination-lg" style="vertical-align: top;display: inline;">
					    <li class="page-item text-center">
					       navigate person_edit(p)[class="page-link"]{<i class="fas fa-3x fa-user-edit"></i>}
					    </li>
					    <li class="page-item text-center">
					    	navigate direct_family_tree(p)[class="page-link"]{<i class="fa fa-3x fa-tree"></i>} 
					    </li>
					    <li class="page-item text-center">
					    	navigate family_overview(p.family)[class="page-link"]{<i class="fas fa-3x fa-users"></i>} 
					    </li>
					  </ul>
	            }
			}
			div[class="row gx-0"]  {
				div[class="col col-md-3"]  {
					div[class="card rounded-0"]  {
						div[class="card-header"]  {
							"Information"
						}
						div[class="card-body p-0"]  {
							<ul class="list-group list-group-flush">
								person_item("First Name"){output(p.firstname)}
								person_item("Middle Name(s)"){output(p.middlenames)}
								person_item("Last Name"){output(p.lastname)}
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
								
								if(siblings.length > 0) {
									<li class="list-group-item"></li>
								}
								for(s : Person in siblings) {
									sibling(s)
									
								}
							</ul>
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

template userImage(p : Person) {
	if(p.icon != null) {
		output(p.icon)[class="user-image", all attributes]
	} else {
		image("/images/user-default.png")[class="user-image", all attributes]
	}
}

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