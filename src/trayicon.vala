using AppIndicator;
using Gtk;
using Notify;

class TimerControl : GLib.Object
{
        public TimerControl()
        {
                indicator = new Indicator(_("Sleep Timer Indicator"), "appointment-soon", IndicatorCategory.APPLICATION_STATUS);
                indicator.set_status(IndicatorStatus.ACTIVE);
                build_initial_menu();
        }
        public TimerControl.non_interactive(DateTime wake_target)
        {
                this();
                timer = new SleepTimer(wake_target);
                noti = new TimerNotification(timer);
        }
        private void start_timer()
        {
                //Common clock alarm entry init code
                build_initial_menu();
                noti = new TimerNotification(timer);
                timer.on_every_minute.connect(indicator_loop);
                timer.start();


//Note: We are building the menu upward

                stop_button = new MenuItem.with_label(_("Stop"));
                stop_button.activate.connect(()=> {
                        timer.stop();
                        build_initial_menu();
                });
                stop_button.show();
                menu.prepend(stop_button);

                var separator = new SeparatorMenuItem();
                separator.show();
                menu.prepend(separator);

                //Remaining time
                time_label = new MenuItem.with_label(_("%s left").printf(timespan_to_string(timer.get_remaining())));
                time_label.show();
                menu.prepend(time_label);
                separator = new SeparatorMenuItem();
                separator.show();
                menu.prepend(separator);

                //Show alarm target
                var item = new MenuItem.with_label("%s -> %s".printf(timer.current_target.format("%I:%M %p"), timer.wake_target.format("%I:%M %p")));
                item.show();
                menu.prepend(item);
        }

        private void build_initial_menu()
        {
                menu = new Menu();
                var item = new MenuItem.with_label(_("Set Timer"));
                /*item.activate.connect(() => {
                	timer.start();
                	});*/

                //TODO: Generate entries automatically and from preset
                var sub = new Menu();
                var subitem = new MenuItem.with_label(_("6:00 AM"));
                subitem.activate.connect(()=> {
                        timer = new SleepTimer(parse_time_string("6:00AM"));
                        start_timer();
                });
                subitem.show();
                sub.append(subitem);

                subitem = new MenuItem.with_label(_("6:30 AM"));
                subitem.activate.connect(()=> {
                        timer = new SleepTimer(parse_time_string("6:30AM"));
                        start_timer();
                });
                subitem.show();
                sub.append(subitem);

                subitem = new MenuItem.with_label(_("7:00 AM"));
                subitem.activate.connect(()=> {
                        timer = new SleepTimer(parse_time_string("7:00AM"));
                        start_timer();
                });
                subitem.show();
                sub.append(subitem);

                item.set_submenu(sub);
                item.show();
                menu.append(item);

                item = new SeparatorMenuItem();
                item.show();
                menu.append(item);

                item = new MenuItem.with_label(_("Quit"));
                item.activate.connect(Gtk.main_quit);
                item.show();
                menu.append(item);

                indicator.set_menu(menu);
        }
        private void indicator_loop()
        {
                //Update the indicator status, icon,etc...
                time_label.set_label(_("%s left").printf(timespan_to_string(timer.get_remaining())));

        }
        private SleepTimer timer;
        private TimerNotification noti;
        private Indicator indicator;
        private Menu menu;
        private MenuItem time_label;
        private MenuItem stop_button;
}

class TimerNotification : GLib.Object
{
        public TimerNotification(SleepTimer _timer)
        {
                timer = _timer;
                unowned List<string> caps = get_server_caps();
                //TODO: Implement GNOME Shell support
                if (caps.find("actions")!=null && caps.find("persistent")!=null) persistent_and_actions = true;
                else persistent_and_actions = false;

                noti = new Notification("","","appointment-soon");

                timer.started.connect(() => {
                        try {

                                noti.update(_("The clock is ticking..."),
                                _("And it will go off at %s. You have %s left, have fun :-j").printf(timer.current_target.format("%I:%M %p"),
                                timespan_to_string(timer.get_remaining())),
                                "appointment-soon");
                                noti.show();
                        } catch (Error e)
                        {
                                warning("Notification Error: %s", e.message);
                        }
                });
                timer.stopped.connect(() => {
                        try {

                                noti.update(_("The clock has stopped!"), null, "appointment-soon");
                                noti.show();
                        } catch (Error e)
                        {
                                warning("Notification Error: %s", e.message);
                        }
                });
                timer.on_every_minute.connect(notification_loop);

        }
        private void notification_loop()
        {
                try {
                        int minute_left = (int) (timer.get_remaining() / 60000000);
                        //TODO: Allow customized messages
                        switch (minute_left) {
                        case 30:
                                noti.update(_("30 minutes left..."), _("Take your time. :-j"), "appointment-soon");
                                noti.show();
                                break;
                        case 15:
                                noti.update(_("15 minutes left..."), _("Maybe preparing the bed now is not a bad idea. ;)"), "appointment-soon");
                                noti.show();
                                break;
                        case 5:
                                noti.update(_("5 minutes left..."), _("Please save your work and get ready for bed. ZzzZzz"), "appointment-soon");
                                noti.show();
                                break;
                        }
                } catch (Error e) {
                        warning("Notification Error: %s", e.message);
                }
        }
        private bool persistent_and_actions;
        private SleepTimer timer;
        private Notification noti;
}
