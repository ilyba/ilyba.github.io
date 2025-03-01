---
layout: article
title:  "Améliorer la qualité du code de vos applications Web"
date:   2025-03-10 08:00:00 +0100
categories: Ruby Rails Architecture
---

# Introduction

Durant ma carrière de développeur Web, j’ai eu l’occasion de travailler sur de nombreuses applications Web différentes. Jai pu observer comment l’organisation d’une équipe affecte la qualité du code produit et comment cette dernière influence la stabilité d’une application.

# L’importance du facteur humain

Les problématiques que va rencontrer une équipe composée pratiquement exclusivement de développeurs expérimentés ne seront pas les mêmes que ceux qu’une équipe de jeunes développeurs.

Les débutants vont avoir tendance à produire du code peu structuré et passant à côté des bonnes pratiques. Faute de connaître les outils les mieux adaptés, ils vont avoir tendance à en utiliser de peu appropriés. Et faute d’expérience, ils vont avoir tendance à privilégier des solutions incomplètes.

Avec l’expérience, les développeurs vont commencer à gagner en confiance et vont parfois développer des solutions inutilement complexes en utilisant par exemple trop de couches d’abstractions, ou en utilisant des patrons de conception inadaptés.

Finalement, les développeurs les plus expérimentés auront parfois tendance à poser des problèmes d’organisation. Grâce à leur expérience accumulée, ils ont des compétences élevés pour résoudre des problèmes divers. Mais cela peut parfois causer des conflits au moment de choisir une solution technique.

L’ensemble de ces problématiques peut affecter la qualité du code d’une application.

# La structure du code affecte la qualité d’une application

Dans une application, le concept de “structure du code” est en réalité plutôt vague et peux représenter plusieurs concepts. En voici quelques exemples :

- L’organisation des fichiers (leur nom et leur emplacement sur le système de fichiers)
- La manière d’organiser le code dans un fichier (l’ordre des objets de code, leur longueur)
- La manière dont les objets de code interagissent ou sont encapsulés…

La liste n’est pas exhaustive. Je vais me concentrer dans cet article sur l’organisation des fichiers, mais les problématiques et les conséquences sont similaires pour les autres aspects d’organisation du code. En réalité, chacun de ces aspects a un impact sur la qualité de la structure d’une application.

## L’organisation des fichiers

Les fichiers représentants le code et qui, en Ruby contiendront le plus souvent des modules ou des classes. L’utilisation de frameworks comme Rails permet de simplifier cet aspect car une hiérarchisation des fichier de base est prévue avec un dossier `config` pour la configuration, des dossiers `models` , `views` et `controllers` pour la logique MVC, etc.

Pour une application simple, cette hiérarchie est amplement suffisante pour organiser les fichiers. Mais au fur et à mesure que la complexité d’une application augmente, on a de plus en plus de fichiers et ils sont de plus en plus volumineux.

Rails propose le concept de “concerns” (module représentant un aspect d’un objet) pour extraire des fonctionnalités dans des modules qui seront ensuite composés entre eux pour former une entité plus importante. Dit plus simplement, on va éclater le code d’un fichier dans plusieurs fichiers.

C’est souvent là que les problèmes commencent. Car il faut choisir comment faire le découpage : quelles méthodes, macros vont aller dans quels fichiers, en suivant quelle logique. Il faut aussi décider du nom des nouveaux fichiers. Il faut aussi se demander si plutôt que d’accumuler différents modules de `concerns`, il ne serait pas plus pertinent de modifier l’architecture du code en introduisant un nouveau concept, une nouvelle classe.

Et à ces questions, il n’existe pas une réponse unique et idéale. Chaque choix aura ses avantages et ses inconvénients. Certains choix auront des conséquences importantes et il sera opportun de les étudier précisément alors que d’autres seront sans importance et une décision arbitraire sera tout à fait satisfaisante. Mais il n’est pas toujours évident d’anticiper l’avenir pour savoir identifier les décisions seront importantes.

Analysons quelques problèmes de structure et leurs conséquences.

## Quelques problèmes de structure

Le problème le plus évident est l’utilisation de noms peu adaptés pour les fichiers, classes, modules.

Le non respect des conventions pour les nommer (utilisation de conventions différentes de celle du projet ou de celles en vigueur dans la communauté). Par exemple, en Ruby les nom des classes et des modules utilisent CamelCase. Le respect de cette convention partagée dans la communauté Ruby facilite considérablement, la lecture, l’écriture du code et la navigation dans le code. Son non respect n’a pas de grave conséquence, mais cela rendra le travail sur la base de code plus fastidieux. Et il faut prendre en compte que la qualité d’écriture du code n’est jamais idéal dans une application qui contient plusieurs milliers de lignes de code. C’est un problème qui s’ajoutera donc automatiquement à d’autres alors qu’il est très simple à éviter.

Parfois, le choix du nom d’un fichier, d’un objet, d’une méthode, d’une variable peut être fait trop rapidement. C’est un problème assez fréquent car au cours du développement, on passe son temps à créer et donc nommer des objets. Il peut être tentant de de nommer rapidement un objet pour passer à la suite de sa réflection. Mais un mauvais choix de nom peut avoir de graves répercussions. Il va compliquer la lecture et la compréhension du code. Une mauvaise compréhension d’un nom peut entrainer rapidement des bugs importants dans une application. Un objet ne fonctionnant pas comme son nom l’indique peut être mal utilisé par exemple, et le bug ne sera pas toujours évident à détecter.

Lors du découpage d’un objet en plusieurs partie, les problèmes peuvent vite se cumuler :

On peut par facilité ou par négligence utiliser une notion technique alors qu’une notion métier serait plus pertinente. Par exemple, on va mettre les définition d’associations dans un fichier, les validations dans un autre. On va extraire tous les callbacks, les filtres, etc. Généralement il est plus pertinent d’identifier des aspects et de regrouper dans un fichier tout ce qui concerne cet aspect donné (un module la facturation, un autre pour la gestion du processus, encore un pour les adresses, un pour les données du client, etc.). Ce type de problème sera gênant à la lecture mais va aussi complexifier les modifications du code qui s’étaleront alors sur plusieurs fichiers.

On peut aussi introduire inutilement des abstractions et des objets intermédiaires. Cela va causer des indirections, et pour suivre le cheminement du code, il faudra naviguer dans plusieurs fichiers au risque de se perdre. La lecture sera plus complexe, et il sera aussi dans certains cas plus difficile de modifier le code correspondant.

Les problèmes de structure peuvent parfois être plus profonds. On peut utiliser des logiques complexes et technique qui va complexifier l’utilisation du code. Par exemple, en utilisant un dossier `services` ou `operations` en plus du dossier `models` et en mettant la logique métier dans les deux dossiers. La création de tels dossiers n’est pas un problème en soi mais le reste de la base de code doit être cohérent. Autrement, encore une fois le code sera plus difficile à lire et à modifier. Lorsque de mauvaises pratiques sont ancrées profondément dans le code, remettre le code en ordre peut être extrêmement long et difficile.

De la même manière mettre de la logique métier dans les helpers, les vues ou les contrôleurs pose le même type de problème. Le fait de regrouper toute la logique métier d’un concept au même endroit est essentiel pour qu’une application puisse être facilement maintenue.

# L’importance de suivre les bonnes pratiques

Nous avons vu comment les problèmes de structure peuvent influer sur la qualité du code et causer des bugs. Le suivi des bonnes pratiques au quotidien est également important.

## L’utilisation et le respect du linter

La majorité des bonnes pratiques peuvent êtres simplement respectées en utilisant un linter (outil d’analyse de code).

Pour ruby, rubocop est conseillé. Personnellement, l’active toutes les politiques et j’utilise autant que possible les paramètres par défaut.

Au départ, cela peut paraitre fastidieux et vain de respecter certaines des contraintes (méthodes de 10 lignes maximum, longueur de ligne limitée, nombre le ligne maximum d’un module, etc). Du coup, les développeurs sont souvent tentés de considérer que le non respect de la règle est justifié dans leur cas. Parmi les excuses les plus fréquentes :

- Le code est quand même suffisamment lisible
- Ça ne dérange personne
- Il n’y a pas de bug dans ce cas
- Il n’y a pas de problème de sécurité dans ce cas
- Ne pas respecter la règle a un avantage significatif ici
- etc.

À mon avis, il est souvent plus important que la règle soit appliquée de manière homogène. En effet, même si le non respect de la règle n’est pas un problème, il est souvent tout de même possible de la respecter. La plupart du temps, le code est meilleur après modification. Dans certains cas, il arrive qu’il soit effectivement moins bon. Même dans ces cas, la plupart du temps, le code est un peu moins bon (peut-être un peu moins lisible par exemple), mais c’est compensé par plusieurs avantages :

- Une exception au respect d’une règle pourra inciter d’autres développeurs à ne pas la respecter (ou même à ne pas respecter en général les règles du linter). Cela aura pour conséquence un code moins homogène au mieux, et au pire causera des bugs dans l’application, des problèmes de lisibilité, etc. Éviter cela est un avantage certain.
- Le code sera globalement plus homogène et donc plus confortable à lire, même si cela se fait ponctuellement au prix d’un code parfois un peu moins lisible.

Pour ces raisons, l’utilisation d’un linter et son respect participent grandement à la qualité du code.

Naturellement, dans certains cas, on préfèrera modifier les paramètres du linter, que ce soit par préférence ou parce qu’une règle spécifique n’apporte pas de bénéfice suffisant au vu de la contrainte.

## Les autres bonnes pratiques

Les autres bonnes pratiques sont importantes à suivre. Un développeur expérimenté en connaitre et en maitrisera plus qu’un développeur débutant.

C’est pour cela que la relecture du code par un développeur plus expérimenté est important pour garantir une bonne qualité du code.

Les bonnes pratiques les plus importantes pour moi sont :

- SRP - Single Responsibility Principle : Le principe de responsabilité unique. Chaque objet de code doit se concentrer sur un seul aspect à la fois.
- KISS - Keep It Simple and Stupid : Garder le code simple et stupide. C’est à dire qu’une solution simple et directe sera préférable à une solution complexe.
- YAGNI - You Are not Gonna Need It : Tu n’en n’auras pas besoin. C’est un peu le pendant de KISS, si une fonctionnalité ou une abstraction, gérer de manière complexe une erreur qui n’arrivera pas, n’est pas nécessaire maintenant, il est inutile de la développer avant d’en avoir réellement le besoin.

Ces bonnes pratiques entrent parfois en contradiction les unes avec les autres, et il faut alors choisir laquelle privilégier.

Le respect des bonnes pratiques impacte énormément la qualité du code :

- Ici aussi, la lecture du code sera plus facile
- La quantité de code produite sera aussi réduire que possible, ce qui apportera des avantages en terme de productivité.
- L’évolution du code en est facilitée car le code aura le bon niveau de complexité.
- La maintenance est plus facile en raison de la simplicité et de la densité du code, et de la limitation des embranchements.
- Pour les mêmes raisons, cela limitera le nombre de bugs.

# Bien choisir ses outils

Un bon choix d’outil est également important pour la qualité du code. Le choix doit toujours se faire en fonction du contexte particulier de votre application. Un bon outil dans une application ne l’est pas forcément dans une autre.

Voici quelques critères importants pour choisir un outil :

- L’organisation et le niveau général de l’équipe. Un outil pourra être adapté à une organisation particulière et pourra être efficace avec des développeurs d’une certaine expérience. Mais il pourra être en revanche contre productif dans une autre organisation. Par exemple pour des besoins simples avec une équipe peu expérimentée, il faudra privilégier des outils simples même si peu performants à des outils complexes et avec une utilisation peu intuitive.
- La maintenance et la popularité : il sera souvent préférable de choisir un outil bien maintenu et populaire plutôt qu’un outil parfaitement adapté mais peu connu et peu maintenu. Bien entendu il sera tout à fait envisageable de porter son choix sur un outil extrêmement adapté et peu populaire à condition d’être prêt à le modifier soi-même pour l’adapter ou corriger des problèmes.
- La licence : c’est un aspect souvent négligé, mais vérifier les licences des outils utilisés est un critère important pour éviter tout problème juridique, en particulier si votre application devient populaire.

# Évitons de prendre trop de raccourcis

Une erreur fréquente dans le développement de fonctionnalités complexe et d’appliquer un peu trop grossièrement le principe KISS.

Il est évidemment essentiel de conserver un code simple, mais il est tout aussi important d’anticiper l’utilisation d’une fonctionnalité.

Dans la pratique, les développeurs doivent réaliser une fonctionnalité en répondant à un cahier des charges qui prend généralement la forme d’un document de spécification.

Dans les entreprises où j’ai travaillé, on utilise des méthodes dites “agile”. En pratique, cela signifie qu’on souhaite diminuer autant que possible le temps entre la spécification d’une idée et sa livraison, quitte à revenir dessus régulièrement si le besoin réel ne correspond pas exactement au besoin exprimé.

La conséquence est que malgré le soin apporté à la rédaction des spécifications. Il y a souvent de nombreux trous. Personnellement, je choisis souvent de concentrer l’effort de spécification sur le besoin principal. Cela se fait souvent au détriment de spécification technique détaillées ou des cas d’utilisation secondaire. Ces aspects sont alors laissés à la responsabilité de la suite de la chaîne de développement, c’est à dire : le développeur de la fonctionnalité, le développeur assigné à la relecture et l’équipe d’assurance qualité.

Un développeur peut alors facilement négliger la prise en compte des cas d’erreur par exemple ou ne pas anticiper des cas d’utilisation alternatif et livrer une fonctionnalité en pratique.

Bien entendu, il serait tout à fait possible de limiter ces inconvénients avec des spécifications techniques plus détaillées, mais cela augmenterait significativement le temps nécessaire pour analyser le code, les besoins, l’utilisation et la rédaction. Le temps passé à rédiger augmenterait, et la capacité à exprimer les besoins en spécification, et donc la capacité de développement diminuerait. Et cela ne garantirait pas pour autant la prise en compte de tous les aspects.

Pour éviter cela, il est essentiel que les développeurs comprennent le contexte d’utilisation d’une fonctionnalité. Grâce à leur connaissance précise du fonctionnement de l’application, ils sont en effet en mesure de préciser le besoin technique. Par exemple, ils peuvent facilement voir si un embranchement est inexistant dans le code et se poser la question de la nécessité de le créer ou non, ou bien se rendre compte qu’un cas d’erreur n’est pas traité dans la spécification.

En évitant d’appliquer une spécification à la lettre et en n’hésitant pas à la remettre en question, il est possible d’éviter des bugs et donc de contribuer à l’amélioration de la qualité de l’application. Mais en plus cela permet d’éviter des aller retours, des étapes de développement et ainsi d’améliorer la productivité de l’équipe.

# Le code “sur-ingénieré” (over-engineered)

C’est un peu la contrepartie du cas précédent. Lors du développement d’une fonctionnalité complexe, une développeur voudra sur-anticiper certains aspects et amener des abstractions inutiles. Ces abstractions vont rendre le code plus difficile à lire et à maintenir.

Ce type de code est souvent difficile à détecter à la relecture.

Mais il existe tout de même quelques approches possibles. En voici une :

À la relecture, il est facile d’identifier un code qui a une approche un peu atypique. Si cette approche est en plus complexe, il est alors essentiel d’essayer de la remettre en question.

Pour cela, on pourra par exemple tenter de partir d’une page blanche d’imaginer l’architecture du code qu’on aurait utilisé pour développer la fonctionnalité.

Il est probable que la solution imaginée sera simpliste car le relecteur n’aura pas tous les détails en tête. Il faudra ensuite comparer l’architecture avec celle choisie. Si le choix d’architecture est significativement plus simple que celui du code relu, une discussion avec le développeur permettra facilement de déterminer si la complexité supplémentaire est utile ou non.

Les impacts de ce type de problème sont très important sur la maintenance et l’évolution d’une application. Et il est bien souvent très compliqué de revenir en arrière même seulement quelques mois après. Il est donc extrêmement important de les détecter et de les éliminer en amont pour éviter d’avoir à les maintenir plus tard.

# Les conflits entre développeurs

Avec l’expérience, les développeurs prennent des habitudes. Mais dans le développement, plusieurs solutions sont souvent équivalentes.

Il est alors fréquent que les développeurs expérimentés souhaitent mettre en place une solution qui a fonctionné pour eux.

Dans certains cas, cela implique de remettre en question des choix qui ont déjà été faits avant l’arrivée du développeur. Parfois cela concerne de nouvelles fonctionnalités.

La plupart du temps, ça cause des débats entre développeurs qui prennent du temps et peuvent même parfois affecter l’ambiance dans l’équipe.

Il est important de ne pas négliger ces débats, car même si techniquement, les choix techniques ne sont pas forcément très importants, l’impact humain peut en revanche être considérable.

Il est alors important que les développeurs comprennent qu’un choix technique qui leur semble inférieur n’est pas forcément un problème et n’aura pas de conséquence importante.

D’un autre côté ces solutions alternatives peuvent parfois apporter un réel bénéfice, et ce bénéfice potentiel ne doit pas être négligé. Il doit bien sûr être considéré en regard de l’effort nécessaire pour le mettre en place. Une solution significativement supérieure devra malheureusement être écartée au profit de la solution en place même inférieure, quand l’effort pour la mettre en place est plus important que le bénéfice espéré.

Cependant, le choix pourra être à nouveau fait à l’occasion d’une éventuelle réécriture de la fonctionnalité en question ou bien en raison de l’évolution de l’application ou de l’équipe.

En général, ce type de conflit n’impacte pas directement la qualité du code. Mais si le conflit n’est pas traité, on peut se retrouver avec plusieurs solutions en concurrence dans l’application. Cela pose bien évidemment des problèmes de maintenance.

# Conclusion

En somme, la qualité du code et la stabilité d’une application sont des enjeux directement influencés par l’organisation de l’équipe, le respect des bonnes pratiques et la gestion des choix techniques. Les problèmes de structure, qu'ils concernent l'organisation des fichiers ou les décisions architecturales, peuvent avoir des répercussions importantes sur la lisibilité, la maintenabilité et l’évolution du code. Il est essentiel pour une équipe de bien comprendre l'impact de chaque décision, de privilégier la simplicité, et de respecter les normes et bonnes pratiques qui facilitent le travail collectif.

Le facteur humain, notamment les différences d’expérience entre les développeurs, joue également un rôle clé dans la manière dont le code est écrit et maintenu. La communication au sein de l’équipe et une gestion proactive des conflits sont indispensables pour éviter que des divergences de vues n'affectent la qualité globale du projet. En gardant ces principes à l’esprit et en choisissant les bons outils et méthodologies, il devient possible de produire un code robuste, évolutif et facile à maintenir, qui résiste à l’épreuve du temps tout en permettant à l’équipe de progresser dans un environnement harmonieux et productif.
