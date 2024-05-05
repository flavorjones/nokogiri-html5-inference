## Unreleased


## v0.3.0 - 2024-05-05

- Use a `<template>` tag as the context node for the majority of fragment parsing, which greatly simplifies this gem. #7 @flavorjones @stevecheckoway
- Clean up the README. @marcoroth
- `Nokogiri::HTML5::Inference.parse` always returns a `Nokogiri::XML::Nodeset` for fragments. Previously this method sometimes returns a `Nokogiri::HTML5::DocumentFragment`, but some API inconsistencies between `DocumentFragment` and `NodeSet` made using the returned object tricky. We hope this provides a more consistent development experience. @flavorjones


## v0.2.0 - 2024-04-26

- When a `<head>` tag is seen first in the input string, include the `<body>` tag in the returned fragment or node set. (#3, #4) @flavorjones


## v0.1.1 - 2024-04-24

- Make protected methods `#context` and `#pluck_path` public, but keeping them undocumented.


## v0.1.0 - 2024-04-24

- Initial release
