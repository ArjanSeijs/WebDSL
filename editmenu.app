module editmenu

imports FamilyTree
imports entities
imports tree
imports templates

native class java.util.UUID as UID {
  static fromString(String) : UID
}

template family_edit_menu(t : FamilyTree) {
	//https://getbootstrap.com/docs/5.0/components/accordion/
	div[class="accordion bg-white sticky-top", id="family_edit_menu"] {
		family_edit_menu_item("Add Family Member", "new_person") {
			family_edit_new_person(t)
		}
		family_edit_menu_item("Add Sibling to Person", "new_sibling") {
			family_edit_new_sibling(t)
		}
		family_edit_menu_item("Add Child to Person", "new_child") {
			family_edit_new_child(t)
		}
		family_edit_menu_item("Add Parent to Person", "new_parent") {
			family_edit_new_parent(t)
		}
		family_edit_menu_item("Add Existing person as Sibling", "add_sibling") {
			family_edit_add_sibling(t)
		}
		family_edit_menu_item("Add Existing person as Child / Parent", "add_child") {
			family_edit_add_child(t)
		}
		if(securityContext.principal == t.owner) {
			family_edit_menu_item("Manage permissions", "manage_permissions") {
				family_edit_permissions(t)
			}	
		}
	}
	<script>
	var myCollapsible = document.getElementById('family_edit_menu')
	myCollapsible.addEventListener('show.bs.collapse', function (e) {
		window.location.hash = e.originalTarget.id
	})

	function selectmode(op) {
		function listener(ev) {
			$(".person-link").unbind("click", listener)
			console.log(ev)
			ev.target.parentElement.querySelector("button[name='"+op+"']").click()
			return false;
		}
		$(".person-link").click(listener)
	}
	//Add the hash the form for opening the menu again
	function redirecthash(e) {
	  e.action=e.action+location.hash;
		return true;
	}
	$(document).ready(function(){
		if(window.location.hash) {
		  $(window.location.hash).addClass('show')
    	  $(window.location.hash.replace('collapse','heading') + '> .accordion-button').removeClass('collapsed')
		}
	})
	
	
	</script>
}

template family_edit_menu_item(title : String, item_id : String) {
	div[class="accordion-item"] {
		h2[class="accordion-header", id="heading_" + item_id] {
			button[class="accordion-button collapsed", type="button", data-bs-toggle="collapse", data-bs-target="#collapse_" + item_id, aria-expanded="false", aria-controls="collapse_" + item_id] {
				output(title)
			}
		}
		div[id="collapse_" + item_id, class="accordion-collapse collapse", aria-labelledby="heading_" + item_id, data-bs-parent="#family_edit_menu"] {
			div[class="accordion-body"] {
				elements
			}
		}
	}
}

template family_edit_permissions(t : FamilyTree) {
	var username : String
	var edit : Bool := true
	var view : Bool := true
	form[onsubmit = "redirecthash(this)"] {
		div[class="form-check"] {
			label("Public")[class="form-check-label"] { 
			    input(t.public)[class="form-check-input", onchange := save()]
			}
		}
	}
	form[onsubmit = "redirecthash(this)"] {
		div[class="form-group"] {
			label("Name: ")[class="form-label"] { 
			    input(username)[class="form-control w-100"]
			}
		}
		div[class="row"] {
			div[class="col col-md-6"] {
				div[class="form-check"] {
					label("Can edit ")[class="form-check-label"] { 
					    input(edit)[class="form-check-input"]
					}
				}
				
				div[class="form-check"] {
					label("Can view ")[class="form-label"] { 
					    input(view)[class="form-check-input"]
					}
				}
			}
			div[class="col col-md-6 m-auto"] {
				submit permission()[class="btn btn-primary"] {<i class="fas fa-user-plus"></i>}				
			}
		}
	}
	form[onsubmit = "redirecthash(this)"] {
		if(t.canSee.length > 0) {
			label("Viewers") {
				<hr>
				for(u in t.canSee) {
					<div class="input-group">
					  span[class="form-control"] {
					  	output(u.username)
					  }
					  <div class="input-group-append">
					    submit removeCanSee(u)[class="btn btn-primary"] {<i class="fa fa-user-times"></i>}
					  </div>
					</div>
				}
			}
			<hr>
		}
		if(t.canEdit.length > 0) {
			label("Editors") {
				<hr>	
				for(u in t.canEdit) {
					<div class="input-group">
					  span[class="form-control"] {
					  	output(u.username)
					  }
					  <div class="input-group-append">
					    submit removeCanEdit(u)[class="btn btn-primary"] {<i class="fas fa-user-times"></i>}
					  </div>
					</div>
				}
			}
		}
				
	}
	
	action removeCanSee(u : User) {
		t.canEdit.remove(u);
		t.canSee.remove(u);
		t.save();
	}
	
	action removeCanEdit(u : User) {
		t.canEdit.remove(u);
		t.save();
	}
	
	action permission() {
		var user := findUser(username);
		validate(user != null, "User does not exists");
		if(view) {
			t.canSee.add(user);
		}
		if(edit) {
			t.canSee.add(user);
			t.canEdit.add(user);
		}
		t.save();
	}
	
	action save() {
		t.save();
	}
}

template family_edit_person(p : Person) {
	label("Firstname: ")[class="form-label"] { 
	    inputajax(p.firstname)[class="form-control w-100"]
	}
	label("Middlename(s): ")[class="form-label"] { 
	    input(p.middlenames)[class="form-control w-100"]
	}
	label("Lastname: ")[class="form-label"] { 
	    input(p.lastname)[class="form-control w-100"]
	}
	label("Gender: ")[class="form-label"] { 
	    input(p.gender)[class="form-control w-100"]
	}
	label("Date of birth: ")[class="form-label"] {
		dateinput(p.birthday)[class="form-control w-100"]
	}
}

template family_edit_new_person(t : FamilyTree) {
	var p := Person{}
	form[onsubmit = "redirecthash(this)"] {
		family_edit_person(p)
		submit save()[class="btn btn-primary"] {<i class="fas fa-user-plus"></i>}
	}
	action save() {
		t.people.add(p);
		p.save();
		goto person_edit(p);
	}
}

template personselector(t : FamilyTree, lbl : String, p : ref Person, selectmode : String) {
	label(lbl)[class="form-label"] {
			div[class="input-group"] {
				selectajax(p, t.people.list())[class="form-control"]
					div[class="input-group-append"] {
	    			button[class="btn btn-outline-secondary", type="button", onclick:="selectmode('"+selectmode+"')"]{<i class="fas fa-user-tag"></i>}
 				}	
			}
			
		}
}

session edit_new_sibling {
	p : Person
}

template family_edit_new_sibling(t : FamilyTree) {
	var sibling := Person{}
	
	form[onsubmit = "redirecthash(this)"] {
		label("Add sibling to: ")[class="form-label"] {
			div[class="input-group"] {
				select(edit_new_sibling.p, t.people.list())[class="form-control"]
					div[class="input-group-append"] {
	    			button[class="btn btn-outline-secondary", type="button", onclick:="selectmode('edit-new-sibling')"]{<i class="fas fa-user-tag"></i>}
 				}	
			}
			
		}
		family_edit_person(sibling)
		submit save()[class="btn btn-primary"] {<i class="fas fa-user-plus"></i>}
	}
	action save() {
		validate(edit_new_sibling.p != null, "Select person");
		
		if(edit_new_sibling.p.parents.length > 0 ) {
			sibling.parents.addAll(edit_new_sibling.p.parents);	
		} else {
			var parent : Person := Person{firstname:="Unkown parent", birthday := Date("01/01/1971"), gender := Other};
			sibling.parents.add(parent);
			edit_new_sibling.p.parents.add(parent);
			t.people.add(parent);
		}
		
		t.people.add(sibling);
		
		edit_new_sibling.p.save();
		sibling.save();
		t.save();
		goto person_edit(sibling);
	}
}

session edit_add_sibling {
	p : Person
	sibling : Person
}

template family_edit_add_sibling(t : FamilyTree) {
	form[onsubmit = "redirecthash(this)"] {
		personselector(t, "Add", edit_add_sibling.p, "edit-add-sibling-p")
		personselector(t, "as sibling to", edit_add_sibling.sibling, "edit-add-sibling-s")
		// label("Add")[class="form-label"] { 
		//     select(edit_add_sibling.p, t.people.list())[class="form-control w-100"]
		// }
		// label("as sibling to: ")[class="form-label"] { 
		//     select(edit_add_sibling.sibling, t.people.list())[class="form-control w-100"]
		// }
		submit save()[class="btn btn-primary"] {<i class="fa fa-user-plus"></i>}
	}
	action save() {
		validate(edit_add_sibling.p != null && edit_add_sibling.sibling != null, "Select person");
		validate(edit_add_sibling.p != edit_add_sibling.sibling, "Can't be a sibling of yourself");
		validate(edit_add_sibling.p.parents.length == 0 || edit_add_sibling.sibling.parents.length == 0, "Can't add relation, both person already have parents");
		
		if(edit_add_sibling.p.parents.length == 0 && edit_add_sibling.sibling.parents.length == 0) {
			var parent : Person := Person{firstname:="Unkown parent", birthday := Date("01/01/1971"), gender := Other};
			t.people.add(parent);
			edit_add_sibling.p.parents.add(parent);
			edit_add_sibling.sibling.parents.add(parent);	
		} else if(edit_add_sibling.p.parents.length == 0) {
			edit_add_sibling.p.parents.addAll(edit_add_sibling.sibling.parents);
		} else {
			edit_add_sibling.sibling.parents.addAll(edit_add_sibling.p.parents);
		}
		
		t.save();
		edit_add_sibling.sibling.save();
		edit_add_sibling.p.save();
	}
}

session edit_new_child {
	p1 : Person
	p2 : Person
}

template family_edit_new_child(t : FamilyTree) {
	var child := Person{}
	form[onsubmit = "redirecthash(this)"] {
		personselector(t, "Add child to: ", edit_new_child.p1, "edit-new-child-p1")
		personselector(t, "With: ", edit_new_child.p2, "edit-new-child-p2")
		// label("Add Child to: ")[class="form-label"] { 
		//     select(edit_new_child.p1, t.people.list())[class="form-control w-100"]
		// }
		// label("With: ")[class="form-label"] { 
		//     select(edit_new_child.p2, t.people.list())[class="form-control w-100"]
		// }
		family_edit_person(child)
		submit save()[class="btn btn-primary"] {<i class="fas fa-user-plus"></i>}
	}
	
	action save() {
		validate(edit_new_child.p1 != null, "Select person");
		child.parents.add(edit_new_child.p1);
		if(edit_new_child.p2 != null) {
			child.parents.add(edit_new_child.p2);	
		}
		t.people.add(child);
		
		child.save();
		edit_new_child.p1.save();
		if(edit_new_child.p2 != null) {
			edit_new_child.p2.save();
		}
		t.save();
		goto person_edit(child);
	}
}

session edit_add_child {
	p1 : Person
	p2 : Person
	child : Person
}

template family_edit_add_child(t : FamilyTree) {
	form[onsubmit = "redirecthash(this)"] {
		personselector(t, "Add child to: ", edit_add_child.p1, "edit-add-child-p1")
		personselector(t, "With: ", edit_add_child.p2, "edit-add-child-p2")
		personselector(t, "Child: ", edit_add_child.child, "edit-add-child-c")
		// label("Add Child to: ")[class="form-label"] { 
		//     select(edit_add_child.p1, t.people.list())[class="form-control w-100"]
		// }
		// label("With: ")[class="form-label"] { 
		//     select(edit_add_child.p2, t.people.list())[class="form-control w-100"]
		// }
		// label("Child: ")[class="form-label"] { 
		//     select(edit_add_child.child, t.people.list())[class="form-control w-100"]
		// }
		submit save()[class="btn btn-primary"] {<i class="fa fa-user-plus"></i>}
	}
	
	action save() {
		validate(edit_add_child.p1 != null, "Select parent(s)");
		validate(edit_add_child.child != null, "Select child");
		validate(edit_add_child.child.parents.length == 0, "Child already has parent(s)");
		
		edit_add_child.child.parents.add(edit_add_child.p1);
		if(edit_add_child.p2 != null) {
			edit_add_child.child.parents.add(edit_add_child.p2);
		}
		
		edit_add_child.p1.save();
		if(edit_add_child.p2 != null) {
			edit_add_child.p2.save();
		}
		edit_add_child.child.save();
		t.save();
	}
}

session edit_new_parent {
	p : Person
}

template family_edit_new_parent(t : FamilyTree) {
	var parent := Person{}
	form[onsubmit = "redirecthash(this)"] {
		personselector(t, "Add Parent to: ", edit_new_parent.p, "edit-new-parent")
		// label("Add Parent to: ")[class="form-label"] { 
		//     select(edit_new_parent.p, t.people.list())[class="form-control w-100"]
		// }
		family_edit_person(parent)
		submit save()[class="btn btn-primary"] {<i class="fas fa-user-plus"></i>}
	}
	
	action save() {
		validate(edit_new_parent.p != null, "Select person");
		validate(edit_new_parent.p.parents.length < 2, "Person " + edit_new_parent.p.fullname() + " already has two parents");
		edit_new_parent.p.parents.add(parent);
		t.people.add(parent);
		
		edit_new_parent.p.save();
		parent.save();
		t.save();
		goto person_edit(parent);
	}
}