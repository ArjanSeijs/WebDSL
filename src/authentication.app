module src/authentication

imports src/bootstrap
imports src/entities
imports src/person
imports src/tree
imports src/templates
imports src/editmenu
imports src/header
imports src/service
imports src/search

	template logoutcard() {
		form {submitlink signoffAction()[class="nav-link"]{"Logout" }}
		action signoffAction() {
			logout();
			goto root();
		}
	}
	
	template registercard() {
		//https://getbootstrap.com/docs/5.0/forms/input-group/
		var user := User{}
  		var p : Secret
		<div class="card">
		
		<article class="card-body">
		<h4 class="card-title text-center mb-4 mt-1">"Register"</h4>
		<hr>
			form {
				label("Email (Optional): ")[class="form-label"] { 
			    	<div class="input-group mb-3">
			    		<span class="input-group-text"><i class="fas fa-envelope-square"></i> </span>
			    		input(user.email)[class="form-control"]
			    	</div> 
			    }
				label("Username: ")[class="form-label"] { 
			    	<div class="input-group mb-3">
			    		<span class="input-group-text"><i class="fa fa-user"></i> </span>
			    		input(user.username)[class="form-control"]
			    	</div> 
			    }
			    label("Password: ")[class="form-label"] {
			    	<div class="input-group mb-3">
			    		<span class="input-group-text"><i class="fa fa-lock"></i> </span>
			    		input(user.password)[class="form-control"] 
			    	</div>
			    }
			    label("Repeat Password: ")[class="form-label"] {
			    	<div class="input-group mb-3">
			    		<span class="input-group-text"><i class="fa fa-lock"></i> </span>
			    		input(p)[class="form-control"] {
			    			validate(user.password == p, "Password does not match") 
			    		} 
			    	</div>
			    }
			    submit register()[class="btn btn-primary"] {"Register "}
			} 
		</article>
		</div>
		
		action register(){
				user.password := user.password.digest();
				user.save();
			    message("You are now registerd.");
		  	}
		
	}
	
	template logincard() {
		var username := ""
		var password : Secret := ""
		<div class="card">
		
		<article class="card-body">
		<h4 class="card-title text-center mb-4 mt-1">"Login"</h4>
		<hr>
			form {
				label("Username: ")[class="form-label"] { 
			    	<div class="input-group mb-3">
			    		<span class="input-group-text"><i class="fa fa-user"></i> </span>
			    		input(username)[class="form-control"]
			    	</div> 
			    }
			    label("Password: ")[class="form-label"] {
			    	<div class="input-group mb-3">
			    		<span class="input-group-text"><i class="fa fa-lock"></i> </span>
			    		input(password)[class="form-control"] 
			    	</div>
			    }
			    submit login()[class="btn btn-primary"] {"Login "}
			} 
		</article>
		</div>
		
		action login(){
			    validate(authenticate(username,password), 
			      "The login credentials are not valid.");
			    message("You are now logged in.");
			}
	}
	
	page register() {
		main {
			<div class="d-flex justify-content-center">
				registercard
			</div>	
		}
	}
	
	page loginPage() {
		main {
			<div class="d-flex justify-content-center">
				logincard
			</div>
		}
	}
	
	override page pagenotfound() {
		title{ "Page not found (404)" }
		main {
			myheader
			<div class="d-flex justify-content-center">
				par{ "That page does not exist!" }
			</div>
		}
	}
	
	override page accessDenied() {
		title{ "Accces denied (401)" }
		main {
			myheader
			<div class="d-flex justify-content-center p-2">
				image("https://imgs.xkcd.com/comics/incident.png")
			</div>
		}
	}
	
	/*
	Check whether the current user (if logged in) has the permission to edit this family tree
	*/
	function canEdit(t : FamilyTree) : Bool {
		return loggedIn() && (securityContext.principal == t.owner || securityContext.principal in t.canEdit);
	}
	
	function canEdit(p : Person) : Bool {
		return canEdit(p.family);
	}
	
	/*
	Check whether the current user (if logged in) has the permission to view this family tree
	*/
	function canSee(t : FamilyTree) : Bool {
		return t.public || (loggedIn() && (securityContext.principal == t.owner || securityContext.principal in t.canSee));
	}
	
	function canSee(p : Person) : Bool {
		return canSee(p.family);
	}
	
	principal is User with credentials username, password

  	access control rules
  	
	rule page loginPage() {true}
	rule page register(){true}
    rule page root(){true}
    rule page accessDenied() {true}
    
    rule page direct_family_tree(p : Person) {canSee(p)}
    rule page family_overview(t: FamilyTree) {canSee(t)}
    rule page family_tree_canvas(p : Person) {canSee(p)}
    rule page person_edit(p : Person) {canEdit(p)} 
    rule page person(p : Person) {canSee(p)}
    rule page search(*) {true}
     
	rule template item {true}
	rule template personcard(p : Person) {canSee(p)} 
	rule template personcardsmall(p : Person) {canSee(p)} 
	rule template person_edit(p : Person) {canEdit(p)} 
	rule template personresult(p : Person) { canSee(p)}
	
	rule template family_edit_menu(t : FamilyTree) {canEdit(t)}
	rule template family_edit_name(t : FamilyTree) {loggedIn() && securityContext.principal == t.owner}
	
	rule template family_edit_new_person(t : FamilyTree) {canEdit(t)}
	rule template family_edit_new_sibling(t : FamilyTree) {canEdit(t)}
	rule template family_edit_new_parent(t : FamilyTree) {canEdit(t)}
	rule template family_edit_new_child(t : FamilyTree) {canEdit(t)}
	rule template family_edit_add_sibling(t : FamilyTree) {canEdit(t)}
	rule template family_edit_add_child(t : FamilyTree) {canEdit(t)}
	rule template family_edit_permissions(t : FamilyTree) {loggedIn() && securityContext.principal == t.owner} //Only owner can edit permissions
	
	rule template familyTreeList {loggedIn()}
	
	rule template * {true}
	rule template *(*) {true}
	
	rule ajaxtemplate descpreview(p:Person){canEdit(p)}
	
	// Acces rule for services
	rule page user_register {true}
	rule page user_login {true}
	rule page user_logout {true}
	rule page user_name {true}
	
	rule page user_families {loggedIn()}
	rule page user_newFamily() {loggedIn()}
	
	rule page user_people(f : FamilyTree) {canSee(f)}
	rule page user_person(p : Person) {canSee(p)}
	rule page getImageFile(p : Person) {canSee(p)}
	rule page user_personTree(p : Person) {canSee(p)}
	
	rule page user_setFamilyName(f : FamilyTree) {canEdit(f)}
	rule page user_newPerson(f : FamilyTree) {canEdit(f)}
	rule page user_deletePerson(p : Person) {canEdit(p)}
	rule page user_editPerson(p : Person) {canEdit(p)}
	rule page user_validParents(p : Person) {canEdit(p)}
	
	rule page sv_search(*) {true}