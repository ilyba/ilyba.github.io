<div class="hero">
  <h1>ILYBA</h1>
  <h2>ITサービス</h2>

  <p></p>
  <a href="/ja/services" class="btn-primary">当社のサービスについてさらに詳しく</a>
</div>

# 最後の記事

{% if site.lang != "fr" %}{% assign lang_prefix = "/" | append: site.lang %}{% else %}{% assign lang_prefix = "" %}{%endif%}
<ul class="articles">
  {% for post in site.posts limit:5 %}
    <li>
      <span class="date">{{ post.date | localize: "%Y年%b%-d日", 'ja' | replace_chars: '0123456789', '０１２３４５６７８９' }}</span><a href="{{site.baseurl_root}}{{lang_prefix}}{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
