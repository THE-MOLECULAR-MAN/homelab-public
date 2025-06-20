// https://support.google.com/docs/answer/3094139?hl=en&sjid=4423763652442581666-NA
// https://developers.google.com/apps-script/guides/sheets/functions#using_a_custom_function
// https://www.jslint.com/
// https://www.scaler.com/topics/string-concatenation-javascript/
// https://support.google.com/docs/answer/2942256?hl=en&co=GENIE.Platform%3DDesktop
// https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
// https://en.wikipedia.org/wiki/ICalendar
// https://developers.google.com/apps-script/guides/sheets/functions




// https://en.wikipedia.org/wiki/ICalendar

function create_ics_file(timestamp_block_start, timestamp_block_end, event_name, event_description, location, event_uid)
{

// BEGIN:VCALENDAR
// VERSION:2.0
// PRODID:-//hacksw/handcal//NONSGML v1.0//EN
// END:VCALENDAR

  return `
BEGIN:VEVENT
UID:${event_uid}
DTSTAMP:${format_date_ics(timestamp_block_start)}
ORGANIZER;CN=John Doe:MAILTO:john.doe@example.com
DTSTART:${format_date_ics(timestamp_block_start)}
DTEND:${format_date_ics(timestamp_block_end)}
SUMMARY:${event_name}
DESCRIPTION;ENCODING=QUOTED-PRINTABLE:${event_description}
LOCATION:${location}
CLASS:PRIVATE
END:VEVENT
`
}


function format_date_ics(datetimeString) {
  var moment = new Date(datetimeString);
  // example date format: 19970714T170000Z
  var timeZone = "America/New_York";
  var format1 =           "YYYYMMdd";
  var format2 =           "HHmmSS";

  output_part1 = Utilities.formatDate(moment, timeZone, format1);
  output_part2 = Utilities.formatDate(moment, timeZone, format2);

  return output_part1.concat("T", output_part2)

}


function MD5 (input) {
  var rawHash = Utilities.computeDigest(Utilities.DigestAlgorithm.MD5, input);
  var txtHash = '';
  for (i = 0; i < rawHash.length; i++) {
    var hashVal = rawHash[i];
    if (hashVal < 0) {
      hashVal += 256;
    }
    if (hashVal.toString(16).length == 1) {
      txtHash += '0';
    }
    txtHash += hashVal.toString(16);
  }
  return txtHash;
}