module src/templates

//Some misc templates and html wrappers

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

template faIcon {
	<i all attributes>
	</i>
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
	
template confirm_modal(name : String) {
	//https://getbootstrap.com/docs/5.0/components/modal/
	<div class="modal fade" id="confirm_delete" tabindex="-1" aria-labelledby="confirmDelete" aria-hidden="true">
	  <div class="modal-dialog">
	    <div class="modal-content">
	      <div class="modal-header">
	        <h5 class="modal-title">"Deleting " output(name)</h5>
	        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
	      </div>
	      <div class="modal-body">
                <p>"Are you sure? "</p>
	      </div>
	      <div class="modal-footer">
	        elements
	      </div>
	    </div>
	  </div>
	</div>
}