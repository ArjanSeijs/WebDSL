module src/service

service user_login() {
	var response := JSONObject();
	if(getHttpMethod() == "POST") {
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
        
	}
	return response;
}

service user_register() {
	var response := JSONObject();
	if(getHttpMethod() == "POST") {
		var request := JSONObject(readRequestBody());
		var username := request.getString("username");
		var password := request.getString("password");
		if(findUser(username) == null) {
			var u := User{username:=username,password:=(password as Secret).digest()};
			u.save();	
			response.put("status", "success");
			response.put("username", username);
			response.put("message", "You are now registered");
		} else {
			response.put("status", "denied");
			response.put("message", "Username taken");
		}
	}
    return response;
}

service user_logout() {
	var response := JSONObject();
	log("Logging out: " + getHttpMethod());
	if(getHttpMethod() == "GET") {		
		if(loggedIn()) {
			logout();
			response.put("status", "success");
			response.put("message", "You are now logged out");
		} else {
			response.put("status", "denied");
			response.put("message", "Failed");
		}
        
	}
	return response;
}

service user_name() {
	var response := JSONObject();
	if(getHttpMethod() == "GET") {		
		if(loggedIn()) {
			response.put("status", "loggedin");
			response.put("username", securityContext.principal.username);
		} else {
			response.put("status", "loggedout");
		}
        
	}
	return response;
}

service user_families() {
	var response := JSONObject();
	if(getHttpMethod() == "GET") {
		var array := JSONArray();
		for (f : FamilyTree in securityContext.principal.trees) {
			var obj := JSONObject();
			obj.put("name", f.name);
			obj.put("uuid", f.id);
			array.put(obj);
		}
		response.put("trees", array);    
	}
	return response;
}