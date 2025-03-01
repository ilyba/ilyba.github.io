---
layout: article
title:  "Improving the Code Quality of Your Web Applications"
date:   2025-03-10 08:00:00 +0100
categories: Ruby Rails Architecture
---

# Introduction

Throughout my career as a web developer, I have had the opportunity to work on many different web applications. I have been able to observe how the organisation of a team affects the quality of the code produced and how this in turn influences the stability of an application.

# The Importance of the Human Factor

The problems encountered by a team made up almost exclusively of experienced developers will not be the same as those faced by a team of junior developers.

Beginners tend to produce unstructured code that overlooks best practices. Due to a lack of knowledge of the most suitable tools, they often use less appropriate ones. And because of their lack of experience, they tend to favour incomplete solutions.

With experience, developers begin to gain confidence and sometimes develop unnecessarily complex solutions, for example, by using too many layers of abstraction or by using design patterns that are not appropriate.

Ultimately, the most experienced developers may sometimes create organisational problems. Thanks to their accumulated experience, they have high-level skills to solve various problems. However, this can sometimes lead to conflicts when choosing a technical solution.

All of these issues can affect the quality of an application’s code.

# The Structure of the Code Affects the Quality of an Application

In an application, the concept of “code structure” is actually quite vague and can represent several concepts. Here are a few examples:

- The organisation of files (their names and their location in the file system)
- The way the code is organised within a file (the order of code objects, their length)
- The way in which code objects interact or are encapsulated...

This list is not exhaustive. In this article, I will focus on file organisation, but the issues and consequences are similar for other aspects of code organisation. In fact, each of these aspects impacts the quality of an application's structure.

## File Organisation

Files represent the code, and in Ruby, they will most often contain modules or classes. The use of frameworks such as Rails helps to simplify this aspect because a basic file hierarchy is provided, with a `config` folder for configuration, `models`, `views`, and `controllers` folders for MVC logic, and so on.

For a simple application, this hierarchy is more than sufficient to organise the files. However, as the complexity of an application increases, we end up with more files, and they become larger and larger.

Rails introduces the concept of "concerns" (modules representing an aspect of an object) to extract functionalities into modules, which are then composed together to form a larger entity. Simply put, we break up the code of a file into several files.

This is often where problems begin. Because it’s necessary to decide how to split the code: which methods, macros go into which files, following which logic. It’s also important to decide on the names of the new files. One must also ask whether, instead of accumulating different `concerns` modules, it would be more relevant to change the architecture of the code by introducing a new concept, or a new class.

And for these questions, there is no single, ideal answer. Every choice will have its advantages and disadvantages. Some choices will have significant consequences and should be studied carefully, while others will be of little importance and an arbitrary decision will be quite satisfactory. But it is not always easy to anticipate the future to know which decisions will be important.

Let’s analyse a few structural issues and their consequences.

## Some Structural Problems

The most obvious problem is the use of poorly suited names for files, classes, and modules.

Failure to follow naming conventions (using conventions different from those of the project or those prevalent in the community). For example, in Ruby, the names of classes and modules use CamelCase. Following this convention, shared by the Ruby community, greatly facilitates reading, writing, and navigating the code. Failure to follow this convention does not have severe consequences, but it will make working with the codebase more tedious. And one must consider that code quality is never ideal in an application containing thousands of lines of code. This is a problem that will automatically add to other issues, even though it is very easy to avoid.

Sometimes, the choice of a file, object, method, or variable name is made too quickly. This is quite a common problem, as during development, we spend much of our time creating and thus naming objects. It can be tempting to quickly name an object and move on to the next part of the thought process. But a poor name choice can have serious repercussions. It will make the code harder to read and understand. Misunderstanding a name can quickly lead to significant bugs in the application. For example, an object that does not behave as its name suggests may be misused, and the bug may not always be easy to spot.

When splitting an object into several parts, the problems can quickly compound:

For ease or negligence, one might use a technical concept when a business concept would be more appropriate. For example, you might put association definitions in one file and validations in another. You might extract all callbacks, filters, and so on. Generally, it’s more pertinent to identify aspects and group everything related to a given aspect into a file (one module for billing, another for process management, one for addresses, one for customer data, etc.). This type of issue will make reading difficult but will also complicate code changes, as they will then span multiple files.

One can also unnecessarily introduce abstractions and intermediate objects. This will cause indirections, and in order to follow the flow of the code, one will have to navigate several files, possibly getting lost. Reading will become more complex, and in some cases, modifying the corresponding code will also become more difficult.

Structural problems can sometimes be deeper. One might use complex technical logic that complicates the use of the code. For example, using a `services` or `operations` folder in addition to the `models` folder and placing business logic in both folders. Creating such folders is not a problem in itself, but the rest of the codebase must remain consistent. Otherwise, once again, the code will be harder to read and modify. When bad practices are deeply ingrained in the code, bringing it into order can be extremely time-consuming and difficult.

Similarly, placing business logic in helpers, views, or controllers presents the same issues. Grouping all the business logic of a concept in one place is essential for ensuring an application is easy to maintain.

# The Importance of Following Best Practices

We have seen how structural issues can impact code quality and lead to bugs. Following best practices on a daily basis is also important.

## The Use and Respect of the Linter

Most best practices can easily be respected by using a linter (a code analysis tool).

For Ruby, RuboCop is recommended. Personally, I enable all policies and use the default settings as much as possible.

At first, it may seem tedious and pointless to follow certain constraints (methods limited to 10 lines, line length limitations, maximum number of lines in a module, etc.). As a result, developers are often tempted to justify not following the rule in their case. Among the most common excuses:

- The code is still sufficiently readable
- It doesn’t bother anyone
- There are no bugs in this case
- There is no security problem in this case
- Not following the rule offers a significant advantage here
- etc.

In my opinion, it is often more important that the rule be applied consistently. Indeed, even if not following the rule is not an issue, it is often still possible to respect it. Most of the time, the code is better after modification. In some cases, it may indeed be less good. Even in these cases, most of the time, the code is slightly worse (perhaps a little less readable, for example), but this is offset by several advantages:

- An exception to the rule might encourage other developers to ignore it (or even to ignore the linter rules altogether). This will result in less homogeneous code, and at worst, will cause bugs, readability issues, etc. Avoiding this is a definite advantage.
- The code will be generally more homogeneous and therefore more comfortable to read, even if this is sometimes at the cost of code that is occasionally slightly less readable.

For these reasons, using a linter and adhering to it greatly contributes to code quality.

Naturally, in certain cases, one might prefer to modify the linter settings, either for personal preference or because a specific rule does not provide sufficient benefit given the constraint.

## Other Best Practices

Other best practices are important to follow. An experienced developer will know and master more of them than a beginner.

This is why having code reviewed by a more experienced developer is important to ensure good code quality.

The most important best practices for me are:

- SRP - Single Responsibility Principle: Each code object should focus on only one aspect at a time.
- KISS - Keep It Simple and Stupid: Keep the code simple and stupid. In other words, a simple and direct solution is preferable to a complex one.
- YAGNI - You Aren't Gonna Need It: You won’t need it. This is the counterpart to KISS; if a feature or an abstraction, such as handling an error that is unlikely to happen, is not needed right now, there is no point in developing it until it is actually needed.

These best practices sometimes contradict one another, and in those cases, it’s necessary to choose which one to prioritise.

Adhering to best practices has a huge impact on code quality:

- Here too, code reading will be easier.
- The amount of code produced will also be kept as minimal as possible, which brings productivity benefits.
- Code evolution is facilitated because the code will have the right level of complexity.
- Maintenance becomes easier due to the simplicity and density of the code and the limitation of branching.
- For the same reasons, this will limit the number of bugs.

# Choosing the Right Tools

A good choice of tools is also important for code quality. The choice should always be made according to the specific context of your application. A good tool for one application may not be suitable for another.

Here are some important criteria for choosing a tool:

- The organisation and overall level of the team: A tool might be well-suited to a particular organisation and effective with developers of a certain level of experience. However, it could be counterproductive in another organisation. For example, for simple needs with a less experienced team, it is better to choose simple tools, even if they are less performant, rather than complex tools with unintuitive use.
- Maintenance and popularity: it is often better to choose a well-maintained and popular tool rather than a perfectly suited one that is obscure and poorly maintained. Of course, it’s entirely feasible to choose a very suitable but unpopular tool, provided one is willing to modify it themselves to adapt it or fix problems.
- The licence: This is often overlooked, but checking the licences of tools used is an important criterion to avoid legal issues, especially if your application becomes popular.

# Avoid Taking Too Many Shortcuts

A common mistake in developing complex features is applying the KISS principle too broadly.

It’s obviously essential to keep code simple, but it’s equally important to anticipate how a feature will be used.

In practice, developers have to implement a feature based on a specification document.

In the companies I’ve worked for, we use “agile” methods. In practice, this means that we want to reduce as much as possible the time between specifying an idea and delivering it, even if this means revisiting it regularly if the actual need doesn’t exactly match the expressed need.

The consequence is that despite the care taken in writing specifications, there are often many gaps. Personally, I often choose to focus specification effort on the main need. This often comes at the expense of detailed technical specifications or secondary use cases. These aspects are then left to the responsibility of the rest of the development chain, i.e., the developer implementing the feature, the developer assigned to review it, and the quality assurance team.

A developer can easily neglect handling error cases, for example, or fail to anticipate alternative use cases, delivering a feature that doesn't fully address the needs.

Of course, it would be possible to limit these drawbacks with more detailed technical specifications, but this would significantly increase the time required to analyse the code, the needs, usage, and writing. The time spent on documentation would increase, and the ability to express needs in specifications would decrease, thus reducing development capacity. And it wouldn’t necessarily guarantee all aspects are taken into account.

To avoid this, it’s crucial that developers understand the context in which a feature will be used. Thanks to their precise knowledge of the application's functioning, they are able to clarify the technical needs. For example, they can easily see if a branch is missing in the code and question whether it should be created, or realise that an error case is not handled in the specification.

By avoiding applying specifications literally and being willing to challenge them, it is possible to prevent bugs and thus contribute to improving the application's quality. Moreover, this helps avoid back-and-forth, development stages, and ultimately improves team productivity.

# Over-Engineered Code

This is the counterpart to the previous case. When developing a complex feature, a developer might over-anticipate certain aspects and introduce unnecessary abstractions. These abstractions make the code harder to read and maintain.

Such code is often difficult to detect upon review.

However, there are still a few approaches that can help. Here’s one:

During a review, it is easy to identify code that follows an atypical approach. If this approach is also complex, it is essential to challenge it.

To do this, one might start from a blank page and imagine the architecture that would have been used to develop the feature.

It is likely that the imagined solution will be simplistic since the reviewer won't have all the details in mind. The architecture should then be compared with the one chosen. If the architectural choice is significantly simpler than the reviewed code, a discussion with the developer will easily determine whether the additional complexity is necessary.

The impacts of this type of problem are very important for the maintenance and evolution of an application. It is often very difficult to go back even a few months later. It is therefore extremely important to detect and eliminate them upfront to avoid having to maintain them later.

# Conflicts Between Developers

With experience, developers develop habits. However, in development, several solutions are often equivalent.

It is then common for experienced developers to want to implement a solution that has worked for them.

In some cases, this means questioning choices that were made before the developer's arrival. Sometimes, it concerns new features.

Most of the time, this leads to debates among developers that take time and can sometimes affect the team’s atmosphere.

It is important not to neglect these debates, as even if the technical choices are not necessarily very important, the human impact can be considerable.

It is important for developers to understand that a technical choice that seems inferior to them is not necessarily a problem and will not have a significant impact.

On the other hand, these alternative solutions can sometimes offer real benefits, and this potential benefit should not be overlooked. It should, of course, be considered in light of the effort required to implement it. A significantly superior solution must unfortunately be dismissed in favour of the existing solution, even if it is inferior, when the effort to implement it is greater than the expected benefit.

However, the choice can be revisited when the functionality is eventually rewritten or when the application or the team evolves.

Generally, this type of conflict doesn’t directly affect code quality. But if the conflict is not addressed, one could end up with several competing solutions in the application. This obviously creates maintenance issues.

# Conclusion

In short, code quality and application stability are issues that are directly influenced by the organisation of the team, adherence to best practices, and management of technical choices. Structural problems, whether concerning file organisation or architectural decisions, can have significant repercussions on readability, maintainability, and ultimately the quality of the application. Consistent adherence to best practices, use of appropriate tools, and a culture of constructive debate will help ensure the long-term success of your web application.
