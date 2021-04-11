module src/tree

imports FamilyTree
imports src/entities
imports src/templates
imports src/header

// Page that shows the direct family of a person
page direct_family_tree(p : Person) {
	template myheaderExtra {
		    item {navigate person_edit(p)[class="nav-link"]{<i class="fas fa-2x fa-user-edit"></i>}}
		    item {navigate direct_family_tree(p)[class="nav-link"]{<i class="fa fa-2x fa-tree"></i>}}
		    item {navigate family_tree_canvas(p)[class="nav-link"]{<i class="fas fa-2x fa-project-diagram"></i>}}
		    item {navigate family_overview(p.family)[class="nav-link"]{<i class="fas fa-2x fa-users"></i>}}
		}
	
	title {"Family Tree of " output(p.fullname())}
	includeCSS("tree.css")
	main {		
		myheader
		direct_family_tree(p)
	}
}
// Inspired by: https://jwcooney.com/2016/08/21/example-pure-css-family-tree-markup/
template direct_family_tree( p : Person) {
	div[class="container-flex min-h-75 p-3"] {
		div[class="tree"] {
			ul {
				if(p.parents.length == 1) {
					li {
						div {
							treeNodePart(p.parents[0])
						}
						ul {
							for(sibling : Person in p.siblings()) {
								direct_family_node(sibling)
							}
							direct_family_node(p)
						}
					}	
				} else if(p.parents.length >= 2) {
					li {
						div {
							treeNodePart(p.parents[0])
							span[class="spacer"] {}
							treeNodePart(p.parents[1])
						}
						ul {
							for(sibling : Person in p.siblings()) {
								direct_family_node(sibling)
							}
							direct_family_node(p)
						}
					}	
				} else {
					direct_family_node(p)
				}
			}
		}
	}
}

template direct_family_node(p : Person) {
	
	li {
		div {
			treeNodePart(p)
			for(partner in p.partners()) {
				 span[class="spacer"] {}
				 treeNodePart(partner)
			}
		}
		if(p.children.length > 0) {
			ul {
				for(c:Person in p.children) {
					direct_family_node(c)
				}
			}
		}
	}
}

template treeNodePart(p : Person) {
	navigate person(p)[class=p.gender.name.toLowerCase()] {
		if(p.passingdate != null) {
			output(p.fullname()) <br> output(p.birthday.getYear()) "-" output(p.passingdate.getYear())
		} else {
			output(p.fullname()) <br> output(p.birthday.getYear()) "-"
		}
	}
}

// Page that displays the canvas using d3 library
page family_tree_canvas(p : Person) {
	template myheaderExtra {
	    item {navigate person_edit(p)[class="nav-link"]{<i class="fas fa-2x fa-user-edit"></i>}}
	    item {navigate direct_family_tree(p)[class="nav-link"]{<i class="fa fa-2x fa-tree"></i>}}
	    item {navigate family_tree_canvas(p)[class="nav-link"]{<i class="fas fa-2x fa-project-diagram"></i>}}
	    item {navigate family_overview(p.family)[class="nav-link"]{<i class="fas fa-2x fa-users"></i>}}
	}
	
	var jsondata := jsonTree(p, 10)
	main {
		myheader
		div[class="container-fluid w-100 h-100 m-3 overflow-hidden"] {
			div[id="tree"] {}	
		}
	}
	includeCSS("d3tree.css")
	<script src="https://d3js.org/d3.v5.min.js"></script>
	<script src="https://cdn.jsdelivr.net/npm/d3plus@2"></script>
		
	<script>
		let familyJson = {data: ~jsondata}
	</script>
	<script src="/FamilyTree/javascript/tree.js"></script>
}

// Transform the data into a json format for use by d3;


function jsonTree(p : Person, depth : Int) : JSONObject {
	//We use the root node as a the 'parent' of this person and this person siblings,
	//and as a 'child' of the parents so that we can get a tree like structure that also includes this person siblings 
	var obj := JSONObject("{}");
	obj.put("name", p.name + "'s family tree");
	
	var children := JSONArray();
	var parents := JSONArray();
	//Add this person
	children.put(jsonChild(p, depth));
	for(sibling : Person in p.siblings()) {
		children.put(jsonChild(sibling, depth));	
	}
	for(parent : Person in p.parents) {
		parents.put(jsonParent(parent, depth));	
	}
	obj.put("children", children);
	obj.put("parents", parents);
	return obj;
}


//Basic information about a person
function json(p : Person) : JSONObject {
	var obj := JSONObject("{}");
	obj.put("name", p.name);
	obj.put("gender", p.gender.name);
	obj.put("uuid", p.id.toString());
	return obj;
}

// Person with spouse and children
function jsonChild(child : Person, depth : Int) : JSONObject {
	var obj := json(child);
	if(depth > 0) {
		obj.put("children", jsonChildren(child, depth - 1));
	}
	var spouses := JSONArray();
  	for(spouse : Person in child.partners()) {
  		var s := JSONObject("{}");
  		s.put("name", spouse.name);
  		s.put("gender", spouse.gender.name);
  		spouses.put(s);
  	}
  	obj.put("spouse", spouses);
	return obj;
}

function jsonChildren(p : Person, depth : Int) : JSONArray {
	var children := JSONArray();
	for(child : Person in p.children) {
		children.put(jsonChild(child, depth));
	}
	return children;
}

// Person with siblings and parents.
function jsonParent(parent : Person, depth : Int) : JSONObject {
	var obj := json(parent);
	if(depth > 0) {
		obj.put("parents", jsonParents(parent, depth - 1));
	}
	var uncles := JSONArray(); //uncles and aunts
  	for(uncle : Person in parent.siblings()) {
  		var s := JSONObject("{}");
  		s.put("name", uncle.name);
  		s.put("gender", uncle.gender.name);
  		uncles.put(s);
  	}
  	obj.put("spouse", uncles); //We use them as spouse to render them in the tree underneath the parents
	return obj;
}

function jsonParents(p : Person, depth : Int) : JSONArray {
	var parents := JSONArray();
	for(parent : Person in p.parents) {
		parents.put(jsonParent(parent, depth));
	}
	return parents;
}