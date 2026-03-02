1.) figure out how url works under the hood, other ways you can use it, understand why it’s actually more use file then something just like fopen.

Conclusion: urls are goated. 'nuff said.

2.) use the fantastic swift feature to create your own type of URL.

let url = SebUrl("myapp://profile/user?id=123&name=john")
for example you have to implement the SebUrl part and do whatever you want there as an example.

2b.) figure out how to register your own handler so that you can do stuff like seburl:// and also file:// with the same code

This should be valid code of some sort
I.e: let router = URLRouter()
router.handle("myapp://profile/user?id=42")
router.handle("file:///some/path/to/file.txt")

3.)  implement an extension(swift feature to change code you have written and add additional stuff for. That allows you to do the following this would solve your grievance as well. I would recommend extending the string type

let data = "/some/path/file.txt".asFile
let text = "/some/path/file.txt".asText
