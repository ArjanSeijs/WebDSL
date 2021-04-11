application FamilyTree

imports src/bootstrap
imports src/entities
imports src/person
imports src/authentication
imports src/tree
imports src/templates
imports src/header
imports src/search
imports src/service
imports src/search
imports src/family

	init {
		// =======================
		// DEMO DATA
		// =======================
		var u1 := User{ username := "user1" password := ("password1" as Secret).digest()  };
    	var u2 := User{ username := "user2" password := ("password2" as Secret).digest()  };
    	var u3 := User{ username := "user3" password := ("password3" as Secret).digest()  };
    	var u4 := User{ username := "user4" password := ("password4" as Secret).digest()  };
    	u1.save(); u2.save(); u3.save(); u4.save();
    	
    	var tree := FamilyTree{name := "Family Smith", owner := u1};
    	var tree2 := FamilyTree{name := "Jones", owner := u1, public := false, canSee := {u2, u3}, canEdit := {u2}};
    	tree.save(); tree2.save();
    	
    	var gFatherM := Person{firstname := "gFatherM", lastname := "Smith", birthday := Date("06/01/1930"), passingdate := Date("05/10/2019"), family := tree, gender := Male, icon := "./images/demo/image8.jpg".pathToImage(), birthplace := "Amsterdam"};
    	var gFatherF := Person{firstname := "gFatherF", birthday := Date("02/07/1943"), passingdate := Date("04/10/2018"), family := tree, gender := Male, birthplace := "Breda"};
    	var gMotherF := Person{firstname := "gMotherF", birthday := Date("04/09/1950"), family := tree, gender := Female, icon := "./images/demo/image1.jpg".pathToImage(), birthplace := "Castricum"};
    	
    	var father := Person{firstname := "father", lastname := "Smith",  birthday := Date("06/09/1968"), parents := {gFatherM}, family := tree, gender := Male, birthplace := "Diemen"};
    	var mother := Person{firstname := "mother", birthday := Date("08/09/1967"), parents := {gFatherF, gMotherF}, family := tree, gender := Female, birthplace := "Eindhoven"};
    	
    	var uncle := Person{firstname := "uncle", birthday := Date("06/09/1968"), parents := {gFatherM}, family := tree, gender := Male, birthplace := "Groningen"};
    	var aunt := Person{firstname := "aunt", birthday := Date("08/09/1967"), parents := {gFatherF, gMotherF}, family := tree, gender := Female, icon := "./images/demo/image2.jpg".pathToImage(), birthplace := "Haarlem"};
    	
    	var fatherL := Person{firstname := "father", middlenames:="in", lastname:="law", birthday := Date("02/02/1967"), family := tree, gender := Male};
    	var motherL := Person{firstname := "mother", middlenames:="in", lastname:="law", birthday := Date("03/04/1967"), family := tree, gender := Female};
    	
    	var me := Person{firstname := "Me", middlenames := "First of His name Breaker of chains", lastname := "Smith", birthday := Date("01/01/1995"), parents := {father, mother}, family := tree, gender := Male, icon := "./images/demo/image7.jpg".pathToImage(), birthplace := "Den Haag"};
    	var wife := Person{firstname := "wife", birthday := Date("02/02/1996"), parents := {fatherL, motherL}, family := tree, gender := Female, birthplace := "Tegelen"};
    	var ex := Person{firstname := "ex", birthday := Date("02/02/1996"), family := tree, gender := Female, birthplace := "Katwijk"};
    	var brother := Person{firstname := "brother", birthday := Date("01/01/1995"), parents := {father, mother}, family := tree, gender := Male, description := ("## Title\n some information" as WikiText), icon := "./images/demo/image9.jpg".pathToImage()};
    	var sister := Person{firstname := "sister", birthday := Date("12/11/1997"), parents := {father, mother}, family := tree, gender := Female};
    	
    	var son := Person{firstname := "son", lastname := "Smith" , birthday := Date("03/03/2020"), parents := {me, wife}, family := tree, gender := Male, birthplace := "Zaandam"};
    	var daughter := Person{firstname := "daughter", lastname := "Smith", birthday := Date("05/05/2018"), parents := {me, ex}, family := tree, gender := Female, icon := "./images/demo/image4.jpg".pathToImage()};
    	var daughterL := Person{firstname := "daughter", middlenames := "in", lastname := "law", birthday := Date("05/05/2018"), family := tree, gender := Female, icon := "./images/demo/image3.jpg".pathToImage()};
    	
    	var grandson := Person{firstname := "grandson", birthday := Date("03/03/2020"), parents := {son, daughterL}, family := tree, gender := Male};
    	var grandddaughter := Person{firstname := "granddaughter", birthday := Date("05/05/2018"), parents := {son, daughterL}, family := tree, gender := Female, icon := "./images/demo/image5.jpg".pathToImage()};
    	
    	var niece := Person{firstname := "niece", birthday := Date("07/09/2017"), parents := {sister}, family := tree, gender := Other};
    	
    	var r1 := Person{firstname := "Relative1", birthday := Date("01/01/1995"), family := tree, gender := Male};
    	var r2 := Person{firstname := "Relative2", birthday := Date("01/01/1995"), family := tree, gender := Female};
    	var r3 := Person{firstname := "Relative3", birthday := Date("01/01/1995"), family := tree, gender := Other};
    	var r4 := Person{firstname := "Relative4", birthday := Date("01/01/1995"), family := tree, gender := Male};
    	
    	var p1 := Person{firstname := "Relative", birthday := Date("04/09/2009"), family := tree2, gender := Male};
		var p2 := Person{firstname := "Father", birthday := Date("04/09/2009"), family := tree2, gender := Male};
		var p3 := Person{firstname := "Mother", birthday := Date("04/09/2009"), family := tree2, gender := Female};
		var p4 := Person{firstname := "Person", birthday := Date("04/09/2009"), parents := {p2, p3}, family := tree2, gender := Male, description := "Put description here"};
				
    	r1.save(); r2.save(); r3.save(); r4.save();
		gFatherM.save(); gFatherF.save(); gMotherF.save(); 
		father.save(); mother.save();uncle.save(); aunt.save(); fatherL.save(); motherL.save(); 
		me.save();wife.save();brother.save();sister.save();ex.save();
		son.save();daughter.save();daughterL.save();
		grandson.save();grandddaughter.save();niece.save();		
		p1.save(); p2.save(); p3.save(); p4.save();
		// =======================
		// END DEMO DATA
		// =======================
	}

	page root() {
		title {"Family Tree Home"}
		main {
			myheader
			carousel
		}
	}
	
	template carousel {
		//https://getbootstrap.com/docs/5.0/components/carousel/
		<div class="container p-2">
		<div id="carouselExampleDark" class="carousel carousel-dark slide rounded border border-primary" data-bs-ride="carousel">
		  <div class="carousel-indicators">
		    <button type="button" data-bs-target="#carouselExampleDark" data-bs-slide-to="0" class="active" aria-current="true" aria-label="Slide 1"></button>
		    <button type="button" data-bs-target="#carouselExampleDark" data-bs-slide-to="1" aria-label="Slide 2"></button>
		    <button type="button" data-bs-target="#carouselExampleDark" data-bs-slide-to="2" aria-label="Slide 3"></button>
		  </div>
		  <div class="carousel-inner">
		    <div class="carousel-item active" data-bs-interval="10000">
		      image("/images/skywalkers.png")[class="d-block w-100", alt="Family Overview"]{}
		      <div class="carousel-caption d-none d-md-block">
			    <h5>"The skywalker family"</h5>
		      </div>
		    </div>
		    <div class="carousel-item" data-bs-interval="10000">
		      image("/images/skywalkers2.png")[class="d-block w-100", alt="Family Overview"]{}
		      <div class="carousel-caption d-none d-md-block">
			    <h5>"The skywalker family"</h5>
		      </div>
		    </div>
		    <div class="carousel-item" data-bs-interval="2000">
		      image("/images/skywalkers-tree.png")[class="d-block w-100", alt="Family Overview"]{}
		      <div class="carousel-caption d-none d-md-block">
			    <h5>"The skywalker family tree"</h5>
		      </div>
		    </div>
		  </div>
		  <button class="carousel-control-prev" type="button" data-bs-target="#carouselExampleDark" data-bs-slide="prev">
		    <span class="carousel-control-prev-icon" aria-hidden="true"></span>
		    <span class="visually-hidden">"Previous"</span>
		  </button>
		  <button class="carousel-control-next" type="button" data-bs-target="#carouselExampleDark" data-bs-slide="next">
		    <span class="carousel-control-next-icon" aria-hidden="true"></span>
		    <span class="visually-hidden">"Next"</span>
		  </button>
		</div>
		</div>
	}