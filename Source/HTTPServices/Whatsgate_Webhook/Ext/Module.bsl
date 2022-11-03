﻿#Область ОбработчикиСобытий

Процедура ОбработатьВходящееСообщение(ДанныеТела)
	//
КонецПроцедуры
//
Процедура ОбработатьДоставкуСообщения(ДанныеТела)
	//
КонецПроцедуры	
//
Процедура ОбработатьЧтениеСообщения(ДанныеТела)
	//
КонецПроцедуры
//
Процедура ОбработатьОтключениеКлиента(ДанныеТела)
	//
КонецПроцедуры
//
Процедура ОбработатьОшибку(ДанныеТела)
	//
КонецПроцедуры

#КонецОбласти

#Область ЛокальныеФункции

Функция ПолучитьJSONФайл(ДанныеТела)
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла("json");
	ЗаписьJSON = Новый ЗаписьJSON; 
	ЗаписьJSON.ОткрытьФайл(ИмяВременногоФайла);
	ЗаписатьJSON(ЗаписьJSON, ДанныеТела,Новый НастройкиСериализацииJSON); 
	ЗаписьJSON.Закрыть();
	Возврат ИмяВременногоФайла;
КонецФункции
//
Функция ПолучитьДанныеТела(ДанныеТелаJSON)
	ДанныеТела = Новый Структура;
	ДанныеТела.Вставить("Идентификатор",ДанныеТелаJSON.id);
	ДанныеТела.Вставить("ИдентификаторОтправителя",ДанныеТелаJSON.whatsapp_id);
	ДанныеТела.Вставить("ИмяСобытия",ДанныеТелаJSON.event_action);
	ДанныеТела.Вставить("ДатаСобытия",ДанныеТелаJSON.event_date);
	ДанныеТела.Вставить("КодСостояния",ДанныеТелаJSON.status_code);
	//
	ДанныеСобытия = Новый Структура;
	//
	Если ДанныеТелаJSON.event_action = "error" Тогда 
		ДанныеСобытия.Вставить("СодержаниеОшибки",ДанныеТелаJSON.event_data.message.error);	
	ИначеЕсли ДанныеТелаJSON.event_action = "disconnect" Тогда
		ДанныеСобытия.Вставить("Причина",ДанныеТелаJSON.event_data.message.reason);
	Иначе
		ДанныеСобытия.Вставить("Идентификатор",ДанныеТелаJSON.event_data.message.id);
		ДанныеСобытия.Вставить("Просмотрено",ДанныеТелаJSON.event_data.message.ack);
		ДанныеСобытия.Вставить("СодержитМедиаФайл",ДанныеТелаJSON.event_data.message.hasMedia);
		ДанныеСобытия.Вставить("КлючМедиа",ДанныеТелаJSON.event_data.message.mediaKey);
		ДанныеСобытия.Вставить("Текст",ДанныеТелаJSON.event_data.message.body);
		ДанныеСобытия.Вставить("Тип",ДанныеТелаJSON.event_data.message.type);
		ДанныеСобытия.Вставить("ДатаСоздания",ДанныеТелаJSON.event_data.message.timestamp);
		ДанныеСобытия.Вставить("ИдентификаторОтправителя",ДанныеТелаJSON.event_data.message.from);
		ДанныеСобытия.Вставить("ИдентификаторПолучателя",ДанныеТелаJSON.event_data.message.to);
		ДанныеСобытия.Вставить("Перенаправлено",ДанныеТелаJSON.event_data.message.isForwarded);
	КонецЕсли;
	//
	ДанныеТела.Вставить("ДанныеСобытия",ДанныеСобытия);
	//
	Возврат ДанныеТела;
КонецФункции

#КонецОбласти


Функция AllPOST(Запрос)
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(Запрос.ПолучитьТелоКакСтроку(КодировкаТекста.UTF8));
	ДанныеТелаJSON = ПрочитатьJSON(ЧтениеJSON);
	ЧтениеJSON.Закрыть();
	//
    ДанныеТела = ПолучитьДанныеТела(ДанныеТелаJSON);
	//
	Если ДанныеТела.ИмяСобытия = "message" Тогда
		ОбработатьВходящееСообщение(ДанныеТела);
	ИначеЕсли ДанныеТела.ИмяСобытия = "sent" Тогда
		ОбработатьДоставкуСообщения(ДанныеТела);
	ИначеЕсли ДанныеТела.ИмяСобытия = "ack" Тогда
		ОбработатьЧтениеСообщения(ДанныеТела);
	ИначеЕсли ДанныеТела.ИмяСобытия = "disconnect" Тогда
		ОбработатьОтключениеКлиента(ДанныеТела);
	ИначеЕсли ДанныеТела.ИмяСобытия = "error" Тогда
		ОбработатьОшибку(ДанныеТела);
	КонецЕсли;
	//
	Ответ = Новый HTTPСервисОтвет(200);
	ДанныеТелаОтвета = Новый Структура;
	ДанныеТелаОтвета.Вставить("result","OK");
	ДанныеТелаОтвета.Вставить("id",ДанныеТела.Идентификатор);
	Возврат Ответ;
КонецФункции
