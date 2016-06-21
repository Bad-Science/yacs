/**
 * Schedule view. Displays periods of selected courses in a week grid.
 * @param {Object} data - Object containing schedule data as returned from the API
 * @return {undefined}
 * @memberOf Yacs.views
 */
Yacs.views.schedule = function (data) {
  Yacs.setContents(HandlebarsTemplates.schedule(data));
  var scheduleElement = document.querySelector('#scheduleContainer');
  var leftSwitchElement = document.querySelector('#leftSwitch');
  var rightSwitchElement = document.querySelector('#rightSwitch');
  var scheduleNumElement = document.querySelector('#scheduleNum');
  var crnListElement = document.querySelector('#crnList');
  var schedule = new Schedule(scheduleContainer);
  var scheduleIndex = 0;
  var courseNumbers = [];

  // this function will be deprecated when backend is updated to use minutes-since-midnight format
  // see issue #102
  var toMinutes = function (timeString) {
    var int = parseInt(timeString);
    return Math.floor(int / 100) * 60 + int % 100;
  }

  var prepareSchedule = function (schedule) {
    var events = [];
    var crns = [];

    schedule.sections.forEach(function (section) {
      crns.push(section.crn)
      
      var color = courseNumbers.indexOf(section.course_number);
      if (color === -1) {
        courseNumbers.push(section.course_number);
        color = courseNumbers.length - 1;
      }

      section.periods.forEach(function (period) {
        events.push({
          start: toMinutes(period.start),
          end: toMinutes(period.end),
          day: period.day,
          colorNum: color,
          title: section.department_code + ' ' + section.course_number + ' - ' + section.name
        });
      });
    });
    schedule.render = { events: events, crns: crns };
  };

  var showSchedule = function (index) {
    schedule.setEvents(data.schedules[index].render.events)
    scheduleNumElement.textContent = index + 1;
    crnListElement.textContent = 'CRNs: ' + data.schedules[index].render.crns.join(', ');
  }

  if(data.schedules.length == 0) {
    // TODO: this will happen if there are no available schedules
    return;
  }

  Yacs.on('click', leftSwitchElement, function () {
    scheduleIndex = (--scheduleIndex < 0 ? data.schedules.length - 1 : scheduleIndex);
    showSchedule(scheduleIndex);
  });
  Yacs.on('click', rightSwitchElement, function () {
    scheduleIndex = (++scheduleIndex < data.schedules.length ? scheduleIndex : 0);
    showSchedule(scheduleIndex);
  });

  data.schedules.forEach(function (schedule, index) {
    prepareSchedule(schedule);
    var schedulePreviewElement = document.querySelector('schedule-preview[data-index="' + index + '"]');
    var schedulePreview = new Schedule(schedulePreviewElement, { preview: true });
    schedulePreview.setEvents(schedule.render.events);
  });

  showSchedule(scheduleIndex);
};
