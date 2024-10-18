---
layout: article
title:  "PostgreSQLのインストール方法: Homebrew対Docker対Postgres.app"
date:   2024-11-26 08:00:00 +0200
categories: PostgreSQL Homebrew Docker
---

# はじめに

PostgreSQLのインストールは、いくつかの方法で行うことができます。本記事では、さまざまなインストール方法の利点と欠点を探り、どの方法が特定のニーズに最適かを判断します。

本番環境用のインストールと開発用のインストールの違いを理解することは重要です。なぜなら、それぞれのコンテキストには独自の課題と優先事項があるからです。

まずは本番環境に関する一般的な考慮事項から始め、その後、開発環境におけるさまざまなインストール方法について深く掘り下げていきます。

# 本番環境でのPostgreSQLのインストール

本番環境でのPostgreSQLのインストール方法を選択することは、アプリケーションのパフォーマンス、セキュリティ、堅牢性を確保するために不可欠です。この概要はすべての可能性を網羅しているわけではありませんが、選択肢を明確にし、特定のニーズに最も適したオプションに向けたガイドを提供することを目的としています。特に、マネージドデータベースを使用することと、独自の専用サーバーにインストールすることの違いについて説明します。

## マネージドデータベースサービスの使用

多くのプロジェクト、特に始まったばかりのプロジェクトにとって、マネージドデータベースインスタンスを選択することが最も明白な選択であることが多いです。このアプローチの主な利点は次のとおりです：

- **デプロイの容易さ:** 簡単にセットアップでき、通常ワンクリックで安全で最適化されています。手動や技術的なインストール手順は不要です。
- **即時の可用性:** データベースはたいてい数十秒後に利用可能です。
- **メンテナンスの容易化:** 更新とメンテナンスがプロバイダーによって管理されます。
- **簡略化された統合:** 接続URLをアプリケーションに追加するだけで済みます。
- **自動バックアップ:** このサービスも一般的にプロバイダーが管理しています。
- **高度な機能:** 冗長性のようなオプションへのアクセス。
- **時間の節約:** 特にプロジェクトの最初に、開発に集中することができます。

しかし、いくつかの欠点があります：

- **コストの増加:** ニーズが増えるにつれて（実際には：データベースをより大きなインスタンスにアップグレードするとき）、コストが急増することがあります。
- **移行の複雑さ:** データベースが大きくなった場合、他のプロバイダーへの移行がより複雑で、より高価で、アプリケーションのダウンタイムが増加します。
- **制御の限定:** サーバーへの直接制御ができず、すべてのオプションにアクセスできないかもしれません。
- **必要な知識:** データベースの内部動作の詳細を理解し、データベース内のデータ量が増えるにつれて良好なパフォーマンスを維持するための知識が必要です。
- **プロバイダーへの依存:** 問題が発生した場合、貴重な助けとなることもありますが、ブロックする要因にもなり得るプロバイダーへの依存。

例えば、私たちの会社は最初にマネージドデータベースサービスを選択しました。しかし、あるインシデントの後、コントロールの欠如が、他のプロバイダーへの移行、同様にマネージドサービスへの移行を予想以上に複雑にすることに気づき、それにより内部で管理されたソリューションを検討することになりました。

結論として、このソリューションはシンプルなニーズに適しています。即時のニーズと予算を考慮してください。アプリケーションが進化するにつれて、コストとコントロールの欠如が別の選択肢を正当化するかどうか評価してください。

## 専用サーバーへのインストール

PostgreSQLを自分で管理するサーバーにインストールすることも、もう一つの有効なオプションです。これは、Dockerを使って行うことも、従来のインストールを行うこともできます。これは、利用者の技術の好みによります。考慮すべき点として以下のようなものがあります：

- **Dockerによるメンテナンス:** Dockerを使用することで、PostgreSQLのアップデートに加え、Dockerのアップデートも管理する必要がある追加のメンテナンス層が追加されます。
- **プリコンフィギュアされたイメージ:** Dockerはすぐに使えるイメージを提供しており、手動のインストールと比べて初期設定を簡単にします。
- **使いやすさ:** Dockerに不慣れな人にとっては、従来のインストールの方が直感的または使いやすいかもしれません。
- **既存インフラへの統合:** Dockerがシステム内の他のサービスで既に使用されている場合、Dockerを通じてPostgreSQLを統合することで、設定を調和させることができます。

これらの2つのアプローチは、リソースとセキュリティの観点で比較可能です。このソリューションは高パフォーマンスや特定の設定を必要とするアプリケーションに理想的です。例えば、マネージドサービスでサポートされていない拡張機能を必要とする場合です。サービス料に関していくつかのマネージドサービスよりも経済的である可能性がありますが、システムのセキュリティと適切な動作を保つための継続的な投資が必要です。問題が発生した場合、外部の連絡先もありません。

成長中の企業で内部メンテナンスに必要なリソースを持っている場合、このソリューションが推奨されます。チームが必要なスキルを持ち、継続的なトレーニングのために予算を計画することが重要です。定期的なアップデート、メンテナンス、最適化のための持続的なコミットメントが不可欠です。

# 開発者向けのPostgreSQL

最近のPostgreSQLに関するリサーチでは、Postgres.appを使ったインストールがよく推奨されていることに気づきました。個人的には、Homebrewを使用することが私にとっては理想的でした。

ここでは、Macの環境に焦点を当てますが、議論される概念は他のオペレーティングシステムにも容易に適応できます。この考察は、開発者に利用可能なオプションをよりよく理解させ、その作業環境やソフトウェアの好みに基づいて選択を助けることを目的としています。

## Postgres.appを使って

Postgres.appを使ったインストールには、いくつかの注目すべき利点があります：

- **グラフィカルインターフェース:** 基本的ではありますが、データベースとのインタラクションに追加の快適性を提供します。
- **スタンドアロンインストール:** 必要な依存関係がすべて統合されており、追加のインストールを避けることができます。
- **バージョン柔軟性:** 複数のPostgreSQLバージョンを同時にインストールして実行でき、さまざまなバージョンでのテストや開発を容易にします。

このようにして、Homebrewをまだ利用していない開発者にとって、Postgres.appはしばしば最も合理的な選択であり、実験と開発を簡素化します。

## Homebrewを使って

Homebrewを介してPostgreSQLをインストールすることの[よく言及される欠点](https://chrisrbailey.medium.com/postgres-on-mac-skip-brew-use-postgres-app-dda95da38d74)の一つは、それがパッケージを自動的に更新することです。これには2つの主要な問題が伴います。第一に、ローカルのメジャーバージョンの更新が本番環境からの乖離を引き起こす可能性があり、開発と本番環境をできるだけ類似させておくことが重要です。第二に、メジャーアップグレードがストレージフォーマットの互換性をなくし、データベースが起動できなくなる可能性があります。

しかしながら、Homebrewにはこの問題を回避するための簡単なソリューションがあります。`@`と`brew link`を使用して使用するメジャーバージョンを指定することができます。また、`pin`コマンドを使えば、必要であればマイナーバージョンを固定することもできます：

```sh
brew install postgresql@17
brew pin postgresql@17
brew link postgresql@17
```

これらのコマンドを適用することで、ローカル環境が本番環境のバージョンを正確に反映することを保証し、互換性の問題を減少させます。Homebrewの自動メジャーバージョンの更新による不便を避け、PostgreSQLの起動を妨げることがなくなります。

## Railsでの設定

Homebrewを使うにせよ、Postgres.appを使うにせよ、PostgreSQLをアプリケーション（例としてRails）に統合する際には特に設定は必要ありません。デフォルトの権限は、本番環境デプロイのためのベストプラクティスには準じていませんが、開発には問題ありません。私の`database.yml`の例を以下に示します：

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  # コネクションプーリングに関する詳細は、Rails設定ガイドを参照
  # http://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: myapp_development
```

これは、アプリケーション作成時にPostgreSQLをデータベースとして構成することを選ぶだけで、Railsによって生成されたデフォルトの設定であり、何の修正もないものです。その後、次のようにしてデータベースを作成することができます：

```bash
rails new myapp --database=postgresql
bin/setup
```

その後、データベースへの接続は単に以下のようにして行います：

```bash
rails db
```

そして、PostgreSQL側で何も設定することなく、ユーザーを作成することもなく私のアプリケーションは動作します。

Postgres.appを利用する際には、コマンドラインツールを使用するために、シェルの`PATH`変数に適切なパスを[追加することを忘れないようにしてください](https://postgresapp.com/documentation/cli-tools.html)。

## Dockerを使用して

開発環境におけるDockerとのPostgreSQLの統合は、検討すべき潜在的な代替案を提示します。

すでにDockerを基盤とした環境で、かつその設定に慣れている場合、ちょうど本番環境のように使うことは良い選択です。しかし、これはDockerのインストールを必要とし、Mac上でパフォーマンスの問題を引き起こす可能性があります。これらの問題を避けるために、Docker Desktopの代わりにOrbStackのような代替策を使用することができます。

Dockerを使ったインストールは、すでに使用されている設定である場合に非常に有利です。これにより、すべてのサービスをそれと一緒に起動することが可能です。Dockerに特に投資していない場合は、Postgres.appやHomebrewがより良い代替になるかもしれません。

最終的に、Dockerを使用することで前述のシンプルなアプリケーション設定を利用することが可能ですが、これはDockerがどのようにPostgreSQLをインストールしたかの設定次第です。

# 結論

最終的に、PostgreSQLのインストール方法の選択は、パフォーマンス、セキュリティ、およびリソース管理に関する特定のニーズの徹底的な分析によって導かれるべきです。小規模なプロジェクトに取り組んでいる開発者は、複雑なアプリケーションを管理する企業と同じ期待を持っていないでしょう。

決断を下す前に、プロジェクトの成長の可能性を評価しましょう。現在のニーズを満たし、将来の進化に適応するソリューションを選択してください。

プロジェクトの立ち上げ時や個々の開発者には、マネージドデータベースが大きな快適さを提供することがあります。逆に、特定のパフォーマンス要件と必要な技術資源を持つ企業は、専用サーバーやDockerによるインストールを好むことが多いでしょう。

すべてのケースで優れた普遍的なソリューションは存在しません。これらの要素を慎重に評価することによって、自分の環境に最も適したPostgreSQLのインストールソリューションを選択してください。プロジェクトの進展に応じて選択を調整しましょう。

---
layout: article
title: "How to Install PostgreSQL: Homebrew vs Docker vs Postgres.app" # THIS IS NOT A HOWTO
date: 2024-11-26 08:00:00 +0200
categories: PostgreSQL Homebrew Docker
---

# Introduction

There are several ways to install PostgreSQL. This article explores the advantages and disadvantages of various installation methods to determine which one is best suited for specific needs.

Understanding the difference between installations for production environments and those for development is crucial, as each context has its unique challenges and priorities.

We begin with general considerations for the production environment, then delve deeply into different installation methods for development environments.

# Installing PostgreSQL in Production Environments

Choosing a method to install PostgreSQL in a production environment is essential to ensure the application's performance, security, and robustness. While this overview does not cover every possibility, it aims to clarify the options and guide you towards the choice that best meets your specific needs. Notably, we'll explain the difference between using a managed database and installing it on your own dedicated server.

## Using Managed Database Services

For many projects, especially those just starting, choosing a managed database instance is often the most obvious choice. The main advantages of this approach are:

- **Ease of Deployment:** Easy to set up, often optimized and secure with just one click. There are no manual or technical installation procedures.
- **Immediate Availability:** The database is generally available within tens of seconds.
- **Easier Maintenance:** Updates and maintenance are handled by the provider.
- **Simplified Integration:** It only requires adding the connection URL to your application.
- **Automatic Backups:** These services are typically managed by the provider.
- **Advanced Features:** Access to options like redundancy.
- **Time-Saving:** Particularly at the start of a project, you can focus on development.

However, there are some drawbacks:

- **Increased Costs:** As needs grow (specifically, when upgrading the database to a larger instance), costs can escalate sharply.
- **Complex Migration:** As the database grows, migrating to other providers can become more complex, more expensive, and increase application downtime.
- **Limited Control:** You may not have direct server control or access to all options.
- **Required Knowledge:** You need knowledge about the database's internal workings to maintain good performance as the data within grows.
- **Dependency on Providers:** While providers can be a valuable help in case of issues, they can also become blocking factors.

For example, our company initially chose a managed database service. However, after an incident, we realized that the lack of control made the migration to a different provider, which was also a managed service, more complex than expected. This led us to consider an internally managed solution.

In conclusion, this solution suits simple needs. Consider your immediate needs and budget. As your application evolves, evaluate whether the cost and lack of control justify exploring other options.

## Installing on a Dedicated Server

Installing PostgreSQL on a self-managed server is another valid option. This can be done using Docker or a traditional installation, depending on the user's technical preference. Considerations include:

- **Maintenance with Docker:** Using Docker adds an additional maintenance layer for both PostgreSQL and Docker updates.
- **Pre-configured Images:** Docker offers ready-to-use images, simplifying initial setup compared to manual installation.
- **Ease of Use:** For those unfamiliar with Docker, traditional installation may be more intuitive or easier to use.
- **Integration into Existing Infrastructure:** If Docker is already used by other services in the system, integrating PostgreSQL through Docker can harmonize the setup.

These two approaches are comparable in terms of resource and security perspectives. This solution is ideal for applications that require high performance or specific configurations, such as needing extensions not supported by managed services. Although potentially more economical than some managed service fees, ongoing investment is required to maintain system security and proper operation, with no external contact in case of issues.

This solution is recommended for growing businesses with resources needed for internal maintenance. It's important that the team has the necessary skills and plans a budget for ongoing training. A continuous commitment to regular updates, maintenance, and optimization is crucial.

# PostgreSQL for Developers

Recent research on PostgreSQL shows that Postgres.app is often recommended for installation. Personally, using Homebrew was ideal for me.

Though focused on Mac environments here, the discussed concepts can be easily adapted to other operating systems. This consideration aims to better understand the options available to developers and assist their choice based on their work environment and software preferences.

## Using Postgres.app

Installing with Postgres.app brings several notable benefits:

- **Graphical Interface:** Although basic, it provides additional comfort in interacting with the database.
- **Standalone Installation:** All necessary dependencies are integrated, avoiding additional installations.
- **Version Flexibility:** You can install and run multiple PostgreSQL versions simultaneously, facilitating testing and development with various versions.

Thus, for developers yet to utilize Homebrew, Postgres.app is often the most logical choice, simplifing experimentation and development.

## Using Homebrew

One [often mentioned disadvantage](https://chrisrbailey.medium.com/postgres-on-mac-skip-brew-use-postgres-app-dda95da38d74) of installing PostgreSQL via Homebrew is its automatic package updates. This presents two major issues: Firstly, the local major version upgrade can cause discrepancies with the production environment, where it is important to keep development and production closely aligned. Secondly, a major upgrade might remove storage format compatibility, preventing the database from starting.

However, Homebrew provides a simple solution to circumvent this issue. You can specify the major version to use with `@` and `brew link`. Moreover, you can fix the minor version if needed using the `pin` command:

```sh
brew install postgresql@17
brew pin postgresql@17
brew link postgresql@17
```

By applying these commands, you ensure that your local environment accurately reflects the production version, reducing compatibility issues, and avoiding the inconvenience caused by Homebrew's automatic major version updates that might prevent PostgreSQL from launching.

## Configuration with Rails

When integrating PostgreSQL into an application (such as Rails), whether using Homebrew or Postgres.app, no special configuration is required. The default permissions are not best practice for production deployments but are fine for development. Below is an example of my `database.yml`:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see the Rails configuration guide
  # http://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: myapp_development
```

This is the default configuration generated by Rails when selecting PostgreSQL as the database during application creation, with no modifications. You can then create the database as follows:

```bash
rails new myapp --database=postgresql
bin/setup
```

Then connect to the database simply by doing the following:

```bash
rails db
```

My application works without setting up anything or creating a user on the PostgreSQL side.

When using Postgres.app, remember to [add the proper path to the shell `PATH` variable](https://postgresapp.com/documentation/cli-tools.html) to use command line tools.

## Using Docker

Integrating PostgreSQL with Docker in a development environment presents a potential alternative to consider.

If you're already in a Docker-based environment and familiar with its setup, using Docker just like in the production environment could be a good choice. However, this requires a Docker installation and might cause performance issues on a Mac. To avoid these problems, you can use alternatives like OrbStack instead of Docker Desktop.

An installation via Docker is highly advantageous if already used settings are in place, allowing all services to be launched along with it. If you haven't particularly invested in Docker, Postgres.app or Homebrew might be better alternatives.

Ultimately, using Docker makes it possible to utilize the previously mentioned simple application setup, but this depends on how Docker installed PostgreSQL.

# Conclusion

Ultimately, the choice of how to install PostgreSQL should be guided by a thorough analysis of specific needs concerning performance, security, and resource management. Developers working on small projects will not have the same expectations as companies managing complex applications.

Evaluate the potential for project growth before making a decision. Choose a solution that meets current needs and adapts to future evolution.

Managed databases can offer great comfort to individual developers or during project launches. Conversely, companies with specific performance requirements and necessary technical resources often prefer dedicated servers or Docker installations.

There is no universally superior solution for all cases. By carefully evaluating these factors, choose the PostgreSQL installation solution that best fits your environment. Adjust your choice as the project progresses.
