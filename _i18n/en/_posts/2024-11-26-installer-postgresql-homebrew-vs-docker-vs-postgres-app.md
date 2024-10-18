---
layout: article
title:  "Install PostgreSQL: Homebrew vs. Docker vs. Postgres.app"
date:   2024-11-26 08:00:00 +0200
categories: PostgreSQL Homebrew Docker
---

# Introduction

The installation of PostgreSQL can be carried out in several ways. In this article, we will explore the advantages and disadvantages of different installation methods to determine which one will best meet your specific needs.

Understanding the distinctions between installations intended for a production environment and those designed for development is crucial, as each context has its own challenges and priorities.

We will start with general considerations on production environments, before delving more deeply into the different installation alternatives in the context of a development environment.

# Installing PostgreSQL in Production

Choosing the right way to install PostgreSQL in a production environment is essential to ensure the performance, security, and robustness of your application. Although this overview does not cover all possibilities, it aims to clarify your choices and guide you toward the most suitable option for your specific needs. I will particularly explain the differences between using managed databases and installing on your own dedicated servers.

## Using a Managed Database Service

For many projects, especially those that are just starting, opting for a managed database instance is often the most obvious choice. Here are the major advantages of this approach:

- **Ease of Deployment:** Easy to set up, often with one click, secure and optimized by default. No need for manual or technical installation procedures.
- **Immediate Availability:** The database is usually available after a few tens of seconds.
- **Facilitated Maintenance:** Updates and maintenance are managed by the provider.
- **Simplified Integration:** The connection URL can be simply added to your application.
- **Automated Backups:** This service is generally also managed by the provider.
- **Advanced Features:** Access to options like redundancy.
- **Time Saving:** Allows a focus on development, especially at the start of the project.

However, there are some disadvantages:

- **Increasing Cost:** The cost can become prohibitive as your needs increase (in practice: you upgrade your database with larger instances and it costs more).
- **Complexity of Migration:** Once your database has become large, migration to another provider will be more complex, more expensive, and will require more downtime for your application.
- **Limited Control:** You will not have direct control over the server and may not have access to all options.
- **Necessary Knowledge:** An understanding of the internal operating details of the database will still be needed to maintain good performance as the volume of data in the database increases.
- **Dependence on the Provider:** Dependence on the provider, which can be a valuable help but also a point of blockage in case of problems.

For example, our company initially opted for a managed database service. However, after an incident, we realized that the lack of control made migration to another (also a managed service) provider more complex than anticipated, which led us to consider an internally managed solution.

In conclusion, this solution is suitable for simple needs. Consider your immediate needs versus your budget. As your application evolves, assess if the cost and lack of control justify an alternative.

## Installation on a Dedicated Server

Installing PostgreSQL on a server under your administration is another viable option. This can be done via Docker or a classic installation, depending on your preferences and familiarity with these technologies. Here are some distinctions to take into account:

- **Maintenance with Docker:** Using Docker adds an extra maintenance layer, requiring the management of Docker updates alongside PostgreSQL updates.
- **Preconfigured Images:** Docker offers ready-to-use images, simplifying the initial setup compared to manual installation.
- **Ease of Use:** For those less familiar with Docker, a classic installation might be more intuitive.
- **Integration with Existing Infrastructure:** If Docker is already present for other services in your system, integrating PostgreSQL through Docker will allow you to harmonize your configuration.

The two approaches are comparable in terms of resources and security. This solution is ideal for applications requiring high performance and a specific configuration, for example, if your needs include extensions not supported by managed services. Although potentially less costly than some managed services in terms of service fees, it requires continuous investment to maintain the system's security and proper functioning. And you will not have an external contact in case of a problem.

This solution is recommended for growing businesses with the resources necessary for internal maintenance. It is crucial that your team has the required skills while planning a budget for continuous training. Sustained commitment is essential for regular updates, maintenance, and optimization.

# PostgreSQL for Developers

In my recent research on PostgreSQL, I have often noticed a recommendation for installation via Postgres.app. Personally, I found that using Homebrew suited me perfectly.

I will focus here on the Mac environment, although the concepts discussed can easily be adapted to other operating systems. This reflection aims to offer developers a better understanding of the options available and to help them choose based on their work environment and software preferences.

## With Postgres.app

Installation via Postgres.app has several notable advantages:

- **Graphical Interface:** Although basic, it provides extra comfort in interacting with databases.
- **Standalone Installation:** All necessary dependencies are integrated, avoiding additional installations.
- **Version Flexibility:** Allows installing and running multiple PostgreSQL versions simultaneously, facilitating testing and development on different versions.

Thus, for developers who are not already relying on Homebrew, Postgres.app often proves to be the most sensible choice, simplifying experimentation and development.

## With Homebrew

One of the [often mentioned disadvantages](https://chrisrbailey.medium.com/postgres-on-mac-skip-brew-use-postgres-app-dda95da38d74) of installing PostgreSQL via Homebrew is that it automatically updates packages. This poses two major issues: first, local major version updates can cause divergence from the production environment, while it is essential to keep development and production environments as similar as possible. Secondly, a major upgrade might render the storage format used incompatible, thus preventing the database from starting.

However, Homebrew offers simple solutions to avoid this problem. You can specify the major version to use with `@` and `brew link`. You can also pin the minor version if desired with the `pin` command:

```sh
brew install postgresql@17
brew pin postgresql@17
brew link postgresql@17
```

By applying these commands, you ensure that your local environment precisely reflects the version of your production environment, thereby reducing compatibility issues.

By applying these commands, you ensure that your local environment accurately reflects the version of your production environment, thereby reducing the risks of compatibility issues. You'll also avoid the inconveniences related to Homebrew's automatic major version updates that can prevent PostgreSQL from starting.

## Configuration in Rails

Whether you use Homebrew or Postgres.app, integrating PostgreSQL into an application (Rails in the example) requires no configuration. The default rights, while not adhering to best practices for a production deployment, pose no problem for development. Here is an illustration of my `database.yml`:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Rails configuration guide
  # http://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: myapp_development
```

This is exactly the default configuration generated by Rails upon application creation, simply by choosing to configure PostgreSQL as the database, without any modification. After that, I can create the database:

```bash
rails new myapp --database=postgresql
bin/setup
```

Then, the connection to the database is simply made via:

```bash
rails db
```

And my application works without having to configure anything on the PostgreSQL side. No user to create or anything.

One thing not to forget with Postgres.app, to use the command-line tools, [make sure to add the appropriate path to your shell's `PATH` variable](https://postgresapp.com/documentation/cli-tools.html).

## With Docker

Integrating PostgreSQL with Docker in your development presents a potential alternative to consider.

If your environment is already based on Docker and you are comfortable with its configuration, just like in production, it's a good option. However, this requires the installation of Docker, which could cause performance issues on Mac. To avoid these problems, you can use an alternative like OrbStack instead of Docker Desktop.

The installation via Docker will be very advantageous if your configuration already uses it, as it will allow you to start all your services alongside it. If you haven't particularly invested in Docker, Postgres.app or Homebrew might be better alternatives.

Finally, with Docker, it is possible to use the simplified application configuration described earlier, but this will depend on the configuration with which Docker has installed PostgreSQL.

# Conclusion

Ultimately, the choice of the PostgreSQL installation method should be guided by a thorough analysis of your specific needs in terms of performance, security, and resource management. A developer working on a small project will not have the same expectations as a company managing a complex application.

Before making a decision, evaluate the potential growth of your project. Choose a solution that not only meets your current needs but also adapts to its future evolution.

For project startups or individual developers, a managed database can provide considerable comfort. Conversely, companies with specific performance requirements and the necessary technical resources will often prefer an installation on a dedicated server or via Docker.

There is no universal solution that is superior to the others in all cases. By carefully evaluating these factors, you can choose the PostgreSQL installation solution best suited to your environments. Adjust your choices over time to respond to your project's developments.
