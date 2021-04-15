module src/family

imports FamilyTree
imports src/entities
imports src/tree
imports src/templates
imports src/editmenu
imports src/header

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
		// Toggle visibilty of edit field
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

template confirm_delete(t : FamilyTree) {
	confirm_modal(t.name){submit delete()[class="btn btn-primary"]{<i class="fa fa-check-square hov-pointer"></i>}}
	action delete() {
		validate(loggedIn() && securityContext.principal == t.owner, "Only owner can delete");
		FamilyTree.delete(t);
		goto root();
	}
}

template family_overview_cards(t : FamilyTree) {
	div[class="row"] {
		for(p : Person in t.people order by p.fullname().toLowerCase().trim()) {
			div[class="col-md-4 p-1"] {
				personcardsmall(p)					
			}
		}
	}
}

template family_overview_header(t : FamilyTree) {
	h1[id="name"] {
		output(t.name)	" " 
		// Toggle button
		if(loggedIn() && securityContext.principal == t.owner){
			<i class="fas fa-edit hov-pointer" onclick="toggle()"></i>
		} 
	}
	// Content to be toggled
	if(loggedIn() && securityContext.principal == t.owner){
		family_edit_name(t)
	}
}

template family_edit_name(t : FamilyTree) {
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
	
	action save() {
		validate(loggedIn() && securityContext.principal == t.owner, "Only owner can edit");
		t.save();
	}
	
}