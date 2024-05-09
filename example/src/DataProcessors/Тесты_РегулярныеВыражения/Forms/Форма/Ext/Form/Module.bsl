﻿&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ЭтотОбъект.ФормаИсходныйТекст = "Просто текст [ПАРАМЕТР] для замены";
	ЭтотОбъект.ФормаШаблонВыражения = "(?i)\[Параметр[0-9]*\]";
	ЭтотОбъект.ФормаТекстЗамены = "ЗНАЧЕНИЕ_ПАРАМЕТРА"
КонецПроцедуры

&НаКлиенте
Асинх Процедура Команда1(Команда)
	результатПодключения = Ждать Подключить(
		"/mnt/SSD_2TB_2023/git/onec/addins/test-addin2/target/debug/libtest_addin2.so",
		"ТестоваяКомпонента");
	Если результатПодключения.Успех = Ложь Тогда
		сообщение = Новый СообщениеПользователю;
		сообщение.Текст = результатПодключения.ТекстОшибки;
		сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	
	объектВК = Новый("Addin.ТестоваяКомпонента.TestAddIn");	
	статусРезультатВК = Ждать объектВК.ПолучитьСтатусАсинх();
	Сообщить(статусРезультатВК.Значение);
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПодключитьНаСервере() Экспорт
	результат = Новый Структура("Успех, ТекстОшибки", Истина, "");
	Если ПодключитьВнешнююКомпоненту(
			"/mnt/SSD_2TB_2023/git/onec/addins/test-addin2/target/debug/libtest_addin2.so", 
			"ТестоваяКомпонента", ТипВнешнейКомпоненты.Native) = Ложь Тогда
		
		результат.Успех = Ложь;
		результат.ТекстОшибки = "Ошибка подключение внешней компоненты";
		
		Возврат результат;
	КонецЕсли; 
	

	Возврат результат;
КонецФункции

&НаКлиенте 
Асинх Функция Подключить(Знач путьФайла, имяВК) Экспорт
	результат = Новый Структура("Успех, ТекстОшибки", Истина, "");
	
	подключено = Ждать ПодключитьВнешнююКомпонентуАсинх(
			путьФайла, 
			имяВК, ТипВнешнейКомпоненты.Native);
	
	Если подключено = Ложь Тогда
		результат.Успех = Ложь;
		результат.ТекстОшибки = "Ошибка подключение внешней компоненты";
		
		Возврат результат;
	КонецЕсли; 
	
	Возврат результат;
КонецФункции

&НаКлиенте
Асинх Процедура ЗаменитьТекст(Команда)
	результатПодключения = Ждать Подключить(
		"/mnt/SSD_2TB_2023/git/onec/addins/test-addin2/target/debug/libtest_addin2.so",
		"ТестоваяКомпонента");
	Если результатПодключения.Успех = Ложь Тогда
		сообщение = Новый СообщениеПользователю;
		сообщение.Текст = результатПодключения.ТекстОшибки;
		сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	
	РегВыраженияВК = Новый("Addin.ТестоваяКомпонента.TestAddIn");
	результатЗамены = Ждать РегВыраженияВК.ЗаменитьТекстАсинх(
		ЭтотОбъект.ФормаИсходныйТекст, ЭтотОбъект.ФормаШаблонВыражения, ЭтотОбъект.ФормаТекстЗамены);
	
	ЭтотОбъект.ФормаРезультатТекст = результатЗамены.Значение;
КонецПроцедуры

