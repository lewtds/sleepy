using Notify;
using Config;
using Gtk;

#if WITH_APPINDICATOR
using AppIndicator;
#endif

class TimerNotification : GLib.Object
{
  public TimerNotification(SleepTimer timer)
  {
    this.timer = timer;
    string sv_name, sv_vendor, sv_version, sv_spec_version;

    //Check notification server name and vendor
    get_server_info(out sv_name, out sv_vendor, out sv_version,
                    out sv_spec_version);
    print("%s\n%s\n%s\n%s", sv_name,sv_vendor, sv_version,
          sv_spec_version);
    noti = new Notification(" ",null,null);
    noti.set_category("Timer");

    if (sv_name == "gnome-shell")
      {
        //Sweet, it's gnome-shell with "resident" and "actions" support
        noti.set_hint("resident", true);
        timer.on_target.connect(() =>
        {
          try {
              noti.close();
              noti.clear_actions();
              noti.add_action("close", _("OK, I'll sleep."), Gtk.main_quit);
              string body = _("You should go to bed now");
              if (timer.get_next_sleep_target() != null)
                {
                  body += _(" or if you insist I'd try to urge you later at ") +
                  timer.get_next_sleep_target().format("%I:%M %p");
                }

              noti.update(_("Time's up!"), body + ".", "appointment-soon");
            }
          catch (Error e)
            {
              warning(_("Notification error: %s"),e.message);
            }
        });
        timer.on_minute.connect(() =>
        {
          try {
              int minute_left = timer.minutes_left();
              string target = timer.current_target.format("%I:%M %p");
              switch (minute_left)
                {
                case 30:
                  noti.update(_("30 minutes left to %s").printf(target),_("Don't worry, just take your time"),"appointment-soon");
                  noti.show();
                  break;
                case 15:
                  noti.update(_("15 minutes left to %s").printf(target), _("Feeling sleepy yet? ;)"), "appointment-soon");
                  noti.show();
                  break;
                case 5:
                  noti.update(_("5 minutes left to %s").printf(target),_("Please save your work and prepare for bed."),"appointment-soon");
                  noti.show();
                  break;
                }
            }
          catch (Error e)
            {
              warning(_("Notification error: %s"),e.message);
            }
        });
        timer.started.connect(() =>
        {
			//print("Noti\n");
          try {
              noti.close();
              noti.clear_actions();
              noti.add_action("close", _("Shut the alarm!"), () => {
                try {
                    noti.close();
                    Gtk.main_quit();
                  }
                catch (Error e)
                  {
                    warning(_("Notification error: %s"),e.message);
                  }

              });
              string message = _("The clock is ticking...");
              //Vala 0.14.0 doesn't support string literal concatenation yet :(
              string body = _("and if not intercepted en route it will go off at %s. That's %s to go. Have fun! ;)").printf(
                timer.current_target.format("%I:%M %p"),timer.time_left_to_string());
              noti.update(message, body, "appointment-soon" );
              noti.show();
              //print("Notification sent:%s\n",message);
            }
          catch (Error e)
            {
              warning(_("Notification error: %s"),e.message);
            }
        });
      }
    else
      {
#if WITH_APPINDICATOR
        //fallback to APPINDICATOR
        this.indicator = new Indicator(APPNAME+"Indicator","clock",
                                       IndicatorCategory.APPLICATION_STATUS);
        indicator.set_status(IndicatorStatus.ACTIVE);
        indicator.set_attention_icon("indicator-messages-new");
        indicator.set_label("00:12 left",null);

        menu = new Menu();

        item = new MenuItem.with_label(_("Quit"));
        item.activate.connect(() =>
        {
          Gtk.main_quit();
        });
        item.show();
        menu.append(item);

        item = new MenuItem.with_label("Bar");
        item.show();
        item.activate.connect(() =>
        {
          indicator.set_label("oae", null);
        });
        menu.append(item);
        indicator.set_menu(menu);
#endif
      }
  }
#if WITH_APPINDICATOR
  private Indicator indicator;
  private Menu menu;
  private MenuItem item;
#endif

  private Notification noti;
  SleepTimer timer;
}
