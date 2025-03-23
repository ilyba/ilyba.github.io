---
layout: article
title:  "Quels critères pour mesurer et garantir la qualité de votre code ?"
date:   2025-03-31 08:00:00 +0100
categories: Bonnes-Pratiques Ruby Rails Architecture Développement
---

# Introduction

Au cours de ma carrière, j’ai constaté une différence majeure entre les développeurs débutants et les développeurs expérimentés dans leur manière d’appréhender l’écriture du code et la qualité. Les premiers se concentrent sur un objectif précis, tandis que les seconds ont une approche plus globale prenant en compte davantage de paramètres différents.

Dans cet article, je vais vous expliquer comment améliorer la qualité de vos développements grâce à une approche globale et en utilisant des critères mesurables.

# L’approche globale

En début de carrière, la préoccupation principale est de produire un code qui permet d’obtenir le résultat principal attendu. C’est logique, mais en réalité, obtenir le résultat attendu n’est pas aussi important qu’on pourrait le penser. C’est même plutôt secondaire…

En effet, il est plutôt habituel que la première version d’un code ne fonctionne pas correctement. Même s’il faudra bien rendre le code fonctionnel avant de le livrer, ce n’est pas ce qu’il y a de plus difficile à corriger.

En revanche, si le premier jet d’un code présente des problèmes structurels, utilise des noms de variables ou de méthodes peu explicites et ne respecte pas les bonnes pratiques il est très probable que cela posera des problèmes par la suite.

C’est pour ça qu’un développeur expérimenté consacrera davantage d’efforts à vérifier, confirmer et remettre en question certains détails des spécifications, s’assurer que leur rédaction correspond bien à la manière la plus efficace de répondre au besoin. Puis, il explore différentes approches techniques, choisit la plus adaptée et réfléchit à l’architecture du code, à la nomenclature des concepts, aux différents cas d’utilisation, aux effets de bord d’une solution sur les autres parties de l’application ainsi qu’aux cas d’erreurs, etc. Et cette liste est loin d’être exhaustive…

C’est seulement une fois la réflexion sur ces aspects terminée qu’il se concentrera sur l’aspect purement fonctionnel du code.

L’avantage de cette approche est de produire un code qui sera plus facile à maintenir dans le temps. Cet avantage a une contrepartie : l’effort fourni et le temps de développement seront plus importants. C’est un inconvénient à court terme qui ne sera compensé qu’à long terme car la prise en compte de tous ces aspects permet de réduire le risque de bugs, un code bien structuré avec une nomenclature claire et pertinente facilite la lecture, l’utilisation d’un niveau d’abstraction adéquat facilite la modification et l’ajout de nouvelles fonctionnalités.

Autrement dit, même s’il est plus rapide de foncer tête baissée dans le code, cette approche se paye plus tard avec des bugs, des problèmes de performances et une application difficile à faire évoluer.

Mais qu’est-ce qui déterminera si un code sera facile à maintenir ou non ?

# La phase de spécification

Concentrons-nous à nouveau sur la phase de spécification. Ces documents sont parfois négligés, perçus comme une étape chronophage du développement apportant peu de valeur.

Pourtant, une spécification bien rédigée permet d’éviter :

- **Une livraison non conforme.** Pour illustrer, on peut imaginer qu’à cause d’une formulation peu claire, le développeur ne l’aura pas interprété comme l’auteur du document. Une autre possibilité est que le document soit tellement long et complexe que le développeur en omette certains détails.
- **Une livraison conforme mais qui ne correspond pas aux besoins réels.** On peut penser à un mauvais choix d’interface.
- **Des problèmes techniques de conception ou de performance.** Même pour une spécification fonctionnelle, si les besoins futurs ne sont pas anticipés par exemple, les choix d’architectures peuvent être affectés et poser problème par la suite.

Pour bien rédiger une spécification, une expérience solide est bien évidemment utile, mais se révèlera souvent insuffisante. Il est essentiel que le document soit relu et discuté avec les donneurs d’ordre ainsi que par l’équipe technique. Si ces discussions sont bien prises en compte, cela aura un impact majeur sur la qualité des développements.

Dans mon expérience, j’ai toujours constaté la même tendance : au départ les spécifications sont négligées et au bout d’un certain temps passé à jongler avec les bugs, les contradictions (quand une modification casse une autre fonction ou un cas d’utilisation), des efforts sont faits pour rédiger des spécifications de meilleure qualité (recrutement d’un product owner, ajout de processus de relecture, etc.). Et systématiquement, on constate des améliorations substantielles même si cela ne suffit pas à résoudre tous les problèmes.

## Conseils pour la rédaction d’une spécification

Pour rédiger une bonne spécification, ma méthode a beaucoup évolué avec le temps. Il n’y a pas de méthode universelle. Certains trouveront cette méthode trop lourde, d’autres pas suffisamment poussée. Tout dépend du prix que vous êtes prêt à mettre ou des conséquences que vous êtes prêts à supporter selon le point de vue. J’utilise principalement deux formats : les user stories et les rapports de bugs. La grande majorité des tâches peut être rédigée dans au moins l’un de ces deux formats.

## User Story

Tout d’abord, le titre doit être clair et bien préciser les éléments suivants :

- **L’acteur :** l’acteur est le principal bénéficiaire du développement
- **Une action :** l’objet principal du développement.
- **Un objectif / bénéfice :** Ce que permet la réalisation de l’action. Cela peut correspondre au bénéfice que l’acteur retire de l’action par exemple. Souvent négligé, il est pourtant essentiel pour confirmer l’utilité d’un développement. Si l’objectif est difficile à formuler, il est possible dans certains cas que ce soit parce que la fonctionnalité ne présente pas d’intérêt.

Voici le modèle que j’utilise : En tant que **<acteur>**, je veux **<action>** afin de **<objectif>**.

Exemple : En tant que **client**, je veux **consulter la liste de mes commandes** afin de **connaître l’historique de mes achats et désengorger le support client**.

Ensuite, je divise la rédaction en trois sections :

- **Un contexte :** Quelques phrases qui précisent la raison d’être de la spécification. Pour la rédiger on peut décrire la situation actuelle et la problématique à résoudre.
Pour reprendre l’exemple précédent : Le support client reçoit de nombreuses demandes de clients qui souhaitent connaître l’historique de leurs commandes mais cette fonctionnalité n’existe pas dans notre application.
- **Une description :** c’est le cœur de la description où l’on va décrire avec le plus précisément possible le résultat attendu. Selon les projets et l’expérience des développeurs, cette section pourra également contenir certains détails d’implémentation si on souhaite les figer, mais personnellement, je préfère laisser la majorité du temps le plus d’autonomie possible aux développeurs sur les détails techniques.
- **Des critères d’acceptation :** cette section est essentielle. C’est parfois une reformulation de la description. Elle permet au développeur de confirmer la bonne compréhension de la spécification et d’avoir une liste de critères permettant d’éviter des refus de l’équipe qualité au moment de la livraison. Et elle permet à l’équipe qualité d’avoir une base de travail sur laquelle s’appuyer pour valider ou non une fonctionnalité.

Sur toutes les tâches, en plus de ces sections, j’associe un niveau de priorité.

## Rapport de bug

Un bon rapport de bug permet d’éviter les incompréhensions qui retardent la correction des problèmes.

Le titre doit être une description succincte et précise du problème.

Par exemple : Sur la page principale, appuyer sur la touche Entrée ne déclenche pas la recherche.

Lors de la rédaction, il peut être tentant, sous l’effet de la frustration, d’utiliser le terme 'Régression'. Pourtant, je recommande vivement de l’éviter à moins de documenter précisément cet état de fait dans le rapport (avec un test identique sur deux versions différentes de l’application par exemple). En effet, bien souvent, ce qualificatif se révèle incorrect ou bien à nuancer, tout en envoyant un message négatif à l’équipe de développement : “vous avez encore cassé un truc”. Ce qui dégrade inutilement l’ambiance de travail.

Mon conseil : même en cas de régression avérée, évitez de mettre ce terme dans le titre, et ajoutez plutôt les détails dans le corps du texte. Vous pouvez en revanche attribuer des niveaux de priorité différents sur vos tickets.

Le corps du rapport se compose de trois parties :

- **La procédure de reproduction.** Une liste d’étape très précise permettant de reproduire le problème.
- **Le résultat attendu.**
- **Le résultat observé.**

# La phase de développement

Lors de la phase de développement, voici quelques conseils pour améliorer la qualité de vos productions :

- Comme vu plus tôt, ayez une approche globale. Essayez de penser à tous les aspects de la fonctionnalité et ne vous focalisez pas uniquement sur l’objectif. Pensez aux impacts sur les autres fonctionnalités, sur les évolutions futures, sur la lisibilité, sur la maintenance, etc.
- Prenez le temps de réfléchir à la structure de votre code. Posez-vous la question de la nécessité de simplifier ou au contraire ajouter des niveaux d’abstractions supplémentaires.
- Appliquez autant que possible les bonnes pratiques, notamment les principes KISS (*Keep It Simple and Stupid* - Gardez votre code simple et stupide), YAGNI (*You Are not Gonna Need It* - Vous n’en aurez pas besoin), SRP (*Single Responsibility Principle* - Principe de responsabilité unique), DRY (*Do not Repeat Yourself* - Ne vous répétez pas), ne pas réinventer la roue ([sauf si vous voulez en apprendre d'avantage sur les roues](https://blog.codinghorror.com/dont-reinvent-the-wheel-unless-you-plan-on-learning-more-about-wheels/) ou sauf si les roues sont mal adaptées), etc.
- Prenez en compte les aspects de performance et d’optimisation. Est-ce que les requêtes SQL sont performantes ? Est-ce qu’il y a des problèmes algorithmiques ?
- Considérez également la documentation. Elle n’est pas toujours nécessaire, mais quand elle l’est il faut la rédiger. Et quand elle existe, il faut la maintenir à jour.
- Utilisez un linter pour homogénéiser votre base de code et éviter certains problèmes structurels (code trop complexe, non respect de certaines bonnes pratiques, etc.). Personnellement, j’utilise Rubocop avec toutes les règles par défaut et erb-lint en activant la majorité des règles optionnelles.
- Ajoutez des tests automatisés et pour les correctifs de bugs, écrivez des tests de non régressions.

# Indicateurs pour mesurer la qualité des développements

Vous connaissez maintenant mes conseils pour améliorer vos spécifications et vos développements. Mais ce qui a fonctionné pour moi pourrait ne pas fonctionner pour vous. Heureusement, il n’est pas nécessaire d’appliquer tout ça aveuglément. Nous allons maintenant nous pencher sur les critères à utiliser pour mesurer l’évolution de la qualité dans votre environnement.

La mise en place de ces conseils peut impliquer un certain effort. Il sera difficile de faire la part des choses entre la part évolutions dues aux modifications de vos processus et la part dues à d’autres facteurs (la montée en compétence de votre équipe, des évolutions dans d’autres processus, etc.). Le suivi de quelques indicateurs ne suffira pas à identifier précisément les mesures les plus efficaces, mais il vous aidera à évaluer votre progression et à ajuster vos décisions en conséquence.

Voici quelques indicateurs dont vous pouvez suivre l’évolution pour déterminer la qualité de vos développements :

- Le nombre d’erreurs dans votre application
- Le nombre de tâches livrées par unité de temps (n’utilisez jamais directement les points Scrum pour ça, le nombre de tâche est un critère plus fiable et qui n’a pas d’effet de bord indésirable).
- La distribution des points Scrum (la proportion des tâches d’un nombre de points donnés par rapport aux autres). Cet indicateur permet d’éclairer le précédent (si le nombre de tâches livrées augmente mais que votre équipe a tendance à découper plus finement les sujets, ça n’indique pas nécessairement une augmentation de la productivité).
- Le nombre de révisions de code pendant la phase de relecture.
- Le nombre de révisions de code pendant la phase de QA.
- Le nombre de dépendances non à jour.
- Le nombre de dépendances totales dans l’application.
- Le nombre de tickets de bugs créés par unité de temps.
- Le nombre de tickets urgents créés par unité de temps.
- Le nombre de tâches techniques sans valeur métier (refactorisation de code, etc.) par unité de temps. Cela ne prend pas en compte les tâches classiques de maintenance comme la mise à jour des dépendances.
- La proportion de ces tickets par rapport à la charge globale, notamment par rapport aux tickets demandés par le métier.
- Le nombre de tickets (ou/et de points Scrum) en phase de spécification
- Le nombre de tickets (ou/et de points Scrum) en attente de développement
- Le nombre de tickets (ou/et de points Scrum) en cours de développement
- La couverture du code par les tests automatisés
- Le ratio de code de test par rapport au code de l’application

Personnellement, je ne suis pas pour le moment ces indicateurs de façon automatisée, mais j’en ai une vision subjective et j’en tiens compte lors de mes prises de décisions et je les utilise pour justifier certains choix.

Ces indicateurs ne permettent pas directement de dire si votre code est de bonne qualité ou pas, mais en suivant leur évolution, il est facile de savoir si la qualité s’améliore ou se dégrade.

# Conclusion

Une bonne qualité de développement ne se résume pas simplement à produire un code fonctionnel. Elle repose sur une approche globale, prenant en compte la clarté des spécifications, la structure du code, la maintenabilité et l'anticipation des évolutions futures. Bien que cette démarche demande un investissement initial plus important, elle permet de réduire les erreurs, d'améliorer la productivité sur le long terme et de faciliter la collaboration au sein des équipes.

En combinant une rédaction rigoureuse des spécifications, une phase de développement réfléchie et un suivi d'indicateurs pertinents, vous serez en mesure d'améliorer progressivement la qualité de vos projets. L'objectif n'est pas d'atteindre une perfection absolue (c’est illusoire), mais d'adopter une démarche itérative et mesurable permettant des ajustements continus. Au final, un code de qualité ne profite pas seulement aux développeurs, mais aussi aux utilisateurs et à l’ensemble de l’entreprise.
