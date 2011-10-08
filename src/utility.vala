DateTime? parse_time_string(string time)
requires (time.length > 3 && time.length <8)
{

        var now = new DateTime.now_local();
        if (!(":" in time)) {
                return null;
        } else {
                var timestring = time.split(":");
                int hour = timestring[0].to_int();
                //TODO: add support for the AM/PM nomenclature
                //6:24PM or 6:24
                //print("%d\n", timestring[1].length);
                if (timestring[1].length != 4 && timestring[1].length !=2) return null;

                //Convert 12-hour to 24-hour
                //eliminate possibilities like 13:00PM
                //if (/[AaPp][Mm]/.match(timestring[1]) && (hour >12)) return null;

                if (/[Aa][Mm]/.match(timestring[1])) {
                        timestring[1] = timestring[1][0:-2];
                } else if (/[Pp][Mm]/.match(time)) {
                        //TODO: what'd happen if hour = 12 ?
                        hour +=12;
                        timestring[1] = timestring[1][0:-2];
                }

                int minute = timestring[1].to_int();


                if ((hour < now.get_hour()) || (hour == now.get_hour() && minute <= now.get_minute()) ) {
                        //next day?
                        //TODO: test month bound
                        now = new DateTime.local(now.get_year(), now.get_month(),
                                                 now.get_day_of_month()+1,hour, minute,0);
                } else {
                        now = new DateTime.local(now.get_year(), now.get_month(),
                                                 now.get_day_of_month(), hour, minute,0);
                }
        }
        //print (now.format("%x %X\n"));
        //return new DateTime();
        return now;
}

string timespan_to_string(TimeSpan span)
{
        //print("%lld\n",span);
        int minutes = (int) (span / 60000000);
        int hours = minutes / 60;
        minutes %= 60;

        return ngettext("%d hour", "%d hours", hours).printf(hours) + " "
               + ngettext("%d minute", "%d minutes", minutes).printf(minutes);
}
