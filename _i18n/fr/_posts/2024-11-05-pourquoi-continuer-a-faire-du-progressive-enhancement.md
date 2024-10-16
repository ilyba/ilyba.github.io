---
layout: article
title:  "Pourquoi continuer à faire du progressive enhancement en 2024 ?"
date:   2024-11-05 08:00:00 +0200
categories: Rails Hotwire Stimulus Turbo
---

# Introduction

L’amélioration progressive est une méthode de conception des sites Web qui consiste à réaliser une version minimaliste et résiliente d’une fonctionnalité. C’est à dire qui sera utilisable dans un navigateur des années 2000. Puis d’intégrer progressivement par couches successives les fonctionnalités modernes.

Pour réaliser cela, on commence par écrire une page avec du code HTML minimaliste et standard, on lui associe une feuille de style CSS avec des directives également minimalistes et standard. On obtient alors une page fonctionnelle qui s’affiche instantanément même avec une connexion bien pourrie et avec le JavaScript désactivé.

Toutes les fonctionnalités non indispensables mais qui améliorent l’expérience utilisateur (polices, comportements interactifs, effets visuels) sont ajoutées ensuite progressivement tout en permettant le fonctionnement de base de la page quand ces améliorations ne sont pas activées.

# L’état de l’art en 2024

La [motivation généralement admise](https://piccalil.li/blog/its-about-time-i-tried-to-explain-what-progressive-enhancement-actually-is/) dans la littérature pour utiliser l’amélioration progressive est de proposer une expérience utilisateur acceptable même dans des conditions dégradées.

Mais en 2024, il est tout à fait possible de lancer un service sans se préoccuper de l’expérience d’un petit nombre de personnes dans des conditions dégradées. C’est d’ailleurs pour ça que beaucoup de développeurs depuis plus de 20 ans choisissent des technologies qui nécessitent d’avoir JavaScript activé et nécessite généralement le téléchargement d’une grande quantité de JavaScript avant de pouvoir commencer à intéragir avec le site.

C’est une approche qui permet sans aucun doute de faire des affaires florissantes. Et même si une partie des utilisateurs est mise de côté, cela n’empêchera certainement pas votre service d’être un succès.

Et même si j’ai évidemment à cœur de ne mettre personne sur le côté dans mes développements, ce n’est pas la raison la plus importante pour moi pour adopter cette approche.

# La raison pour faire de l’amélioration progressive

La bonne raison c’est celle qui va vous convaincre ou vous permettre de convaincre toute une équipe, des dirigeants de passer sur cette approche.

Si vous vous espérez convaincre toutes ces personnes en leur disant qu’ils vont pouvoir augmenter leur cible de 98% des utilisateurs à 99%, vous avez peu de chances de les convaincre à moins que ce soit une multinationale déjà bien implantée dont c’est peut-être le dernier levier de croissance.

Même si vous les convainquez qu’une majeure partie de leurs utilisateurs sera de temps en temps confrontée à une mauvaise expérience (une pensée à tous ceux qui utilisent leur téléphone dans les transports), parce qu’elle se trouvera face à des conditions dégradées, ça ne permettra pas forcément de changer leurs priorités.

Mais pour moi le plus intéressant est que cette technique permet d’obtenir un code plus simple et plus facile à maintenir.

# L’amélioration progressive améliore le code

Pour moi, la bonne raison c’est que cette approche permet d’améliorer la qualité du code et d’éviter un nombre considérable de problèmes dans une application. C’est ce que je vais vous expliquer ici.

> Working in the actual deliverable’s medium — the web — in cycles/iterations/sprints, with progressive enhancement at the root will — I promise — result in smaller codebases, simpler UIs and happier users!
>
> [*Andy Bell*](https://piccalil.li/author/andy-bell)
>

## Cela réduit la quantité de JavaScript

Pour commencer, on de va utiliser JavaScript que pour améliorer l’expérience existante.
Cette expérience sera donc réalisée uniquement grâce aux fonctionnalités standard du Web.
On utilisera du coup par défaut [les liens et les formulaires](/rails/actioncontroller/actionview/2024/10/15/les-bonnes-pratiques-avec-les-formulaires-rails.html)
pour communiquer avec le serveur. Pour une majorité des fonctionnalités
cela sera tout à fait suffisant, et il n’y aura rien besoin d’ajouter
pour avoir une expérience satisfaisante.

Mais parfois, on voudra optimiser l’expérience. Prenons l’exemple d’un champ avec autocompletion.
Le principe est d’afficher une liste de suggestions au fur et à mesure de la saisie.
[Une telle fonctionnalité ~~est irréalisable sans~~ nécessite souvent JavaScript](https://gomakethings.com/how-to-create-an-autocomplete-input-with-only-html/)
puisqu’elle nécessite de déclencher un comportement au fil de la saisie.
Si une interaction avec le serveur est nécessaire avec le serveur, le HTML simple ne suffit pas.

Pourtant réaliser ce type de fonctionnalité en suivant les principes de
l’amélioration progressive permet de simplifier l’architecture du code.

Imaginons à quoi pourrait ressembler une telle fonctionnalité sans JavaScript.
Nous pouvons afficher un champ de saisie et une liste de proposition initialement vide.
Lors de la saisie, l’utilisateur va vouloir consulter les suggestions.
Pour cela, plutôt que de lui afficher instantanément, l’utilisateur pourra activer
un bouton dédié au chargement des suggestions sur le formulaire pour les afficher.
Sans JavaScript l’ensemble de la page sera rechargée y compris la liste.
Il pourra ensuite choisir un élément dans la liste et valider définitivement le formulaire.


```ruby
class Order < ApplicationRecord
  belongs_to :product
  attr_accessor :product_name
end

class Product < ApplicationRecord
  def self.search(query)
    return none if query.blank?

    where('name like :query', query: "#{query}\%")
  end
end
```

```ruby
class OrdersController < ApplicationController
  def new
    @order = Order.new
  end

  def create
    @order = Order.new(params[:order].permit!)

    if params[:commit] && @order.save
      redirect_to @order
    else
      render :new
    end
  end
end
```

```erb
<%= form_with model: @order do |f| %>
  <fieldset>
    <legend>Todo</legend>

    <%= f.text_field :name %>

    <%= f.text_field :product_name,
                     list: 'product-suggestions',
                     value: params.dig(:order, :product_name) %>

    <datalist id="product-suggestions">
      <% Product.search(@order.product_name).each do |product| %>
        <%= content_tag :option, '', value: product.name %>
      <% end %>
    </datalist>

    <%= f.submit 'Rechercher', name: 'autocomplete' %>
  </fieldset>

  <%= f.submit %>
<% end %>
```

On peut ensuite utiliser JavaScript pour améliorer l’expérience. L’avantage d’avoir utilisé
cette approche, c’est qu’on aura très peu de JavaScript à ajouter. Et en utilisant
des technologies comme Hotwire Turbo, on n’aura même pas à ajouter le JavaScript nous-même
mais seulement un peu de configuration sur les formulaires. Le JavaScript permettra de
masquer le bouton et de déclencher le comportement lors de la saisie. Ce comportement consiste à
charger la liste puis en remplaçant la liste sur la page actuelle. Le chargement de la liste
pourra se faire en récupérant la page existante mise à jour (et donc sans nécessiter de
mise à jour de la partie serveur) ou bien une version partielle de la page contenant
uniquement les suggestions.

Dans notre exemple, on note que le contrôleur n'a besoin d'aucune adaptation
pour pouvoir afficher les suggestions de produits et nécessite uniquement
de vérifier si `params[:commit]` est défini pour gérer les comportements interactifs
avant validation.

On a donc montré comment cette approche peut permettre de réduire la quantité de JavaScript
dans une application. Nous allons maintenant voir comment la réduction du JavaScript permet en plus
de faciliter la maintenance de votre application.

# Cela facilite la maintenance du code

Dans une application Rails, le code JavaScript est plus difficile et complexe à tester car il nécessite un navigateur Web pour fonctionner contrairement au code backend qui tourne nativement sur le serveur sans navigateur. Cela va donc rendre les tests également plus longs à s’exécuter.

Avec l’amélioration progressive le code JavaScript produit est plus général, ce qui le rend beaucoup plus facile à tester. Il n’y a pas de dépendances envers le code métier donc le code est plus susceptible de pouvoir être réutilisé ailleurs dans l’application. Par effet boule de neige, cette capacité à pouvoir être réutilisé réduit d’autant la quantité de code JavaScript. C’est un cercle vertueux.

Évidemment, le code JavaScript (plus précisément le code JavaScript exécuté directement par le navigateur) n’est pas en soi un problème, mais son utilisation systématique rend les systèmes plus complexes. La réduction de cette complexité entraine une amélioration de la maintenabilité des applications.

# Un deuxième exemple

Pour copier un texte dans le presse-papier automatiquement, le JavaScript est obligatoire.

Mais là encore, on peut concevoir une fonctionnalité équivalente qui ne nécessite pas de JavaScript. À savoir : afficher le texte à copier et suggérer à l’utilisateur de copier le texte en question lui-même en utilisant les fonctionnalités de son système d’exploitation.

```erb
<% if @order.product %>
  URL <%= text_field_tag '', url_for(@order.product) %>
<% end %>
```

Le besoin de l’utilisateur est ainsi satisfait. La solution proposée est extrêmement rudimentaire mais terriblement efficace.

Il est ensuite possible d’utiliser JavaScript pour améliorer l’expérience utilisateur de cette fonctionnalité de base en permettant de réaliser l’opération de sélection du texte et de copie automatiquement.

Le principe consiste à (éventuellement) masquer le texte à copier tout en le laissant dans de code de la page et à ajouter un bouton qui permettra de déclencher la copie dans le presse-papier de l’utilisateur et afficher un message confirmant le bon déroulement de l’opération.

Ainsi lorsque JavaScript n’est pas disponible, le site affichera un texte simple et suggèrera à l’utilisateur de copier le texte avec un message. La fonction restera ainsi accessible. Puis quand le JavaScript, l’utilisateur verra un simple bouton pour copier le texte automatiquement.

Dans cet exemple également, le principe reste le même : on crée une version de base fonctionnelle sans JavaScript et on en améliore l’expérience utilisateur en ajoutant plus d’interactivité grâce à JavaScript. On constante tous les avantages cités précédemment : la fonction est toujours accessible et la version améliorée est réutilisable, facilement maintenable et ne nécessite que peu de code supplémentaire.

# Plus c'est complexe, plus c'est avantageux

L’exemple précédent était extrêmement simple, mais est suffisant pour illustrer l’intérêt de cette approche.

Poussons l’exemple un peu plus loin en y ajoutant des interactions avec le serveur.

Désormais, notre utilisateur va sélectionner un produit de la base de données à partir de son nom (en utilisant la fonction d’autocomplete). Notre utilisateur souhaite ensuite copier le lien permettant d’accéder à ce produit pour l’envoyer par email à un client.

Comme dans le premier exemple, la saisie de l’utilisateur va être envoyée au serveur (via le bouton du formulaire ou bien automatiquement), et le navigateur va récupérer une liste de résultats.

La différence cette fois, est que lorsque l’utilisateur sélectionne un résultat, on veut lui proposer de copier le lien correspondant à ce résultat.

Pour cela on peut utiliser la même approche et ajouter un bouton ‘Afficher le lien’ sur le formulaire pour déclencher l’interaction. Une fois notre produit sélectionner, l’utilisateur pourra activer ce bouton et la page sera rechargée avec le lien du produit que l’utilisateur pourra copier.

Ici aussi, on pourra améliorer l’expérience utilisateur en déclenchant ce comportement automatiquement lors de la sélection du produit. L’utilisateur verra alors un bouton lui permettant de copier le lien dans le presse-papier.

Sans JavaScript, l’utilisateur utilise les boutons du formulaire pour déclencher les comportements interactifs. Avec, les comportements sont déclenchés automatiquement par les actions de l’utilisateurs. L’expérience est ainsi plus naturelle.

On peut noter dans nos approches qu’on ajoute ces boutons dans le formulaire existant. Il est essentiel de procéder ainsi pour que le serveur récupère les informations et qu’au rechargement de la page, la saisie de l’utilisateur soit conservée sur la nouvelle page. Avec JavaScript on peut recharger partiellement la page et contourner le problème, mais sans JavaScript le rechargement de la page sera un passage obligé.

On remarque également que chaque comportement a son propre bouton. Cette approche permet de pourvoir réutiliser et combiner les différents comportements. Cela peut permettre au serveur de s'adapter si nécessaire, autrement l'activation de n'importe quel bouton pourra déclencher l'ensemble des interactions disponibles.

Le fait d’utiliser le processus requête / réponse habituel du navigateur permet aussi de mieux gérer les erreurs. En cas d’erreur serveur ou de problème réseau empêchant de le chargement de la page par exemple un message clair sera affiché au client là où une interaction JavaScript par défaut se contentera de ne pas fonctionner.

Si nous avions eu une autre approche, il nous aurait peut-être paru plus naturel de combiner les comportements en même temps, d’envoyer des requêtes au serveur et d’utiliser une réponse avec un format qui ne pourrait être traité par le navigateur qu’avec du code JavaScript. Finalement, le résultat aurait été moins robuste, moins fiable et plus difficile à maintenir.

Finalement, on peut voir grâce à cet exemple qu’on peut facilement utiliser cette approche pour concevoir des interactivités complexes en ajoutant très peu de code JavaScript sur le navigateur. Mais évidemment, ce qu’on gagne côté client on le perd côté serveur.

Notre formulaire doit en effet répondre à plusieurs besoins fonctionnels :

- Il faut distinguer les différentes actions (autocomplete, affichage du lien, validation définitive).
- Lorsqu’on ne valide par définitivement le formulaire, il faut l’afficher à nouveau tout en conservant la saisie de l’utilisateur sans réellement créer l’objet associé.
- Lorsqu’un produit est sélectionné la page renvoyée par le serveur doit contenir le lien à copier et la configuration permettant l’activation du comportement JavaScript pour la copie dans le presse-papier.

Gérer ces comportements supplémentaires nécessite effectivement des adaptations du serveur. Mais en réalité c’est un moindre mal :

- Les adaptations sont en réalité simple à implémenter, de simples ajouts dans le code de la vue sont suffisants pour transmettre les nouvelles données des différentes interactions.
- Il suffira de re-réhydrater le formulaire avec les paramètres reçus par le serveur pour préserver la saisie.
- En réalité, il n’est pas nécessaire de distinguer les différentes actions individuellement. Il suffit en fait de différencier la validation définitive d’une simple demande d’interaction. On voit que cette approche est facilement généralisable et la quantité de code n’augmente pas avec le nombre de comportement interactifs (on gère tous les comportements interactifs avec une seule modification du contrôleur).
- Une autre approche aurait également nécessité des adaptations côté serveur (par exemple, une API permettant de renvoyer la liste ou le lien à copier). On peut en plus remarquer que les adaptations rendues nécessaires par l’approche d’amélioration progressive sont beaucoup plus génériques et seront donc aussi plus faciles à maintenir.

Cette approche ne dépend pas du type de fonctionnalité et peut donc être facilement généralisée à n’importe quel type de comportement interactif. En plus les fonctionnalités elles-mêmes sont génériques et pourront sans difficulté être réutilisées dans différents contextes et combinées pour fournir une expérience optimale tout en s’adaptant à la qualité de l’environnement de l’utilisateur.

## Conclusion

L'amélioration progressive, bien que n'étant pas un concept nouveau est toujours d'actualité.
Elle permet de concevoir toutes les fonctionnalités dont vous avez besoin à l'aide
des technologies web standard, complétées progressivement avec du JavaScript pour
enrichir l'expérience utilisateur. Même si de nombreux services se lancent sans
se soucier des conditions dégradées que peuvent expérimenter leurs utilisateurs,
notamment mobiles, l'amélioration progressive permet d'atteindre un public plus large
et d'offrir une expérience utilisateur satisfaisante.

Les avantages de cette approche sont multiples. En réduisant la quantité de
JavaScript utilisée, elle conduit à un code plus léger, simple et facile à maintenir.
La maintenance s'en trouve facilitée, car le code JavaScript est également
plus général et réutilisable. Cette méthode offre également une robustesse accrue,
les interactions utilisateur étant plus fiables grâce à l'utilisation des
cycles de requête/réponse standards du navigateur, qui offrent également
une meilleure gestion des erreurs par défaut.

Enfin, bien que l'adoption de l'amélioration progressive nécessite
quelques ajustements côté serveur, ces derniers restent simples et génériques,
favorisant l'évolutivité et la maintenabilité du code. En intégrant ces principes,
les développeurs peuvent concevoir des applications performantes et accessibles.
