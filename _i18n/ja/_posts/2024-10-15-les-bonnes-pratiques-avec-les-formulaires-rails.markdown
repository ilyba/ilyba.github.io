---
layout: article
title:  "シンプルで洗練されたRailsフォームのためのベストプラクティスガイド"
date:   2024-10-15 18:30:00 +0200
categories: Rails ActionController ActionView
---

# はじめに

Railsアプリケーションでは、ビジネスロジックや避けることができるマークアップを追加すると、[コントローラー](https://guides.rubyonrails.org/action_controller_overview.html)や[ビュー](https://guides.rubyonrails.org/action_view_overview.html)が複雑化することがあります。

この記事では、Railsの[FormBuilders](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html)と[ActiveRecord](https://guides.rubyonrails.org/active_record_basics.html)の[アソシエーション](https://guides.rubyonrails.org/association_basics.html)を使用して、フォームコードを読みやすく保つための戦略を探ります。

# 問題提起

私が働いてきたほとんどの企業では、コントローラーとビューが過剰になっていることが多々あり、数多くの努力にもかかわらず、この問題を完全になくすことはできませんでした。

理想的なコントローラーは、次のようなアクションを持つべきだと考えます：

```ruby
  def new
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(todo_params)

    if @todo.save
      redirect_to action: :index,
                  flash: { notice: :successfully_saved }
    else
      render :new,
             flash: { error: :could_not_be_saved }
    end
  end
```

このスニペットでは、アクションコードは標準的で、ビジネスロジックを含んでいません。コードはシンプルで理解しやすいです。

しかし、関連するビジネスロジックは明示的ではなく、モデルに実装され、ビューに表示ロジックが組み込まれます。

時間が経つと、さまざまな理由で、連続する開発がコントローラを自然に複雑化させる傾向があります：

- 関連モデルの更新を要求されることがあり、そのため、いくつかの開発者はこれらのアソシエーションの設定を（例：空のオブジェクトを作成する）コントローラーに追加して、フォームの表示を簡単にするかもしれません。
- モデルに直接変換されない特定の動作を有効にしたい場合があります。このためには、モデル構造とは独立したパラメータをフォームに追加し、コントローラでその値を検出して特定のロジックを実行します。
- データ量の増加は、フィルター（またはスコープ）を使用することにつながり、クエリが時折複雑化します。これらのフィルターは時には条件付きで適用する必要があります。このロジックがコントローラーに追加されると、すぐに悪化する可能性があります。
- 複雑な領域での習熟度が不足した開発者が、グラフの特定のオブジェクトを個別に保存することを結果的に行うことを見てきました。これがデータの不整合につながる可能性があることを強調しておきます。一般的に、アソシエーションとネストしたフォームの適切な使用はこれを避けるのに役立ちます。
- リストは続きます：他にも、メールやその他の通知の送信、オートコンプリートを管理するための[REST](https://medium.com/podiihq/understanding-rails-routes-and-restful-design-a192d64cbbb5)標準に準拠しないアクションなども考えられます。

ビューもまた、複雑さを逃れることはできません。対話型の動作を追加するには、Stimulusコントローラーを介して例えばJavaScriptコードを統合する必要があり、その設定がコードの読みやすさを乱し、複雑化することがあります。ユーティリティCSSクラスの使用や、標準のフォームとTurboを使用する代わりにサーバーとの通信にJSONデータを使用することも、この複雑さに寄与することがあります。時にはフォーム構造を適応させ、Turboを使用する方が賢明です。その他の複雑さの例としては、冗長または類似のコード、既存のデータ構造を考慮せずにビジネス要件に基づいて設計されたフォームが含まれます。

# 解決策

実際には、この問題はRailsが初めから提供しているツールを使用して比較的簡単に解決することができます。解決策は、いくつかの重要なRails機能を習得することにあります：

- FormBuilders
- アソシエーション
- [ヘルパー](https://guides.rubyonrails.org/action_view_helpers.html)
- [コールバック](https://guides.rubyonrails.org/active_record_callbacks.html)
- コントローラーとモデル内の[HTTPパラメータ管理](https://codefol.io/posts/How-Does-Rack-Parse-Query-Params-With-parse-nested-query/)

### 全インタラクティビティを管理するためのRailsフォーム

Railsのアソシエーションは非常に強力です。いくつかの開発者は、フォームを扱うのは少し複雑であまり柔軟ではないと見ています。実際には、ブラウザとサーバー間のすべてのインタラクションはフォームで実行できます。

私が観察してきたフォームの使用への障壁の一つは、フォームを単なる[CRUD](https://fr.wikipedia.org/wiki/CRUD#:~:text=L'acronyme%20informatique%20anglais%20CRUD,informations%20en%20base%20de%20donn%C3%A9es.)と見なしていることです。基本的に、Railsの[scaffold](https://guides.rubyonrails.org/command_line.html#bin-rails-generate)、つまり、テーブルのフィールドを反映するフォームを作成し、それをデータベースに保存することです。

しかし、フォームを用いてアソシエーションを駆使することで、サーバーとの任意のインタラクションをモデル化することができます。Hotwireを追加することで、ユーザーはフォームを扱っていることさえ意識せず、単なる技術的な細部に変えます。

もちろん、少し誇張していますが、実際には、おそらくアソシエーションを管理するための`fields_for`をご存知でしょう。`fields_for`はRailsのメソッドで、関連するオブジェクトのためのフォームフィールドを作成することを可能にし、これにより複雑なモデル関係の管理が容易になります。例えば、注文編集フォームで複数の関連商品を入力するために`fields_for`を使用できます。

```ruby
<%= form_for @order do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.fields_for :items do |fi| %>
    <%= fi.label :name %>
    <%= fi.text_field :name %>

    <%= fi.label :quantity %>
    <%= fi.number_field :quantity %>

    <%# 既存オブジェクトの更新 %>
    <%= fi.hidden_field :id %>
  <% end %>

  <%= f.submit %>
<% end %>
```

### `fields_for`の複雑さ

`fields_for`の使用は、フォーム内でいくつかのケースを考慮する必要があるため、最初は少し面倒に思えるかもしれません：

- データベースに既に保存されているオブジェクトの表示と更新。
- 一つまたは複数の新規オブジェクトの作成可能性。

ActiveRecordでは、これをほぼ透明に扱うことができますが、保存されたオブジェクトとまだ保存されていないオブジェクトの管理は同じではありません。Railsは強力ですが、開発者は常にいくつかの微妙な点を念頭に置いておく必要があります。そうしないと、混乱してコントローラを調整して動かすことで諦める可能性があります。

これらの微妙な点の一部は、見逃すと本当に問題になります。おそらくいくつかはご存知でしょう。特に、アソシエーションを更新するためのhiddenフィールドを忘れることを考えています。この場合、安全のために更新されたオブジェクトを適切にフィルタリングしてください。モデル内では、`reject_if`を使用して、更新されたオブジェクトが既存のアソシエーションの一部か、まだデータベースに存在しないことを確認します。別の例としては、モデル内で`accepts_nested_attributes_for`を設定することを忘れることです。

他にもいくつかあり、それらが増えるにつれて混乱が増します。

### チェックボックスと_destroyを使ったアソシエーションの管理（コントローラーを複雑にせずに）

オブジェクトとそのアソシエーションを持つフォームを用意したら、より多くのケースを扱うことができます。

しかし、データストレージとフォームの等価性を壊すとさらに興味深くなります。

例えば、オンライン販売アプリケーションを持っているとします（`Order`モデルを`has_many :services`アソシエーションと一緒に考えます）。注文時には、チェックボックス（またはトグル）を使って、どのサービスを有効にするかを選択するだけです。

単純なアプローチは、フォームに追加属性を追加し、コントローラ側でパラメータを取得し、対応するサービスを作成/削除することを含むかもしれません。

このコードをコントローラーに置くのを避けるために、モデルに対応するアクセサを作成することができます（またはビューのロジックで、ビジネスロジックではないため、[View Object](https://jetthoughts.com/blog/cleaning-up-your-rails-views-with-view-objects-development/)内に作成します）。それはよりクリーンで、同様に機能します。

このアプローチはもちろん機能しますが、ビジネスの価値をほとんど持たない多くのプランビングロジックを書くことを伴います。

関連付けに`_destroy`属性を使用することでこれらの問題を解決します。注文に利用可能なすべてのサービスを正しいパラメータで初期化するためのいくつかのロジックはまだありますが、デフォルトでサービスを有効にしないためには（オプトイン）、`_destroy`をtrueに設定し、デフォルトでサービスを有効にするためには（オプトアウト）設定しない必要があります。モデル側で`after_initialize`コールバックを使って行うことができます。条件付きで`Order.new(build_services: true)`のように行います。`build_services`はコールバックを有効にするかどうかを示す`attr_accessor`です。

```ruby
class Order < ApplicationRecord
  has_many :services

  accepts_nested_attributes_for \
    :services,
    allow_destroy: true,
    reject_if: :belongs_to_foreign_record?

  attr_accessor :build_services
  after_initialize :build_services_records, if: :build_services

  def build_services_records
    Service::KINDS.each { |kind| services.build(kind:) }
  end

  def belongs_to_foreign_record?(attributes)
    attributes['id'].present? &&
      services.ids.include?(attributes['id'].to_i)
  end
end
```

この方法でコントローラーは、モデルの実装詳細を知る必要がなくなります（strong_parametersを忘れない場合）。少しだけ標準から外れていますが、実際には問題ありません。

ビュー側では、`f.fields_for :services`を使ってそれを処理できます。そして、`_destroy`に対応するチェックボックスをCSSで反転して表示します（`_destroy`がtrueの場合、ボックスはチェックされず、その反対も同様です）。

```ruby
<%= f.fields_for :services do |fs| %>
  <%= fs.hidden_field :id %>
  <%= fs.check_box :_destroy %>
<% end %>
```

フォームのパラメータがコントローラからモデルに送られると、`_destroy`がtrueに設定されたアソシエーションが削除されます。したがって、アクティブ化されたサービスのみが注文に関連付けられます。

ここで示したのは、Railsのロジックを少し曲げることで何ができるかを示す一例に過ぎません。

些細なことに見えるかもしれませんが、この手法は余分なコード（肥大化）を制限するのに役立ちます。比較的簡単で理解しやすいコードを維持しながら、複雑な機能を実装することができます。このロジックは少し込み入っているかもしれませんが、これらのパターンは異なる状況に適用できるため、アプリケーションは成長し続け、さらに長い時間修正されていなくてもアクセス可能なコードを維持できます。

私たちのアプリケーションでは、このアプローチを使用して、注文に関連付けられたサービスを構成しています。これによってビューの多くのコードを削除し、コントローラーを簡素化することができました。

### カスタムFormBuilderを使用した冗長性の排除

ActiveAdminは、`formtastic`を使用してフォームを生成します。これは少し風変わりで非常に簡潔な構文で、ActiveAdminでフォームを作成することができます。カスタマイズする必要があった場合には、この構文と苦闘したことがあるかもしれません。

おそらく、別のform builderである`simple_form`もご存知でしょう。

しかし実際には、アプリケーションに自分のform builderを持つことで、よりクリーンなビューが可能になります。

利点は、form builderの作成者が行った選択に適応するのではなく、自分のアプリケーションのニーズに応じて調整できる点で、本当はそれほど難しいことではありません。

多くの場合、フォームを書くときに一般的な方法があります。ほぼすべてのフォームに似たレイアウトやスタイルを適用します（または少なくともいくつかの異なるスタイルをうまく使い分けます）。

例えば、ラベルを使用し、その後にフィールドを使用し、場合によってはCSSクラスを追加してdivにカプセル化します（Tailwindを好む場合や、セマンティックHTML/CSSアプローチを好む場合でも）。

Railsのデフォルトのヘルパーは、ActiveRecordを使ってHTMLフィールドを再現します。そのため、Railsのヘルパーにだけ依存している場合、ビューは冗長で反復的になります。必ずその中にdivとそのクラスがあり、それにラベルとフィールドが含まれています。

FormBuilder内で、Railsのヘルパーをオーバーライドする（または別のものを横に作成します）ことで、一度にすべてを生成できます。これにより、ビューはずっとクリーンになります。異なるバージョンを作成する必要がある場合は、別のヘルパーを追加するか、追加オプションをヘルパーに追加することもできます。

```ruby
module ApplicationFormHelper
  def semantic_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
    merged_options = { builder: ApplicationFormBuilder }.merge(options)
    form_with(model:, scope:, url:, format:, **merged_options, &block)
  end
end

class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options = {})
    _wrapped_field(method, super)
  end

  def value(method)
    _wrapped_field(method, object.public_send(method))
  end

  def _wrapped_field(method, value)
    @template.content_tag(:p) do
      @template.safe_join [label(method), value]
    end
  end
end
```

次に問題となってくるのがStimulusコントローラーです。Stimulusの構文は特に冗長で、書くのは比較的簡単ですが、読み解くのは時にかなり消化不良になります。

例えば、アソシエーション内で動的にオブジェクトを追加/削除したい場合、[Stimulus Components](https://www.stimulus-components.com)の`nested-form`を使用したいかもしれません。構文は比較的まっすぐですが、簡素化できるでしょう：

- 機能を有効にするためにフォームタグにデータ属性を追加する必要があります。
- テンプレートの設定が多くのタグを伴います。

ヘルパーを追加することによって（例えば`f.has_many :items`を使用するのに使用できる）、次のことができます：

- デフォルトの伝説を持つ`fieldset`を自動的に生成します。
- `fields_for`を正しいパラメータで自動的に呼び出します。
- Stimulusコントローラーを設定します。
- 追加/削除ボタンを適切な場所に配置することで、呼び出し元が表示するフィールドを簡単に定義できるようにします。

このロジックを、アプリケーション内のすべてのStimulusコントローラー（フォーム内であってもそうでなくても）に適用することもでき、その結果、ビューの可読性がさらに向上するはずです。

### ActiveRecordのアソシエーション

Railsでフォームを作成する際に頭を悩ませる問題を避ける鍵は、いくつかの概念を理解し、習得することです：

- Rackのパラメータ形式（パラメータがどのようにオプションのハッシュとして渡されるか）。
- 永続化された状態と非永続化された状態でのアソシエーション管理。Railsは、アソシエーションのグラフが永続化されているかどうかに関わらずナビゲートできる機能を持っています。しかし、両者の間には違いがあります。Railsの魔法にも限界があります。
- データベースのトランザクションシステムの理解が重要です。鍵は一つの簡単なルールにあります：一つのコントローラーアクション = 一回のsave。Railsでのsaveは、オブジェクトグラフ全体をトランザクションで保存することを可能にすることを理解することが重要です。トランザクションを手動でブロック管理する必要はなく、フォームをすべての関連オブジェクトを、それらのアソシエーションを介して保存するように構築する必要があるだけです。

## ActiveRecord内のアソシエーションの永続化

フォームが期待通りに機能するためにどのように書かれるべきか理解するために、一般的に最初はRailsコンソールを探ります。

フォームで想定されるパラメータを持つ新しいオブジェクトを作成し、グラフをナビゲートし、保存し、すべてが期待通りに機能する場合は、フォームで使用される構造を複製します。

スコープを使用したより複雑なアソシエーションや[ポリモーフィックアソシエーション](https://edgeguides.rubyonrails.org/association_basics.html#polymorphic-associations)を行う場合には、時折[驚き](https://stackoverflow.com/questions/35104876/why-are-polymorphic-associations-not-supported-by-inverse-of)を伴うことがあります。

通常、これが実際の参考にならないことはめったにありませんが、時折、手動で設定しなければならないことがあります。

アソシエーションは可能な限りシンプルに保ってください。一部の組み合わせはRailsで正しく機能しない可能性があるためです。

以下のケースでは、アソシエーションがまだ保存されていない場合、逆の取得を許可しないことがわかります。これは容易に理解できることであり、スコープがDBクエリであるため保存されたアソシエーションでは実行されないためです。

すでに`has_many :items`があり、アイテムと同じクラスから`has_one :special_item, -> { where(kind: :special) }`を追加したい場合、そのアソシエーションは保存されていないアソシエーションに対して正しく機能しません。これは特定の使用ケースで問題を引き起こすことがあります。

```ruby
# アイテムとスペシャルアイテムを持つ新しいtodoを作成する
>  todo = Todo.new(
     items_attributes: [{}],
     special_item_attributes: {}
   )
=> #<Todo id: nil, name: nil>

# アイテムは逆のアソシエーションを介してtodoにしっかりと関連付けられている
>  todo.items.first.todo
=> #<Todo id: nil, name: nil>

# しかし、スペシャルアイテムは違う
>  todo.special_item.todo
=> nil
```

ActiveRecordの動作が期待通りにうまくいかない場合、そのアソシエーションを管理しているコードを確認し、問題の原因を理解する価値があります。

このような場合、私は[source_location](https://ruby-doc.org/core-2.4.6/Method.html#method-i-source_location)を使って、アソシエーションコール中に使用されるコードを簡単に見つけます。このメソッドは、ソースファイルとメソッドが定義されている行番号を返します。例えば：

```ruby
> Todo.method(:has_many).source_location
=> ["gems/activerecord-7.2.1.1/lib/active_record/associations.rb", 1268]

> Todo.instance_method(:items).source_location
=> ["gems/activerecord-7.2.1.1/lib/active_record/associations/builder/association.rb", 103]
```

実装の詳細を理解することで、ActiveRecordと統合された機能を作成できます。それにより、アプリに自分自身の特殊な機能を追加でき、Railsの一部として存在するように見える機能を持つことが可能です。

# 結論

Railsアプリケーションは複雑になることがあります。フレームワークの実用的なアプローチは時折、コードの組織上の問題を引き起こすことがあります。このような手法を使うことで、非常にシンプルで明確なビューとコントローラーを維持することができます。この問題はモデルの複雑さを管理する際にも存在しますが、私たちは次の機会にこの話題を取り上げることにします。
