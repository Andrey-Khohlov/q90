# Coffee Domain Description
## Основной пользователь 
конечные $\color{#7CFC00}  потребители (Users)$ кофе. 
- получают информацию о $\color{Green}новинки$ кофе через $\color{#7CFC00}подписки (Subscriptions)$ на сообщения под обзорами, новинки кофейков от обжарщиков, фермеров, сортов, зеленки. 
- смотрят $\color{#7CFC00}рейтинги (Ratings): 
кофе (Coffee), зеленки (Beans), обжарщиков (Roaster), фермеров (Farmer), сортов (Variety), обработка (ProcessingMethod)$
- входят в $\color{yellow}группы$ по общим взглядам на кофе.
- исследуют кофе, для этого ведут $\color{#7CFC00}дневник.заварок (BrewNotes)$.
- делают $\color{yellow}заказы$ кофе.
- делится впечатлением: ставят $\color{#7CFC00}оценки (Ratings)$ по трем шкалам 3,5,10,100,Q100, пишут $\color{#7CFC00}обзоры (Reviews)$ на кофе с 
    * $\color{#7CFC00}рецептами (Recipe)$, 
    * $\color{#7CFC00}водой (Water)$, 
    * $\color{#7CFC00}оборудованием (Equipment)$, 
    * $\color{yellow}помолом$, 
- видят $\color{#7CFC00}прослеживаемость (Geography)$ кофе $\color{#7CFC00}  обжарщик-импортер-экспортер-фермер$
- обсуждают, пишут $\color{#7CFC00}сообщения (Messages)$
- $\color{#7CFC00}модерируют. данные (Moderation)$
- $\color{#7CFC00}модерируют. сообщения (Moderation)$
- $\color{#7CFC00}сообщают (Report)$ о проблемах с сообщениями и данными

## Обжарщик, фермер.
- получает обратную связь в виде отзывов и оценок
- смотрит тренды потребления в виде $\color{#7CFC00}количества. оценок (Ratings)$

# Anchors
## Actor
* User +
* Roaster +
* Farmer (Cooperative/Mill) + 
* Importer +
* Exporter +
## Product
* Beans +
* Coffee +
* Variety +
* ProcessingMethod +
## Social
* Group
* Subscriptions +
    - key: User - Coffee (Green_coffee, Farmer, Roaster, Processing, Variety), User_messages, User_reviews
* Messages +
* Ratings +
* Reviews (BrewNotes, Message) - Это события, связывающие пользователя и кофе. Это классические Ties (связи), которые могут иметь свои атрибуты (текст, число).
* BrewNotes (Recipe, Equipment, GrindSize...) +
* Recipe
## Equipment +
* Brewer +
* Grinder +
* Water +
* Filter +
## Geography +
* World_part
* Country
* Region
* City/locality
* Farm
# Metha-data and Moderation
* RatingScale
* WheelFlavours
* Tags
* Moderation +
* Report +
* Localization


# Что не стало якорами?
* группы - не делаем, нет смысла
* заказы - не целевое, можно будет добавить через внешний сервис
* помол - атрибут
* новинки - Это просто состояние кофе (дата добавления), а не сущность.



