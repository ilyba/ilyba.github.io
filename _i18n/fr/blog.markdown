# Blog

{% if site.lang != "fr" %}{% assign lang_prefix = "/" | append: site.lang %}{% else %}{% assign lang_prefix = "" %}{%endif%}
<ul class="articles">
  {% for post in site.posts %}
    <li>
      <span class="date">{{ post.date | date: "%-d %B %Y" }}</span><a href="{{site.baseurl_root}}{{lang_prefix}}{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>

{% for post in page.posts %}
    {% capture year_of_current_post %}
    {{ post.date | date: "%Y" }}
    {% endcapture %}

    {% capture year_of_previous_post_in_set %}
    {{ page.posts[forloop.index].date | date: "%Y" }}
    {% endcapture %}

    {% if forloop.first %}
    <h2>{{ year_of_current_post }}</h2>
    <ul>
    {% endif %}

      <li><a href="{{ post.url }}">{{ post.title }}</a></li>

    {% if forloop.last %}
    </ul>
    {% else %}
    {% if year_of_current_post != year_of_previous_post_in_set %}
    </ul>

    <h2>{{ year_of_previous_post_in_set }}</h2>
    <ul>
    {% endif %}
    {% endif %}
{% endfor %}
