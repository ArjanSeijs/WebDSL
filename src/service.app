module src/service

imports src/search

service user_login() {
	if(getHttpMethod() == "POST") {
		var response := JSONObject();
		var request := JSONObject(readRequestBody());
		var username := request.getString("username");
		var password := request.getString("password");
		
		
		if(authenticate(username, password)) {
			response.put("status", "success");
			response.put("username", username);
			response.put("message", "You are now logged in");
		} else {
			response.put("status", "denied");
			response.put("message", "Invalid credentials");
		}
		return response;
	}
}

service user_register() {
	if(getHttpMethod() == "POST") {
		var response := JSONObject();
		var request := JSONObject(readRequestBody());
		var username := request.getString("username");
		var password := request.getString("password");
		if(findUser(username) == null) {
			var u := User{username:=username,password:=(password as Secret).digest()};
			u.save();	
			authenticate(username, password);
			response.put("status", "success");
			response.put("username", username);
			response.put("message", "You are now registered");
		} else {
			response.put("status", "denied");
			response.put("message", "Username taken");
		}
    	return response;
	}
}

service user_logout() {
	if(getHttpMethod() == "GET") {
		var response := JSONObject();		
		if(loggedIn()) {
			logout();
			response.put("status", "success");
			response.put("message", "You are now logged out");
		} else {
			response.put("status", "denied");
			response.put("message", "Failed");
		}
    	return response;    
	}
	
}

service user_name() {
	if(getHttpMethod() == "GET") {
		var response := JSONObject();		
		if(loggedIn()) {
			response.put("status", "loggedin");
			response.put("username", securityContext.principal.username);
		} else {
			response.put("status", "loggedout");
		}
		return response;    
	}
}

function visibleTrees() : List<FamilyTree> {
	var trees := Set<FamilyTree>();
	trees.addAll(securityContext.principal.trees);
	trees.addAll(securityContext.principal.canSee);
	return trees.list();
}

service user_families() {
	if(getHttpMethod() == "GET") {
		var response := JSONObject();
		var array := JSONArray();
		for (f : FamilyTree in visibleTrees()) {
			var obj := JSONObject();
			obj.put("name", f.name);
			obj.put("uuid", f.id);
			array.put(obj);
		}
		response.put("trees", array);  
		return response;  
	}
}

/*
Base used everywhere and to represent parents and siblings.
*/
function jsonPersonBase(p : Person) : JSONObject {
	var obj := JSONObject();
	obj.put("name", p.name); //If this person is referenced by other user.
	obj.put("fullname", p.fullname());
	obj.put("uuid", p.id);
	return obj;
	
}

/**
Used in search results
*/
function jsonPerson(p : Person) : JSONObject {
	var obj := jsonPersonBase(p);
	obj.put("birthday", p.birthday.toString());
	obj.put("family", p.family.name);
	obj.put("gender", p.gender.name);
	if(p.passingdate != null) {
		obj.put("passingdate", p.passingdate.toString());
	}
	if(p.birthplace != null) {
		obj.put("birthplace", p.birthplace);			
	}
	return obj;
}

/*
Used in family overview
*/
function jsonPersonParents(p : Person) : JSONObject {
	var obj := jsonPerson(p);
	var parents := JSONArray();
	for(parent : Person in p.parents) {
		parents.put(jsonPersonBase(parent));
	}
	obj.put("parents", parents);
	return obj;
}

/**
Used in personOverview and personEdit
*/
function jsonPersonAll(p : Person) : JSONObject {
	var obj := jsonPersonParents(p);
	var children := JSONArray();
	var siblings := JSONArray();
	
	obj.put("firstname", p.firstname);
	if(p.middlenames != null) {
		obj.put("middlenames", p.middlenames);		
	}
	if(p.lastname != null) {
		obj.put("lastname", p.lastname);
	}
	if(p.description != null) {
		obj.put("description", p.description);
	}
	for(child : Person in p.children) {
		children.put(jsonPersonBase(child));
	}
	for(sibling : Person in p.siblings()) {
		siblings.put(jsonPersonBase(sibling));
	}
	obj.put("children", children);
	obj.put("siblings", siblings);
	return obj;
}

/**
Get all information about a person.
*/
service user_person(p : Person) {
	if(getHttpMethod() == "GET") {
		var response := JSONObject();
		var obj := jsonPersonAll(p);
		response.put("canEdit", canEdit(p.family));
		response.put("owner", p.family.owner.username);
		response.put("person", obj);
		return response;
	}
}

service user_validParents(p : Person) {
	if(getHttpMethod() == "GET") {
		var response := JSONObject();
		var parents := JSONArray();
		for(parent : Person in p.validAllowedParents()) {
			parents.put(jsonPersonBase(parent));
		}
		response.put("parents", parents);
		return response;
	}
}


service user_newPerson(f : FamilyTree) {
	if(getHttpMethod() == "POST") {
		var response := JSONObject();
		var p := Person{family := f, firstname := "Name", gender := Male, birthday := now()};
		p.save();
		response.put("uuid", p.id);
		response.put("status", "success");
		return response;
	}
}

service user_editPerson(p : Person) {
	if(getHttpMethod() == "POST") {
		var response := JSONObject();
		var json := JSONObject(readRequestBody());
		
		if(json.has("firstname")) {
			p.firstname := json.getString("firstname");
		}
		if(json.has("middlenames")) {
			p.middlenames := json.getString("middlenames");
		}
		if(json.has("lastname")) {
			p.lastname := json.getString("lastname");
		}
		
		if(json.has("birthplace")) {
			p.birthplace := json.getString("birthplace");
		}
		if(json.has("birthday")) {
			p.birthday := Date(json.getString("birthday"), "yyyy-MM-dd");
		}
		if(json.has("passingdate")) {
			p.passingdate := Date(json.getString("passingdate"), "yyyy-MM-dd");
		}
		
		if(json.has("gender")) {
			case(json.getString("gender")) {
				"Male" {
					p.gender := Male;
				}
				"Female" {
					p.gender := Female;
				}
				"Other" {
					p.gender := Other;
				}
			}
		}
		if(json.has("description")) {
			p.description := json.getString("description") as WikiText;
		}
		if(json.has("parents")) {
			var parents := json.getJSONArray("parents");
			// Check correct length
			if(parents.length() > 2) {
				response.put("status", "failed");
				response.put("message", "max two parents");
				return response;
			}
			
			// Check correct attributes
			var r := valid([
				valid(!(parents.length() == 2 && !parents.getJSONObject(1).has("uuid")), "Missing paremter uuid on parent[1]"),
				valid(!(parents.length() >= 1 && !parents.getJSONObject(0).has("uuid")), "Missing paremter uuid on parent[0]"),
				valid(!(parents.length() == 2 && findParent(p, parents.getJSONObject(1).getString("uuid")) != null), "Parent[1] does not exist"),
				valid(!(parents.length() >= 1 && findParent(p, parents.getJSONObject(0).getString("uuid")) != null), "Parent[0] does not exist")
			]);
			if(r != null) {
				return r;
			}
			p.parents.clear();
			if(parents.length() >= 1) {
				p.parents.add(findParent(p, parents.getJSONObject(0).getString("uuid")));
			}
			if(parents.length() >= 2) {
				p.parents.add(findParent(p, parents.getJSONObject(1).getString("uuid")));
			}
		
		}
		p.save();
		response.put("status", "success");
		response.put("message", "Saved");
    	return response;
	}
}
/*
 If result is nonnull return error to client
*/
function valid(b : Bool, m : String) : JSONObject {
	if(b) {
		return null;
	}
	var response := JSONObject();
	response.put("status", "failed");
	response.put("message", m);
    return response;
}

/**
Concat error messages for multiple responses.
*/
function valid(responses : [JSONObject]) : JSONObject {
	var b := true;
	var m := "";
	for(r : JSONObject in responses where r != null) {
		b := false;
		m := m + "\n" + r.getString("message");
	}
	if(b) {
		return null;
	}
	var response := JSONObject();
	response.put("status", "failed");
	response.put("message", m);
	return response;
}

/**
* Find valid parent with id
*/
function findParent(p : Person, s : String) : Person {
	var found := [parent | parent : Person in p.validAllowedParents() where parent.id.toString() == s limit 1];
	if(found.length == 0) {
		return null;
	} 
	return found[0];
}

/*
Get all people with limited information about this person.
*/
service user_people(f : FamilyTree) {
	if(getHttpMethod() == "GET") {
		var response := JSONObject();
		var people := JSONArray();
		for (p : Person in f.people) {
			var obj := jsonPersonParents(p);
			var parents := JSONArray();
			if(p.passingdate != null) {
				obj.put("passingdate", p.passingdate.toString());
			}
			if(p.birthplace != null) {
				obj.put("birthplace", p.birthplace);			
			}
			for(parent : Person in p.parents) {
				parents.put(parent.id);
			}
			obj.put("parents", parents);
			people.put(obj);
		}
		response.put("people", people);
		response.put("name", f.name);
		response.put("owner", f.owner.username);
		return response;
	}
}

service user_setFamilyName(f : FamilyTree) {
	if(getHttpMethod() == "PUT") {
        f.name := readRequestBody();
        return f.name;
     }
}

service user_newFamily() {
	if(getHttpMethod() == "POST") {
		var response := JSONObject();
		var name := readRequestBody();
		var t := FamilyTree{name := name, owner := securityContext.principal};
		t.save();
		response.put("name", name);   
		response.put("uuid", t.id);
		return response;
	}
}

service sv_search(query : String) {
	if(getHttpMethod() == "GET") {
		var response := JSONObject();
		var trees := JSONArray();
		for (f : FamilyTree in searchtree(query)) {
			var obj := JSONObject();
			obj.put("name", f.name);
			obj.put("uuid", f.id);
			trees.put(obj);
		}
		var people := JSONArray();
		for (p : Person in searchperson(query)) {
			var obj := jsonPerson(p);
			people.put(obj);
		}
		response.put("trees", trees);
		response.put("people", people);
		return response;
	}
}

type String {
  utils.File.createFromFilePath as pathToImage() : Image
}


service expire-cache getImageFile(p : Person){
	var default := "./images/user-default.png".pathToImage();
	if(p.icon != null) {
		p.icon.download();
	} else {
		default.download();
	}
}