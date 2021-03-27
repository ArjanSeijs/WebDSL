module bootstrap

template bootstrapHeader {
// https://getbootstrap.com/docs/5.0/getting-started/introduction/#starter-template
	head {
		<!-- Required meta tags -->
		<title>"demo"</title>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<!-- Bootstrap CSS -->
		includeCSS("https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/css/bootstrap.min.css")[integrity="sha384-BmbxuPwQa2lc/FVzBcNJ7UAyJxM6wuqIj61tLrc4wSX0szH/Ev+nYRRuWlolflfl", crossorigin="anonymous"]
		// <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/css/bootstrap.min.css" rel="stylesheet"
		// integrity="sha384-BmbxuPwQa2lc/FVzBcNJ7UAyJxM6wuqIj61tLrc4wSX0szH/Ev+nYRRuWlolflfl" crossorigin="anonymous">
		<!-- Font Awesome -->
		includeCSS("https://use.fontawesome.com/releases/v5.15.3/css/all.css")
		// <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.8/css/all.css">
		<!-- Common Css -->
		includeCSS("common_.css")
		includeCSS("style.css")
		}
}
template bootstrapJavaScript {
	<!-- Option 1: Bootstrap Bundle with Popper -->
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/js/bootstrap.bundle.min.js" integrity="sha384-b5kHyXgcpbZJO/tY9Ul7kGkf1S0CWuKcCD38l8YkeH8z8QjE0GmW1gYU5S9FOnJ0" crossorigin="anonymous"></script>
	// includeJS("https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/js/bootstrap.bundle.min.js")[integrity="sha384-b5kHyXgcpbZJO/tY9Ul7kGkf1S0CWuKcCD38l8YkeH8z8QjE0GmW1gYU5S9FOnJ0", crossorigin="anonymous"]
}

template main {
	bootstrapHeader
	<body style="background-color: antiquewhite !important;">
	elements
	</body>
	bootstrapJavaScript
}