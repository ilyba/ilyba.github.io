---
layout: article
title:  "What criteria to measure and ensure the quality of your code?"
date:   2025-03-31 08:00:00 +0100
categories: Bonnes-Pratiques Ruby Rails Architecture Développement
---

# Introduction

Throughout my career, I have noticed a major difference between beginner developers and experienced developers in how they approach writing code and quality. The former focus on a specific goal, while the latter take a more holistic approach, considering a wider range of factors.

In this article, I will explain how to improve the quality of your development through a holistic approach using measurable criteria.

# The Holistic Approach

At the beginning of one’s career, the primary concern is to produce code that achieves the main expected result. This is logical, but in reality, achieving the expected result is not as important as one might think. In fact, it’s actually secondary...

Indeed, it is quite common for the first version of code not to work properly. While the code will ultimately need to be functional before delivery, this is not the most difficult part to fix.

On the other hand, if the initial draft of code has structural issues, uses unclear variable or method names, and doesn’t follow best practices, it is very likely to cause problems later on.

This is why an experienced developer will spend more effort verifying, confirming, and questioning certain details of the specifications, ensuring that their wording corresponds to the most efficient way of meeting the requirement. Then, they will explore different technical approaches, select the most appropriate one, and think about the architecture of the code, the naming of concepts, the different use cases, the side effects of a solution on other parts of the application, as well as error cases, etc. And this list is far from exhaustive…

It is only once the reflection on these aspects is complete that they will focus on the purely functional aspects of the code.

The advantage of this approach is that it results in code that will be easier to maintain over time. This advantage comes with a trade-off: the effort and development time will be higher. This is a short-term disadvantage that will only be compensated for in the long term because considering all these aspects reduces the risk of bugs. Well-structured code with clear and relevant naming makes it easier to read, using an appropriate level of abstraction facilitates modification and adding new features.

In other words, while it is faster to dive straight into the code, this approach costs more later on with bugs, performance problems, and an application that is difficult to evolve.

But what will determine whether code is easy to maintain or not?

# The Specification Phase

Let’s focus again on the specification phase. These documents are sometimes neglected, seen as a time-consuming step in development that adds little value.

However, a well-written specification helps to avoid:

- **Non-compliant delivery.** For example, due to unclear phrasing, the developer may interpret it differently from what the document author intended. Another possibility is that the document is so long and complex that the developer misses some details.
- **Conforming delivery that doesn’t meet real needs.** For instance, a poor choice of interface.
- **Technical design or performance problems.** Even for a functional specification, if future needs are not anticipated, architectural choices may be affected and cause issues later on.

To write a good specification, solid experience is of course useful, but it often proves insufficient. It is essential for the document to be reviewed and discussed with the stakeholders as well as the technical team. If these discussions are properly taken into account, it will have a major impact on the quality of the developments.

In my experience, I’ve always noticed the same trend: initially, specifications are neglected, and after some time spent dealing with bugs, contradictions (when a modification breaks another function or use case), efforts are made to write better-quality specifications (hiring a product owner, adding review processes, etc.). And consistently, substantial improvements are seen, even if this doesn’t solve all the problems.

## Tips for Writing a Specification

Over time, my approach to writing specifications has evolved significantly. There is no one-size-fits-all method. Some will find this method too cumbersome, while others may not find it detailed enough. It all depends on the price you’re willing to pay or the consequences you’re prepared to accept, depending on your perspective. I primarily use two formats: user stories and bug reports. The vast majority of tasks can be written in at least one of these two formats.

## User Story

First, the title should be clear and specify the following elements:

- **The actor:** the primary beneficiary of the development
- **An action:** the main focus of the development.
- **A goal/benefit:** what the completion of the action allows. This could correspond to the benefit the actor gains from the action, for example. Often overlooked, this is essential to confirm the usefulness of a development. If the goal is hard to formulate, it may be because the feature lacks value.

Here is the model I use: As a **<actor>**, I want to **<action>** in order to **<goal>**.

Example: As a **customer**, I want to **view the list of my orders** in order to **know my purchase history and reduce pressure on customer support**.

Next, I divide the writing into three sections:

- **A context:** A few sentences that clarify the purpose of the specification. To write this, you can describe the current situation and the problem to be solved.
For example: Customer support receives numerous requests from customers who want to know their order history, but this feature does not exist in our application.
- **A description:** This is the heart of the description where we will describe as precisely as possible the expected result. Depending on the project and the developers' experience, this section may also contain some implementation details if we want to lock them in, but personally, I prefer to leave as much autonomy as possible to developers on technical details.
- **Acceptance criteria:** This section is essential. Sometimes it is a rewording of the description. It allows the developer to confirm the correct understanding of the specification and provides a list of criteria to avoid rejections from the quality team during delivery. It also gives the quality team a solid base to validate or reject a feature.

For all tasks, in addition to these sections, I assign a priority level.

## Bug Report

A good bug report helps avoid misunderstandings that delay problem resolution.

The title should be a succinct and precise description of the problem.

For example: On the main page, pressing the Enter key does not trigger the search.

When writing, it may be tempting, in the heat of frustration, to use the term 'Regression.' However, I highly recommend avoiding this unless you can document this fact precisely in the report (with identical tests on two different versions of the application, for example). Often, this term proves inaccurate or needs qualification, while sending a negative message to the development team: "You’ve broken something again." This unnecessarily degrades the working environment.

My advice: Even in the case of confirmed regression, avoid putting this term in the title and instead add the details in the body of the text. You can, however, assign different priority levels to your tickets.

The body of the report consists of three parts:

- **Reproduction steps.** A precise step-by-step list to reproduce the issue.
- **Expected result.**
- **Observed result.**

# The Development Phase

During the development phase, here are some tips for improving the quality of your output:

- As mentioned earlier, take a holistic approach. Try to think about all aspects of the functionality and not just the objective. Consider the impacts on other features, future changes, readability, maintainability, etc.
- Take the time to think about the structure of your code. Ask yourself whether you need to simplify or, on the contrary, add more levels of abstraction.
- Apply best practices whenever possible, including the KISS (*Keep It Simple and Stupid*), YAGNI (*You Are Not Gonna Need It*), SRP (*Single Responsibility Principle*), DRY (*Don’t Repeat Yourself*), don’t reinvent the wheel ([unless you want to learn more about wheels](https://blog.codinghorror.com/dont-reinvent-the-wheel-unless-you-plan-on-learning-more-about-wheels/), or unless the wheels are poorly suited), etc.
- Consider performance and optimisation aspects. Are the SQL queries performant? Are there any algorithmic problems?
- Also consider documentation. It’s not always necessary, but when it is, it should be written. And when it exists, it must be kept up to date.
- Use a linter to standardise your codebase and avoid structural issues (e.g., overly complex code, not following best practices, etc.). Personally, I use Rubocop with all default rules and erb-lint with most optional rules enabled.
- Add automated tests, and for bug fixes, write regression tests.

# Indicators to Measure the Quality of Developments

You now know my tips for improving your specifications and developments. But what worked for me might not work for you. Fortunately, it’s not necessary to apply all of this blindly. Let’s now look at the criteria to use to measure the evolution of quality in your environment.

Implementing these tips may require some effort. It will be difficult to distinguish between improvements due to changes in your processes and those due to other factors (the increasing competence of your team, changes in other processes, etc.). Tracking a few indicators won’t be enough to precisely identify the most effective measures, but it will help you assess your progress and adjust your decisions accordingly.

Here are some indicators whose evolution you can track to determine the quality of your developments:

- The number of errors in your application
- The number of tasks delivered per unit of time (never use Scrum points directly for this, the number of tasks is a more reliable criterion with no undesirable side effects).
- The distribution of Scrum points (the proportion of tasks with a given number of points compared to others). This indicator helps shed light on the previous one (if the number of tasks delivered increases but your team is tending to break down topics more finely, it doesn’t necessarily indicate an increase in productivity).
- The number of code reviews during the review phase.
- The number of code reviews during the QA phase.
- The number of outdated dependencies.
- The total number of dependencies in the application.
- The number of bug tickets created per unit of time.
- The number of urgent tickets created per unit of time.
- The number of technical tasks with no business value (code refactoring, etc.) per unit of time. This does not include routine maintenance tasks like dependency updates.
- The proportion of these tickets compared to the overall load, particularly compared to business-required tickets.
- The number of tickets (and/or Scrum points) in the specification phase.
- The number of tickets (and/or Scrum points) awaiting development.
- The number of tickets (and/or Scrum points) in development.
- The test coverage of the codebase.
- The ratio of test code to application code.

Personally, I don’t track these indicators in an automated way at the moment, but I have a subjective view of them and consider them when making decisions. I also use them to justify certain choices.

These indicators don’t directly tell you whether your code is of good quality or not, but by tracking their evolution, it’s easy to see if the quality is improving or deteriorating.

# Conclusion

Good development quality is not simply about producing functional code. It relies on a holistic approach, taking into account the clarity of specifications, code structure, maintainability, and anticipation of future changes. While this approach requires more initial investment, it helps reduce errors, improves long-term productivity, and facilitates collaboration within teams.

By combining rigorous specification writing, thoughtful development, and monitoring relevant indicators, you will be able to gradually improve the quality of your projects. The goal is not to achieve absolute perfection (which is illusory), but to adopt an iterative and measurable approach that allows for continuous adjustments. Ultimately, good quality code benefits not only developers but also users and the entire business.
