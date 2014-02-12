Barebones
=========

Using Backbone models and collections for simple data organization and manipulation is overkill. This should probably just be renamed Collection.js or something, since it doesn't do 99% of the things Backbone does.

## What It Isn't
It isn't Backbone. It doesn't do Views or Events. No .sync() or .fetch() -- for now at least.

## What It Is
A way to work with collections of data. Sometimes you want to process a considerable amount of data on the client. My use case is for organizing, sorting, and filtering large sports datasets. Thus, I don't want the added overhead of Backbone Events, or having to .set() or .get() model attributes. Essentially, I want a Collection class with chainable Lodash / Underscore collection methods.