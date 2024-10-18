---
layout: article
title:  "Why Continue Embrassing Progressive Enhancement in 2024?"
date:   2024-11-05 08:00:00 +0200
categories: Rails Hotwire Stimulus Turbo
---

# Introduction

Progressive enhancement is a web design methodology that involves creating a minimalist and resilient version of a feature—meaning one that will be usable in a browser from the 2000s. Then, modern features are gradually layered over it.

To achieve this, start by writing a page with minimal and standard HTML code, and associate a CSS stylesheet with equally minimal and standard directives. You get a functional page that loads instantly, even with a poor connection and JavaScript disabled.

All non-essential functionalities that enhance user experience (fonts, interactive behaviors, visual effects) are added progressively, ensuring that the basic page functionality works even when these enhancements aren’t activated.

# The State of the Art in 2024

The generally accepted [motivation](https://piccalil.li/blog/its-about-time-i-tried-to-explain-what-progressive-enhancement-actually-is/) in the literature for using progressive enhancement is to provide an acceptable user experience even in degraded conditions.

However, in 2024, it is entirely possible to launch a service without worrying about the experience of a small number of people in degraded conditions. This is why many developers for over 20 years have chosen technologies that require JavaScript to be enabled and generally require the download of a large amount of JavaScript before users can interact with the site.

This approach unquestionably allows for thriving business. And even if some users are left behind, it certainly won't prevent your service from being a success.

While I am obviously committed to not leaving anyone behind in my developments, for me, that is not the most important reason to adopt this approach.

# The Reason for Progressive Enhancement

The right reason is the one that will convince you or allow you to convince an entire team or executives to switch to this approach.

If you hope to convince all these people by telling them they can increase their target from 98% of users to 99%, you have little chance of convincing them unless it’s an already well-established multinational, where this might be the last lever for growth.

Even if you convince them that a major part of their users will occasionally encounter a poor experience (a thought for those using their phone on public transport), because they face degraded conditions, it won't necessarily change their priorities.

But for me, the most interesting thing is that this technique leads to simpler and easier-to-maintain code.

# Progressive Enhancement Improves Code

For me, the good reason is that this approach improves code quality and avoids a considerable number of problems in an application. That's what I'm going to explain here.

> Working in the actual deliverable’s medium — the web — in cycles/iterations/sprints, with progressive enhancement at the root will — I promise — result in smaller codebases, simpler UIs and happier users!
>
> [*Andy Bell*](https://piccalil.li/author/andy-bell)

## It Reduces the Amount of JavaScript

To start, we’re going to use JavaScript only to enhance the existing experience.
Thus, this experience will be realized only with the standard features of the Web.
We’ll use [links and forms](/en/rails/actioncontroller/actionview/2024/10/15/les-bonnes-pratiques-avec-les-formulaires-rails.html)
by default to communicate with the server. For the majority of functionalities,
this will be sufficient, and nothing will need to be added
to achieve a satisfactory experience.

However, sometimes we’ll want to optimize the experience. Take, for example, a field with autocompletion.
The principle is to display a list of suggestions as you type.
[Such functionality ~~is unachievable without~~ often requires JavaScript](https://gomakethings.com/how-to-create-an-autocomplete-input-with-only-html/)
as it needs to trigger a behavior with each input.
If server interaction is necessary, simple HTML is not enough.

However, implementing this type of functionality by following the principles of
progressive enhancement simplifies code architecture.

Imagine how such a feature might look without JavaScript.
We can display an input field and an initially empty suggestion list.
As the user types, they will want to consult the suggestions.
To do this, instead of displaying them instantly, the user can activate
a dedicated suggestion-loading button on the form to display them.
Without JavaScript, the entire page will reload with the list.
The user can then choose an item from the list and finalize the form.

```ruby
class Order < ApplicationRecord
  belongs_to :product
  attr_accessor :product_name
end

class Product < ApplicationRecord
  def self.search(query)
    return none if query.blank?

    where('name like :query', query: "#{query}\%")
  end
end
```

```ruby
class OrdersController < ApplicationController
  def new
    @order = Order.new
  end

  def create
    @order = Order.new(params[:order].permit!)

    if params[:commit] && @order.save
      redirect_to @order
    else
      render :new
    end
  end
end
```

```erb
<%= form_with model: @order do |f| %>
  <fieldset>
    <legend>Todo</legend>

    <%= f.text_field :name %>

    <%= f.text_field :product_name,
                     list: 'product-suggestions',
                     value: params.dig(:order, :product_name) %>

    <datalist id="product-suggestions">
      <% Product.search(@order.product_name).each do |product| %>
        <%= content_tag :option, '', value: product.name %>
      <% end %>
    </datalist>

    <%= f.submit 'Search', name: 'autocomplete' %>
  </fieldset>

  <%= f.submit %>
<% end %>
```

We can then use JavaScript to enhance the experience. The advantage of using
this approach is that there will be very little JavaScript to add. By using
technologies like Hotwire Turbo, we don’t even need to add the JavaScript ourselves
but just a bit of configuration on the forms. JavaScript will hide the button and trigger behavior on input. This behavior involves
loading the list, then replacing the list on the current page. Loading the list
can be done by fetching the updated current page (thus not requiring
an update to the server part) or a partial version of the page containing
only the suggestions.

In our example, note that the controller requires no adaptation
to display product suggestions and only needs
to check if `params[:commit]` is defined to handle interactive behaviors
before validation.

Thus, we have shown how this approach can reduce the amount of JavaScript
in an application. We will now see how reducing JavaScript also
facilitates application maintenance.

# It Facilitates Code Maintenance

In a Rails application, JavaScript code is more difficult and complex to test as it requires a web browser to run, in contrast to backend code, which runs natively on the server without a browser. This will also make tests longer to execute.

With progressive enhancement, the JavaScript code produced is more general, making it much easier to test. It has no dependencies on business logic so code is more likely to be reusable elsewhere in the application. This snowball effect of reusability further reduces the amount of JavaScript code. It’s a virtuous cycle.

Of course, JavaScript code (more precisely the code executed directly by the browser) is not inherently a problem, but its systematic use makes systems more complex. Reducing this complexity leads to improved maintainability of applications.

# A Second Example

To automatically copy text to the clipboard, JavaScript is required.

However, we can design an equivalent feature without JavaScript. Namely: display the text to be copied and suggest the user copy the text themselves using their operating system's functionality.

```erb
<% if @order.product %>
  URL <%= text_field_tag '', url_for(@order.product) %>
<% end %>
```

This satisfies the user’s need. The proposed solution is extremely rudimentary but incredibly effective.

JavaScript can then be used to enhance the user experience of this basic feature by allowing the text selection and copying to be done automatically.

The principle is to (optionally) hide the text to be copied while keeping it in the page's code and add a button to trigger the copy to the user's clipboard and display a message confirming successful operation.

Thus, when JavaScript is not available, the site will display simple text and suggest the user copy the text with a message. The function remains accessible. Then, when JavaScript is available, the user will see a simple button to automatically copy the text.

In this example, the principle remains the same: create a functional base version without JavaScript and enhance the user experience by adding more interactivity with JavaScript. We see all the previously mentioned advantages: the function is always accessible, and the enhanced version is reusable, easily maintainable, and requires little additional code.

# The More Complex, the More Advantageous

The previous example was extremely simple but sufficient to illustrate the interest of this approach.

Let’s push the example a little further by adding interactions with the server.

Now, our user will select a product from the database by its name (using the autocomplete function). The user then wants to copy the link to access this product to send it by email to a customer.

As in the first example, the user’s input will be sent to the server (via the form button or automatically), and the browser will retrieve a list of results.

The difference this time is when the user selects a result, we want to offer them the option to copy the link corresponding to that result.

To do this, we use the same approach and add a ‘Display Link’ button on the form to trigger the interaction. Once our product is selected, the user can activate this button, and the page will reload with the link to the product that the user can copy.

Here too, we can enhance the user experience by automatically triggering this behavior when the product is selected. The user will then see a button allowing them to copy the link to the clipboard.

Without JavaScript, the user utilizes the form buttons to trigger interactive behaviors. With JavaScript, behaviors are automatically triggered by user actions, making the experience more natural.

Note that in our approaches, we add these buttons to the existing form. It's essential to do this so the server retrieves the information, ensuring that user input is preserved on the new page when it's reloaded. With JavaScript, we can partially reload the page and circumvent the problem, but without JavaScript, page reloads are necessary.

We also observe that each behavior has its own button. This approach allows for the reuse and combination of the different behaviors. It may allow the server to adapt if needed, otherwise, the activation of any button can trigger all available interactions.

Using the usual request/response process of the browser also helps better manage errors. In case of a server error or network issue preventing page loading, for example, a clear message will be displayed to the client, where a default JavaScript interaction might simply fail silently.

Had we taken another approach, it might have seemed more natural to combine behaviors simultaneously, send requests to the server, and use a response in a format that could only be processed by the browser with JavaScript. Ultimately, the result would have been less robust, less reliable, and harder to maintain.

In conclusion, this example shows that we can easily use this approach to design complex interactions by adding very little JavaScript code in the browser. However, what we save on the client side, we spend on the server side.

Our form must indeed respond to multiple functional needs:

- Differentiate between different actions (autocomplete, link display, final validation).
- When not definitively validating the form, re-display it while retaining user inputs without actually creating the associated object.
- When a product is selected, the page returned by the server must contain the link to copy and the configuration for activating the clipboard copy JavaScript behavior.

Handling these additional behaviors indeed requires some server adaptations. But this is a manageable drawback:

- The adaptations are actually simple to implement, with simple additions in the view code sufficing to transmit new data for the different interactions.
- Rehydrating the form with parameters received by the server preserves the input.
- It's unnecessary to distinguish individual actions; differentiating final validation from a simple interaction request suffices. This approach generalizes easily, and the amount of code doesn’t increase with the number of interactive behaviors (all handled with a single controller modification).
- Another approach would also require server-side adaptations (e.g., an API to return the list or link to copy). Note that the adaptations required by progressive enhancement are more generic and thus easier to maintain.

This approach isn’t dependent on the type of functionality and can be generalized to any type of interactive behavior. Additionally, the functionalities themselves are generic and can be reused in different contexts, combining to provide an optimal experience tailored to user environment quality.

## Conclusion

Progressive enhancement, while not a new concept, remains relevant. It allows designing all needed functionalities using standard web technologies, progressively complemented with JavaScript to enrich user experience. Even though many services launch without considering degraded conditions users might experience, especially on mobile, progressive enhancement lets you reach a broader audience and offer a satisfactory user experience.

The benefits of this approach are numerous. By reducing the amount of JavaScript used, it leads to lighter, simpler, and easier-to-maintain code. Maintenance becomes easier, as the JavaScript code is also more general and reusable. This method also offers increased robustness, with user interactions being more reliable thanks to the use of standard request/response cycles of the browser, which also provide better default error handling.

Finally, while adopting progressive enhancement requires some server-side adjustments, these are simple and generic, promoting scalability and maintainability of the code. By integrating these principles, developers can design performant and accessible applications.
