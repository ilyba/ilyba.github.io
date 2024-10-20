---
layout: article
title:  "Asynchronous Exports in ActiveAdmin"
date:   2024-04-25 21:37:00 +0200
categories: Rails ActiveAdmin
---

# Introduction

Data export is a feature present in most enterprise applications. ActiveAdmin offers an export feature by default, which functions synchronously, meaning the generation of data occurs at the client's request.

# The Problem with Synchronous Exports

However, when the volume of data to be exported is significant, the process can take time. The server, being occupied, is not available to handle requests that pile up, leading to a bottleneck. Performance degrades, and users notice that the application is slow.

If the situation worsens, the backlog becomes too substantial, and the server is no longer able to process requests promptly. The application then starts returning errors. If the situation continues to deteriorate, the application ceases to function entirely and becomes inaccessible.

# Implementing an Asynchronous Solution

Faced with this type of problem, we used the gem [`activeadmin-async_exporter`](https://github.com/rootstrap/activeadmin-async_exporter) to address it. This library allows for asynchronous data exports in ActiveAdmin with ActiveJob. However, we had to make adaptations to use this solution.

Firstly, the gem `activeadmin-async_exporter` is no longer maintained by its author and was not compatible with our version of Rails. Therefore, we had to modify it and update its dependencies.

We made some additional adaptations to handle parameters with strong_parameters and resolve a missing method issue due to our application's use of `current_user` while the gem author uses `current_admin_user`.

Unlike our application, the gem does not use ActiveStorage for attachments. We also adapted this part accordingly.

To record the request, the gem provides a generator for the migration to create the necessary tables in the database. The gem also provides an ActiveAdmin generator for the interface to manage exports. However, these generators are undocumented.

We eventually incorporated the code of the gem directly into our application and customised it according to our needs.

# Publishing in a Gem

We decided not to publish our modifications as a new gem since the code is integrated into our application, and it would require a new effort for adaptation. Furthermore, given the little activity on this library, I am not convinced this solution necessarily meets a community need, though it proved very useful in improving our application's performance.

Nevertheless, if you are interested in these modifications, have questions or comments, do not hesitate to contact me for further information.

# Conclusion

This anecdote illustrates, through a concrete example, the type of problem that can arise during the evolution of an application. The solution based on the use and adaptation of an unpopular and unmaintained gem may seem atypical, but this approach actually follows a very classic process of resolving a technical issue.
