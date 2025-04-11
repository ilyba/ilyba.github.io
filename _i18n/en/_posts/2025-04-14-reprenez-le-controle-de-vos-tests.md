---
layout: article
title:  "Take Back Control of Your Application’s Tests"
date:   2025-04-14 08:00:00 +0200
categories: Bonnes-Pratiques Ruby Rails Architecture Développement Tests
---

# Introduction

Discover how to turn an unstable and poorly tested application into a robust product through effective testing practices.

When you join a young start-up project, you’re often faced with gaps in some best practices. And it’s not always obvious where to start.

In this article, after a quick overview of the context, I’ll introduce you to an effective approach in four simple steps to quickly improve your test suite without compromising productivity: stabilisation, implementing good practices, cleaning up existing tests, and optimisation.

# At the start: few tests and lots of bugs…

The history of a web application is always complex. The codebase evolves with its developers and goes through different phases that are unique to the history of each project. Depending on whether the project starts with a large team of experienced engineers and a sizeable budget or, conversely, with a small team of recently graduated developers, the challenges are not the same.

The project I’m talking about here started with developers of intermediate experience, an ambitious project, and a tight budget. The strategy used was to favour rapid development while still putting some effort into testing and best practices, albeit limited by constraints.

The application was so insufficiently tested that it affected its stability.

# Phase 1: Act quickly to improve stability

Large critical parts of the code were poorly covered. To fix this issue, we used Rails system tests. The principle of such a test is to automatically control a browser. In short, the test code tells the browser which page to navigate to and which actions to perform (clicking links, filling in forms) then checks the resulting outcome. Compared to other types of tests, these are slower but in return allow for testing the site’s interactivity.

In our case, one of our tests involved filling in a sequence of multiple forms to test a complete use case. This approach had the advantage of quickly adding tests that covered a large part of the project.

The approach was fairly suited to the situation, but still had some drawbacks:

These tests age poorly: as the application evolves and becomes more complex, the tests also become more complex and more fragile. For example, we added a component for auto-completing addresses, and we were entering many addresses in our forms. This component is complex and its repeated use makes the test long and more likely to fail randomly. Eventually, the test ends up constantly needing adjustments and fixes.

And although this type of test was developed to correct an initially problematic situation, some developers used it as a model for new features.

While this approach was suitable at first to quickly resolve a problematic situation, anticipating the evolution of the code is essential.

# Phase 2: Establish sustainable best practices

For a while, the situation is acceptable — even if the tests are slower than they should be and some parts of the code aren’t properly tested — the application’s stability is fine and team productivity is good.

But after some time, we saw the failure rate due to flaky tests increase, and at the same time, test durations increased significantly, which started to affect productivity.

We therefore decided to be more demanding with our tests and apply the following principles:

- We wanted to increase test coverage without swinging to the other extreme. Developers are encouraged to be vigilant and write more tests. This allows us to be more confident when modifying existing code. At first, this may seem a bit excessive, but as the project becomes more complex, having good functional coverage is essential to avoid regressions.
- We also asked developers to favour other types of tests over system tests. This improves performance more easily. For example, a test that submits a form and observes the result can be replaced by a controller test. In execution, this is much faster than a system test.
- The use of `sleep` in tests is strictly forbidden, and an action plan was set up to remove sleep from all legacy tests or delete the tests in question.
- We reserved the use of these tests for components using JavaScript. At the same time, we limited the use of JavaScript in the application as much as possible.

Implementing these few rules quickly helped us gain stability. However, this doesn’t solve the problems with existing tests. And for the future, we ensure that the number and duration of tests don’t increase too quickly over time.

# Phase 3: Cleaning up existing tests

Once best practices are in place, it’s time to deal with the legacy.

Rather than keeping costly and fragile tests, it’s often better to replace them with more focused unit or integration tests.

Thanks to the best practices, the majority of system tests originally added to compensate for gaps are now covered by more targeted and stable tests. The remaining ones often cover very stable features that shouldn’t change. In both cases, we can simply delete the original tests.

We finished our clean-up by identifying the longest tests and redundant tests.

To find long tests, we used the following command:

```ruby
rails test -v | sort -t = -k 2 -g
```

This command runs Rails tests in verbose mode, sorts the results by execution time, and displays the longest tests first.

To identify redundant tests, there’s no simple command, but we can detect them as we go along in development. If one change causes multiple tests to fail, there’s a strong suspicion of unnecessary redundancy.

As a result, by applying a few simple principles, we saved nearly 30% of test suite execution time, going from just under 20 minutes to under 15 minutes.

# Phase 4: A pragmatic approach to improving performance

We could have spent more time optimising, but it’s a long-term job that requires a full, detailed audit of all our tests. When tests can be deleted or quickly modified, that’s great. But sometimes, it takes a much more expensive effort.

In this case, it’s better to stick with applying the best practices mentioned earlier, and for the rest, we adopted pragmatic strategies to optimise performance:

- We switched providers for one that was faster, more flexible, and not particularly more expensive.
- We also took the opportunity to distribute the work across several machines running tasks in parallel.

Result: we went from just under 15 minutes to 6 minutes.

It’s a good result, but if not combined with good practices during test writing, the number of tests will increase, pushing us to increase the number of machines running tests in parallel and driving up costs.

# Conclusion: a well-maintained test suite

This progressive approach allowed us to reach a more than satisfactory state despite starting from a problematic situation. By starting with the most critical urgencies, then establishing sustainable rules before correcting problematic legacy and ending with a targeted clean-up, we maximised the impact of our actions without wasting time on an overly systematic approach.

This pragmatic and iterative method is especially suited to large-scale refactoring projects where it’s beneficial to start with a broad approach to quickly handle the bulk before refining the details. It’s a simple and effective approach that can be applied to many other areas of software development, whenever it’s time to take back control of a slightly neglected codebase.

In the end, the key remains the same: progress step by step, with quick wins at the start and continuous improvement over the long term. This method allows you to gradually take back control of a complex codebase while maintaining the team’s stability and productivity.
