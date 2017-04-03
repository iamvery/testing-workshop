# Workshop

##### TDD: From feature to tests to implementation

**Duration:** 2 hours 20 minutes

# Introduction

The goal is to expose you to different levels of testing and how to move in and out of them to see a feature to completion driven by tests. You may or may not have feelings of overkill through this exercise. It is important to not focus too much on whether this particular example is overkill, but rather note the strategies and tools which may aid your development in the future.

# Pinster

The rest of this material will be an interactive tutorial. Start by downloading and bootstrapping a simple application, Pinster. Pinster is a revolutionary link "pinning" app. Never again will you forget a link to an important thing you found on the Internet!

Once you have Pinster running, you will begin adding a brand new feature to it! This will change everything.

## Get Pinster

The base Pinster application is free and open source. Clone the source to your machine and changing to its directory:

```bash
$ git clone https://github.com/iamvery/rc17-testing-workshop.git
Cloning into 'rc17-testing-workshop'...
... done.
$ cd rc17-testing-workshop
```

Next bootstrap the app by installing dependencies and setting up your development database:

```Shell
rc17-testing-workshop$ bundle install && bin/rake db:setup && echo done!
...
done!
```

Finally, start Pinster and see what it can do:

```
rc17-testing-workshop$ bin/rails server
...
=> Rails application starting in development on http://localhost:3000
...
```

Open the application at [http://localhost:3000][local].

Pinster has a tantilizing user interface which consists of a brilliantly simple, single _URL_ input and submission button. Go ahead and submit a link. You will see the link immediately appear below the input. The sky is the limit on the number of links you can submit!

You will also notice a small "x" to the right of each link. This powerful little button is a tool of destruction. By clicking it, the corresponding link vaporizes.

As if this app wasn't already powerful enough, it has one more secret. Changes made to links are _streamed in real-time_ to other clients connected to the app. Open another browser, add and remove some links, and see the brilliance of Pinster in action.

Pinster comes with an automated test suite written in [RSpec][rspec]. You can run the full test suite at any time with the command `bin/rspec`. Run the tests a lot while you're developing features. Before each run, consider for a moment what _you expect_ to happen. If you're surprised by what _actually_ happens, think about why it behaves in an unexpected way.

### Tests

Ok, so this app isn't actually all that fancy, but it does come with a few tests. In fact, the functionality is so basic that no unit tests are needed to confidently deliver its core functionality: adding and deleting links. All the tests included so far are _**acceptance**_ tests. As their name suggests, these tests define the acceptance criteria for each feature they represent. Have a look at the acceptance test for viewing links:

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

If you haven't used RSpec, don't fret. The syntax tends to be very intuitive. If you're feeling lost, check out [Treehouse][th-rspec] and [Code School][cs-rspec]. Acceptance tests often read as if a user is interacting with the app. At the top, the conditions are set up for the test. Next, the user interacts with the app by visiting the page. Finally, observations are made about the content of the page that must be true for the feature to be implemented correctly. This structure of tests is often called ["Given-When-Then"][gwt].

## A New Feature

To make Pinster even more useful, each link should include its fetched page title as a preview. Here are the requirements:

- Given a link to some webpage exists.
- When you view links.
- Then you will see the fetched page title for that webpage beside its URL.

That sounds useful. Make it so.

## Your First Test

With any clearly defined user story, the first test you write is an _**acceptance**_ test. This is the so-called "highest level" test that you will write, and although it is the first one written, it is likely to be the _last_ one passing. The passing of this test is an indication that your feature _might_ be done. Any time the acceptance tests pass, it is time to consider refactors to the implementation.

---

### ✍️ _WRITE!_

It is time to write your acceptance test for the page title feature. You should think about the structure of this test:

- Given: What state much the app have before the user interacts with it?
- When: What interaction does the user perform?
- Then: What observation(s) must be true for the feature to be complete?

Go ahead and write your acceptance test in `spec/acceptance/links_spec.rb` before continuing.

---

Ok, now that you have written the acceptance test, let's talk about it together. You _did_ write it yourself didn't you..?

Fundamentally, this feature is about _viewing_ links, so it probably fits best into the "viewing links" context:

```diff
 # in spec/acceptance/links_spec.rb
 describe "viewing links" do
   it "displays all links" # ...
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

Nice! That test cleanly summarizes an acceptable scenario for the feature you are adding.

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

You're first failing test! To figure out where to go from here, take a moment to think about what the test is telling you. It expected to find "Twitter", the first link's page title, on the page. Of course, you are only displaying the URL for each link. Have a look at the link view partial:

```erb
<!-- app/views/links/_link.html.erb -->
<li class="list-group-item" data-link-id=<%= link.id %>>
  <%= link_to link.url, link.url %>
  <%= link_to link, method: :delete, remote: true, class: "pull-right", data: { role: "delete-link" } do %>
  <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>
  <% end %>
</li>
```

You could go lo-fi and put a static `Twitter` in the page, but that's not really a step forward. The test would still immediately fail when it looks for "Google". The intuition here is that you need to move deeper into the system in order to continue building this feature. As a first step, make a predicion about how your model will work by adding a `link.title` to the page:

```diff
 <!-- app/views/links/_link.html.erb -->
 <li class="list-group-item" data-link-id=<%= link.id %>>
+  <%= link.title %>
   <%= link_to link.url, link.url %>
 <!-- ... ->
```

Oops, now when you run the tests _everything_ fails!

```
$ bin/rspec
Failures:

  1) Links viewing links displays all links
     Failure/Error: <%= link.title %>

     ActionView::Template::Error:
       undefined method `title' for #<Link:0x007f97671676b8>
...
```

 Oh no! Actually, oh _yes_. What is this telling you? It's telling you that you're missing a fundamental interface on our model, Link#title. This hint informs you that it is time to zoom in with our testing strategy. It's time to write a _**unit**_ test.

## Unit Testing

---

### ✍️ _WRITE!_

Take a moment to write a unit test for the Link#title method. It should return the page title for the link's URL. In case you're not familiar with RSpec, here's the skeleton for this new spec file:

```ruby
# in spec/models/link_spec.rb
require "rails_helper"

RSpec.describe Link do
  describe "#title" do
    it "returns the page title" do
      # WRITE THE TEST HERE
    end
  end
end
```

- What is the simplest possible test you could write here?
- What is the simplest possible implementation to make your test pass? Make it _very_ simple, even dumb.

------

Your first unit test will be used to drive the `Link` model's `title` instance method implementation. Start by finishing the test:

```ruby
# in spec/models/link_spec.rb
# ...
it "returns the page title" do
  link = Link.new(url: "http://google.com")
  title = link.title

  expect(title).to eq("Google")
end
```

While focusing on a single unit, you will want to run only the relevant unit tests. In this case, run the link model spec:

```
$ bin/rspec spec/models/link_spec.rb
Failures:

  1) Link#title returns the open graph title
     Failure/Error: title = link.title

     NoMethodError:
       undefined method `title' for #<Link:0x007fe563b23298>
```

That is the same error you got in the acceptance test! You're on the right track, but now that the error has manifested closer to the unit being built. You can focus your energy on this single method. Go ahead and add a minimal implementation to the `Link` model:

```diff
 # in app/models/link.rb
 class Link < ApplicationRecord
+  def title
+    "Google"
+  end
 end
```

It might seem strange to start with such a dumb implementation. Obviously the literal "Google" is not the page title for any link URL, but this silly addition has some valueable purposes:

1. It serves to make the unit test pass. Run it and see!
2. It serves to again isolate the acceptance test failure to the our one feature scenario. Run `bin/rspec` and see!

From here you may continue to iterate on the implementation and find an optimal solution.

Take a moment to consider your next move. You could zoom back out to the acceptance level, but the unit is still not complete. The implementation of Link#title is clearly lacking. You need a way to fetch the actual page title for a link's URL.

### Open Graph

The [Open Graph Protocol][ogp] defines a way of relaying page information as a part of it's [meta][meta] data. You find the Rubygem `opengraph_parser` and it seems to fit the bill. Don't overthink this too much. Given the right design, you should be able to swap implementations in and out as you look for the optimal solution.

Add `gem "opengraph_parser"` to your `Gemfile` and `bundle install`. Take a moment to play around with this library in the Rails console:

```
$ bin/rails console
irb> og = OpenGraph.new("http://google.com")
=> #<OpenGraph...>
irb> og.title
=> "Google"
```

That works well enough! Next, use this library to complete the implementation of Link#title.

---

### ✍️ _WRITE!_

Go ahead and update the implementation to use the `opengraph_parser` library. This should only require a small change. Once you have made the minimal change necessary to get the tests passing, consider the solution as a whole. Do you recognize any drawbacks?

---

The change to `title` is straight forward. Replace the static title value with a call to the Open Graph library:

```diff
 # in app/models/link.rb
 class Link < ApplicationModel
   def title
-    "Google"
+    OpenGraph.new(url).title
   end
 end
```

When you run the model unit test, you see that it passes. In fact, running the entire test suite passes! But is the feature done?!

```
$ bin/rspec
.....

Finished in 2.36 seconds (files took 1.9 seconds to load)
5 examples, 0 failures
```

Actually there's a problem. Did you notice that the test run was _significantly_ slower that time? That's because your test suite now has a dependency on the network in order to pass. Try disabling your network and run the tests. You should see many tests fail again. This is unacceptable for a couple reasons:

1. The "slowness" of your test suite will grow with every test that accesses the network.
2. Your test suite now _requires_ an Internet connection. What if you want to hack on the road?

This is quite a problem, but thankfully you fix problems for a living.

## An Adapter

The problem you have at this point is that your test suite establishes a _real connection_ to an external resource. This has the effect of coupling your test suite to the Internet which is both slow and painful for offline development.

One solution to this problem is to introduce a tool like [VCR][vcr] to record and playback external network requests during your tests. While this approach works, it is often tedious to manage the recorded network transactions as your application grows in complexity. As an alternative, consider [injecting a test fake][fakes] which mocks the interface of the object making the external connection. Besides, why test the library code again when it already [has tests][og-specs].

Remember, it is important that you [don't mock an interface that you don't own][dont-mock]. So first, create an adapter object which has an interface you _do_ own. Go ahead and do that.

------

### ✍️ _WRITE!_

Create an adapter for the `OpenGraph` object that exposes the minimal interface needed by your system, a `title`. It's important establish concepts in your domain, so for simplicity call this object a `WebPage`. Here are a couple files to get you started:

```ruby
# in spec/lib/web_page_spec.rb
require "spec_helper"
require "web_page"

RSpec.describe WebPage do
  # YOUR TESTS HERE
end
```

```Ruby
# in lib/web_page.rb
class WebPage
  # YOUR IMPLEMENTATION HERE
end
```

Consider the purpose of this new object: to establish an interface you own for interacting with a library you do not own. Therefore, all these tests should do is verify that integration behaves correctly. Give the implementation a shot, but don't spend too much time on it if things aren't making sense.

------

To keep with the tradition of test-driven code, first define the tests that verify the behavior of the adapter.

# **TODO** split this example up and explain things more thoroughly!

```ruby
# in spec/lib/web_page_spec.rb
require "spec_helper"
require "web_page"

RSpec.describe WebPage do
  let(:lib) { double(:open_graph_class) }
  let(:instance) { double(:open_graph_instance) }
  let(:url) { "http://example.com" }

  before do
    allow(lib).to receive(:new) { instance }
    allow(instance).to receive(:page_title)
  end

  describe "#initialize" do
    it "creates a new instance of the Open Graph library with its URL" do
      described_class.new(url, lib: lib)

      expect(lib).to have_received(:new).with(url)
    end
  end

  describe "#title" do
    it "returns Open Graph instance page title" do
      adapter = described_class.new(url, lib: lib)
      adapter.title

      expect(instance).to have_received(:page_title)
    end
  end
end
```

A close reading of these tests reveal that the adapter is expected to create an instance of the given `lib` class as later send that instance the `:title` message. These tests may seem like overkill, but it is necessary to know that the integration between your adapter and the library code is accurate as you will eventually remove references to the library code from the test suite, instead relying on a test fake.

Complete the implementation by filling out the `WebPage` definition:

```ruby
# in lib/web_page.rb
require "open_graph"

class WebPage
  def initialize(lib: OpenGraph)
    @open_graph = lib.new(url)
  end
  
  def title
    @open_graph.page_title
  end
end
```

Run the unit test for the adapter and see it pass:

```
$ bin/rspec spec/lib/open_graph_adapter_spec.rb
..

Finished in 0.00857 seconds (files took 0.20866 seconds to load)
2 examples, 0 failures
```

But there's a problem… Did you catch it? The test is passing… What could be wrong?

### Verifying Mocks

You may have noticed that the test that was written for the `WebPage` never involved the actual `OpenGraph` object. Instead it _assumed_ that the interface of the object is mocked accurately. Except it isn't. An instance of `OpenGraph` does not respond to `page_title` as the implementation suggests, but you may not have caught that mistake until you ran the application and viewed some links. The bug might even have made it all the way to production!

This is because your tests never _verify_ the interface being mocked. The solution to this problem depends on your tools, but RSpec provides you with [verifying doubles][verifying] for this very scenario. Update your test doubles to solicit RSpec's help:

```Diff
 # in spec/lib/web_page_spec.rb
-let(:lib) { double(:open_graph_class) }
-let(:instance) { double(:open_graph_instance) }
+let(:lib) { class_double(OpenGraph) }
+let(:instance) { instance_double(OpenGraph) }
```

Now any message sent to these doubles will be verified as valid messages of the class or instance respectively. Run the tests and see them now fail:

```
$ bin/rspec spec/lib/web_page_spec.rb
Failures:

  1) OpenGraphAdapter#initialize creates a new instance of the Open Graph library with its URL
     Failure/Error: allow(instance).to receive(:page_title)
       the OpenGraph class does not implement the instance method: page_title
...
```

Finally, update spec and implementation to fix the erroneous message:

```Diff
 # in spec/lib/web_page_spec.rb
 before do
   allow(lib).to receive(:new) { instance }
-  allow(instance).to receive(:page_title)
+  allow(instance).to receive(:title)
 end
 
 # ...
 
 describe "#title" do
-  it "returns Open Graph instance page title" do
+  it "returns Open Graph instance title" do
     adapter = described_class.new(url, lib: lib)
     adapter.title
 
-    expect(instance).to have_received(:page_title)
+    expect(instance).to have_received(:title)
   end
 end
```

```diff
 # in lib/web_page.rb
 def title
-  @open_graph.page_title
+  @open_graph.title
 end
```

Hurray! The tests are passing again, and you have an adapter ready to use and mock in place of `OpenGraph`.

Now that your adapter is rock-solid and ready for use, go ahead and plug it into your model:

```diff
 # in app/models/link.rb
+require "web_page"
+
 class Link < ApplicationModel
   def title
-    OpenGraph.new(url).title
+    WebPage.new(url).title
   end
 end
```

All of your tests are still passing, but… they're still slow. Don't lose site of the finish line. You're still not quite there...

## Fake It

The work you just did to create an adapter for `OpenGraph` didn't solve the issue of your test suite being coupled to the network. But it did do the important work of establishing an interface you can mock in you tests.

------

### ✍️ _WRITE!_

Create a fake object to stand in for a `WebPage`. Using this object in tests will allow you to exercise application code without the network dependency. It is important for this object to have non-trivial behavior, but without dependency on the network. Here are the files with the fake's `title` behavior pre-specified for you:

```ruby
# in spec/support/fake_web_page_spec.rb
require "spec_helper"
require "support/fake_web_page"

RSpec.describe FakeWebPage do
  describe "#title" do
    it "returns the titleized URL domain name" do
      web_page = described_class.new("http://some_web_page.com/content")
      title = web_page.title

      expect(title).to eq("Some Web Page")
    end
  end
end
```

```Ruby
# in spec/support/fake_web_page.rb

class FakeWebPage
  # YOUR IMPLEMENTATION HERE
end
```

Hint: check out the `URI` object in Ruby's standard library to complete the implementation. If you feel stuck, check out [this blog post][fakes].

------

Complete the implementation of `FakeWebPage`:

```ruby
# in spec/support/fake_web_page.rb
require "uri"
require "active_support/core_ext/string/inflections"

class FakeWebPage
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def title
    domain.titleize
  end

  private

  def domain
    host.split(".").first
  end

  def host
    uri.host
  end

  def uri
    URI(url)
  end
end
```

With that you can begin to decouple your `Link` model from the network.

## Dependency Injection

To decouple the `Link` model from the network, you need to replace calls to the real `WebPage` object with a `FakeWebPage`. Dependency injection is a good strategy for loosening coupling and supporting such replacements. It is a viable strategy for this case. Update the `title` method of `Link` to accept an injected library as an optional argument:

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

With this small change, you can already start the process of decoupling by eliminating the Link#title unit test's network dependency.

```diff
 # in spec/models/link_spec.rb
+require "support/fake_web_page"
 
 # ...
   describe "#title" do
     it "returns the page title" do
       link = Link.new(url: "http://google.com")
-      title = link.title
+      title = link.title(lib: FakeWebPage)

       expect(title).to eq("Google")
     end
```

Before you injected `FakeWebPage` this one test took about 0.9s to run. Now it completes in 9ms! That's 100x faster for the unit test, but the acceptance tests are still very slow...

## Environment Configuration

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
-def title(lib: WebPage)
+def title(lib: Rails.configuration.web_page_lib)
   lib.new(url).title
 end
```

At this point, you tests still pass and the behavior is unchanged, but an important seam now exists. You can change the Rails conguration to specify _anything_ you want to be used for the web page lib! Update your test environment to always use the test fake:

```diff
 # in spec/rails_helper.rb
 require "capybara/rspec"
 # Add additional requires below this line. Rails is not loaded until this point!

+require "support/fake_web_page"
+Rails.configuration.web_page_lib = FakeWebPage
+
 # Requires...
```

Now your test suite configures the application to always use `FakeWebPage`. Before this change, the entire test sweet ran in about 2s. Now it completes in 0.3s! This completely eliminates your tests' dependency on the network! You can now enjoy fast, offline tests. Go ahead and hack on it in planes, trains, and automobiles!

## The End

Are you surprised that such a simple feature took _this_ much time and thought to implement with tests? Testing can be tricky, but when done well it provides tremendous confidence in the software you produce. When you hit a rhythm, you may go a really long time without ever actually running the app!

## But wait, there's more!

There are a couple more interesting things to consider about your solution:

- The design you settled on makes it really easy to swap out your Open Graph implementation for something else.
- The tests that you have written are _content focused_. This means that you should be able to make significant changes to the design of your page without having to update tests.

### Roll Your Own Page Title

# **TODO** fill out open-uri + nokogiri implementation

### Redesign Links

# **TODO** replace link list with bootstrap wells. make title an h3 and link paragraph. change delete icon to button with text

[local]: http://localhost:3000
[rspec]: http://rspec.info/
[th-rspec]: http://blog.teamtreehouse.com/an-introduction-to-rspec
[cs-rspec]: https://www.codeschool.com/courses/testing-with-rspec
[gwt]: https://en.wikipedia.org/wiki/Given-When-Then
[ogp]: http://ogp.me/
[meta]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta
[vcr]: https://github.com/vcr/vcr
[fakes]: https://www.bignerdranch.com/blog/testing-external-dependencies-with-fakes/
[og-specs]: https://github.com/huyha85/opengraph_parser/tree/master/spec
[dont-mock]: https://github.com/testdouble/contributing-tests/wiki/Don&#39;t-mock-what-you-don&#39;t-own
[verifying]: https://relishapp.com/rspec/rspec-mocks/docs/verifying-doubles