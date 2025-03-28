---
layout: article
title:  "Fail Fast: 本番環境のバグを素早く修正するために素早く失敗する"
date:   2025-03-24 08:00:00 +0100
categories: Bonnes-Pratiques Ruby Rails Architecture
---

# はじめに

「Fail Fast（フェイルファスト）」戦略とは、アプリケーションの開発または実行サイクルの中でできるだけ早い段階でエラーを検出し、即座に修正することで、より深刻な問題を未然に防ぐことを目的としています。これにより、コードの安定性と保守性が向上します。

Web アプリケーションにおいて、ユーザーが感じるサービスの品質は、エラーを検出し迅速に対処する能力に大きく依存します。

この記事では、監視ツールを使用してエラーを特定し、迅速に修正する方法を紹介します。その後、より複雑なエラーを処理するための戦略について説明します。

# 監視ツール

Rails アプリケーションでは、エラーはログに記録されますが、誰もログを確認しない場合、ユーザーが報告しない限りエラーは見過ごされる可能性があります。

そのため、Rollbar、AppSignal、Sentry などの専用の監視ツールを使用することが推奨されます。これらのツールを導入することで、エラーを直感的なインターフェース上で効率的に管理できます。新しいアプリケーションでは、こうしたツールの導入を最優先事項とすべきです。

このようにして、エラーは自動的に分類・集計され、重要なエラーに集中できるようになります。また、エラー発生時には即座に通知を受け取ることができるため、迅速に対応でき、ユーザーへの影響を最小限に抑えられます。

# 修正の優先順位付け

プロジェクトの初期段階から監視ツールを導入していれば、発生するエラーの数は少なく、都度修正することが可能になります。

基本戦略はシンプルです。エラーが発生した際に通知を受け取り、エラー数が少なければ、作業を一時中断して即座に修正するのが最善です。

しかし、エラーの量が多くなると、優先順位を付ける必要があります。その際に考慮すべきポイントを以下に示します。

## 作業を中断してエラー対応をすべきか？

エラーの数が多すぎると、頻繁な中断が発生し、他の修正や新機能の開発が遅れる可能性があります。その場合は、定期的にエラーをチェックし、通常のワークフローに修正を組み込むことで、影響を最小限に抑えるのが効果的です。

例えば、毎日一定の時間を割いて新しいエラーをリストアップし、タスク管理ツールに記録し、他の作業との優先順位を調整する方法が考えられます。

## エラーの緊急度はどの程度か？

エラーが収益や評判、ユーザー体験に与える影響を考慮します。回避策が存在するかどうかも重要なポイントです。これらの情報を基に、エラー修正の優先順位を決定します。

## エラー修正に十分な時間を割いているか？

エラーの発生数を定量的に追跡し、増加傾向にあるか、減少しているかを分析します。その結果に基づいて、修正に割く時間を調整できます。

# Fail Fast 戦略による複雑なエラーの解決

ほとんどのエラーは、修正が容易です。開発中の単純な見落としであることが多く、監視ツールの情報を見れば迅速に対応できます。

しかし、一部のエラーは解釈が難しいものがあります。例えば、変数やオブジェクトの属性が `nil` になってしまい、コードが想定する値がない場合などです。

このような問題は、アプリケーション内にバリデーションが存在していても発生することがあります。原因としては以下のようなケースが考えられます。

- データがバリデーションを通さずに追加・変更された（意図的または意図せず）
- バリデーションが追加される前に、不正なデータがすでに存在していた

結果として、無効なデータがアプリケーションのさまざまな箇所でバグを引き起こし、診断が難しくなります。

例えば、ユーザーを削除する際にデータベースの制約が設定されていなかった場合、そのユーザーの注文データが孤立してしまう可能性があります。その状態で注文データから関連するユーザーを取得しようとすると、```undefined method `name' for nil``` という典型的なエラーが発生します。この問題を防ぐために、外部キー制約を設定することで、関連する注文データがあるユーザーを削除できないようにするべきです。これにより、不整合を防ぎ、エラーが発生した瞬間に問題を明確にできます。

このようなケースでは、データベース内の不正なデータを修正した後、再発を防ぐために制約を追加することを推奨します。

具体的には、以下のような手法が考えられます。

- 整合性制約 (`NOT NULL`, `FOREIGN KEY`, `UNIQUE`)
- トリガー（特定の条件下でデータベースが自動で処理を実行）

こうすることで、同じ問題が発生した場合、監視ツールが即座に関連するコードを特定できます。

このような制約を追加すると、正当な懸念が生じる可能性があります。ここでは、それに対処する方法を説明します。

# 制約のある環境で

このような解決策を提案すると、しばしば反発を受けます。それには正当な理由があります。

- 制約がプロセスの正常な動作を妨げ、送信されたデータが失われる可能性がある。
- 問題を修正するどころか、新たなエラーを引き起こす可能性がある。

これらの懸念はもっともですが、代替案の方が問題です。それは、エラーを許容することです。時間が経つにつれて、不正なデータが蓄積し、アプリケーションが不安定になります。

さらに、この状況は一時的なものです。確かに、ユーザーがエラーに遭遇することはありますが、そのおかげで迅速に恒久的な修正を施すことができます。データが適切に検証されていれば、同じエラーが再び発生することはなくなります。

プロセスが重要なものである場合、問題が再現されたらすぐに制約を解除することで、影響を最小限に抑えることができます。しかし、場合によっては、これすら許容できないこともあります。そのようなケースでは、プロセスを継続しつつ、エラーを記録するという選択肢もあります。ただし、このアプローチはエラーの発生源がデータベースである場合、より複雑になります。

トリガーを変更して、データを特定のテーブルに記録することができます。PostgreSQL では、`CREATE RULE` を `NOTIFY` と組み合わせて使用することも可能です。これにより、監視ツールにエラーを送信する処理を追加できます。

# この戦略のメリット

このアプローチは、「Fail Fast」戦略のメリットを明確に示しています。それは、異常な状態が検出された時点で、システムを即座に停止させることです。

ここではデータベースの制約を例に説明しましたが、この戦略は他のコンテキストにも適用できます。例えば、メソッドの実行開始時に事前条件をチェックすることなどが挙げられます。

早い段階で失敗させることで、不正なデータがコード全体に広がるのを防ぎ、不必要な防御的ロジックを排除し、保守性を向上させることができます。防御的なコードを追加することは良い戦略とは言えません。なぜなら、どこでチェックが必要なのかを完全に把握することは難しく、さらに、将来の変更でチェックが抜け落ちる可能性もあるからです。

# 結論

バグが少なくなれば、それを修正するための時間が減り、その分アプリケーションの改善や進化に時間を割くことができます。このアプローチにより、保守が効率的になり、新機能の実装も容易になります。

直感に反するように思えるかもしれませんが、「Fail Fast」戦略はバグを減らし、アプリケーションの保守を簡単にするための優れたベストプラクティスです。

エラーが少なくなれば、それを修正するための時間も短縮され、その分のリソースをプロダクトの改善や拡張に充てることができます。この考え方を取り入れることで、保守が効率化され、コードの堅牢性が向上し、新機能の実装もよりスムーズに行えるようになります。
