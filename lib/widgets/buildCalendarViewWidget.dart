import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';

class BuildCalendarViewWidget extends StatelessWidget {
  final DateTime selectedDate;
  final EventList<Event> markedDateMap;
  final Function(DateTime, List<Event>) onDayPressed;
  final Function(DateTime) onDateSelected;

  const BuildCalendarViewWidget({super.key,
    required this.selectedDate,
    required this.markedDateMap,
    required this.onDayPressed,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CalendarCarousel<Event>(
      weekdayTextStyle: const TextStyle(color: Colors.white),
      iconColor: Colors.white,
      todayButtonColor: Colors.black,
      todayTextStyle: const TextStyle(color: Colors.white),
      selectedDayButtonColor: Colors.white38,
      thisMonthDayBorderColor: Colors.grey,
      headerTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      markedDatesMap: markedDateMap,
      customDayBuilder: _customDayBuilder,
      onDayPressed: onDayPressed,
      weekFormat: false,
      height: 380.0,
      width: 370,
      selectedDateTime: selectedDate,
    );
  }

  Widget _customDayBuilder(
    bool visible,
    int index,
    bool isSelectedDay,
    bool isToday,
    bool isPrevMonthDay,
    TextStyle textStyle,
    bool isNextMonthDay,
    bool isThisMonthDay,
    DateTime day,
  ) {
    Color textColor = Colors.white;

    if (day.weekday == 7) {
      // Sunday
      textColor = Colors.red;
    } else if (day.weekday == 6) {
      // Saturday
      textColor = Colors.blue;
    }

    return Center(
      child: Text(
        day.day.toString(),
        style: TextStyle(color: textColor),
      ),
    );
  }
}
