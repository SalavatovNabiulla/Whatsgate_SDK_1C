﻿#Область ЛокальныеФункции 

Функция ВставитьПараметры(Адрес,Параметры)
	Адрес = Адрес + "?";
	Для Каждого Стр Из Параметры Цикл
		Адрес = Адрес + "&" + Стр.Ключ + "=" + Стр.Значение;
	КонецЦикла;
	Возврат Адрес;
КонецФункции
//
Функция ПолучитьСоединение()
	ЗС = Новый ЗащищенноеСоединениеOpenSSL();
	HTTPСоединение = Новый HTTPСоединение("whatsgate.ru",,,,,,ЗС,);
	Возврат HTTPСоединение;
КонецФункции
//
Функция ПолучитьЗаголовки()
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("X-Api-Key",Whatsgate_Сервер.ПолучитьТокен());
	Заголовки.Вставить("Content-Type","application/json");
	Возврат Заголовки;
КонецФункции
//
Функция ОбработатьОтвет(Ответ)
	Если Ответ.КодСостояния = 200 Или Ответ.КодСостояния = 204 Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции
//
Функция УбратьРазделители(Стр)
	Если Стр <> Неопределено Тогда
		Врем = Строка(Стр);
		Врем = СтрЗаменить(Врем,",","");
		Врем = СтрЗаменить(Врем,".","");
		Врем = СтрЗаменить(Врем,"'","");
		Возврат Врем;
	Иначе
		Возврат Стр;
	КонецЕсли;
КонецФункции
//
Функция ПолучитьJSONФайл(ДанныеТела)
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла("json");
	ЗаписьJSON = Новый ЗаписьJSON; 
	ЗаписьJSON.ОткрытьФайл(ИмяВременногоФайла);
	ЗаписатьJSON(ЗаписьJSON, ДанныеТела,Новый НастройкиСериализацииJSON); 
	ЗаписьJSON.Закрыть();
	Возврат ИмяВременногоФайла;
КонецФункции
//
Функция УстановитьТипыДанных(Данные = Неопределено,НазваниеФайла = Неопределено)

	Файл = Новый Файл(НазваниеФайла);
	//
	РасширенияИзображений = Новый Массив;
	РасширенияИзображений.Добавить("gif");
	РасширенияИзображений.Добавить("jpeg");
	РасширенияИзображений.Добавить("pjpeg");
	РасширенияИзображений.Добавить("png");
	РасширенияИзображений.Добавить("svg+xml");
	РасширенияИзображений.Добавить("tiff");
	РасширенияИзображений.Добавить("webp");
	//
	Если РасширенияИзображений.Найти(СтрЗаменить(Файл.Расширение,".","")) <> Неопределено Тогда
		Данные.Сообщение.Медиа.Тип = "image/"+СтрЗаменить(Файл.Расширение,".","");
		Данные.Сообщение.Тип = "image";
	Иначе
		Данные.Сообщение.Тип = "doc";
		Данные.Сообщение.Медиа.Тип = "application/gzip";	
	КонецЕсли;
	//
	Возврат Данные;
КонецФункции
//

#КонецОбласти

#Область ГлобальныеФункции

#Область Сообщения

Функция ОтправитьСообщение(Данные = Неопределено) Экспорт // Работает
	Если Данные = Неопределено Тогда
		Данные = ПолучитьСтруктуруДанных(0);
	КонецЕсли;
	//
	Если Данные.ИдентификаторОтправителя = Неопределено Тогда
		Возврат Неопределено;
	ИначеЕсли Данные.Получатель.Номер = Неопределено Тогда
		Возврат Неопределено;
	ИначеЕсли Данные.Сообщение.Тип = "text" Тогда
		Если Данные.Сообщение.Текст = Неопределено Или ПустаяСтрока(Данные.Сообщение.Текст) Тогда
			Возврат Неопределено;
		КонецЕсли;
	ИначеЕсли Данные.Сообщение.Тип = "media" Тогда
		Если Данные.Сообщение.Медиа.Тип = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
	КонецЕсли;
	//
	HTTPСоединение = ПолучитьСоединение();
	//
	ДанныеТела = Новый Структура;
		ДанныеТела.Вставить("WhatsappID",Данные.ИдентификаторОтправителя);
		ДанныеТела.Вставить("async",Данные.Асинхронно);
		//
		Получатель = Новый Структура;
			Если Данные.Получатель.ЭтоГруппа Тогда
				Получатель.Вставить("type","group");
			Иначе
				Получатель.Вставить("type","contact");
			КонецЕсли;
			Получатель.Вставить("number",Данные.Получатель.Номер);
		//
		ДанныеТела.Вставить("recipient",Получатель);
		//
		Сообщение = Новый Структура;
			Если Данные.Сообщение.Медиа.Тип = Неопределено Тогда
				Если Данные.Сообщение.Тип = Неопределено Тогда
					Сообщение.Вставить("type","text");
				Иначе
					Сообщение.Вставить("type",Данные.Сообщение.Тип);
				КонецЕсли;
				Сообщение.Вставить("body",Данные.Сообщение.Текст);
			Иначе
				Медиа = Новый Структура;
					Медиа.Вставить("mimetype",Данные.Сообщение.Медиа.Тип);
					Медиа.Вставить("data",Данные.Сообщение.Медиа.Данные);
					Медиа.Вставить("filename",Данные.Сообщение.Медиа.НазваниеФайла);
				//
				Сообщение.Вставить("type",Данные.Сообщение.Тип);
				Сообщение.Вставить("media",Медиа);
				Если Данные.Сообщение.Текст <> Неопределено Тогда
					Сообщение.Вставить("body",Данные.Сообщение.Текст);
				КонецЕсли;
			КонецЕсли;
		//
		Если Данные.Сообщение.ИдентификаторИсходногоСообщения <> Неопределено Тогда
			Сообщение.Вставить("quote",Данные.Сообщение.ИдентификаторИсходногоСообщения);
		КонецЕсли;
		//
		ДанныеТела.Вставить("message",Сообщение);
	//
	Параметры = Новый Структура;
	//
	HTTPЗапрос = Новый HTTPЗапрос(ВставитьПараметры("/api/v1/send",Параметры),ПолучитьЗаголовки());
		HTTPЗапрос.УстановитьИмяФайлаТела(ПолучитьJSONФайл(ДанныеТела));
		Ответ = HTTPСоединение.ВызватьHTTPМетод("POST",HTTPЗапрос);
		//
	Если ОбработатьОтвет(Ответ) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(Ответ.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8));
		ДанныеJSON = ПрочитатьJSON(ЧтениеJSON);
		ЧтениеJSON.Закрыть();
		Если Данные.Асинхронно Тогда
			Если ДанныеJSON.result = "OK" Тогда
				Возврат Истина;
			Иначе
				Возврат Ложь;
			КонецЕсли;	
		Иначе
			Результат = Новый Структура;
			Результат.Вставить("Идентификатор",ДанныеJSON.result.id);
			Результат.Вставить("КлючМедиа",ДанныеJSON.result.mediaKey);
			Возврат Результат;
		КонецЕсли;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции
//
Функция ПометитьКакПрочитанное(Данные = Неопределено) Экспорт // Работает
	Если Данные = Неопределено Тогда
		Данные = ПолучитьСтруктуруДанных(0);
	КонецЕсли;
	//
	Если Данные.Номер = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
    //
	HTTPСоединение = ПолучитьСоединение();
	//
	ДанныеТела = Новый Структура;
		ДанныеТела.Вставить("WhatsappID",Whatsgate_Сервер.ПолучитьИдентификаторОтправителя());
		//
		Получатель = Новый Структура;
			Если Данные.ЭтоГруппа Тогда
				Получатель.Вставить("type","group");
			Иначе
				Получатель.Вставить("type","contact");
			КонецЕсли;
			Получатель.Вставить("number",Данные.Номер);
		//
	ДанныеТела.Вставить("recipient",Получатель);
	//
	Параметры = Новый Структура;
	//
	HTTPЗапрос = Новый HTTPЗапрос(ВставитьПараметры("/api/v1/seen",Параметры),ПолучитьЗаголовки());
		HTTPЗапрос.УстановитьИмяФайлаТела(ПолучитьJSONФайл(ДанныеТела));
		Ответ = HTTPСоединение.ВызватьHTTPМетод("POST",HTTPЗапрос);
		//
	Если ОбработатьОтвет(Ответ) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(Ответ.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8));
		ДанныеJSON = ПрочитатьJSON(ЧтениеJSON);
		ЧтениеJSON.Закрыть();
		Если ДанныеJSON.result = "OK" Тогда
			Возврат Истина;
		Иначе
			Возврат Ложь;
		КонецЕсли;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции
//
Функция ПолучитьПрикрепленныйМедиафайл(КлючМедиа = Неопределено) Экспорт //Работает но надо перепроверить в Postman 
	Если КлючМедиа = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	//
	HTTPСоединение = ПолучитьСоединение();
	//
	ДанныеТела = Новый Структура;
	ДанныеТела.Вставить("WhatsappID",Whatsgate_Сервер.ПолучитьИдентификаторОтправителя());
	ДанныеТела.Вставить("mediaKey",КлючМедиа);
	//
	Параметры = Новый Структура;
	//
	HTTPЗапрос = Новый HTTPЗапрос(ВставитьПараметры("/api/v1/get-media",Параметры),ПолучитьЗаголовки());
		HTTPЗапрос.УстановитьИмяФайлаТела(ПолучитьJSONФайл(ДанныеТела));
		Ответ = HTTPСоединение.ВызватьHTTPМетод("POST",HTTPЗапрос);
	//	
	Если ОбработатьОтвет(Ответ) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(Ответ.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8));
		ДанныеJSON = ПрочитатьJSON(ЧтениеJSON);
		ЧтениеJSON.Закрыть();
		Если ДанныеJSON.result = "OK" Тогда
			Если ДанныеJSON.media <> Ложь Тогда
				Данные = ПолучитьСтруктуруДанных(3);	
				Данные.Тип = ДанныеJSON.media.mimetype;
				Данные.Данные = ДанныеJSON.media.data;
				Данные.НазваниеФайла = ДанныеJSON.media.filename;
				Возврат Данные;
			Иначе
				Возврат Ложь;
			КонецЕсли;
		Иначе
			Возврат Ложь;
		КонецЕсли;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции

#КонецОбласти

#Область Пользователи

Функция ПроверитьЗарегистрированЛиНомер(Номер = Неопределено) Экспорт // Работает
	Если Номер = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	//
	HTTPСоединение = ПолучитьСоединение();
	//
	ДанныеТела = Новый Структура;
	ДанныеТела.Вставить("WhatsappID",Whatsgate_Сервер.ПолучитьИдентификаторОтправителя());
	ДанныеТела.Вставить("number",Номер);
	//
	Параметры = Новый Структура;
	//
	HTTPЗапрос = Новый HTTPЗапрос(ВставитьПараметры("/api/v1/check",Параметры),ПолучитьЗаголовки());
		HTTPЗапрос.УстановитьИмяФайлаТела(ПолучитьJSONФайл(ДанныеТела));
		Ответ = HTTPСоединение.ВызватьHTTPМетод("POST",HTTPЗапрос);
	//	
	Если ОбработатьОтвет(Ответ) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(Ответ.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8));
		ДанныеJSON = ПрочитатьJSON(ЧтениеJSON);
		ЧтениеJSON.Закрыть();
		Если ДанныеJSON.result = "OK" Тогда
			Возврат ДанныеJSON.data;
		Иначе
			Возврат Ложь;
		КонецЕсли;
	Иначе
		Возврат Неопределено;
	КонецЕсли;

КонецФункции

#КонецОбласти

#Область Чаты

Функция ПолучитьВсеАктивныеЧаты() Экспорт // Работает
	HTTPСоединение = ПолучитьСоединение();
	//
	ДанныеТела = Новый Структура;
	ДанныеТела.Вставить("WhatsappID",Whatsgate_Сервер.ПолучитьИдентификаторОтправителя());
	//
	Параметры = Новый Структура;
	//
	HTTPЗапрос = Новый HTTPЗапрос(ВставитьПараметры("/api/v1/get-chats",Параметры),ПолучитьЗаголовки());
		HTTPЗапрос.УстановитьИмяФайлаТела(ПолучитьJSONФайл(ДанныеТела));
		Ответ = HTTPСоединение.ВызватьHTTPМетод("POST",HTTPЗапрос);
	//	
	Если ОбработатьОтвет(Ответ) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(Ответ.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8));
		ДанныеJSON = ПрочитатьJSON(ЧтениеJSON);
		ЧтениеJSON.Закрыть();
		//
		Если ДанныеJSON.result = "OK" Тогда
			Чаты = Новый Массив;
			Для Каждого Чат Из ДанныеJSON.data Цикл
				Если Чат.isGroup Тогда
					Данные = ПолучитьСтруктуруДанных(5);
					Данные.Идентификатор = Чат.id;
					Данные.Имя = Чат.name;
					Данные.ЭтоГруппа = Чат.isGroup;
					Данные.ТолькоЧтение = Чат.isReadOnly;
					Данные.КоличествоНепрочитанныхСообщений = Чат.unreadCount;
					Данные.ВремяПоследнейАктивности = Чат.timestamp;
					Данные.Закрепленный = Чат.pinned;
					Данные.Приглушен = Чат.isMuted;
					Данные.ДлительностьПриглушения = Чат.muteExpiration;
					Данные.МетаданныеГруппы.Идентификатор = Чат.groupMetadata.id;
					Данные.МетаданныеГруппы.ДатаСозданияГруппы = Чат.groupMetadata.creation;
					Данные.МетаданныеГруппы.ИдентификаторВладельца = Чат.groupMetadata.owner;
					Данные.МетаданныеГруппы.КоличествоУчастников = Чат.groupMetadata.size;
					Данные.МетаданныеГруппы.Участники = Новый Массив;
					//
					Для Каждого Участник Из Чат.groupMetadata.participants Цикл
						ПодДанные = ПолучитьСтруктуруДанных(7);
						ПодДанные.Идентификатор = Участник.id;
						ПодДанные.Админ = Участник.isAdmin;
						ПодДанные.СуперАдмин = Участник.isSuperAdmin;
						Данные.МетаданныеГруппы.Участники.Добавить(ПодДанные);
					КонецЦикла;
					//
					Чаты.Добавить(Данные);
				Иначе
					Данные = ПолучитьСтруктуруДанных(4);
					Данные.Идентификатор = Чат.id;
					Данные.Имя = Чат.name;
					Данные.ЭтоГруппа = Чат.isGroup;
					Данные.ТолькоЧтение = Чат.isReadOnly;
					Данные.КоличествоНепрочитанныхСообщений = Чат.unreadCount;
					Данные.ВремяПоследнейАктивности = Чат.timestamp;
					Данные.Закрепленный = Чат.pinned;
					Данные.Приглушен = Чат.isMuted;
					Данные.ДлительностьПриглушения = Чат.muteExpiration;
					Чаты.Добавить(Данные);
				КонецЕсли;
			КонецЦикла;
			Возврат Чаты;
		Иначе
			Возврат Неопределено;
		КонецЕсли;
		//
	Иначе
		Возврат Неопределено;
	КонецЕсли;	
КонецФУнкции

#КонецОбласти

#Область Сессии

Функция СоздатьНовуюСессию(НазваниеСессии = Неопределено) Экспорт // Работает

	HTTPСоединение = ПолучитьСоединение();
	//
	ДанныеТела = Новый Структура;
	ДанныеТела.Вставить("name",НазваниеСессии);
	//
	Параметры = Новый Структура;
	//
	HTTPЗапрос = Новый HTTPЗапрос(ВставитьПараметры("/api/v1/session-create",Параметры),ПолучитьЗаголовки());
		HTTPЗапрос.УстановитьИмяФайлаТела(ПолучитьJSONФайл(ДанныеТела));
		Ответ = HTTPСоединение.ВызватьHTTPМетод("POST",HTTPЗапрос);
	//	
	Если ОбработатьОтвет(Ответ) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(Ответ.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8));
		ДанныеJSON = ПрочитатьJSON(ЧтениеJSON);
		ЧтениеJSON.Закрыть();
		Если ДанныеJSON.result = "OK" Тогда
			Данные = ПолучитьСтруктуруДанных(8);
			Данные.Идентификатор = ДанныеJSON.data.id;
			Данные.Название = ДанныеJSON.data.name;
			Данные.УникальныйИдентификатор = ДанныеJSON.data.unique_id;
			Данные.Состояние = ДанныеJSON.data.status;
			Данные.URL_Обработчик = ДанныеJSON.data.callback;
			Данные.ДатаСоздания = ДанныеJSON.data.date_add;
			Данные.НазваниеСостояния = ДанныеJSON.data.status_name;
			Данные.СсылкаНаQR_Код = ДанныеJSON.data.qr_link;
			//
			Возврат Данные;
		Иначе
			Возврат Ложь;
		КонецЕсли;
	Иначе
		Возврат Неопределено;
	КонецЕсли;

КонецФункции
//
Функция УдалитьВсеСессии() Экспорт // Работает
	//
	HTTPСоединение = ПолучитьСоединение();
	//
	ДанныеТела = Новый Структура;
	ДанныеТела.Вставить("WhatsappID",Whatsgate_Сервер.ПолучитьИдентификаторОтправителя());
	//
	Параметры = Новый Структура;
	//
	HTTPЗапрос = Новый HTTPЗапрос(ВставитьПараметры("/api/v1/session-delete",Параметры),ПолучитьЗаголовки());
		HTTPЗапрос.УстановитьИмяФайлаТела(ПолучитьJSONФайл(ДанныеТела));
		Ответ = HTTPСоединение.ВызватьHTTPМетод("POST",HTTPЗапрос);
	//	
	Если ОбработатьОтвет(Ответ) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(Ответ.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8));
		ДанныеJSON = ПрочитатьJSON(ЧтениеJSON);
		ЧтениеJSON.Закрыть();
		Если ДанныеJSON.result = "OK" Тогда
			Возврат Истина;
		Иначе
			Возврат Ложь;
		КонецЕсли;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции
//
Функция ПолучитьВсеСессии() Экспорт // Не работает
	
	HTTPСоединение = ПолучитьСоединение();
	//
	ДанныеТела = Новый Структура;
	//
	Параметры = Новый Структура;
	//
	HTTPЗапрос = Новый HTTPЗапрос(ВставитьПараметры("/api/v1/session-create",Параметры),ПолучитьЗаголовки());
		HTTPЗапрос.УстановитьИмяФайлаТела(ПолучитьJSONФайл(ДанныеТела));
		Ответ = HTTPСоединение.ВызватьHTTPМетод("POST",HTTPЗапрос);
	//	
	Если ОбработатьОтвет(Ответ) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(Ответ.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8));
		ДанныеJSON = ПрочитатьJSON(ЧтениеJSON);
		ЧтениеJSON.Закрыть();
		Если ДанныеJSON.result = "OK" Тогда
			Сессии = Новый Массив;
			Для Каждого Сессия Из ДанныеJSON.data Цикл 
				Данные = ПолучитьСтруктуруДанных(8);
				Данные.Идентификатор = Сессия.id;
				Данные.Название = Сессия.name;
				Данные.УникальныйИдентификатор = Сессия.unique_id;
				Данные.Состояние = Сессия.status;
				Данные.URL_Обработчик = Сессия.callback;
				Данные.ДатаСоздания = Сессия.date_add;
				Данные.QR_Код = Сессия.qr;
				Данные.НазваниеСостояния = Сессия.status_name;
				Данные.СсылкаНаQR_Код = Сессия.qr_link;
				Сессии.Добавить(Данные);
			КонецЦикла;
			//
			Возврат Сессии;
		Иначе
			Возврат Ложь;
		КонецЕсли;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции
//
Функция ИзменитьИмяСессии(НазваниеСессии = Неопределено) Экспорт // Работает

	HTTPСоединение = ПолучитьСоединение();
	//
	ДанныеТела = Новый Структура;
	ДанныеТела.Вставить("WhatsappID",Whatsgate_Сервер.ПолучитьИдентификаторОтправителя());
	ДанныеТела.Вставить("name",НазваниеСессии);
	//
	Параметры = Новый Структура;
	//
	HTTPЗапрос = Новый HTTPЗапрос(ВставитьПараметры("/api/v1/set-name",Параметры),ПолучитьЗаголовки());
		HTTPЗапрос.УстановитьИмяФайлаТела(ПолучитьJSONФайл(ДанныеТела));
		Ответ = HTTPСоединение.ВызватьHTTPМетод("POST",HTTPЗапрос);
	//	
	Если ОбработатьОтвет(Ответ) Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(Ответ.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8));
		ДанныеJSON = ПрочитатьJSON(ЧтениеJSON);
		ЧтениеJSON.Закрыть();
		Если ДанныеJSON.result = "OK" Тогда
			Данные = ПолучитьСтруктуруДанных(8);
			Данные.Идентификатор = ДанныеJSON.data.id;
			Данные.Название = ДанныеJSON.data.name;
			Данные.УникальныйИдентификатор = ДанныеJSON.data.unique_id;
			Данные.Состояние = ДанныеJSON.data.status;
			Данные.URL_Обработчик = ДанныеJSON.data.callback;
			Данные.ДатаСоздания = ДанныеJSON.data.date_add;
			Данные.НазваниеСостояния = ДанныеJSON.data.status_name;
			//
			Возврат Данные;
		Иначе
			Возврат Ложь;
		КонецЕсли;
	Иначе
		Возврат Неопределено;
	КонецЕсли;	
	
КонецФункции

#КонецОбласти

#Область Другое

Функция ПрикрепитьФайл(Данные = Неопределено, НазваниеФайла = Неопределено) Экспорт
	Если Данные = Неопределено Или НазваниеФайла = Неопределено Тогда
		Возврат Данные;
	КонецЕсли;
	//
	Данные = УстановитьТипыДанных(Данные,НазваниеФайла);
	Если Данные.Сообщение.Медиа.Тип <> Неопределено Тогда
		Файл = Новый Файл(НазваниеФайла);
		ДД = Новый ДвоичныеДанные(НазваниеФайла);
		СтрокаB64 = Base64Строка(ДД);
		//
		Данные.Сообщение.Медиа.Данные = СтрокаB64;
		Данные.Сообщение.Медиа.НазваниеФайла = Файл.Имя;
	КонецЕсли;
	//
	Возврат Данные;
КонецФункции
//
Функция ПолучитьСтруктуруДанных(НомерСтруктуры = 0) Экспорт
	Шаблон = Новый Структура;
	//
	Если НомерСтруктуры = 0 Тогда // Объект отправки сообщения
		Шаблон.Вставить("ИдентификаторОтправителя",Whatsgate_Сервер.ПолучитьИдентификаторОтправителя());
		Шаблон.Вставить("Асинхронно",Ложь);
		Шаблон.Вставить("Получатель",ПолучитьСтруктуруДанных(1));
		Шаблон.Вставить("Сообщение",ПолучитьСтруктуруДанных(2));
	ИначеЕсли НомерСтруктуры = 1 Тогда // Объект получателя сообщения
		Шаблон.Вставить("Номер",Неопределено);
		Шаблон.Вставить("ЭтоГруппа",Ложь);
	ИначеЕсли НомерСтруктуры = 2 Тогда // Объект сообщения
		Шаблон.Вставить("Тип",Неопределено);
		Шаблон.Вставить("Текст",Неопределено);
		Шаблон.Вставить("ИдентификаторИсходногоСообщения",Неопределено);
		Шаблон.Вставить("Медиа",ПолучитьСтруктуруДанных(3));
	ИначеЕсли НомерСтруктуры = 3 Тогда // Объект медиа-файла
		Шаблон.Вставить("Тип",Неопределено);
		Шаблон.Вставить("Данные",Неопределено);
		Шаблон.Вставить("НазваниеФайла",Неопределено);
	ИначеЕсли НомерСтруктуры = 4 Тогда // Объект контакт чата
		Шаблон.Вставить("Идентификатор",Неопределено);
		Шаблон.Вставить("Имя",Неопределено);
		Шаблон.Вставить("ЭтоГруппа",Неопределено);
		Шаблон.Вставить("ТолькоЧтение",Неопределено);
		Шаблон.Вставить("КоличествоНепрочитанныхСообщений",Неопределено);
		Шаблон.Вставить("ВремяПоследнейАктивности",Неопределено);
		Шаблон.Вставить("Закрепленный",Неопределено);
		Шаблон.Вставить("Приглушен",Неопределено);
		Шаблон.Вставить("ДлительностьПриглушения",Неопределено);
	ИначеЕсли НомерСтруктуры = 5 Тогда // Объект группа чата 
		Шаблон.Вставить("Идентификатор",Неопределено);
		Шаблон.Вставить("Имя",Неопределено);
		Шаблон.Вставить("ЭтоГруппа",Неопределено);
		Шаблон.Вставить("ТолькоЧтение",Неопределено);
		Шаблон.Вставить("КоличествоНепрочитанныхСообщений",Неопределено);
		Шаблон.Вставить("ВремяПоследнейАктивности",Неопределено);
		Шаблон.Вставить("Закрепленный",Неопределено);
		Шаблон.Вставить("Приглушен",Неопределено);
		Шаблон.Вставить("ДлительностьПриглушения",Неопределено);
		Шаблон.Вставить("МетаданныеГруппы",ПолучитьСтруктуруДанных(6));
	ИначеЕсли НомерСтруктуры = 6 Тогда // Объект метаданных группы
		Шаблон.Вставить("Идентификатор",Неопределено);
		Шаблон.Вставить("ДатаСозданияГруппы",Неопределено);
		Шаблон.Вставить("ИдентификаторВладельца",Неопределено);
		Шаблон.Вставить("КоличествоУчастников",Неопределено);
		Шаблон.Вставить("Участники",Неопределено);
	ИначеЕсли НомерСтруктуры = 7 Тогда // Объект участник группы
		Шаблон.Вставить("Идентификатор",Неопределено);
		Шаблон.Вставить("Админ",Неопределено);
		Шаблон.Вставить("СуперАдмин",Неопределено);
	ИначеЕсли НомерСтруктуры = 8 Тогда // Объект сессии
		Шаблон.Вставить("Идентификатор",Неопределено);
		Шаблон.Вставить("Название",Неопределено);
		Шаблон.Вставить("УникальныйИдентификатор",Неопределено);
		Шаблон.Вставить("Состояние",Неопределено);
		Шаблон.Вставить("URL_Обработчик",Неопределено);
		Шаблон.Вставить("ДатаСоздания",Неопределено);
		Шаблон.Вставить("QR_Код",Неопределено);
		Шаблон.Вставить("НазваниеСостояния",Неопределено);
		Шаблон.Вставить("СсылкаНаQR_Код",Неопределено);
	КонецЕсли;
	//
	Возврат Шаблон;
КонецФункции

#КонецОбласти

#КонецОбласти