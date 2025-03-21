<div class="hero">
  <h1>ILYBA</h1>
  <h2>Services informatiques</h2>

  <p></p>
  <a href="/services" class="btn-primary">En savoir plus sur nos services</a>
</div>

# Derniers articles

{% if site.lang != "fr" %}{% assign lang_prefix = "/" | append: site.lang %}{% else %}{% assign lang_prefix = "" %}{%endif%}
<ul class="articles">
  {% for post in site.posts limit:5 %}
    <li>
      <span class="date">{{ post.date | localize: "%-d %B %Y", site.lang }}</span><a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>

<a href="/blog" class="btn-primary">Tous les articles</a>
