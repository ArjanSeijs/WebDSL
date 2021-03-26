module authentication

imports bootstrap
imports entities
imports person
imports authentication
imports tree
imports templates
imports editmenu

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
	
	
	function canEdit(t : FamilyTree) : Bool {
		return loggedIn() && (securityContext.principal == t.owner || securityContext.principal in t.canEdit);
	}
	
	function canSee(t : FamilyTree) : Bool {
		return t.public || (loggedIn() && (securityContext.principal == t.owner || securityContext.principal in t.canSee));
	}
	
	principal is User with credentials username, password

  	access control rules
  	
  	
  	
	rule page loginPage() {true}
	rule page register(){true}
    rule page root(){true}
    // rule page account(){loggedIn()}
    // rule page user(*) {true}
    rule page direct_family_tree(p : Person) {canSee(p.family)}
    rule page family_overview(t: FamilyTree) {canSee(t)}
    rule page person_edit(p : Person) {canEdit(p.family)} 
    rule page person(p : Person) {canSee(p.family)}
    rule page search(*) {true}
     
	rule template item {true}
	rule template personcard(p : Person) {canSee(p.family)} 
	rule template personcardsmall(p : Person) {canSee(p.family)} 
	rule template person_edit(p : Person) {canEdit(p.family)} 
	
	rule template family_edit_menu(t : FamilyTree) {canEdit(t)}
	
	rule template family_edit_new_person(t : FamilyTree) {canEdit(t)}
	rule template family_edit_new_sibling(t : FamilyTree) {canEdit(t)}
	rule template family_edit_new_parent(t : FamilyTree) {canEdit(t)}
	rule template family_edit_new_child(t : FamilyTree) {canEdit(t)}
	rule template family_edit_add_sibling(t : FamilyTree) {canEdit(t)}
	rule template family_edit_add_child(t : FamilyTree) {canEdit(t)}
	rule template family_edit_permissions(t : FamilyTree) {securityContext.principal == t.owner}
	
	rule template * {true}
	rule template *(*) {true}
	
	rule ajaxtemplate descpreview(p:Person){canEdit(p.family)}