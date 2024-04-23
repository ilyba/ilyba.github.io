---
layout: article
title:  "Jekyllへようこそ!"
date:   2023-07-05 00:38:44 +0200
categories: jekyll update
---
この投稿は「_posts」ディレクトリにあります。 編集してサイトを再構築し、変更内容を確認してください。 サイトはさまざまな方法で再構築できますが、最も一般的な方法は、「jekyllserve」を実行することです。これは、Web サーバーを起動し、ファイルが更新されたときにサイトを自動再生成します。

Jekyll では、ブログ投稿ファイルに次の形式に従って名前を付ける必要があります。

`年-月-日-タイトル.マークアップ`

ここで、「YEAR」は 4 桁の数字、「MONTH」と「DAY」は両方とも 2 桁の数字、「MARKUP」はファイルで使用される形式を表すファイル拡張子です。 その後、必要な前付けを含めます。 この投稿のソースを見て、それがどのように機能するかを理解してください。

Jekyll は、コード スニペットの強力なサポートも提供します。

{% highlight ruby %}
def print_hi(名前)
   「こんにちは、#{名前}」と入力します
終わり
print_hi('トム')
#=> は「Hi, Tom」を STDOUT に出力します。
{% endhighlight %}

Jekyll を最大限に活用する方法の詳細については、[Jekyll docs][jekyll-docs] を参照してください。 すべてのバグ/機能リクエストは [Jekyll の GitHub リポジトリ][jekyll-gh] に提出してください。 質問がある場合は、[Jekyll Talk][jekyll-talk] で質問してください。

[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]: https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
