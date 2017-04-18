# Workshop

##### Feature. Tests. Implementation.

**Duration:** 2 hours 20 minutes

# Introduction

The goal of this workshop is to expose you to different levels of testing and how to move in and out of them to see a feature driven by tests to completion. You may or may not have reactions of overkill through this exercise. It is important to not focus too much on whether any particular example is overkill, but rather stow away the strategies and tools discussed which may aid your development of future software. The methodology used in this material unofficially follows the [London-school][london] style.

In this interactive tutorial you will be guided in realizing a new feature using tests. You should already have the app bootstrapped by following the [preparation guide][prep-guide].

To help orient you in the material, there are a few conventions used.

> ✍️ _**WRITE!**_

When you see this, it's your turn. Take a few moments to try and find the solution to the current problem. If you feel stuck or short on patience, continue after the break and complete the implementation. We'll work each section aloud together after folks have had a chance to try it themselves.

> 👂 _**LISTEN!**_

When you see this, it's my turn. Hopefully I'll have something interesting/useful/humorous (pick two) to say about the section.

Finally, the material will sometimes reference external links. Don't feel like you need to go read them during the workshop. You probably won't have time, but they're good resources for further learning.

Hope you enjoy it!

# Pinster

Just as a reminder of what you learned in the [preparation guide][prep-guide], Pinster is a link-pinning app.

### Tests

Pinster comes with an automated test suite written with [RSpec][rspec] which can be run at any time with the command `bin/rspec`. Run the tests frequently while you're developing features. Before each run, consider for a moment what you _expect_ to happen. If you're surprised by what _actually_ happens, think about why it behaves in an unexpected way.

Give the tests a run:

```
$ bin/rspec
...

Finished in 0.41927 seconds (files took 2.65 seconds to load)
3 examples, 0 failures
```

The functionality of Pinster is so basic that no isolated tests were needed to confidently deliver its core functionality: adding and deleting links. All the tests included are integrated _**acceptance**_ tests. As their name suggests, these tests define the acceptance criteria for each feature they represent. Have a look at the acceptance test for viewing links:

```ruby
# in spec/acceptance/links_spec.rb
describe "viewing links" do
  it "displays all links" do
    Link.create!(url: "http://iamvery.com")
    Link.create!(url: "http://google.com")

    visit links_path

    expect(page).to have_content("iamvery.com")
    expect(page).to have_content("google.com")
  end
end
```

This test reads easily to describe the app's behavior.

> When two links exist, they are both visible on the page.

Acceptance tests often read as if a user is interacting with the app. At the top, the conditions are set up for the test. Next, the user interacts with the app by visiting the page. Finally, observations are made about the content of the page that must be true for the feature to be implemented correctly. This structure of tests is often referred to as [Arrange-Act-Assert][arrange-act-assert].

If you haven't used RSpec, don't fret. The syntax is intuitive. If you're interested in learning more, check out the book [Effective Testing with RSpec 3][rspec-book]. There is also good intro material at [Treehouse][th-rspec] and [Code School][cs-rspec].

## A New Feature

It's time to add a new feature to Pinster. Each link shall include its fetched page title as a preview. The requirements:

- Given a link to some webpage exists.
- When you view links.
- Then you will see the fetched page title for that webpage beside its URL.

That sounds useful. Make it so.

## Your First Test

With any clearly defined user story, the first test you write is an _**acceptance**_ test. This is the so-called "highest level" test that you will write, and although it is the first one written, it is likely to be the _last_ one passing. The passing of this test is an indication that your feature _might_ be done. Any time the acceptance tests pass, it is time to consider refactoring your implementation.

---

### ✍️ _WRITE!_

Write the acceptance test for this new feature. Model it after existing tests. Consider the structure of this new test:

- Given: What state must the app have before the user interacts with it? (Arrange)
- When: What interaction does the user perform? (Act)
- Then: What observation(s) must be true for the feature to be complete? (Assert)

Add your acceptance test to `spec/acceptance/links_spec.rb`. Once you've written the test, run it and listen to the results. What will your next move be?

---

Nice work! You _did_ write it yourself didn't you..? 😉

Fundamentally, this feature is about _viewing_ links, so it probably fits best into the "viewing links" context:

```diff
 # in spec/acceptance/links_spec.rb
 describe "viewing links" do
   it "displays all links" do
     # ...
   end
+
+  it "displays the page title for each link" do
+    Link.create!(url: "http://twitter.com")
+    Link.create!(url: "http://google.com")
+
+    visit links_path
+
+    expect(page).to have_content("Twitter")
+    expect(page).to have_content("Google")
+  end 
 end
```

Nice! That test cleanly summarizes an acceptable scenario for the feature you are adding. Note the similarty is has to the other test in this context.

- Given: a link to Twitter and a link to Google exist in the app.
- When: the user views the links.
- Then: they see Twitter's page title "Twitter" and Google's page title "Google" on the page.

Now that you have defined _done_ for this feature, give it a run and let the tests tell you what to do next.

```rsp
$ bin/rspec
Failures:

  1) Links viewing links displays page title for each link
     Failure/Error: expect(page).to have_content("Twitter")
       expected to find text "Twitter" in "Pinster Url URL http://twitter.com http://google.com". (However, it was found 1 time using a case insensitive search.)
     # ./spec/acceptance/links_spec.rb:21:in `block (3 levels) in <top (required)>'
```

You're first failing test! To figure out where to go from here, take a moment to think about what the test is telling you. It expected to find "Twitter", the first link's page title, on the page. Of course, you are only displaying the URL for each link.

Have a look at the link view partial to see how links are formatted for display:

```erb
<!-- app/views/links/_link.html.erb -->
<li class="list-group-item" data-link-id=<%= link.id %>>
  <%= link_to link.url, link.url %>
  <%= link_to link, method: :delete, remote: true, class: "pull-right", data: { role: "delete-link" } do %>
  <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>
  <% end %>
</li>
```

To correct the first failure, you could go lo-fi and put a static `Twitter` in the partial, but that's not really a step forward. The test would still immediately fail at the next assertion when it looks for "Google".

The realization here is that your model lacks the concept of a link's `title`. You need to move deeper into the system in order to continue building this feature with tests. As a first step, make a prediction about how your model will work by adding a `link.title` to the page:

```diff
 <!-- app/views/links/_link.html.erb -->
 <li class="list-group-item" data-link-id=<%= link.id %>>
+  <%= link.title %>
   <%= link_to link.url, link.url %>
 <!-- ... ->
```

Run the suite again and see _everything_ fails!

```
$ bin/rspec
Failures:

  1) Links viewing links displays all links
     Failure/Error: <%= link.title %>

     ActionView::Template::Error:
       undefined method `title' for #<Link:0x007f97671676b8>
...
```

 Oh no!.. Actually, oh _yes_. The test suite now tells you explicitly that you're missing a fundamental interface on your model, the `Link` `title`. These errors inform you that it is time to zoom in with your testing strategy. It's time to build this new interface with an isolated test.

------

### 👂 _LISTEN!_

- Write the acceptance test.
- Make up something to reveal missing interface.
- Multiple scenarios are covered in test.
- Next up: building an interface with isolated tests.

---

## Isolated Testing

When adding interfaces, you should build them in isolation. Of course you will need to have some idea how this new interface will be used, so it's often useful to take a guess or make an assumption like you did by adding `link.title` to the view partial. Then you can start by writing an isolated test and then building the behavior needed to make it pass. This type of test is sometimes called a "unit test", but folks struggle to agree on what "unit" means. The point is, the subject under test is being isolated from the rest of the system, an _isolated_ test.

---

### ✍️ _WRITE!_

Add an isolated test for the `Link` `title` method. It will return the page title for the link's URL. Here's the skeleton for this new spec file:

```ruby
# in spec/models/link_spec.rb
require "rails_helper"

RSpec.describe Link do
  describe "#title" do
    it "returns the page title" do
      # What is the simplest possible test you could write here?
    end
  end
end
```

Once you have written the isolated test, complete the implementation in the `Link` model to make the test pass. What is the simplest possible implementation to make your test pass? Make it _very_ simple, even dumb...

Run this spec in isolation while you build the new interface with `bin/rspec spec/models/link_spec.rb`.

------

Your first isolated test will be used to drive the `Link` model's `title` instance method implementation. Complete the test:

```ruby
# in spec/models/link_spec.rb
# ...
it "returns the page title" do
  link = described_class.new(url: "http://google.com")
  title = link.title

  expect(title).to eq("Google")
end
```

While focusing on a single unit of behavior, you will want to focus the test run to the relevant isolated test(s). In this case, run only the `Link` model spec:

```
$ bin/rspec spec/models/link_spec.rb
Failures:

  1) Link#title returns the open graph title
     Failure/Error: title = link.title

     NoMethodError:
       undefined method `title' for #<Link:0x007fe563b23298>
```

That is the same error you got in the acceptance tests! You're on the right track, but now that the error has manifested in isolation, closer to the interface being built. You can focus your energy on this single method. Go ahead and add a minimal implementation to the `Link` model:

```diff
 # in app/models/link.rb
 class Link < ApplicationRecord
+  def title
+    "Google"
+  end
 end
```

It might seem strange to start with such a dumb implementation. Obviously the literal `"Google"` is not the page title for _all_ links, but this silly addition has a valuable property. It serves to again limit the acceptance test failure to the our one new feature scenario. It no longer errors, it _fails_. Run the full suite with `bin/rspec` and see!

Take a moment to consider your next move. You could zoom back out to the acceptance test, but this new interface is clearly incomplete. You need a way to fetch the actual page title for a link.

---

### 👂 _LISTEN!_

- Write an isolated test.
- Build naive `Link` `title` in isolation.
- Next up: replace naive implementation with something real.

---

### Open Graph

The [Open Graph Protocol][ogp] defines a way of relaying page information as a part of its [meta][meta] data. The Rubygem `opengraph_parser` seems to fit the bill for parsing this information. Don't worry about the particular library too much. Given the right design, you can swap implementations in and out as you look for the best fit.

Confirm `gem "opengraph_parser"` is in your `Gemfile` and installed. Play around with it in the Rails console to see how it works:

```
$ bin/rails console
irb> page = OpenGraph.new("http://google.com")
=> #<OpenGraph...>
irb> page.title
=> "Google"
```

That works well enough! Use this library to complete the implementation of `Link` `title`.

---

### ✍️ _WRITE!_

Replace the naive implementation by using the `opengraph_parser` library. This should be a very small change.

With the library utilitized, run the entire suite with `bin/rspec`. Does it all pass? Are there any drawbacks to this implementation?

---

The change to `title` is minimal. Replace the static title value with a call to the Open Graph library:

```diff
 # in app/models/link.rb
+require "open_graph"
+
 class Link < ApplicationModel
   def title
-    "Google"
+    OpenGraph.new(url).title
   end
 end
```

When you run the model isolated test, you see that it passes. In fact, running the entire test suite passes! But is the feature done?!

```
$ bin/rspec
.....

Finished in 2.36 seconds (files took 1.9 seconds to load)
5 examples, 0 failures
```

Not quite. There's a subtle problem.

Did you notice that the test run was _significantly_ slower that time? The original test run took about **0.4s** to complete. Now it is taking well over **2s**!

That's because your test suite now has a dependency on the network in order to pass. Each time `OpenGraph` is used, it makes a network request to fetch the remote page. This drastically slows your tests down and _requires_ a connection to the Internet.

Try disabling your network and run the tests. You should see many tests fail again. Consider the drawbacks of this dependency:

1. The "slowness" of your test suite will increase with every additional test that accesses the network.
2. Your test suite now _requires_ an Internet connection. Tests cannot run reliably offline.

---

### 👂 _LISTEN!_

- Complete `title` implementation.
- Discuss drawbacks.
- Use webmock to prevent HTTP connections.
- Next up: establish owned interface for mocking.

---

## A Wrapper

The problem you have at this point is that your test suite establishes a _real connection_ to an external resource. This has the effect of coupling your test suite to the Internet which is both slow and painful for offline development.

One solution to this problem is to introduce a tool like [VCR][vcr] to record and playback external network requests during your tests. While this approach works, it is often tedious to manage the recorded network transactions as your application grows in complexity. As an alternative, consider [injecting a test fake][fakes] which mimics the interface of the object making the external connection.

To isolate the app code away from the network dependent code, you must establish a seam in which you can inject a fake. Remember, it is important that you [don't mock an interface that you don't own][dont-mock]. So first, create a wrapper object which has an interface you _do_ own.

Before building this wrapper, take a moment to prevent external connections in your tests by configuring [webmock][webmock]. It is already installed in your Gemfile, to configure it add one line to `spec/spec_helper.rb`.

```ruby
# in spec/spec_helper.rb
require "webmock/rspec"
# ...
```

Now when you run your tests, they all fail due to the attempted HTTP request.

```
$ bin/rspec
1) Link#title returns the open graph title
     Failure/Error: OpenGraph.new(url).title

     WebMock::NetConnectNotAllowedError:
       Real HTTP connections are disabled. Unregistered request: GET http://google.com/...

       You can stub this request with the following snippet:

       stub_request(:get, "http://google.com/")...
...
```

Now it's time to iterate on making the test suite green again!

------

### ✍️ _WRITE!_

Create a wrapper for the `OpenGraph` object that exposes the minimal interface needed by your system, a `title`. It's useful to establish concepts in your domain, so for simplicity call this object a `WebPage`. Here are a couple files to get you started:

```ruby
# in spec/lib/web_page_spec.rb
require "spec_helper"
require "web_page"

RSpec.describe WebPage do
  describe "#title" do
    # YOUR TESTS HERE
  end
end
```

```Ruby
# in lib/web_page.rb
class WebPage
  # YOUR IMPLEMENTATION HERE
end
```

Consider the purpose of this new object: to establish an interface you own for interacting with a library you do not own. Therefore, all these tests should do is verify that integration behaves correctly. Give the implementation a shot. If you're not sure how to continue on your own, read on.

**Hint:** Listen to the output from webmock to stub the network connection.

------

Add a test that verifies expected the behavior of the wrapper in integration with `OpenGraph`.

```ruby
# in spec/lib/web_page_spec.rb
require "spec_helper"
require "web_page"

RSpec.describe WebPage do
  describe "#title" do
    it "returns the fetched page title" do
      url = "http://google.com"
      
      page = described_class.new(url)
      title = page.title
      
      expect(title).to eq("Google")
    end
  end
end
```

Iterate by running the test and adding code to complete the implementation of `WebPage`.

```ruby
# in lib/web_page.rb
require "open_graph"

class WebPage
  def initialize(url)
    @url = url
  end
  
  def title
    open_graph.title
  end
  
  private
  
  attr_reader :url
  
  def open_graph
    @open_graph ||= OpenGraph.new(url)
  end
end
```



Run the the new spec. What do you expect will happen?

```
$ bin/rspec
1) WebPage#title returns the remote page title

     WebMock::NetConnectNotAllowedError:
     ...

     You can stub this request with the following snippet:

     stub_request(:get, "http://google.com/").
       with(...)
       to_return(...)
...
```

Of course, webmock will not allow the HTTP request, but notice that it provides a mechanism for stubbing the request. Useful!

Webmock will match as much or as little of the information as you give it about the request. Add a stub for the URL being fetched.

```diff
 # in spec/lib/web_page_spec.rb
 # ...
 it "returns the fetched page title" do
   url = "http://google.com"
+  body = "<html><head><title>Google</title></head></html>"
+
+  stub_request(:get, url).to_return(body: body)
      
   page = WebPage.new(url)
   title = page.title
      
   expect(title).to eq("Google")
 end
 # ...
```

This stubs the underlying HTTP request with _just enough_ markup to let the test pass.

```
$ bin/rspec
.

Finished in 0.00457 seconds (files took 0.44342 seconds to load)
1 example, 0 failures
```

Perfect! That completes your thin wrapper over `OpenGraph`. Now you own an interface, `WebPage`, that can be faked to decoupled your remaining tests from the network.

Finally, replace the direct use of `OpenGraph` with `WebPage` in your `Link` model.

```diff
 # in app/models/link.rb
-require "open_graph"
+require "web_page"

 class Link < ApplicationRecord
   def title
-    OpenGraph.new(url).title
+    WebPage.new(url).title
   end
 end
```

This isolates your app code from direct reference to the 3rd party. In fact, `WebPage` itself has the _only_ reference to `OpenGraph` in your code. This isolation is tremendously useful. Imagine creating a wrapper for processing payments with [Stripe](https://stripe.com/). If later you decide to change payment processing to [Braintree](https://www.braintreepayments.com/), the entirety of the change is isolated to the implementation of your wrapper!

---

### 👂 _LISTEN!_

- Build wrapper over library.
- Next up: build fake.

---

## Fake It

The work you just did to create a wrapper for `OpenGraph` didn't solve the issue of your test suite being coupled to the network. But it did do the important work of establishing an interface you can mock in you tests. It's time to build a fake.

------

### ✍️ _WRITE!_

Create a fake object to stand in for a `WebPage`. Using this object in tests will allow you to exercise application code without the network dependency. It is important for this object to have non-trivial behavior, but without dependency on the network. Here are the files with the fake's `title` behavior pre-specified for you:

```ruby
# in spec/lib/fake_web_page_spec.rb
require "spec_helper"
require "fake_web_page"

RSpec.describe FakeWebPage do
  describe "#title" do
    it "returns the titleized URL domain name" do
      web_page = described_class.new("http://some-web-page.com/content")
      title = web_page.title

      expect(title).to eq("Some Web Page")
    end
  end
end
```

```Ruby
# in lib/fake_web_page.rb
class FakeWebPage
  # YOUR IMPLEMENTATION HERE
end
```

**Hint:** Check out the `URI` object in Ruby's standard library.

------

Here's an implementation of `FakeWebPage`:

```ruby
# in spec/support/fake_web_page.rb
require "uri"
require "active_support/core_ext/string/inflections" # defines String#titleize

class FakeWebPage
  def initialize(url)
    @url = url
  end

  def title
    domain.titleize
  end

  private

  attr_reader :url

  def domain
    host.split(".").first
  end

  def host
    uri.host
  end

  def uri
    @uri ||= URI(url)
  end
end
```

You might have come up with something different, but the truth is it doesn't matter what the implementation of the fake is, so long as it does something more interesting than return a single literal value. You could even have kept an internal map of URLs to page titles if you wanted. The important thing is that with this fake you can begin to decouple your `Link` model from the network.

---

### 👂 _LISTEN!_

- Build fake.
- Illustrate alternative implementation.
- Next up: inject fake to decouple tests from network.

---

## Dependency Injection

To decouple the `Link` model from the network, you need to replace calls to the real `WebPage` object with a `FakeWebPage`. Dependency injection is a good strategy for loosening coupling and supporting such replacements. It is a viable strategy for this case.

---

### ✍️ _WRITE!_

Identify seams for injecting the `FakeWebPage` in place of the real `WebPage`. Consider:

- Where do you reference `WebPage`?
- How can you control what class is referenced differently when running tests? Perhaps you could configure the test environment differently from other environments?

---

Update the `title` method of `Link` to accept an injected library as an optional argument:

```Diff
 # in app/models/link.rb
 require "web_page"

 class Link < ApplicationModel
-  def title
-    WebPage.new(url).title
+  def title(lib: WebPage)
+    lib.new(url).title
   end
 end
```

With this small change, you can already start the process of decoupling by eliminating the `Link` `title` test's network dependency.

```diff
 # in spec/models/link_spec.rb
+require "fake_web_page"
 
 # ...
   describe "#title" do
     it "returns the page title" do
       link = Link.new(url: "http://google.com")
-      title = link.title
+      title = link.title(lib: FakeWebPage)

       expect(title).to eq("Google")
     end
```

Before you turned on webmock, this one test took nearly **1s** to run. Now it completes in about **8ms**! That's more than 100x faster for the isolated test alone. But the acceptance tests still fail...

## Configuration

Dependency injection is a great way to enhance objects with flexible interfaces that make them easier to use and test. However, at the acceptance level of testing you are not interacting with object's interfaces directly. This eliminates the luxury of dependency injection for acceptance tests. Instead, you must shift your focus to the environment. How can you configure the test environment to use a test fake while other environments use real libraries?

### Rails? Configure it!

In Rails, your app has a configuration. It is often initialized by small configuration files in `config/initializers`. Add an initializer for your `WebPage` lib:

```ruby
# in config/initializers/web_page_lib.rb
require "web_page"
Rails.configuration.web_page_lib = WebPage
```

Now you can update the Link#title method to inject this configuration rather than the `WebPage` itself:

```diff
 # in app/models/link.rb
-require "web_page"
-
 class Link < ApplicationModel
-  def title(lib: WebPage)
+  def title(lib: Rails.configuration.web_page_lib)
     lib.new(url).title
   end
 end
```

This does not fix the failing tests, but an important seam now exists. You can change the Rails conguration to specify _anything_ you want to be used for the web page lib! Update your test environment to always use the test fake:

```diff
 # in spec/rails_helper.rb
 require "capybara/rspec"
 # Add additional requires below this line. Rails is not loaded until this point!

+require "fake_web_page"
+Rails.configuration.web_page_lib = FakeWebPage
+
 # Requires...
```

Huzzah! All tests pass. Now your test suite configures the application to use `FakeWebPage`. Before this change, the entire test suite without webmock ran in about **2s**. Now it completes in only **0.3s**! Further, this completely eliminates your tests' dependency on the network! You can now enjoy fast, offline tests. Go ahead and hack on it in planes, trains, and automobiles!

**Note:** If you used other URLs in your acceptance tests, you may have to tweak the expectations to expect page titles based on the behavior of your `FakeWebPage`, e.g. for `iamvery.com` expect `Iamvery` instead of the _actual_ page title `Jay Hayes`.

---

### 👂 _LISTEN!_

- Finish the implementation.

---

## The End?

Are you surprised that such a simple feature took _this_ much time and thought to implement with tests? Testing can be tricky, but when done well it provides tremendous confidence in the software you produce. When you trust your test suite and find a rhythm, you may go a really long time without ever actually running the app!

...

## But wait, there's more!

There are a couple more interesting things to consider about your solution:

- The design you built on makes it really easy to swap out your Open Graph implementation for something else.
- The tests that you have written are _content focused_. This means that you should be able to make non-trivial changes to the design of your page without having to update tests.
- What if you didn't use webmock?

### Roll Your Own Page Title

Did you notice that the dependency on `OpenGraph` is entirely an implementation detail of `WebPage`? To illustrate this, refactor `WebPage` using [nokogiri][nokogiri], which is already installed as it is a dependency of Rails itself.

Nokogiri is an XML parser, so it's well-suited to dig into an HTML document. A quick refactor does the job:

```diff
 # in lib/web_page.rb
-require "open_graph"
+require "open-uri"
+require "nokogiri"

 class WebPage
   def initialize(url)
     @url = url
   end
  
   def title
-    open_graph.title
+    page.css("title").text
   end
  
   private
  
   attr_reader :url
  
-  def open_graph
-    @open_graph ||= OpenGraph.new(url)
-  end
+  def page
+    @page ||= Nokogiri::HTML(html)
+  end
+
+  def html
+    @html ||= open(url)
+  end
end
```

That's it! A true _refactor_. The entire test suite is still green. Being careful about coupling in your test suite gives you the flexibility to make unforseen changes with relatively little pain.

---

### 👂 _LISTEN!_

- Implement alternative internals of `WebPage`.

---

### Redesign Links

Another aspect of your test suite that is worth note is that its acceptance tests are very _content focused_. A useful effect of writing tests in this style is it allows you to change _how_ the content is displayed without breaking the tests. Another way of thinking about this is the test suite is not unnecessarily coupled to the structure of the page.

To illustrate this, take a moment to change the structure of the Pinster display. Recall what Pinster looks like currently.

![pinster-regular](/Users/jay/Code/OSS/rc17-testing-workshop/doc/pinster-regular.png)

Replace the Twitter Bootstrap `list-group` with `well`s.

```diff
 <!-- in app/views/links/index.html.erb -->
 <!-- ... -->
-<ul class="list-group">
   <% @links.each do |link| %>
     <%= render link %>
   <% end %>
-</ul>
```

```diff
 <!-- in app/views/links/_link.html.erb -->
-<li class="list-group-item" data-link-id=<%= link.id %>>
+<div class="well" data-link-id=<%= link.id %>>
   <%= link.title %>
   <%= link_to link.url, link.url %>
   <%= link_to link, method: :delete, remote: true, class: "pull-right", data: { role: "delete-link" } do %>
     <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>
   <% end %>
-</li>
+</div>
```

Then move around the link display by wrapping the title in an `<h3>`, the URL in a `<p>`, and make the delete icon a button with text.

```diff
 <!-- in app/views/links/_link.html.erb -->
 <div class="well" data-link-id=<%= link.id %>>
-  <%= link.title %>
-  <%= link_to link.url, link.url %>
-  <%= link_to link, method: :delete, remote: true, class: "pull-right", data: { role: "delete-link" } do %>
-    <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>
-  <% end %>
+  <h3><%= link.title %></h3>
+   <%= link_to "Remove", link, method: :delete, remote: true, class: "btn btn-default pull-right", data: { role: "delete-link" } %>
+  <p><%= link_to link.url, link.url %></p>
 </div>
```

![pinster-redesign](/Users/jay/Code/OSS/rc17-testing-workshop/doc/pinster-redesign.png)

Despite these structural changes to the rendered HTML, the entire test suite continues to pass!

```
$ bin/rspec
.......

Finished in 0.39228 seconds (files took 1.81 seconds to load)
7 examples, 0 failures
```

This is another example of consider test implementation that minimizes uneccessary coupling.

---

### 👂 _LISTEN!_

- Change visible design.
- Note tests are still happy.
- Next up: what if tests were more coupled?

---

### Testing the Wrapper in Isolation

When you realized you needed to build a wrapper for `OpenGraph`, you opted to write a small, integrated test that used [webmock][webmock] to stub the underlying HTTP request. What if instead you decided to build this wrapper with an isolated test? How would the resulting implementation have turned out?

Start again with your base `WebPage` spec and empty implementation.

```ruby
# in spec/lib/web_page_spec.rb
require "spec_helper"
require "web_page"

RSpec.describe WebPage do
  describe "#title" do
    # YOUR TESTS HERE
  end
end
```

Begin filling out the expected behavior.

```ruby
# in spec/lib/web_page_spec.rb
# ...
describe "#title" do
  it "delegates to the OpenGraph instance for its title" do
    page = described_class.new(url, lib: lib)
    expect(instance).to receive(:page_title)
    page.title    
  end
end
```

(If you think you see a typo, stick with me here...)

Running this test in isolation reminds you to add values for `url`, `lib`, and `instance`. Add some values to the context.

```ruby
# in spec/lib/web_page_spec.rb
# ...
RSpec.describe WebPage do
  let(:url) { "http://example.com" }
  let(:lib) { double(:open_graph_class) }
  let(:instance) { double(:open_graph_instance) }
```

After a few iterations on the spec and object, you end up with the following test which stubs and mocks `OpenGraph` to verify the implementation:

```ruby
# in spec/lib/web_page_spec.rb
require "spec_helper"
require "web_page"

RSpec.describe WebPage do
  let(:url) { "http://example.com" }
  let(:lib) { double(:open_graph_class) }
  let(:instance) { double(:open_graph_instance) }
  
  before do
    allow(lib).to receive(:new).with(url).and_return(instance)
  end
  
  describe "#title" do
  	it "delegates to the OpenGraph instance for its title" do
  	  page = described_class.new(url, lib: lib)
  	  expect(instance).to receive(:page_title)
      page.title    
  	end
  end
end
```

 And implementation:

```ruby
# in lib/web_page.rb
require "open_graph"

class WebPage
  def initialize(url, lib: OpenGraph)
    @url = url
    @lib = lib
  end
  
  def title
    open_graph.page_title
  end
  
  private
  
  attr_reader :url, :lib
  
  def open_graph
    @open_graph ||= lib.new(url)
  end
end
```

Aside from the injected `lib` the implementation is the same as before. Cool!

All the tests pass and everything looks good. Except there's a huge bug in the code that the tests fail to highlight for us.

The mistake is only caught after running the app and using it in your browser. It could have been worse though. The bug could have been shipped to production.

![wrapper-typo](/Users/jay/Code/OSS/rc17-testing-workshop/doc/wrapper-typo.png)

We made an inaccurate assumption about the `OpenGraph` interface. It doesn't respond to `page_title` 🤦‍♂️.

The point of this drawn-out exercise is to highlight a major drawback of using mocks and stubs to "isolate" tests. If you are not careful, you might lull youself into a false sense of security that feels fine right up until everything is terrible. Of course, this is not to say that mocks and stubs are _evil_ and should never be used. Like all things, they're tools that can both build a house and severe limbs.

#### Verifying Mocks

You may have noticed that the test that was written for the `WebPage` never involved the actual `OpenGraph` object. Instead it _assumed_ that the interface of the object is mocked accurately. Except it isn't. An instance of `OpenGraph` does not respond to `page_title` as the implementation suggests.

This is because your tests never _verify_ the interface being mocked. The solution to this problem depends on your tools, but RSpec provides you with [verifying doubles][verifying] for this very scenario. Update your test doubles to solicit RSpec's help:

```Diff
 # in spec/lib/web_page_spec.rb
 # ...
-let(:lib) { double(:open_graph_class) }
-let(:instance) { double(:open_graph_instance) }
+let(:lib) { class_double(OpenGraph) }
+let(:instance) { instance_double(OpenGraph) }
```

Now any message sent to these doubles will be verified as valid messages of the class or instance respectively. Run the tests and see them now fail:

```
$ bin/rspec spec/lib/web_page_spec.rb
Failures:

  1) WebPage#title delegates to the OpenGraph instance for its title
     Failure/Error: allow(instance).to receive(:page_title)
       the OpenGraph class does not implement the instance method: page_title
...
```

Finally, update spec and implementation to fix the erroneous message:

```Diff
 # in spec/lib/web_page_spec.rb
 # ...
 it "delegates to the OpenGraph instance for its title" do
   page = described_class.new(url, lib: lib)
-  expect(instance).to receive(:page_title)
+  expect(instance).to receive(:title)
   page.title    
 end
```

```diff
 # in lib/web_page.rb
 # ...
 def title
-  open_graph.page_title
+  open_graph.title
 end
```

Hurray! The tests are passing again, and you now have the confidence that the interfaces you mock actually exist.

#### Yes, but...

One last thing to point out before we conclude. While this alternate implementation does provide us similar confidence in the system, there is one small drawback that is worth calling attention to.

The new spec for `WebPage` is _significantly more coupled_ to `OpenGraph`. The effect is that our isolated test will resist refactoring done to `WebPage`. This can be frustrating. It doesn't make the implementation _wrong_, but you must keep these things in mind when designing tests.

---

### 👂 _LISTEN!_

- Illustrate how differently things would look if we implemented wrapper with isolated test.
- Conclusion.

---

## Conclusion

As you have seen through this workshop, there are many imporant decisions to be made while implementing even a small feature. Perhaps you have thought "this took a lot longer then just building the feature". Yes, however, you feature is securely covered by a set of tests that ensure it behaves correctly. This gives you the confidence to deliver it to your client knowing that it works. If it ends up being unacceptable for them, it provides you with a starting point for modeling what they want to begin making changes. No doubt, testing is an investment, but all good investments reward you in the long run.

[rspec]: http://rspec.info/
[rspec-book]: https://pragprog.com/book/rspec3/effective-testing-with-rspec-3
[th-rspec]: http://blog.teamtreehouse.com/an-introduction-to-rspec
[cs-rspec]: https://www.codeschool.com/courses/testing-with-rspec
[arrange-act-assert]: https://github.com/testdouble/contributing-tests/wiki/Arrange-Act-Assert
[ogp]: http://ogp.me/
[meta]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta
[vcr]: https://github.com/vcr/vcr
[fakes]: https://www.bignerdranch.com/blog/testing-external-dependencies-with-fakes/
[og-specs]: https://github.com/huyha85/opengraph_parser/tree/master/spec
[dont-mock]: https://github.com/testdouble/contributing-tests/wiki/Don&#39;t-mock-what-you-don&#39;t-own
[verifying]: https://relishapp.com/rspec/rspec-mocks/docs/verifying-doubles
[webmock]: https://github.com/bblimke/webmock
[nokogiri]: http://www.nokogiri.org/
[london]: https://github.com/testdouble/contributing-tests/wiki/London-school-TDD
[prep-guide]: https://github.com/iamvery/nothing-to-see-here/releases/download/v0/PREPARATION.pdf

