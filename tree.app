module tree

imports FamilyTree
imports entities
imports templates

page direct_family_tree(p : Person) {
	
	title {"Family Tree of " output(p.fullname())}
	includeCSS("tree.css")
	main {
		myheader
		direct_family_tree(p)
	}
}

template direct_family_tree( p : Person) {
	div[class="container p-3"] {
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