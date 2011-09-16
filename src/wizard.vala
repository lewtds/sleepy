class ArrowButton : Gtk.Button
{
  public ArrowButton(Gtk.ArrowType arrow_type,
                     Gtk.ShadowType shadow_type)
  {
    arrow = new Gtk.Arrow(arrow_type, shadow_type);
    this.add(arrow);
  }
  public ArrowButton.up()
  {
    this(Gtk.ArrowType.UP,Gtk.ShadowType.OUT);
  }
  public ArrowButton.down()
  {
    this(Gtk.ArrowType.DOWN,Gtk.ShadowType.OUT);
  }
  private Gtk.Arrow arrow;
}

// TODO: add date control, use SpinButton?

class ClockSpin : Gtk.VBox
{
  public ClockSpin (string label, int climb_rate)
  {
    this.climb_rate = climb_rate;
    this.label = new Gtk.Label(label);
    up_button = new ArrowButton.up();
    down_button = new ArrowButton.down();
    up_button.clicked.connect(() =>
    {
      this.label.label = button_pressed(climb_rate);
    });
    down_button.clicked.connect(() =>
    {
      this.label.label = button_pressed(-climb_rate);
    });

    this.pack_start(up_button);
    this.pack_start(this.label);
    this.pack_start(down_button);
  }
  public void new_label (string new_label)
  {
    this.label.label = new_label;
  }
  private Gtk.Label label;
  private ArrowButton up_button;
  private ArrowButton down_button;
  public signal string button_pressed(int rate);

  int climb_rate;
}


class SetclockPage : Gtk.HBox
{
  public SetclockPage (SleepTimer timer)
  {
    this.timer = timer;
    hour_spin = new ClockSpin(this.timer.wake_up_time.format("%I"), 60);
    minute_spin = new ClockSpin(this.timer.wake_up_time.format("%M"),1);
    ampm_spin = new ClockSpin(this.timer.wake_up_time.format("%p"),720);
    var separator = new Gtk.Label(":");


    hour_spin.button_pressed.connect((rate) =>
    {
      timer.set_new_wake_up_time(this.timer.wake_up_time.add_minutes(rate));
      ampm_spin.new_label(this.timer.wake_up_time.format("%p")); //it only affects the ampm spin
      return timer.wake_up_time.format("%I");
    });
    minute_spin.button_pressed.connect((rate) =>
    {
      timer.set_new_wake_up_time(this.timer.wake_up_time.add_minutes(rate));
      hour_spin.new_label(this.timer.wake_up_time.format("%I")); //it affects the 2 other spins
      ampm_spin.new_label(this.timer.wake_up_time.format("%p"));
      return this.timer.wake_up_time.format("%M");
    });

    this.pack_start(hour_spin);
    this.pack_start(separator);
    this.pack_start(minute_spin);
    this.pack_start(ampm_spin);
  }

  private ClockSpin hour_spin;
  private ClockSpin minute_spin;
  private ClockSpin ampm_spin;

  private SleepTimer timer;
  public string title
  {
    get;
    private set;
  }
  public Gtk.AssistantPageType page_type
  {
    get;
    private set;
  }
  public bool complete
  {
    get;
    set;
  default=true;
  }
}

class ChooseTargetPage : Gtk.HBox
{
  public ChooseTargetPage(SleepTimer timer)
{
  this.timer = timer;

  var vbox = new Gtk.VBox(false, 0);
  button1 = new Gtk.RadioButton(null);
  button2 = new Gtk.RadioButton.from_widget(button1);
  button3 = new Gtk.RadioButton.from_widget(button1);

  button1.clicked.connect(() =>
  {
    this.timer.choose_target(1);
  });
  button2.clicked.connect(() =>
  {
    this.timer.choose_target(2);
  });
  button3.clicked.connect(() =>
  {
    this.timer.choose_target(3);
  });
  vbox.pack_start(new Gtk.Label("You should go to bed at one of these times:"));
  vbox.pack_start(button1);
  vbox.pack_start(button2);
  vbox.pack_start(button3);
  this.pack_start(vbox);

  this.title = "Choose a time to set the alarm";
  this.page_type = Gtk.AssistantPageType.CONTENT;

}

public void prepare_buttons(Gtk.Widget page)
{
  if (page == this)
    {
      button2.hide();
      button3.hide();
      button1.label = timer.sleep_targets.index(0).format("%r");
      button1.set_active(true);
      this.timer.choose_target(0);
      if (timer.sleep_targets.length > 1)
        {
          button2.label = timer.sleep_targets.index(1).format("%I:%M %p");
          button2.show();
          if (timer.sleep_targets.length > 2)
            {
              button3.label = timer.sleep_targets.index(2).format("%I:%M %p");
              button3.show();
            }
          //this.show_all();
        }
    }

}
private Gtk.RadioButton button1;
private Gtk.RadioButton button2;
private Gtk.RadioButton button3;
private SleepTimer timer;
public string title
{
  get;
  private set;
}
public Gtk.AssistantPageType page_type
{
  get;
  private set;
}
public bool complete
{
  get;
  set;
default=true;
}

}

class ConcludePage : Gtk.HBox
{
  public ConcludePage (SleepTimer timer)
{
  this.timer = timer;
  message = new Gtk.Label(null);
  this.pack_start(message);
}

public void prepare_message(Gtk.Widget page)
{
  if (page == this)
    {
      string text = "So you set your mind. I'll try to urge " +
                    "you to go to sleep at "+ timer.current_target.format("%I:%M %p");
      var next = timer.get_next_sleep_target();
      if (next != null)
        {
          text += " or, if you're deep in your work, at " + next.format("%I:%M %p");
        }
      text += ".";
      message.label = text;

    }

}
private SleepTimer timer;
private Gtk.Label message;
}

class SetupAssistant: Gtk.Assistant
{
  public SetupAssistant (SleepTimer timer)
  {
    this.timer = timer;

    var setclock = new SetclockPage(timer);
    this.append_page(setclock);
    this.set_page_complete(setclock, setclock.complete);
    this.set_page_title(setclock, setclock.title);
    this.set_page_type(setclock, setclock.page_type);

    var choosetarget = new ChooseTargetPage(timer);
    this.append_page(choosetarget);
    this.set_page_complete(choosetarget, choosetarget.complete);
    this.set_page_title(choosetarget, choosetarget.title);
    this.set_page_type(choosetarget, choosetarget.page_type);

    var conclude = new ConcludePage(timer);
    this.append_page(conclude);
    this.set_page_complete(conclude, true);
    this.set_page_title(conclude, "Done!");
    this.set_page_type(conclude, Gtk.AssistantPageType.SUMMARY);
    //on_target();

    this.cancel.connect(() => {Gtk.main_quit();});
    this.close.connect(() => {timer.start(); this.hide();});

    this.prepare.connect(choosetarget.prepare_buttons);
    this.prepare.connect(conclude.prepare_message);
  }
  private SleepTimer timer;

}
