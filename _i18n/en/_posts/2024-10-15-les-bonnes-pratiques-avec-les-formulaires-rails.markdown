---
layout: article
title:  "Best Practices Guide for Simple and Clean Rails Forms"
date:   2024-10-15 18:30:00 +0200
categories: Rails ActionController ActionView
---

# Introduction

In Rails applications, [controllers](https://guides.rubyonrails.org/action_controller_overview.html) and [views](https://guides.rubyonrails.org/action_view_overview.html) can become complex when business logic or markup that could be avoided is added.

In this article, we will explore strategies to keep your form code readable, particularly by using Rails' [FormBuilders](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html) and [ActiveRecord](https://guides.rubyonrails.org/active_record_basics.html) [associations](https://guides.rubyonrails.org/association_basics.html).

# Problem Statement

In most companies where I've worked, I've often seen overloaded controllers and views, and despite many efforts, this problem wasn't completely avoided.

To me, an ideal controller should have actions that look like this:

```ruby
  def new
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(todo_params)

    if @todo.save
      redirect_to action: :index,
                  flash: { notice: :successfully_saved }
    else
      render :new,
             flash: { error: :could_not_be_saved }
    end
  end
```

In this snippet, the action code is canonical and contains no business logic. The code is simple and immediately understandable.

However, the associated business logic is not necessarily obvious, but it will be implemented in the model and the display logic in the views.

Over time, successive developments will naturally tend to complicate the controller for various reasons:

- They might require updating associated models, and for that, some developers might be tempted to add the configuration of these associations (by creating, for example, an empty object) in the controller to make the form display easier.
- You might want to enable a specific behavior that doesn't directly translate to the model. To do this, you would add a parameter in the form independent of the model's structure, detect its value in the controller, and execute certain logic.
- The increase in data quantity will lead to using filters (or scopes), making queries sometimes complex. These filters must sometimes be applied conditionally. If this logic is added to the controller, it can quickly degenerate.
- I've occasionally seen developers lacking mastery in a complex domain end up separately saving certain objects of the graph. I emphasize that this can lead to data inconsistencies. Generally, proper use of associations and nested forms can avoid this.
- The list goes on: I also think of sending emails or other notifications, actions non-compliant with the [REST](https://medium.com/podiihq/understanding-rails-routes-and-restful-design-a192d64cbbb5) standard to manage autocomplete, etc.

The view doesn't escape complexity either. Adding interactive behaviors often requires integrating JavaScript code, for instance, via Stimulus controllers, whose configuration can clutter and complicate code readability. Using utility CSS classes or resorting to JSON data for server communication (instead of standard forms and Turbo) can also contribute to this complexity. Sometimes, it would be wiser to adapt the form structure and use Turbo. Other examples of complexity include redundant or similar code, as well as forms designed based on business requirements but without considering the existing data structure.

# Solutions

It is actually relatively simple to solve these problems using the tools provided by Rails from the start. The solution lies in mastering a few essential Rails features:

- FormBuilders
- Associations
- [Helpers](https://guides.rubyonrails.org/action_view_helpers.html)
- [Callbacks](https://guides.rubyonrails.org/active_record_callbacks.html)
- [HTTP parameter management](https://codefol.io/posts/How-Does-Rack-Parse-Query-Params-With-parse-nested-query/) in controllers and models.

### Rails Forms for Managing All Interactivity

Associations in Rails are extremely powerful. Some developers see forms as a bit complicated to handle, not very flexible. In reality, every interaction between the browser and the server can be executed with a form.

One of the barriers to using a form that I've observed is the notion of considering a form as merely a [CRUD](https://fr.wikipedia.org/wiki/CRUD#:~:text=L'acronyme%20informatique%20anglais%20CRUD,informations%20en%20base%20de%20donn%C3%A9es.). Essentially, the Rails [scaffold](https://guides.rubyonrails.org/command_line.html#bin-rails-generate), which means creating a form that mirrors the fields of a table and storing it in the database.

But by using forms to juggle with associations, you can model any interaction with the server. Adding Hotwire makes the user not even aware of dealing with forms, turning them into a simple technical detail.

Of course, I'm exaggerating a bit, in reality, you probably know `fields_for` for managing associations. `fields_for` is a Rails method that allows creating form fields for associated objects, thereby facilitating the management of complex model relationships. For example, `fields_for` can be used in an order editing form to input multiple associated items.

```ruby
<%= form_for @order do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.fields_for :items do |fi| %>
    <%= fi.label :name %>
    <%= fi.text_field :name %>

    <%= fi.label :quantity %>
    <%= fi.number_field :quantity %>

    <%# Updating existing objects %>
    <%= fi.hidden_field :id %>
  <% end %>

  <%= f.submit %>
<% end %>
```

### The Complexity of `fields_for`

Using `fields_for` may seem a bit cumbersome in a form at first as there are several cases to consider:

- Displaying and updating objects already stored in the database.
- The possibility of creating one or more new objects.

ActiveRecord allows this to be almost transparent, but managing a persisted object and one that isn't yet is not the same thing. Even though Rails is powerful, developers must always keep certain subtleties in mind to avoid getting tangled up, sometimes even giving up and tweaking the controller to get it to work.

Some of these subtleties can really ruin your life if you miss them, you probably know some. I think in particular of forgetting the hidden field to update an association. Be careful in this case to properly filter updated objects for security, for this in the model, use `reject_if` to ensure the updated objects are part of the existing association or not yet in the database. Another one is forgetting to configure `accepts_nested_attributes_for` in the model.

There are more, and confusion grows when they multiply.

### Managing Associations with Checkboxes and _destroy without Complicating the Controller

Once you have your form with an object and its associations, you can already handle many more cases.

But it becomes even more interesting when you break the equivalence between data storage and the form.

For example, if you have an online sales application (Let's take a `Order` model with a `has_many :services` association). When ordering, you simply want to choose the services you're interested in by activating or deactivating them with a checkbox (or a toggle).

A naive approach might involve adding additional attributes in the form, then retrieving the parameters on the controller side and creating/deleting the corresponding services.

To avoid putting this code in the controller, you can create the corresponding accessors in the model (or in a [View Object](https://jetthoughts.com/blog/cleaning-up-your-rails-views-with-view-objects-development/) since it's view logic and not business logic). It would be cleaner and work just as well.

This approach obviously works, but it entails writing quite a bit of plumbing logic that doesn’t really have business value.

Using the `_destroy` attribute on the association solves these problems. There is still some logic to initialize all services available for the order with the right parameters, then `_destroy` needs to be set to true to not activate the service by default (opt-in), and not set to activate a service by default (opt-out). This can be done on the model side with an `after_initialize` callback, probably conditionally in this way `Order.new(build_services: true)`. `build_services` being an `attr_accessor` that indicates whether to activate the callback.

```ruby
class Order < ApplicationRecord
  has_many :services

  accepts_nested_attributes_for \
    :services,
    allow_destroy: true
    reject_if: :belongs_to_foreign_record?

  attr_accessor :build_services
  after_initialize :build_services_records, if: :build_services

  def build_services_records
    Service::KINDS.each { |kind| services.build(kind:) }
  end

  def belongs_to_foreign_record?(attributes)
    attributes['id'].present? &&
      services.ids.include?(attributes['id'].to_i)
  end
end
```

The controller is a bit less canonical, but it's fine. Even if a parameter is specified, this approach prevents the controller from having knowledge of the model's implementation details (if strong_parameters is missed).

On the view side, one can handle it with a `f.fields_for :services`. And the checkbox corresponding to `_destroy` is displayed but inverted with some CSS (when `_destroy` is true, the box will be unchecked and vice versa).

```ruby
<%= f.fields_for :services do |fs| %>
  <%= fs.hidden_field :id %>
  <%= fs.check_box :_destroy %>
<% end %>
```

When the controller sends form parameters to the model, associations with `_destroy` set to true are deleted. So only the activated services will be associated with the order.

This was just to show an example of what can be done by bending Rails logic a bit.

It may seem somewhat trivial, but this kind of approach helps limit superfluous code (bloat). It allows for implementing complex features while keeping relatively simple, understandable code. Even though the logic may appear a bit convoluted, since these patterns can be applied in different situations, the application can grow while maintaining accessible code even without having been modified for a long time.

In our application, we use this approach to configure the services associated with an order. This allowed us to remove a lot of code in the view and simplify our controllers.

### Eliminating Redundancies with a Custom FormBuilder

ActiveAdmin uses `formtastic` to generate forms. You know, it's the slightly quirky but very concise syntax that allows creating forms in ActiveAdmin, and you may have struggled with it if you've needed to customize them.

You may also know `simple_form`, which is another form builder.

But in reality, having your own form builder in your application will allow for cleaner views.

The advantage is that rather than adapting to the choices made by the form builder's creator and possibly ending up fighting with them, you can tailor it to suit your application's needs, and it’s not really that complicated to do.

Often, you have a generic way of writing your forms, applying a similar layout or style to nearly all your forms (or at least juggling with a few different styles).

For example, you use a label, then your field, encapsulated in a div, possibly with some CSS classes (whether you’re a fan of Tailwind or prefer the semantic HTML/CSS approach).

The default Rails helpers replicate HTML fields by hydrating them with ActiveRecord. So if you only rely on Rails helpers, your views will be verbose and repetitive. Consistently, you’ll have a div and its classes, with the label and field inside.

In your FormBuilder, you can override Rails helpers (or create others alongside) so they generate everything at once. Your views become much cleaner. If you need to make a different version, you can always add another helper or add extra options to your helper.

```ruby
module ApplicationFormHelper
  def semantic_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
    merged_options = { builder: ApplicationFormBuilder }.merge(options)
    form_with(model:, scope:, url:, format:, **merged_options, &block)
  end
end

class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options = {})
    _wrapped_field(method, super)
  end

  def value(method)
    _wrapped_field(method, object.public_send(method))
  end

  def _wrapped_field(method, value)
    @template.content_tag(:p) do
      @template.safe_join [label(method), value]
    end
  end
end
```

Next comes the issue of your Stimulus controllers. The Stimulus syntax can be particularly verbose, and while it’s relatively easy to write, reading it sometimes becomes quite indigestible.

For instance, if you want to dynamically add/remove an object in an association, you might wish to use `nested-form` from [Stimulus Components](https://www.stimulus-components.com). The syntax is relatively straightforward but could be simplified:

- Data attributes must be added on the form tag to enable the functionality.
- Configuring the template involves many tags.

By adding a helper (which could be used with `f.has_many :items`, for instance), you can:

- Automatically create a `fieldset` with a default legend.
- Automatically call `fields_for` with the correct parameters.
- Configure the Stimulus controller.
- Add the add/remove buttons in the right place so the caller can simply define the fields to display.

You can, of course, apply this logic of creating helpers with all Stimulus controllers in your application (whether they’re in forms or not), so your views should gain in readability.

### Associations in ActiveRecord

A key to avoiding headaches when creating forms in Rails is understanding and mastering several concepts:

- The parameter format in Rack (how parameters are passed as a hash of options).
- How associations are handled in persisted and non-persisted mode. Rails is, indeed, capable of navigating an association graph whether they are persisted or not. But there are differences between the two. The magic of Rails has its limits.
- Understanding the database transaction system is important. The key lies in one simple rule: one controller action = one save. It is crucial to grasp that a save in Rails allows saving an entire object graph in a transaction. You don’t need to manage the transaction manually with a block or anything; all it takes is to build your form so that it contains all the objects to save via the associations.

## Persistence of Associations in ActiveRecord

To understand how a form should be written to function as desired, I usually start by taking a tour in the Rails console.

Create a new object with the parameters expected in the form, navigate the graph, save, and if everything works as expected, replicate the structure used in a form.

When making more complex associations, with scopes, for instance, or [polymorphic associations](https://edgeguides.rubyonrails.org/association_basics.html#polymorphic-associations), you may occasionally have [surprises](https://stackoverflow.com/questions/35104876/why-are-polymorphic-associations-not-supported-by-inverse-of).

Usually, this doesn’t pose a problem in practice, but occasionally, you may have to configure manually.

Keep your associations as simple as possible because certain combinations may not work correctly in Rails.

In the case below, you can see that the association configuration doesn’t allow the inverse to be retrieved when the association isn’t yet persisted. This can be easily understood since the scope is a DB query and, therefore, not executed for a non-persisted association.

If you already have a `has_many :items` and want to add `has_one :special_item, -> { where(kind: :special) }` from the same class as items, the association won’t work correctly for non-persisted associations. This can sometimes cause issues in certain use cases.

```ruby
# Create a new todo with an item and a special item
>  todo = Todo.new(
     items_attributes: [{}],
     special_item_attributes: {}
   )
=> #<Todo id: nil, name: nil>

# The item is well-linked to the todo via the inverse association
>  todo.items.first.todo
=> #<Todo id: nil, name: nil>

# But not the special item
>  todo.special_item.todo
=> nil
```

When ActiveRecord behavior doesn’t function as expected, it’s worth checking the code managing the association to understand the issue's origin.

In these cases, I use [source_location](https://ruby-doc.org/core-2.4.6/Method.html#method-i-source_location) to find easily the code used during the association call. This method returns the source file and the line number where the method is defined. For example:

```ruby
> Todo.method(:has_many).source_location
=> ["gems/activerecord-7.2.1.1/lib/active_record/associations.rb", 1268]

> Todo.instance_method(:items).source_location
=> ["gems/activerecord-7.2.1.1/lib/active_record/associations/builder/association.rb", 103]
```

Understanding implementation details allows creating functions integrated with ActiveRecord. This enables adding your own magic to your app and having functions that seem like they belong to Rails.

# Conclusion

Rails applications can be complex, and the pragmatic approach of the framework sometimes leads to problems in code organization. Using the techniques outlined in this article, you can maintain very simple and clear views and controllers. This issue also exists for managing model complexity, but we will tackle this topic in a future article.
