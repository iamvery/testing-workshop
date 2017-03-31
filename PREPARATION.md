# TDD: From Feature to Tests to Implementation

Take a few moments to prepare your system for the workshop. In this guide, you will download the example app source code and install it's dependencies.

## TL;DR

- Ruby (v2.1 or higher)
- SQlite3
- PhantomJS
- App source code (https://github.com/iamvery/rc17-testing-workshop)

## Ruby

It is assumed that you have a modern version of Ruby installed on your system. The workshop should work well on the latest Ruby (2.4 at the time of writing). It should also work on versions as old as 2.1.

If you need assistance installing Ruby, check out the information available at https://www.ruby-lang.org/en/documentation/installation/.

## SQlite3

The app you will be using during the workshop uses a SQlite3 database. SQlite is not a production-ready database, but it is relatively easy to configure and is available by default on macOS. If you are unsure whether you have SQlite3 installed, you might just try completing this guide. If you run into any problems bundling or setting up the database, here is a good resource for configuring SQlite3 on your system: http://mislav.net/rails/install-sqlite3/.

## PhantomJS

This is a so-called headless browser used to drive acceptance tests from a user's perspective. PhantomJS is a dependency of [poltergeist](https://github.com/teampoltergeist/poltergeist) which is the driver used by [capybara](https://github.com/teamcapybara/capybara) this app's test suite. Basically, you don't need to know about this stuff, but it is required to build and run the test suite, so make sure you have it installed.

The poltergist documentation has a concise guide for installing PhantomJS at https://github.com/teampoltergeist/poltergeist#installing-phantomjs.

## Pinster

The work you will do through this workshop will be on a small Rails app, Pinster. Pinster is a link "pinning" app, not unlike [Pinterest](https://pinterest.com/).

The base Pinster application is free and open source. Clone the source to your machine and enter its directory:

```
$ git clone https://github.com/iamvery/rc17-testing-workshop.git
Cloning into 'rc17-testing-workshop'...
... done.
$ cd rc17-testing-workshop
```

From here on, it is assumed that all commands are run from within this cloned directory. Next bootstrap the app by installing dependencies and setting up your development database:

```
$ bundle install && bin/rake db:setup && echo done!
...
done!
```

Pinster comes with an automated test suite written in [RSpec][rspec]. You can run the full test suite at any time with the command `bin/rspec`. With the app fully bootstrapped, you should be able to run the full test suite and see all the tests pass.

```
$ bin/rspec
...

Finished in 0.41927 seconds (files took 2.65 seconds to load)
3 examples, 0 failures
```

This not only tells you that your system is working. It also ensures that the _app_ is working as expected! Finally, start Pinster and see what it can do firsthand:

```
$ bin/rails server
...
=> Rails application starting in development on http://localhost:3000
...
```

Open the application at [http://localhost:3000][local].

![Screen Shot 2017-03-29 at 11.12.36 AM](/Users/jay/Desktop/Screen Shot 2017-03-29 at 11.12.36 AM.png)

You should see something like above. Try creating a link.

![Screen Shot 2017-03-29 at 11.13.25 AM](/Users/jay/Desktop/Screen Shot 2017-03-29 at 11.13.25 AM.png)

And that just about does it. As the interface suggests, you can also delete links by clicking the "x" icon to the right. One final feature that is less obvious from the interface is that Pinster uses ActionCable to stream link created and deleted links to clients. You can try this out by opening another browser window and watch them both while adding and deleting links.

### Congratulations!

You are now all set for the workshop "TDD: From Feature to Tests to Implementation". As you might have guessed, you will be adding to the understated simplicity of Pinster by building a new feature with tests! I can't wait to see you there 🙂.