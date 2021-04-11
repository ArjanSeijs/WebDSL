module src/entities

imports search/searchconfiguration
/*
A user is someone who can edit/create things
*/
entity User {
	username : String (id, validate(isUniqueUser(this), "Username already taken"))
	email : Email
	password : Secret (validate(password.length() > 2, "Pasword length must be larger than 2"))
	trees -> {FamilyTree}
	
	canSee -> {FamilyTree} (inverse=FamilyTree.canSee)
	canEdit -> {FamilyTree} (inverse=FamilyTree.canEdit)
}

/*
Genders
*/
enum Gender {
	Male("Male"),
	Female("Female"),
	Other("Other")
}

/*
A family tree is a collection of people that belong to the same family
*/
entity FamilyTree {
	
	name : String (not null, validate(name.length() > 0, "Family Tree must have a name"), searchable)
	owner -> User (inverse=User.trees)
	people -> {Person} (inverse=Person.family)
	
	public : Bool (default=true)
	canSee -> {User}
	canEdit -> {User} (allowed=from User as u where u in canSee)
	
	static function delete(t : FamilyTree) {
		for(p : Person in t.people) {
			Person.delete(p);
		}
		t.canSee.clear();
		t.canEdit.clear();
		t.owner.trees.remove(t);
		t.delete();
	}
	
	search mapping {
		name ^ 10.0
		name using none as name_untokenized ^ 5.0
		name using phonetic as name_phonetic
		people	 
	}
}

/*
A person is a family member part of a familyTree.
The parents (and children) attributes are used to keep track of relation ships within the family.
These attributes are then used to compute siblings, partners etc. 
*/
entity Person {
	name :: String := fullname() + " (" + birthday + ")" //display name for inputs
	
	fullname :: String := fullname()
	/* Names */
	firstname : String (not null, validate(firstname.length() > 0, "Person must have a firstname"))
	middlenames : String
	lastname : String
	
	/* General info */
	birthplace : String
	
	birthday : Date (validate(birthday != null, "Birthday required, if unknown enter approximate birthday"))
	passingdate : Date (validate(passingdate == null || passingdate.after(birthday),"Passing date is before birth!"))
	
	gender : Gender (not null)
	description : WikiText 
	icon: Image
	
	/* Relation */
	parents -> {Person} (allowed=from Person as p where p.family = family and p != ~this, validate(this.parents.length <= 2, "Max 2 parents"), validate(this.isValid(this.parents), "Cycle in family tree"))
	children -> {Person} (inverse=Person.parents)
	family -> FamilyTree (not null)
	
	search mapping {
		//Full name has highest priority then followed by close matches
		//then come birthday and passing date and end on name parts individual
		//exact magnitues are arbitrary
		 fullname ^ 15.0 
		 fullname using none as fullname_untokenized ^ 10.0
		 fullname using phonetic as fullname_phonetic ^ 7.5
		 firstname ^ 1.0
		 firstname using none as fname_untokenized ^ 0.5
		 firstname using none as fname_phonetic
		 middlenames ^ 1.0
		 middlenames using none as mname_untokenized ^ 0.5
		 middlenames using phonetic as mname_phonetic
		 lastname ^ 1.0
		 lastname using none as lname_untokenized ^ 0.5
		 lastname using phonetic as lname_phonetic
		 birthday ^ 6.0 using date_iso as bday_iso_format
		 birthday ^ 6.0 using date_eur as bday_eur_format
		 birthday ^ 3.0 using date_year as bday_year
		 birthday ^ 6.0 
		 passingdate ^ 4.0 using date_iso as pday_iso_format
		 passingdate ^ 4.0 using date_eur as pday_eur_format
		 passingdate ^ 2.0 using date_year as pday_year 
		 passingdate ^ 4.0 
	}
	/*
		Age of this person	
	*/
	function getAge() : Int {
		if(passingdate == null) {
			return age(birthday);
		}
		var offset := 0;
		if(passingdate.getMonth() < this.birthday.getMonth() || 
			(passingdate.getMonth() == passingdate.getMonth() && passingdate.getDay() < birthday.getDay())) {
			offset := 1;
		}
		return passingdate.getYear() - birthday.getYear() - offset;
		
	}
	
	/*
		Full name of this person
	*/
	function fullname() : String {
		var fullname : String := firstname;
		if(middlenames != null && middlenames.length() > 0) {
			fullname := fullname + " " + middlenames;
		}
		if(lastname != null && lastname.length() > 0) {
			fullname := fullname + " " + lastname;
		}
		return fullname;
	}
	
	/*
		Uses the isValid function to get all family members that are allowed to be this persons parent
		without creating a cycle in the relationships. (Can't be your own ancestor)
	*/
	function validAllowedParents() : List<Person> {
		var result : List<Person> := List<Person>();
		for(p : Person in family.people.list() order by p.fullname()) {
			if(p != this && this.isValid(p)) {
				result.add(p);
			}
		}
		return result;
	}
	
	/*
		Check if at most two parents and if these parents do not create a cycle in the relationships
	*/
	function isValid(parents : {Person}) : Bool {
		if(this.parents.length > 2) {
			return false;
		}
		for(p : Person in parents) {
			if(!this.isValid(p)) {
				return false;
			}
		}
		return true;
	}
	
	/*
		Check if at parent does not create a cycle in the relationships
	*/
	function isValid(p : Person) : Bool {
		return Person.notAncestors(this, p);
	}
	
	
	static function notAncestors(check : Person, ancestor : Person) : Bool {
		return Person.notAncestors(check, ancestor, Set<Person>());		
	}
	/*
		Recursive function to check whether 'check' is not an ancestor for 'ancestor'
	*/
	static function notAncestors(check : Person, ancestor : Person, acc : Set<Person>) : Bool {
		// Base cases
		if (ancestor == null) {
			return true;	
		}
		if(check == ancestor) {
			return false;
		}
		for(nextAncestor : Person in ancestor.parents ) {
			if(!(nextAncestor in acc)) { //We already checked this ancestor
				var new_acc := Set<Person>();
				new_acc.addAll(acc);
				new_acc.add(nextAncestor);
				if(!Person.notAncestors(check, nextAncestor, new_acc)) {
					return false;
				}				
			}
		}
		return true;
	}
	
	/*
		Use the children parents to determine all the partners of this person.
	*/
	function partners() : Set<Person> {
		var partners : Set<Person> := Set<Person>();
		for(c : Person in this.children) {
			for(p : Person in c.parents) {
				partners.add(p);	
			}
		}
		partners.remove(this);
		return partners;
	}
	
	/*
		Use the children of your parents to get all the siblings
	*/
	function siblings() : Set<Person> {
		var siblings : Set<Person> := Set<Person>();
		for(p : Person in this.parents) {
			siblings.addAll(p.children);
		}
		siblings.remove(this);
		return siblings;
	}
	
	static function delete(p : Person) {
		p.parents.clear();
		for(c : Person in p.children) {
			c.parents.remove(p);
		}
		p.family.people.remove(p);
		p.delete();
	}
}


