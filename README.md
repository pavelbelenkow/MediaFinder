# Media Finder

# Назначение и цели приложения

iOS-приложение для поиска музыки и фильмов, которое состоит из двух экранов:

- Экран поиска музыки и фильмов
- Экран с детальной информацией, который отображается после нажатия на элемент из результатов поиска

Приложение предназначено для просмотра карточек с музыкой и фильмами через iTunes API.

Цели приложения:

- Поиск и просмотр карточек с музыкой и фильмами
- Просмотр более подробной информации о выбранной карточке мультимедиа

# Запуск приложения

## Требования

- iOS 14.0 или позднее
- Xcode 14.0 или позднее
- Интернет-соединение

## Установка

1) Возможны несколько вариантов установки проекта:
- Склонировать репозиторий на свой компьютер https://github.com/pavelbelenkow/MediaFinder.git
- Воспользоваться кнопкой "Open with Xcode" в репозитории
- Скачать ZIP архив и распаковать его на компьютере
2) Откройте проект в Xcode

## Запуск

1) Откройте файл MediaFinder.xcodeproj в Xcode
2) Выберите целевое устройство (симулятор или реальное устройство)
3) Нажмите кнопку "Start" или воспользуйтесь hotkey "cmd + R" в Xcode

### Запуск Unit-тестов

1) Выберите таргет "MediaFinderTests" в схеме проекта
2) Зажмите кнопку "Start" и в контекстном меню появится выбор "Test" или воспользуйтесь hotkey "cmd + U" в Xcode

## Примеры использования

### Экран поиска музыки и фильмов

1) Введите поисковый запрос в поле поиска
2) Нажмите кнопку "Поиск" на клавиатуре
3) Результаты поиска будут отображены в виде плиток на экране
4) Над коллекцией плиток будут отображены три вкладки:
   - "All"(по умолчанию, отображает результаты поиска для типов Музыка и Фильмы),
   - "Movies",
   - "Songs"
5) По нажатию на каждую из вкладок коллекция будет запрашивать данные для конкретного типа медиа-контента на основе предоставленного поискового запроса
6) В правом верхнем углу навигационного бара есть кнопка с меню установления лимита на количество результатов на страницу данных:
   - 10
   - 30(по умолчанию)
   - 50
7) По нажатию на кнопку откроется меню с выбором лимита и при его выборе данные в коллекцию будут загружаться пакетами по установленному лимиту

### Экран с детальной информацией

1) Нажмите на элемент поисковой выдачи, чтобы открыть экран с детальной информацией
2) На этом экране будет отображена детальная информация о выбранном медиа-контенте
3) В зависимости от типа контента(музыка или фильм) будут показаны:
   - Для музыки - изображение(artwork), тип(kind), исполнитель(artist), ссылка на трек в Apple Music(trackViewUrl), блок с информацией об исполнителе - тип, имя, жанр, ссылка в Apple Music на исполнителя(artistLinkUrl)
   - Для фильмов - изображение(artwork), тип(kind), режиссер(artist), описание(longDescription), ссылка на фильм в Apple TV(trackViewUrl), блок с информацией о продакшене(если предоставлено) - тип, название, жанр, ссылка в iTunes на продакшн(artistLinkUrl)

## Примеры запросов и ответов

### Пример запроса Музыки и Фильмов с лимитом по умолчанию(30) для текста "To build a home":

```https://itunes.apple.com/search?term=To%20build%20a%20home&limit=30&offset=0```

### Пример ответа:

```
{
  "resultCount": 30,
      "results": [
        {
            "wrapperType": "track",
            "kind": "song",
            "artistId": 3631576,
            "collectionId": 255464394,
            "trackId": 255470095,
            "artistName": "The Cinematic Orchestra",
            "collectionName": "Ma Fleur",
            "trackName": "To Build a Home",
            "collectionCensoredName": "Ma Fleur",
            "trackCensoredName": "To Build a Home (feat. Patrick Watson)",
            "artistViewUrl": "https://music.apple.com/us/artist/the-cinematic-orchestra/3631576?uo=4",
            "collectionViewUrl": "https://music.apple.com/us/album/to-build-a-home-feat-patrick-watson/255464394?i=255470095&uo=4",
            "trackViewUrl": "https://music.apple.com/us/album/to-build-a-home-feat-patrick-watson/255464394?i=255470095&uo=4",
            "previewUrl": "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview112/v4/1b/bf/89/1bbf89f1-65d9-6f0e-b811-a31a7e84a9b9/mzaf_13133980812581457054.plus.aac.p.m4a",
            "artworkUrl30": "https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/de/73/f2/de73f26c-42b9-168c-e003-592f44b7857e/801390015120.png/30x30bb.jpg",
            "artworkUrl60": "https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/de/73/f2/de73f26c-42b9-168c-e003-592f44b7857e/801390015120.png/60x60bb.jpg",
            "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/de/73/f2/de73f26c-42b9-168c-e003-592f44b7857e/801390015120.png/100x100bb.jpg",
            "collectionPrice": 9.99,
            "trackPrice": 1.29,
            "releaseDate": "2007-05-07T07:00:00Z",
            "collectionExplicitness": "notExplicit",
            "trackExplicitness": "notExplicit",
            "discCount": 1,
            "discNumber": 1,
            "trackCount": 11,
            "trackNumber": 10,
            "trackTimeMillis": 370667,
            "country": "USA",
            "currency": "USD",
            "primaryGenreName": "Electronic",
            "isStreamable": true
        },
        // Следующий элемент списка данных

    ]
}
```

### Пример запроса Фильмов с лимитом 10 для текста "Amelie":

``` https://itunes.apple.com/search?term=Amelie&entity=movie&limit=10&offset=0 ```

### Пример ответа:
```
{
    "resultCount": 1,
    "results": [
        {
            "wrapperType": "track",
            "kind": "feature-movie",
            "trackId": 1671072038,
            "artistName": "Jean-Pierre Jeunet",
            "trackName": "Amelie",
            "trackCensoredName": "Amelie",
            "trackViewUrl": "https://itunes.apple.com/us/movie/amelie/id1671072038?uo=4",
            "previewUrl": "https://video-ssl.itunes.apple.com/itunes-assets/Video126/v4/d0/01/dd/d001dd0b-98ea-9308-d978-5aefcdd1f75c/mzvf_8537400894470000935.640x364.h264lc.U.p.m4v",
            "artworkUrl30": "https://is1-ssl.mzstatic.com/image/thumb/Video116/v4/af/bb/1c/afbb1c85-5dac-42ef-17c8-5939fd6e98d9/SPE_AMELIE_TH_ITUNES_WW_ARTWORK_EN_2000x3000_3P8G6K000000PY.lsr/30x30bb.jpg",
            "artworkUrl60": "https://is1-ssl.mzstatic.com/image/thumb/Video116/v4/af/bb/1c/afbb1c85-5dac-42ef-17c8-5939fd6e98d9/SPE_AMELIE_TH_ITUNES_WW_ARTWORK_EN_2000x3000_3P8G6K000000PY.lsr/60x60bb.jpg",
            "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/Video116/v4/af/bb/1c/afbb1c85-5dac-42ef-17c8-5939fd6e98d9/SPE_AMELIE_TH_ITUNES_WW_ARTWORK_EN_2000x3000_3P8G6K000000PY.lsr/100x100bb.jpg",
            "collectionPrice": 12.99,
            "trackPrice": 12.99,
            "trackRentalPrice": 3.99,
            "collectionHdPrice": 12.99,
            "trackHdPrice": 12.99,
            "trackHdRentalPrice": 3.99,
            "releaseDate": "2001-11-16T08:00:00Z",
            "collectionExplicitness": "notExplicit",
            "trackExplicitness": "notExplicit",
            "trackTimeMillis": 7304588,
            "country": "USA",
            "currency": "USD",
            "primaryGenreName": "Comedy",
            "contentAdvisoryRating": "R",
            "shortDescription": "Quiet and reserved, Amelie Poulin spends her days as a waitress at a Paris cafe and entertains",
            "longDescription": "Quiet and reserved, Amelie Poulin spends her days as a waitress at a Paris cafe and entertains herself by playing kindhearted practical jokes on her father and her neighbors, finding love in the meantime."
        }
    ]
}
```
### Пример запроса Музыки с лимитом 50 для текста "Emily":

```https://itunes.apple.com/search?term=Emily&entity=song&limit=50&offset=0```

### Пример ответа:
```
{
    "resultCount": 50,
    "results": [
        {
            "wrapperType": "track",
            "kind": "song",
            "artistId": 5565555,
            "collectionId": 204051949,
            "trackId": 204052021,
            "artistName": "Joanna Newsom",
            "collectionName": "Ys",
            "trackName": "Emily",
            "collectionCensoredName": "Ys",
            "trackCensoredName": "Emily",
            "artistViewUrl": "https://music.apple.com/us/artist/joanna-newsom/5565555?uo=4",
            "collectionViewUrl": "https://music.apple.com/us/album/emily/204051949?i=204052021&uo=4",
            "trackViewUrl": "https://music.apple.com/us/album/emily/204051949?i=204052021&uo=4",
            "previewUrl": "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/ea/e4/13/eae41322-58de-f346-f682-12e1a8866d9b/mzaf_12402789342095452240.plus.aac.p.m4a",
            "artworkUrl30": "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/85/a1/a2/85a1a29f-7a03-0c8a-ce4c-3a57e0213413/781484030324.png/30x30bb.jpg",
            "artworkUrl60": "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/85/a1/a2/85a1a29f-7a03-0c8a-ce4c-3a57e0213413/781484030324.png/60x60bb.jpg",
            "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/85/a1/a2/85a1a29f-7a03-0c8a-ce4c-3a57e0213413/781484030324.png/100x100bb.jpg",
            "collectionPrice": 10.99,
            "trackPrice": -1.00,
            "releaseDate": "2006-11-14T12:00:00Z",
            "collectionExplicitness": "notExplicit",
            "trackExplicitness": "notExplicit",
            "discCount": 1,
            "discNumber": 1,
            "trackCount": 5,
            "trackNumber": 1,
            "trackTimeMillis": 728480,
            "country": "USA",
            "currency": "USD",
            "primaryGenreName": "Alternative",
            "isStreamable": true
        },
        // Следующий элемент списка данных

  ]
}
```
