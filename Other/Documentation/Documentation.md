Версия проекта: 1.6.2
Страница проекта: https://infostart.ru/public/1751665/
Разработчик проекта: https://infostart.ru/profile/1662204/
___
# Как получить токен пользователя и идентификатор сессии?
    1. Перейти по ссылке https://whatsgate.ru/app/login и авторизоваться
    2. Нажать на иконку "Добавить" над списком сессий и ввести название
    3. После откроется окно с QR-кодом, который необходимо отсканировать
    4. И теперь можете скопировать "X-Api-Key"(Токен пользователя) и "WhatsappID"(Идентификатор сессии)
Обратите внимание что токен пользователя всегда один и тот же, при работе с сессиями меняется только идентификатор сессии!
___
# Как использовать токен пользователя и идентификатор сессии в 1С?
В общем модуле ``Whatsgate_Сервер`` находится функция ``ПолучитьТокенПользователя()`` , внутри которой вы должны либо просто расположить этот токен и возвращать его как строку, либо реализовать свой способ хранения токенов в базе, например присвоить их в реквизит справочника. Именно на этот случай модуль и исполняется на сервере!
___
# Что такое структура данных, какие бывают структуры данных и как с ними работать?
>Если рассуждать с точки зрения ООП то в Whatsgate есть 8 типов объектов, с которыми мы можем работать. То есть:
    - Отправка сообщения
    - Получатель сообщения
    - Сообщение
    - Медиа-файл
    - Чат-контакт
    - Чат-группа
    - Метаданные группы
    - Участник группы
    - Сессия
Каждый из них имеет свой набор данных, который содержит такие элементы как идентификатор, название и так далее. Следовательно чтобы было удобно работать с библиотекой, я заранее подготовил эти наборы данных в виде структур, чтобы разработчику не пришлось каждый раз думать какие данные нужно занести в структуру, которую он собирается передать в функцию. Короче говоря это просто заранее подготовленные шаблоны структур, которые вы заполняете перед тем как передать их на обработку. Чтобы получить структуру данных вам необходимо обратиться к функции ```ПолучитьСтруктуруДанных``` из модуля ```Whatsgate_Клиент``` и передать в неё номер структуры данных(можете найти ниже) в виде числа! 
Далее подробно про содержание структур:
>
>**Отправка сообщения - 0**:
	ИдентификаторОтправителя = ```Whatsgate_Сервер.ПолучитьИдентификаторСессии()```
	Асинхронно = Ложь
	Получатель = ```ПолучитьСтруктуруДанных(1)```
	Сообщение = ```ПолучитьСтруктуруДанных(2)```
>
>**Получатель сообщения - 1**:
	Номер = Неопределено
	ЭтоГруппа = Ложь
>
>**Сообщение - 2**:
	Тип = Неопределено
	Текст = Неопределено
	ИдентификаторИсходногоСообщения = Неопределено
	Медиа = ```ПолучитьСтруктуруДанных(3)```
>
>**Медиа-файл - 3**:
	Тип = Неопределено
	Данные = Неопределено
	НазваниеФайла = Неопределено
>
>**Чат-контакт - 4**:
	Идентификатор = Неопределено
	Имя = Неопределено
	ЭтоГруппа = Неопределено
	ТолькоЧтение = Неопределено
	КоличествоНепрочитанныхСообщений = Неопределено
	ВремяПоследнейАктивности = Неопределено
	Закрепленный = Неопределено
	Приглушен = Неопределено
	ДлительностьПриглушения = Неопределено
>
>**Чат-группа - 5**:
	Идентификатор = Неопределено
	Имя = Неопределено
	ЭтоГруппа = Неопределено
	ТолькоЧтение = Неопределено
	КоличествоНепрочитанныхСообщений = Неопределено
	ВремяПоследнейАктивности = Неопределено
	Закрепленный = Неопределено
	Приглушен = Неопределено
	ДлительностьПриглушения = Неопределено
	МетаданныеГруппы = ```ПолучитьСтруктуруДанных(6)```
>
>**Метаданные группы - 6**:
	Идентификатор = Неопределено
	ДатаСозданияГруппы = Неопределено
	ИдентификаторВладельца = Неопределено
	КоличествоУчастников = Неопределено
	Участники = Неопределено
>
>**Участник группы - 7**:
	Идентификатор = Неопределено
	Админ = Неопределено
	СуперАдмин = Неопределено
>
>**Сессия - 8**:
	Идентификатор = Неопределено
	Название = Неопределено
	УникальныйИдентификатор = Неопределено
	Состояние = Неопределено
	URL_Обработчик = Неопределено
	ДатаСоздания = Неопределено
	QR_Код = Неопределено
	НазваниеСостояния = Неопределено
	СсылкаНаQR_Код = Неопределено
>
___
# Как отправить сообщение?
>Для начала вам необходимо получить структуру данных отправки сообщения. После необходимо заполнить её следующими данными:
    - Асинхронно (Булево)
    - Получатель.ЭтоГруппа (Булево)
    - Получатель.Номер (Строка) (Обязательный)
    - Сообщение.Текст (Строка) (Обязательный, если не прикреплен файл)
После заполнения необходимо обратиться к функции ```ОтправитьСообщение``` из модуля ```Todoist_Клиент``` и передать в неё заполненные данные. Для того чтобы прикрепить к сообщению файл вы можете обратиться к функции ```ПрикрепитьФайл``` в том же модуле и передать ей заполненные данные с названием файла. После прикрепления функция вернет ту же структуру с данными но уже прикрепив файл.
После всего функция отправки вернет структуру данных с идентификатором сообщения и медиа ключом, если были приклеплены файлы!
>
Пример:
```
	Данные = Whatsgate_Клиент.ПолучитьСтруктуруДанных(0);
	Данные.Асинхронно = Ложь;
	Данные.Получатель.ЭтоГруппа = Ложь;
	Данные.Получатель.Номер = "7**********";
	Данные.Сообщение.Текст = "Отправлено из 1С";
	//
	ДВФ = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Если ДВФ.Выбрать() Тогда
		Данные = Whatsgate_Клиент.ПрикрепитьФайл(Данные,ДВФ.ПолноеИмяФайла);
	КонецЕсли;
	Результат = Whatsgate_Клиент.ОтправитьСообщение(Данные);
```
___
# Как пометить последние сообщения в чате как прочитанные?
>Для начала вам необходимо получить структуру данных получателя сообщения. После необходимо заполнить её следующими данными:
    - ЭтоГруппа (Булево)
    - Номер (Строка) (Обязательный)
После заполнения необходимо обратиться к функции ```ПометитьКакПрочитанное``` из модуля ```Todoist_Клиент``` и передать в неё заполненные данные.
После всего функция вернет результат в виде булева значения!
>
Пример:
```
	Данные = Whatsgate_Клиент.ПолучитьСтруктуруДанных(1);
	Данные.ЭтоГруппа = Ложь;
	Данные.Номер = "7**********";
	Результат = Whatsgate_Клиент.ПометитьКакПрочитанное(Данные);
```
___
# Как получить прикрепленный к сообщению медиа-файл?
>Вы можете обратиться к функции ```ПолучитьПрикрепленныйМедиафайл``` из модуля ```Todoist_Клиент``` и передать в неё ключ медиа в виде строки.
После всего функция вернет результат в виде структуры данных медиа файла!
>
Пример:
```
Результат = Whatsgate_Клиент.ПолучитьПрикрепленныйМедиафайл("xa4m1xe4LBqIlIgiwdw+6mmzeqVqvHCemmc7yYGQQvM=");
```
___
# Как проверить зарегистрирован ли номер?
>Вы можете обратиться к функции ```ПроверитьЗарегистрированЛиНомер``` из модуля ```Todoist_Клиент``` и передать в неё номер телефона в виде строки.
После всего функция вернет результат в виде структуры данных медиа файла!
>
Пример:
```
Результат = Whatsgate_Клиент.ПроверитьЗарегистрированЛиНомер("7**********");
```
___
# Как получить все активные чаты?
>Вы можете обратиться к функции ```ПолучитьВсеАктивныеЧаты``` из модуля ```Todoist_Клиент```.
После всего функция вернет результат в виде массива, каждый элемент которого будет структурой данных чата группы или чата контакта!
>
Пример:
```
Результат = Whatsgate_Клиент.ПолучитьВсеАктивныеЧаты();
```
___
# Как создать новую сессию?
>Вы можете обратиться к функции ```СоздатьНовуюСессию``` из модуля ```Todoist_Клиент``` и передать в неё имя сессии в виде строки.
После всего функция вернет результат в виде структуры данных сессии!
Структура данных сессии содержит поле со ссылкой на QR-код, который нужно отсканировать, чтобы активировать сессию.
>
Пример:
```
Результат = Whatsgate_Клиент.СоздатьНовуюСессию("test");
```
___
# Как получить все сессии?
>Вы можете обратиться к функции ```ПолучитьВсеСессии``` из модуля ```Todoist_Клиент```.
После всего функция вернет результат в виде массива, каждый элемент которого будет структурой данных сессии!
>
Пример:
```
Результат = Whatsgate_Клиент.ПолучитьВсеСессии();
```
___
# Как изменить имя сессии?
>Вы можете обратиться к функции ```ИзменитьИмяСессии``` из модуля ```Todoist_Клиент```.
После всего функция вернет результат в виде булева значения!
>
Пример:
```
Результат = Whatsgate_Клиент.ИзменитьИмяСессии("Nabi");
```
___
# Как удалить сессию?
>Вы можете обратиться к функции ```ИзменитьИмяСессии``` из модуля ```Todoist_Клиент```.
После всего функция вернет результат в виде булева значения!
>
Пример:
```
Результат = Whatsgate_Клиент.УдалитьВсеСессии();
```
___
# Как установить Webhook?
>Вы можете обратиться к функции ```УстановитьWebhook``` из модуля ```Todoist_Клиент``` и передать в неё URL обработчика в виде строки. Как сформировать URL обработчика вы можете почитать в этой [статье](https://its.1c.ru/db/metod8dev/content/5756/hdoc).
После всего функция вернет результат в виде булева значения!
>	

Пример:
```
Результат = Whatsgate_Клиент.УстановитьWebhook("http://localhost:8090/Platform8Demo/hs/whatsgate/");

```
___
# Как обработать событие Webhook?
>Вы можете реализовать обработку событий внутри функций обработчиков в модуле HTTP-Сервиса ```Whatsgate_Webhook```, которые получают структуру данных тела. Структура данных тела может меняться в зависимости от события но как правило все они имеют следующие поля:
>	
- Идентификатор
- ИдентификаторОтправителя
- ИмяСобытия
- ДатаСобытия
- КодСостояния
- ДанныеСобытия

Поле "ДанныеСобытия" может хранить в себе "СодержаниеОшибки","Причину" или структуру с сообщением, которая имеет следующее содержание:
- Идентификатор
- Просмотрено
- СодержитМедиаФайл
- КлючМедиа
- Текст
- Тип
- ДатаСоздания
- ИдентификаторОтправителя
- ИдентификаторПолучателя
- Перенаправлено

Пример:
```
Процедура ОбработатьВходящееСообщение(ДанныеТела = Неопределено)
Процедура ОбработатьДоставкуСообщения(ДанныеТела = Неопределено)
Процедура ОбработатьЧтениеСообщения(ДанныеТела = Неопределено)
Процедура ОбработатьОтключениеКлиента(ДанныеТела = Неопределено)
Процедура ОбработатьОшибку(ДанныеТела = Неопределено)
```
___


