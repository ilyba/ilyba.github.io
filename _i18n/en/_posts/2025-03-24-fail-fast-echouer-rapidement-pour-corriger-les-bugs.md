---
layout: article
title:  "Fail Fast: fail quickly to fix bugs in production"
date:   2025-03-24 08:00:00 +0100
categories: Bonnes-Pratiques Ruby Rails Architecture
---

# Introduction

The 'fail fast' strategy involves detecting errors as early as possible in the development or execution cycle of an application, so that they can be fixed immediately and prevent more serious issues later on. This helps to improve the stability and maintainability of the code.

In a web application, the perceived quality of service by the user depends on your ability to detect errors and handle them quickly.

In this article, we will see how monitoring tools help identify and fix the majority of errors quickly. We will then discuss strategies for handling more complex errors.

# Monitoring Tools

In a Rails application, errors are logged, and if no one checks them, they will go unnoticed unless a user reports them.

This is why it is recommended to use dedicated monitoring tools such as Rollbar, AppSignal, or Sentry. These tools allow you to efficiently manage errors through a user-friendly interface. Installing such a tool should be a priority in a new application.

Thus, errors are grouped, counted, and sorted to help you focus on the most important ones. You are notified immediately when they occur, enabling quick responses and minimising inconvenience for users.

# Prioritising Fixes

If you have installed your monitoring tool from the start of the project, the number of errors to handle should be low enough to allow you to fix them as they arise.

The strategy is simple: when an error occurs, you receive a notification. If the volume is low, it is best to pause your current work to check and fix the error immediately.

When the volume is higher, prioritisation becomes necessary. Here are some questions to consider:

## Should I interrupt my work to address errors?

If there are too many errors, frequent interruptions may delay other fixes or prevent progress on new features. In such cases, it is more effective to schedule regular error reviews and integrate their resolution into your usual workflow, minimising disruption.

For example, you could set aside time each day to list new errors, log them in your planning tool, and adjust their ranking within your workflow based on priority.

## How urgent is the error?

Consider the impact of the error on your revenue, reputation, or user experience. Are there any available workarounds? This information will help you determine the priority of fixes within your task list.

## Are you spending enough time fixing errors?

Use numerical indicators to track error trends. Are errors increasing or decreasing? By analysing this trend, you can adjust the time allocated to fixing them.

# Solving Complex Errors with the Fail Fast Strategy

For most errors, the fix is straightforward. It is often an oversight during development, and monitoring tool information is enough to correct them quickly.

However, some errors are harder to interpret. For example, when a variable or object attribute is `nil` when the code expects a value.

This can happen even when validation is present in the application, for several reasons. For example:

- Data was added or modified without validation (intentionally or not).
- The validation was added after non-compliant data already existed.

This results in invalid data causing bugs in different parts of the application, sometimes making diagnosis difficult.

For example, if a user is deleted in an application without a database constraint, their orders may become orphaned. If elsewhere in the code, an attempt is made to find the user associated with an order, the classic error ```undefined method `name' for nil``` will occur. To avoid this, a foreign key constraint ensures that a user cannot be deleted if they have associated orders. This prevents inconsistencies and makes the error explicit as soon as it occurs.

In such a case, after correcting the incorrect data in the database, I recommend adding a database constraint to prevent such data from appearing in the future.

For example, you can use:

- An integrity constraint (`NOT NULL`, `FOREIGN KEY`, `UNIQUE`).
- A trigger (an action triggered by the database under certain conditions).

This way, when the problem recurs, the monitoring tool will directly highlight the responsible code.

Adding such constraints, however, may raise legitimate concerns. Here’s how to address them.

# In a Constrained Environment

When I propose these types of solutions, I often face resistance, and for good reasons:

- The constraint may prevent a process from functioning normally and result in the loss of submitted data.
- Instead of fixing the problem, additional errors may be introduced.

These concerns are valid, but the alternative is worse: accepting errors. Over time, incorrect data will accumulate, making the application unstable.

Moreover, the situation is temporary. Yes, a user may encounter an error, but this allows for a permanent fix to be implemented quickly. With validated data, the guarantee is that the error will never occur again in your application.

If the process is critical, you can remove the constraint as soon as the problem is reproduced to minimise impact. In some cases, even this is unacceptable. If you encounter such a situation, you can accept the process and log an error instead, but this approach is more complex when the source of the error is the database. You can modify your trigger to log data into a table; with PostgreSQL, you can also use a rule (`CREATE RULE`) with `NOTIFY`. You can then add a process to send errors to the monitoring tool.

# Benefits of This Strategy

This approach clearly demonstrates the benefits of the "fail fast" strategy: making the system fail as soon as an abnormal condition is detected.

Here, we illustrated this with database constraints, but the strategy can also be applied in other contexts, such as checking method preconditions at the start of execution.

By failing quickly, invalid data is prevented from propagating within the code, avoiding unnecessary defensive logic and simplifying maintenance. Adding defensive code is a poor strategy because it is generally impossible to comprehensively identify all areas requiring validation, let alone prevent future modifications from neglecting checks.

# Conclusion

Fewer bugs mean less time wasted fixing them, freeing up time to improve and evolve the application. This approach creates a virtuous cycle where maintenance becomes more efficient, and new features are easier to implement.

Although counterintuitive, the fail fast strategy is a best practice that reduces bugs and simplifies application maintenance.

Fewer errors mean less time wasted correcting them, thereby freeing up resources to enhance and evolve the product. By adopting this mindset, we create a virtuous cycle: maintenance becomes more efficient, the code more robust, and new features easier to implement.

