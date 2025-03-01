---
layout: article
title:  "ActiveRecord vs Repository : comprendre leurs différences"
date:   2025-03-02 08:00:00 +0100
categories: Ruby Rails Architecture
---

# Introduction

Je vais vous parler d’un cas d’école vu et revu. Tous les développeurs et développeuses Rails sont confronté(e)s plutôt tôt que tard à la nécessité d’envoyer un email après avoir fait une opération en base de données. Typiquement, envoyer un email de bienvenue à un utilisateur après son inscription au service. Cependant, cette tâche simple peut vite se compliquer, surtout lorsque cela implique des callbacks ActiveRecord, des transactions en base de données et des files d’attentes…

Le décor est posé pour illustrer la confusion qui put être faite avec Ruby on Rails entre les patterns ActiveRecord et Repository.

# Mise en situation

La situation est tout à fait banale : l’inscription d’un utilisateur correspond à la création d’une ligne dans la table users de la base de données. Si on utilise le vocabulaire d’ActiveRecord, on dira simplement qu’on va créer un nouvel utilisateur.

Et ça tombe bien, notre développeur ou développeuse n’a peut-être pas beaucoup d’expérience, mais a bien étudié et sait que dans ActiveRecord on a un callback appelé `after_create` et on veut justement envoyer un email après la création de l’utilisateur.

Notre apprenti dev a également  appris que l’envoi des emails doit se faire en utilisant une file d’attente et utilise donc Sidekiq, Good Job ou Solid Queue.

Ni une ni deux, en 5 minutes, notre dev met en place l’envoi de l’email après la création… Ça semble fonctionner, mais il y a un hic… Ça ne fonctionne pas à tous les coups, c’est très instable : dès fois le mail part, dès fois non.

# Analyse du problème

Pour comprendre ce qui se passe, notre junior doit comprendre comment les transactions interviennent ici.

Rails utilise les transactions pour les opérations en base de données (un `save`). Cela signifie que si une erreur survient pendant la création d’un utilisateur, toute la transaction (insertion dans la table `users` et autres actions associées) est annulée et rien n’est modifié dans la base de données. Si tout s’est bien passé, Rails valide la transaction et toutes les tables sont modifiées en même temps.

Et c’est là que le problème arrive. Notre app utilise le callback `after_create` pour ajouter l’envoi du mail à la file d’attente et ce callback intervient avant la fin de la transaction. Quand l’envoi de mail est mis en file d'attente, la transaction n’est pas encore terminée. Lorsque le job d'envoi d'email est lancé, la transaction n'est pas pas obligatoirement validée, et l'utilisateur n'est alors pas encore complètement créé dans la base de données. Cela provoque l'erreur de récupération de l'utilisateur, car ce dernier n'est pas encore visible dans la base de données pendant l'exécution du job.

# Le mauvais conseil du senior

Evidemment, notre junior ne comprenant pas ce qui se passe et va voir un senior qui va lui dire: "Malheureux, tu as utilisé les callbacks, c’est le mal, sois damné pour l’éternité!"

Notre junior est plus confus, pourquoi il y a des callbacks dans Rails si on n’a pas le droit de les utiliser ?

« Mais tu n’as rien compris à la séparation des responsabilité. ActiveRecord c’est la base de données, tu ne peux pas l’utiliser pour envoyer des mails, pour ça tu dois utiliser un service. Et surtout n’appelle pas ton service avec ActiveRecord, utilise ton contrôleur. Mais comme ça va salir ton contrôleur, utilise donc dry-transaction[^1]. »

Et notre dev junior se retrouve alors avec une semaine de travail pour envoyer son email.

Notre senior ne pensait pas à mal, mais cela ne résout pas le vrai problème et complique inutilement la situation.

# Distribuons les mauvais points

Alors dans cette histoire, notre dev senior a tort. Il n’a pas tort de vouloir vanter les mérites de l’écosystème dry, de la séparation des responsabilité, de séparer le code de la DB du code lié aux services externes mais il a tout a fait tort d’imposer ça à notre dev junior.

L’erreur du dev senior vient d’une confusion : le problème de notre junior n’est pas lié à l’utilisation des callbacks. En effet, ce callback n’aurait jamais posé problème si l’envoi de mail n’était pas fait dans un job. Le job n’est pas non plus le problème, tout se passerait bien si le job était déclenché après la transaction.

C’est d’ailleurs ce que notre junior doit faire ici : remplacer son `after_commit` par un `after_create_commit`. Dans ce cas, l'envoi de mail partira après la fin de la transaction, ce qui résoudra le problème. Notre junior pourra à cette occasion approfondir ses connaissances sur le fonctionnement interne des callbacks, leur ordre, et les interactions avec les transactions de base de données.

En l’occurrence et c’est le conseil que notre senior aurait du donner en premier quitte à digresser et poursuivre ensuite sur des points d’architecture plutôt que d’utiliser un argument au mieux incorrect, au pire fallacieux pour imposer sa manière de travailler et chercher à se rassurer sur ses propres décisions d’architecture logicielle. En faisant cela, il n’aide pas notre junior, et au lieu de résoudre son problème, il le contourne.

Cependant la solution du senior fonctionne également, même si elle est plus couteuse à mettre en place.

# ActiveRecord n’est pas le pattern Repository

Une autre confusion faite par notre senior c’est qu’ActiveRecord n’est pas le pattern repository.

Si on reprend la définition d’ActiveRecord, la classe ActiveRecord est destinée à encapsuler les données et la logique métier. Or, l’envoi d’email fait tout à fait partie de la logique métier et dans ce pattern il est tout à fait légitime qu’il soit déclenché par ActiveRecord.

Dans le pattern Repository, ce n’est pas le cas, la responsabilité d’une classe Repository est uniquement de communiquer avec la base de données et ne doit donc contenir aucune logique métier. Dans Rails, il est possible d'utiliser ActiveRecord avec le pattern Repository, mais cela nécessitera de se passer d’un bon nombre de fonctionnalités d’ActiveRecord (et cela comprend probablement les callbacks).

Mais c’est un choix d’architecture. Il n’y a pas qu’une seule manière de faire. Et chaque choix à ses conséquences, ses avantages et ses inconvénients. Et c'est bien sûr aussi une question de préférence personnelle.

Pour moi, l’avantage principal d’ActiveRecord est la lisibilité du code, le côté magique magique qui n’est en fait que de la complexité masquée (pour demander à un chien d’aboyer, on écrit `dog.bark!` et pas `DogBarker.new(AnimalFactory.create(:dog, DogAttributeValidator.validate(dog_attributes)).call` par exemple, et ce même si l’action implique d’appeler un service externe ou je ne sais quoi, les détails d’implémentation sont masqués.

Mais il y a un prix à payer pour avoir cet avantage. Et ceux qui ne sont pas prêts à en payer le prix peuvent tout à fait choisir une autre architecture. Mais ils ne doivent pas se sentir obligés d’imposer leur décision à tout le monde pour se rassurer sur leurs propres décisions.

Laissons donc notre junior faire ses propres choix d’architecture, de peser le pour et le contre.

# Conclusion

Chaque choix d’architecture a ses propres défauts. ActiveRecord a les siens, mais les callbacks sont un outil puissant et je trouve dommage de décourager les dev juniors de les utiliser au lieu de les inciter à en comprendre leur fonctionnement pour les utiliser correctement pour les maîtriser.

Dans nos débats, utilisons les arguments, restons factuels, pragmatiques, ouverts et courtois. Et n’utilisez pas d’homme de paille comme je l’ai fait ici…

[^1]: L'outil dry-transaction est une approche qui permet d'encapsuler des étapes métier dans des objets distincts, ce qui permet de mieux structurer le code en séparant les responsabilités. Cependant, pour des raisons de cohérence, son utilisation impliquera de convertir tout le code de l'application à cette approche ainsi que la formation de l'équipe de développement.
