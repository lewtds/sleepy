
//TODO: Allow non-interactive setup
using Config;
using Gtk;

void print_help()
{

}

DateTime? parse_time(string args)
requires (args.length > 3 && args.length <8)
{

  var now = new DateTime.now_local();
  if (!(":" in args))
    {
      return null;
    }
  else
    {
      var timestring = args.split(":");
      int hour = timestring[0].to_int();
      //TODO: add support for the AM/PM nomenclature
      //6:24PM or 6:24
      print("%d\n", timestring[1].length);
      if (timestring[1].length != 4 && timestring[1].length !=2) return null;

      //Convert 12-hour to 24-hour
      //eliminate possibilities like 13:00PM
      //if (/[AaPp][Mm]/.match(timestring[1]) && (hour >12)) return null;

      if (/[Aa][Mm]/.match(timestring[1]))
        {
          timestring[1] = timestring[1][0:-2];
        }
      else if (/[Pp][Mm]/.match(args))
        {
          //TODO: what'll happen if hour = 12 ?
          hour +=12;
          timestring[1] = timestring[1][0:-2];
        }

      int minute = timestring[1].to_int();

      //Compare
      if ((hour <= now.get_hour()) && (minute <= now.get_minute()) )
        {
          //next day?
          //TODO: test month bound
          now = new DateTime.local(now.get_year(), now.get_month(),
                                   now.get_day_of_month()+1,hour, minute,0);
        }
      else
        {
          now = new DateTime.local(now.get_year(), now.get_month(),
                                   now.get_day_of_month(), hour, minute,0);
        }
    }
  print (now.format("%x %X"));
  //return new DateTime();
  return now;
}


int main (string[] args)
{

  Intl.setlocale(LocaleCategory.ALL, "");
  Intl.bindtextdomain(GETTEXT_PACKAGE, LOCALE_DIR);
  Intl.textdomain(GETTEXT_PACKAGE);
  Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");

  Gtk.init(ref args);
  Environment.set_application_name(APPLONGNAME);
  if (Notify.init(APPLONGNAME) == false)
    {
      warning("Cannot initialize libnotify.");
    };
  //var window = new Gtk.Window();

  //build timer setup control
  SleepTimer timer;

  if (args.length == 1)
    {
      timer = new SleepTimer(new DateTime.now_local().add_hours(8));
      var setup = new SetupAssistant(timer);
      setup.set_icon_name("appointment-soon");
      setup.set_size_request(450,300);
      setup.show_all();
    }
  else if (args.length == 2 )
    {
      var target = parse_time(args[1]);
      if (target == null) return -1;
      timer = new SleepTimer(target);
      timer.choose_target(0);
      if (!timer.start()) return -1;
	  
    }
  /*
  var wake_up_time = new DateTime.now_local().add_hours(8);
  var timer = new SleepTimer(wake_up_time);
  timer.choose_target(2);
  timer.start();
  */
  Gtk.main();
  Notify.uninit();
  return 0;
}

