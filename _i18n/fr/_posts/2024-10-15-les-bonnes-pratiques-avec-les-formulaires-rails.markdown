---
layout: article
title:  "Guide de bonnes pratiques pour des formulaires Rails simples et épurés"
date:   2024-10-15 18:30:00 +0200
categories: Rails ActionController ActionView
---

# Introduction

Dans les applications Rails, les [contrôleurs](https://guides.rubyonrails.org/action_controller_overview.html) et les [vues](https://guides.rubyonrails.org/action_view_overview.html) peuvent devenir complexes quand on y ajoute de la logique métier ou du balisage qui pourrait être évité.

Dans cet article, nous explorerons des stratégies pour garder votre code des formulaires lisible, notamment en utilisant les [FormBuilders](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html) de Rails et les [associations](https://guides.rubyonrails.org/association_basics.html) [ActiveRecord](https://guides.rubyonrails.org/active_record_basics.html).

# Problématique

Dans la plupart des entreprises où j’ai travaillé, j’ai souvent vu des contrôleurs et des vues encombrées, et malgré de nombreux efforts on a évité complètement ce problème.

Pour moi, un contrôleur idéal devrait avoir des actions qui ressemblent à ça :

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

Dans cet extrait, le code des actions est canonique et ne contient aucune logique métier. Le code est simple et immédiatement compréhensible.

Pourtant, la logique métier associée n’est pas nécessairement évidente, mais elle sera implémentée dans le modèle et la logique d’affichage dans les vues.

Avec le temps, les évolutions successives vont avoir naturellement tendance à complexifier contrôleur pour différentes raisons :

- Elles pourraient nécessiter de mettre à jour des modèles associés, et pour cela certains développeurs pourraient être tentés d’ajouter la configuration de ces associations (en créant par exemple un objet vide) dans le contrôleur pour faciliter l’affichage du formulaire.
- On pourrait vouloir activer un comportement spécifique qui ne se traduit pas directement dans le modèle. Pour cela, on ajouterait un paramètre dans le formulaire indépendant de la structure du modèle, détecter sa valeur dans le contrôleur et exécuter une certaine logique.
- L’augmentation de la quantité de données amènera à vouloir utiliser des filtres (ou scopes) rendant les requêtes parfois complexes. Il faudra parfois appliquer ces filtres de façon conditionnelle. Si cette logique est ajoutée au contrôleur, cela peut très vite dégénérer.
- J’ai parfois vu des développeurs manquer de maîtrise face à un domaine complexe finir par enregistrer séparément certains objets du graphe. Je tiens à préciser que cela qui peut entraîner des incohérences dans les données. Généralement la bonne utilisation des associations et des formulaires imbriqués permet d’éviter cela.
- La liste est interminable : je pense aussi à l’envoi de mails ou autres notifications, des actions non conformes au standard [REST](https://medium.com/podiihq/understanding-rails-routes-and-restful-design-a192d64cbbb5) pour gérer des autocomplete, etc…

La vue n'échappe pas non plus à la complexité. L'ajout de comportements interactifs nécessite souvent l'intégration de code JavaScript, par exemple via des contrôleurs Stimulus, dont la configuration peut encombrer et compliquer la lecture du code. L'utilisation de classes CSS utilitaires ou le recours à des données JSON pour la communication avec le serveur (plutôt que d'employer des formulaires standard et Turbo) peut également contribuer à cette complexité. Parfois, il serait plus judicieux d'adapter la structure du formulaire et d’utiliser Turbo. D'autres exemples de complexité incluent le code redondant ou similaire, ainsi que des formulaires conçus en fonction des demandes métiers mais sans prendre en compte la structure des données existante.

# Les solutions

Il est en fait relativement simple de résoudre ces problèmes en utilisant les outils fournis par Rails depuis le début. La solution repose sur la maîtrise de quelques fonctionnalités essentielles de Rails :

- Les FormBuilders
- Les associations
- Les [helpers](https://guides.rubyonrails.org/action_view_helpers.html)
- Les [callbacks](https://guides.rubyonrails.org/active_record_callbacks.html)
- La [gestion des paramètres HTTP](https://codefol.io/posts/How-Does-Rack-Parse-Query-Params-With-parse-nested-query/) dans les contrôleurs et les modèles.

### Des formulaires Rails pour gérer toute l’interactivité

Les associations dans Rails sont extrêmement puissantes. Certains développeurs voient les formulaires comme quelque chose d’un peu compliqué à manipuler, pas très flexibles. En réalité toute interaction entre le navigateur et le serveur peut être réalisée avec un formulaire.

Un des freins à l’utilisation d’un formulaire que j’ai pu observer, c’est le fait de considérer un formulaire comme un simple [CRUD](https://fr.wikipedia.org/wiki/CRUD#:~:text=L'acronyme%20informatique%20anglais%20CRUD,informations%20en%20base%20de%20données.). En gros, le [scaffold](https://guides.rubyonrails.org/command_line.html#bin-rails-generate) de Rails. C’est à dire : on crée un formulaire qui reprend les champs d’une table et on enregistre ça en base de données.

Mais en utilisant les formulaires pour jongler avec les associations, on peut modéliser n’importe quelle interaction avec le serveur. En y ajoutant Hotwire, l’utilisateur n’a même plus conscient d’avoir affaire à des formulaires qui deviennent un simple détail technique.

Évidemment, je caricature un peu, en réalité, vous connaissez probablement `fields_for` pour gérer les associations. `fields_for` est une méthode Rails qui permet de créer des champs de formulaire pour les objets associés. Cela facilite ainsi la gestion des relations complexes entre modèles. `fields_for` peut être utilisé par exemple dans un formulaire d'édition d'une commande pour saisir plusieurs articles associés.

```ruby
<%= form_for @order do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>

  <%= f.fields_for :items do |fi| %>
    <%= fi.label :name %>
    <%= fi.text_field :name %>

    <%= fi.label :quantity %>
    <%= fi.number_field :quantity %>

    <%# Mise à jour des objets existants %>
    <%= fi.hidden_field :id %>
  <% end %>

  <%= f.submit %>
<% end %>
```

### La complexité de fields_for

Utiliser `fields_for` peut paraître un peu fastidieux dans un formulaire au premier abord car il y a plusieurs cas à prendre en compte :

- L’affichage et la mise à jour des objets déjà enregistrés en base de données.
- La possibilité de créer un ou plusieurs nouveaux objets.

ActiveRecord permet de rendre cela quasiment transparent mais gérer un objet déjà persisté et un objet qui ne l’est pas encore ce n’est pas la même chose. Même si Rails est puissant, les développeurs doivent quand même toujours avoir en tête certaines subtilités pour éviter de s’emmêler les pinceaux et parfois même de jeter l’éponge et finir par bricoler dans le contrôleur pour le faire marcher.

Certaines de ces subtilités peuvent véritablement vous pourrir la vie si vous passez à côté, vous en connaissez probablement certaines. Je pense en particulier à l’oubli du champ caché pour mettre à jour une association. Attention dans ce cas à bien filtrer les objets mis à jour pour la sécurité, pour cela dans le modèle, utilisez `reject_if` pour vérifier que les objets mis à jour font bien partie de l’association existante ou qu’ils ne sont pas encore en base… Une autre est d'oublier de configurer `accepts_nested_attributes_for` dans le modèle.

Il y en a encore d’autres, et la confusion augmente quand elles se multiplient.

### Gérer les associations avec des cases à cocher et _destroy sans complexifier le contrôleur

Une fois qu’on a son formulaire avec un objet et ses associations, on peut déjà traiter beaucoup plus de cas.

Mais cela devient encore plus intéressant lorsqu’on casse l’équivalence entre le stockage des données et le formulaire.

Par exemple, si vous avez une application de vente en ligne (Prenons un modèle `Commande` avec une association `has_many :services`). Lorsque vous commandez vous voulez simplement choisir les services qui vous intéressent en les activant ou pas avec une case à cocher (ou un toggle).

Une approche naïve pourrait consister à ajouter des attributs supplémentaires dans le formulaire, puis côté contrôleur à récupérer les paramètres et créer/supprimer les services correspondants.

Pour éviter de mettre ce code dans le contrôleur, on peut créer les accesseurs correspondants dans le modèle (ou dans un [View Object](https://jetthoughts.com/blog/cleaning-up-your-rails-views-with-view-objects-development/) vu que c’est de la logique de vue et pas de la logique métier). Ça serait plus propre et ça marcherait tout aussi bien.

Cette approche fonctionne bien évidemment, mais implique d’écrire pas mal de logique de plomberie qui n’a pas vraiment de valeur métier.

L’utilisation de la propriété `_destroy` sur l’association permet de résoudre ces problèmes. Il y a tout de même un peu de logique pour initialiser tous les services disponibles pour la commande avec les bons paramètres, ensuite il faut positionner `_destroy` à true pour ne pas activer le service par défaut (opt-in), et ne pas le positionner pour un service à activer par défaut (opt-out). On peut le faire côté modèle avec un callback `after_initialize`, probablement de façon conditionnelle de cette façon `Commande.new(build_services: true)` . `build_services` étant un `attr_accessor` qui permet d’indiquer si on souhaite activer le callback.

```ruby
class Commande < ApplicationRecord
  has_many :services

  accepts_nested_attributes_for \
    :services,
    allow_destroy: true
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

Le contrôleur est un peu moins canonique, mais en vrai ça va. Même si on spécifie un paramètre, cette approche évite que le contrôleur n’ait connaissance des détails d’implémentation du modèle (si on oublie strong_parameters).

Côté vue, on s’en sort avec un `f.fields_for :services` . Et on affiche la case à cocher qui correspond à `_destroy` mais en l’inversant avec un petit du CSS (quand `_destroy` vaut true, la case sera désactivée et inversement).

```ruby
<%= f.fields_for :services do |fs| %>
  <%= fs.hidden_field :id %>
  <%= fs.check_box :_destroy %>
<% end %>
```

Quand le contrôleur renvoie des paramètres du formulaire dans le modèle, les associations qui ont `_destroy` à true sont supprimées. Et donc seuls les services activés seront associés à la commande.

Voilà, c’était juste pour vous montrer un exemple de ce qu’on peut faire en tordant un peu la logique de Rails.

Cela peut paraître un peu anodin, mais ce type d’approche permet de limiter le code superflu (bloat). Ça permet de réaliser des fonctionnalités complexes en conservant un code relativement simple à comprendre. Même si la logique peut paraître un peu tordue, comme ces patterns peuvent être appliqués dans différentes situations, l’application peut grossir tout en conservant un code accessible même sans y avoir touché depuis longtemps.

Dans notre application, nous utilisons cette approche pour configurer les services associés à une commande. Cela nous a permis de supprimer beaucoup de code dans la vue et de simplifier nos contrôleurs.

### Suppression des redondances grâce un FormBuilder personnalisé

ActiveAdmin utilise `formtastic` pour générer les formulaires. Vous savez, c’est la syntaxe un peu bizarre mais très concise qui permet de créer les formulaires dans ActiveAdmin, vous vous êtes peut-être déjà battu avec si vous avez eu besoin de les personnaliser.

Vous connaissez peut-être aussi `simple_form` qui est un autre form builder.

Mais en réalité avoir votre propre form builder dans votre application vous permettra d’avoir des vues épurées.

L’avantage est que plutôt que de vous adapter aux choix faits par le créateur du form builder et éventuellement finir par vous battre avec, vous pouvez l’adapter aux besoins de votre application, et ce n’est pas vraiment compliqué à faire.

Souvent, vous avez une manière générique d’écrire vos formulaires, vous appliquez une mise en page un style similaire sur à peu près vos formulaires (ou à la limite vous jonglez avec quelques styles différents).

Par exemple, vous utilisez un label, puis votre champ, vous l’encapsulez dans une div, éventuellement avec quelques classes CSS (si vous êtes adepte de Tailwind ou pas si vous préférez l’approche semantic HTML/CSS).

Les helpers par défaut de Rails se contentent de répliquer les champs du HTML en les hydratant avec ActiveRecord. Donc si vous vous contentez des helpers de Rails, vos vues seront verbeuses et répétitives. Systématiquement, vous aurez votre div et ses classes, avec le label et le champ dedans.

Dans votre FormBuilder, vous allez pouvoir surcharger les helpers de Rails (ou en créer d’autres à côté) pour qu’ils génèrent tout d’un coup. Vos vues sont ainsi beaucoup plus épurées. Si vous avez besoin de faire une version différente, vous pouvez toujours ajouter un autre helper, ou bien ajouter des options supplémentaires sur votre helper.

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

Ensuite, reste le problème de vos contrôleurs Stimulus, la syntaxe Stimulus peut être particulièrement verbeuse et si elle est relativement simple à écrire, sa lecture se révèle parfois assez indigeste.

Par exemple, si vous voulez ajouter/retirer dynamiquement un objet dans une association vous voudrez par exemple utiliser `nested-form` de [Stimulus Component](https://www.stimulus-components.com). La syntaxe est relativement simple, mais elle pourrait être simplifiée :

- Il faut ajouter des attributs data sur la balise du formulaire pour activer la fonctionnalité
- Configurer le template implique beaucoup de balises

En ajoutant un helper (qui pourrait s’utiliser avec `f.has_many :items` par exemple), vous pourrez :

- Créer automatiquement un `fieldset` avec une légende par défaut
- Appeler `fields_for` avec les bons paramètres automatiquement
- Configurer le contrôleur Stimulus
- Ajouter les boutons d’ajout/suppression au bon endroit ainsi l’appelant pourra se contenter de définir les champs à afficher.

Vous pouvez bien sûr appliquer cette logique de création d’helpers avec tous les contrôleurs Stimulus de votre application (qu’ils soient dans des formulaires ou non), si bien que vos vues devraient gagner encore en lisibilité.

### Les associations dans ActiveRecord

Une des clés pour éviter les prises de tête lors de la création de formulaires dans Rails est de bien comprendre et maîtriser un certain nombre de concepts :

- Le format des paramètres dans Rack (comment on passe des paramètres à un hash d’options)
- Comment les associations sont gérées en mode persisté et en mode non persisté. Rails est en effet capable de naviguer dans un graphe d’associations qu’elles soient persistées ou non. Mais il y a des différences entre les deux. La magie de Rails a ses limites.
- Bien comprendre le système de transaction en base de données. La clé réside dans une seule règle simple : une action de contrôleur = un seul save. Il faut bien comprendre qu’un save dans Rails permet d’enregistrer tout un graphe d’objet dans une transaction. Vous n’avez pas besoin de gérer la transaction manuellement avec un bloc ou quoi que ce soit, tout ce qu’il faut faire c’est construire votre formulaire de sorte à ce qu’il contienne tous les objets à enregistrer via les associations.

## La persistance des associations dans ActiveRecord

Pour comprendre comment un formulaire doit être écrit pour fonctionner comme je veux, je commence généralement par faire un tour dans la console Rails.

On crée un nouvel objet avec les paramètres attendus dans le formulaire, on parcourt le graphe, on enregistre et si tout fonctionne comme prévu, on réplique la structure utilisée dans un formulaire.

Quand on fait des associations plus complexes, avec des scopes par exemple ou des [associations polymorphiques](https://edgeguides.rubyonrails.org/association_basics.html#polymorphic-associations) on peut parfois avoir des [surprises](https://stackoverflow.com/questions/35104876/why-are-polymorphic-associations-not-supported-by-inverse-of).

Souvent ça ne pose pas de problème en pratique, mais parfois, on se retrouve à devoir faire de la configuration à la main.

Gardez vos associations le plus simple possible car certaines combinaisons ne fonctionnent pas correctement dans Rails.

Dans le cas ci-dessous, on peut voir que la configuration de l’association ne permet pas de récupérer l’inverse quand l’association n’est pas encore persistée. On peut le comprendre facilement vu que le scope est une requête sur la DB et n’est donc pas exécuté pour une association non persistée.

Si vous avez déjà un `has_many :items` et que vous voulez ajouter `has_one :special_item, -> { where(kind: :special) }` de la même classe qu'`items`, l’association ne va pas fonctionner correctement pour les associations non persistées. Ce qui peut parfois poser des problèmes dans certains cas d’utilisation.

```ruby
# On crée une nouvelle todo avec un item et un item spécial
>  todo = Todo.new(
     items_attributes: [{}],
     special_item_attributes: {}
   )
=> #<Todo id: nil, name: nil>

# L'item est bien lié à la todo via l'association inverse
>  todo.items.first.todo
=> #<Todo id: nil, name: nil>

# Mais pas l'item spécial
>  todo.special_item.todo
=> nil
```

Quand un comportement d’ActiveRecord ne fonctionne pas comme attendu, il ne faut pas hésiter à consulter le code qui gère l’association pour comprendre d’où vient le problème.

Dans ces cas-là j’utilise [source_location](https://ruby-doc.org/core-2.4.6/Method.html#method-i-source_location) pour trouver facilement le code utilisé lors de l’appel de l’association. Cette méthode renvoie le fichier source et le numéro la ligne où est définie la méthode. Par exemple :

```ruby
> Todo.method(:has_many).source_location
=> ["gems/activerecord-7.2.1.1/lib/active_record/associations.rb", 1268]

> Todo.instance_method(:items).source_location
=> ["gems/activerecord-7.2.1.1/lib/active_record/associations/builder/association.rb", 103]
```

Comprendre les détails d’implémentation permet de concevoir des fonctions intégrées avec ActiveRecord. Cela permet d’ajouter sa propre magie dans son application et d’avoir des fonctions qui paraissent faire partie de Rails.

# Conclusion

Les applications Rails peuvent être complexes et l’approche pragmatique du framework mène parfois à des problèmes d’organisation du code. En utilisant les techniques exposées dans cet article, vous pourrez conserver des vues et des contrôleurs très simples et très lisibles. Cette problématique existe également pour gérer la complexité des modèles, mais nous aborderons cette problématique dans un futur article.
