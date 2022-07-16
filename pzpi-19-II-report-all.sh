#! /bin/bash

select input_file in QUIT ПІБ*-comma_separated.csv; do
	[ "${input_file}" = 'QUIT' ] && exit
	[ "${REPLY}" = 'q' ] && exit
	echo "Input file: ${input_file}"
	break
done

# if [ ! -e result.csv ]; then
# 	echo 'No input file: result.csv'
# 	exit 1
# fi

#####################################################

#     1	Ім'я
#     2	Прізвище
#     3	"Індивідуальний номер"
#     4	Заклад
#     5	Відділ
#     6	"Електронна пошта"
#     7	"Загальне за курс (Бали)"
#     8	"Відвідування:Відвідування занять (Бали)"
#     9	"Завдання:Практична робота №1 (Завдання №1) (Бали)"
#    10	"Завдання:Практична робота №2 (Завдання №2) (Бали)"
#    11	"Завдання:Лабораторна робота №1 (Завдання №3) (Бали)"
#    12	"Завдання:Лаборатона робота №2 (Завдання №4) (Бали)"
#    13	"Завдання:Лабораторна робота №3 (Завдання №5) (Бали)"
#    14	"Завдання:Відповіді на питання екзаменаційних білетів (pdf розміром не більше 5 МБ) (Бали)"
#    15	"Завдання:Сертифікати дистанційних курсів Android (за бажанням студента) (pdf) (Бали)"
#    16	"Відвідування:Відвідування екзамену (Бали)"
#    17	"Останні завантаження з цього курсу"

#####################################################

#     1	Ім'я,
#     2	Прізвище,
#     3	"Індивідуальний номер",
#     4	Заклад,
#     5	Відділ,
#     6	"Електронна пошта",
#     7	"Загальне за курс (Бали)",
#     8	"Відвідування:Відвідування (Бали)",
#     9	"Відвідування:Відвідування практичних занять / лабораторних робіт з дисципліни (Бали)",

#    40	"Завдання:Звіт з Пз/Лб 1 (Бали)", група 11 *
#    41	"Завдання:Звіт з Пз/Лб 2 (Бали)",
#    42	"Завдання:Звіт з Пз/Лб 4 (Бали)",
#    43	"Завдання:Звіт з Пз/Лб 6 (Бали)",
#    44	"Завдання:Звіт з Пз/Лб 3 (Бали)",
#    45	"Завдання:Звіт з Пз/Лб 5 (Бали)",

#    76	"Virtual programming lab:Завдання на Пз/Лб 1 (Бали)", група 11 *
#    77	"Virtual programming lab:Завдання на Пз/Лб 2 (Бали)",
#    78	"Virtual programming lab:Завдання на Пз/Лб 3 (Бали)",
#    79	"Virtual programming lab:Завдання на Пз/Лб 4 (Бали)",
#    80	"Virtual programming lab:Завдання на Пз/Лб 5 (Бали)",
#    81	"Virtual programming lab:Завдання на Пз/Лб 6 (Бали)",

#    82	"Завдання:Звіти виконаних робіт (Бали)",
#    83	"Відвідування:Відвідування екзамену (Бали)",
#    84	"Завдання:Відповіді на питання екзаменаційних білетів (pdf розміром не більше 5 МБ) (Бали)",
#    85	"Завдання:Сретифікити дистанційних курсів Android (за бажанням студента) (pdf) (Бали)",
#    86	"Останні завантаження з цього курсу"

cat "${input_file}" | gawk '

function result_string(res_num,   res_str) {

    res_num = int(res_num)

    if (res_num >= 96) {
	res_str="5 (відмінно), A"
	vidminno++
	ziavylosia++
    } else if ((res_num >= 90) && (res_num <= 95)) {
	res_str="5 (відмінно), B"
	vidminno++
	ziavylosia++
    } else if ((res_num >= 75) && (res_num <= 89)) {
	res_str="4 (добре), C"
	dobre++
	ziavylosia++
    } else if ((res_num >= 66) && (res_num <= 74)) {
	res_str="3 (задовільно), D"
	zadovilno++
	ziavylosia++
    } else if ((res_num >= 60) && (res_num <= 65)) {
	res_str="3 (задовільно), E"
	zadovilno++
	ziavylosia++
    } else if ((res_num >= 35) && (res_num <= 59)) {
	res_str="2 (незадовільно), FX"
	ne_zadovilno++
	ziavylosia++
    } else if ((res_num >= 1) && (res_num <= 34)) {
	res_str="2 (незадовільно), F"
	ne_zadovilno++
	ziavylosia++
    } else {
	res_str="не з\47явився"
	ne_ziavylosia++
    }

    return res_str
}

function whitespace(num,   whitespase_str) {
    if (num < 10 ) {
	whitespase_str="  "
    } else if (num < 100) {
	whitespase_str=" "
    } else {
	whitespase_str=""
    }
    return whitespase_str
}

BEGIN {
    FS=","

    stud_num = 1

    vidminno = 0
    dobre = 0
    zadovilno = 0
    ne_zadovilno = 0
    ziavylosia = 0
    ne_ziavylosia = 0

    print "-----------------"
    print "№   Прізвище ім\47я\t\tСеместр\tЕкзамен\tСертифікат\tДисципліна"
}

NR == 1 {
    field_pattern = "Останні завантаження з цього курсу"
    if ($17 ~ field_pattern) {
	potik=1
    } else if ($86 ~ field_pattern) {
	potik=2
    } else {
	potik=0 
    }
}

NR > 1 {

    if (potik == 1) {
	task1 = 1.0 * $9
	task2 = 1.0 * $10
	task3 = 1.0 * $11
	task4 = 1.0 * $12
	task5 = 1.0 * $13
	task6 = 0.0
	ekzam = 1.0 * $14
	sertyf = 1.0 * $15
    } else if (potik == 2) {
	task1 = 20.0 * ($10 + $16 + $22 + $28 + $34 + $40)
	task2 = 20.0 * ($11 + $17 + $23 + $29 + $35 + $41)
	task3 = 20.0 * ($12 + $18 + $24 + $30 + $36 + $42)
	task4 = 20.0 * ($13 + $19 + $25 + $31 + $37 + $43)
	task5 = 20.0 * ($14 + $20 + $26 + $32 + $38 + $44)
	task6 = 20.0 * ($15 + $21 + $27 + $33 + $39 + $45)
	semestr = (task1 + task2 + task3 + task4 + task5 + task6)/5.0
	ekzam = 1.0 * $84
	sertyf = 1.0 * $85
    } else {
	task1 = 0
	task2 = 0
	task3 = 0
	task4 = 0
	task5 = 0
	task6 = 0
	ekzam = 0
	sertyf = 0
    }
    semestr = (task1 + task2 + task3 + task4 + task5 + task6)/5.0
    result = int((0.6 * semestr) + (0.4 * ekzam) + (sertyf) + 0.9)
    if (result > 100 ) result = 100
    if ((result >= 20) && (result < 35)) result = 35

    if(0) {
	print (stud_num) " " whitespace(stud_num) $2 " " $1 " " $6 \
	"\t" task1 "\t" task2 "\t" task3 "\t" task4 "\t" task5 "\t" task6 \
	"\tсем.=" semestr "\tекз.=" ekzam "\tсерт.=" sertyf "\tрез.=" result \
	"\t" result_string(result)
    } else {
#	print (stud_num) " " whitespace(stud_num) $2 " " $1 " " $6 "\t" result "\t" result_string(result)
	print (stud_num) " " whitespace(stud_num) $2 " " $1 "\t" \
	"\t" semestr "\t" ekzam "\t" sertyf\
	"\t" result "  " result_string(result)

    }
    stud_num++
}

END {
    print "-----------------"
    print "Bідмінно:      " vidminno 
    print "Добре:         " dobre 
    print "Задовільно:    " zadovilno
    print "Не задовільно: " ne_zadovilno 
    print "Не з\47явилися:  " ne_ziavylosia
    print "РАЗОМ:         " vidminno + dobre + zadovilno + ne_zadovilno + ne_ziavylosia
    print "-----------------"
    print "Потік: " potik
    print "-----------------"

}
' | column -s "	" -t

