<div class="hero">
  <h1>ILYBA</h1>
  <h2>IT Services</h2>

  <p></p>
  <a href="/en/services" class="btn-primary">More about our services</a>
</div>

# Last articles

{% if site.lang != "fr" %}{% assign lang_prefix = "/" | append: site.lang %}{% else %}{% assign lang_prefix = "" %}{%endif%}
<ul class="articles">
  {% for post in site.posts limit:5 %}
    <li>
      <span class="date">{{ post.date | localize: "%B %-d, %Y", site.lang }}</span><a href="{{site.baseurl_root}}{{lang_prefix}}{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>

<a href="/en/blog" class="btn-primary">All articles</a>
