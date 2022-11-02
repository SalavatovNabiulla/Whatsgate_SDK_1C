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

#КонецОбласти

#Область ГлобальныеФункции

#Область Сообщения

Функция ОтправитьСообщение(Данные = Неопределено) Экспорт
	Если Данные = Неопределено Тогда
		Данные = ПолучитьСтруктуруДанных(0);
	КонецЕсли;
	//
	//TODO:Проверка обязательных данных
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
		//TODO: Возврат структуры ответа
		Возврат Неопределено
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
	ДД = Новый ДвоичныеДанные(НазваниеФайла);
	СтрокаB64 = Base64Строка(ДД);
	//TODO: Определение MIME-типа и типа сообщения по расширению
	Данные.Сообщение.Тип = "image";
	Данные.Сообщение.Медиа.Тип = "image/png";
	Данные.Сообщение.Медиа.Данные = СтрокаB64;
	Данные.Сообщение.Медиа.НазваниеФайла = НазваниеФайла;
	//
	Возврат Данные;
КонецФункции

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
	КонецЕсли;
	//
	Возврат Шаблон;
КонецФункции

#КонецОбласти

#КонецОбласти