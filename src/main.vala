
//TODO: Allow non-interactive setup
using Config;
using Gtk;

void main (string[] args)
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
      timer = new SleepTimer(new DateTime.now_local().add_hours(8));
      var noti = new TimerNotification(timer);
      timer.choose_target(1);
      timer.start();

    }
  /*
  var wake_up_time = new DateTime.now_local().add_hours(8);
  var timer = new SleepTimer(wake_up_time);
  timer.choose_target(2);
  timer.start();
  */
  Gtk.main();
  Notify.uninit();
}

