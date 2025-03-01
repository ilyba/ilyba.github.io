---
layout: article
title:  "ActiveRecord vs Repository: Understanding Their Differences"
date:   2025-03-02 08:00:00 +0100
categories: Ruby Rails Architecture
---

# Introduction

I am going to talk about a well-known case study. All Rails developers are confronted sooner or later with the need to send an email after performing an operation in the database. Typically, sending a welcome email to a user after they have registered for the service. However, this simple task can quickly become complicated, especially when it involves ActiveRecord callbacks, database transactions, and queues…

This sets the stage to illustrate the confusion that can arise in Ruby on Rails between the ActiveRecord and Repository patterns.

# Scenario

The situation is quite ordinary: a user registration corresponds to the creation of a row in the `users` table in the database. If we use ActiveRecord terminology, we would simply say that we are going to create a new user.

And this is perfect, our developer might not have much experience, but they have studied well and know that in ActiveRecord we have a callback called `after_create`, and we want to send an email right after the user is created.

Our junior developer has also learned that emails must be sent using a queue, and so they use Sidekiq, Good Job, or Solid Queue.

In no time, within 5 minutes, our dev sets up the email to be sent after creation... It seems to work, but there’s a catch… It doesn’t work every time; it’s very unstable: sometimes the email is sent, sometimes it’s not.

# Problem Analysis

To understand what is going wrong, our junior needs to grasp how transactions intervene here.

Rails uses transactions for database operations (a `save`). This means that if an error occurs during the creation of a user, the entire transaction (insertion into the `users` table and other associated actions) is cancelled, and nothing is modified in the database. If everything goes smoothly, Rails commits the transaction, and all the tables are updated at the same time.

And here is where the problem arises. Our app uses the `after_create` callback to add the email to the queue, and this callback is triggered before the transaction has finished. When the email is queued, the transaction is not yet complete. When the email job is triggered, the transaction is not necessarily committed, and the user is not yet fully created in the database. This causes an error when trying to retrieve the user, as they are not yet visible in the database during the execution of the job.

# The Bad Advice from the Senior

Obviously, our junior, not understanding what is going wrong, goes to see a senior who tells them: "You poor thing, you’ve used callbacks, that’s evil, be damned for eternity!"

Our junior is even more confused – why are there callbacks in Rails if we’re not allowed to use them?

"But you’ve misunderstood the separation of concerns. ActiveRecord is for the database, you can’t use it to send emails, for that you need to use a service. And don’t call your service with ActiveRecord, use your controller. But since that will dirty your controller, use dry-transaction[^1]."

And so our junior developer ends up spending a week just to send an email.

Our senior didn’t mean any harm, but this doesn’t solve the real problem and unnecessarily complicates the situation.

# Let’s Distribute the Bad Points

In this case, our senior developer is wrong. They’re not wrong to praise the merits of the dry ecosystem, the separation of concerns, or separating database code from code related to external services, but they are absolutely wrong to impose this on our junior.

The senior’s mistake lies in a confusion: the junior’s problem is not related to using callbacks. In fact, the callback would never have been a problem if the email was not being sent in a job. The job is not the problem either; everything would work fine if the job was triggered after the transaction.

This is exactly what our junior should do here: replace the `after_create` with `after_create_commit`. In this case, the email will be sent after the transaction has finished, which will solve the problem. Our junior will then have the opportunity to deepen their understanding of how callbacks work internally, their order, and their interactions with database transactions.

In this case, and this is the advice the senior should have given first, even if they wanted to digress and later discuss architectural points, rather than using an argument that is at best incorrect, and at worst fallacious, to impose their own way of working and seek reassurance for their own software architecture decisions. By doing so, they are not helping our junior, and instead of solving their problem, they are bypassing it.

However, the senior’s solution also works, although it is more costly to implement.

# ActiveRecord is Not the Repository Pattern

Another confusion made by our senior is that ActiveRecord is not the repository pattern.

If we go back to the definition of ActiveRecord, the ActiveRecord class is designed to encapsulate both data and business logic. Now, sending emails is very much part of business logic, and in this pattern, it is perfectly legitimate for it to be triggered by ActiveRecord.

In the Repository pattern, this is not the case; the responsibility of a Repository class is solely to communicate with the database and therefore should contain no business logic. In Rails, it is possible to use ActiveRecord with the Repository pattern, but this would require doing away with many of ActiveRecord’s features (and this likely includes callbacks).

But it’s an architectural choice. There’s not just one way to do things. Each choice has its consequences, advantages, and disadvantages. And, of course, it’s also a matter of personal preference.

For me, the main advantage of ActiveRecord is code readability, the magical aspect that is actually just complexity hidden away (to ask a dog to bark, we write `dog.bark!`, not `DogBarker.new(AnimalFactory.create(:dog, DogAttributeValidator.validate(dog_attributes)).call`, for example, even if the action involves calling an external service or whatever, the implementation details are hidden).

But there’s a price to pay for this advantage. And those who are not willing to pay that price can absolutely choose another architecture. But they should not feel compelled to impose their decision on everyone else to reassure themselves about their own architectural decisions.

Let’s leave our junior to make their own architectural choices, weighing up the pros and cons.

# Conclusion

Every architectural choice has its own flaws. ActiveRecord has its own, but callbacks are a powerful tool, and I find it a shame to discourage junior devs from using them rather than encouraging them to understand how they work and use them correctly in order to master them.

In our debates, let’s use arguments, remain factual, pragmatic, open, and polite. And let’s not use straw man arguments, as I have done here…

[^1]: The dry-transaction tool is an approach that allows encapsulating business steps into distinct objects, which helps better structure the code by separating responsibilities. However, for the sake of consistency, its use will require converting the entire application’s code to this approach, as well as training the development team.
