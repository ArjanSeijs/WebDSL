module templates

	template a() {
		<a all attributes>
			elements
		</a>
	}
	
	template ul() {
		<ul all attributes>
			elements
		</ul>
	}
	
	template li() {
		<li all attributes>
			elements
		</li>
	}
	
	template item() {
		<li class="nav-item" all attributes>
			elements
		</li>
	}
	
	template button {
		<button type="button" all attributes>
			elements
		</button>
	}
	
	template dateinput(d : ref Date) {
		input(d, 100, now().getYear() + 100)[all attributes]{elements}
	}
	
	template card() {
		div[class="card h-100", all attributes] {
			elements
		}
	}