//using Gee; //Should try using GList to minimize dependencies

/*
 * OK, here's how to use this class.
 * You first get a new instance of it with a desired wake_up_time (this
 * should be in the local timezone). Then the constructor will calculate
 * possible times at which you should go to bed using _set_sleep_targets().
 * You can see that list with the sleep_targets property. When you feel
 * you're on the target choose_target(int target_number), target_number
 * is counted from 1 which is the target closest to "now".
 *
 * Signals :
 * - on_target is emitted when current_target is reached
 * - wake_up_time_changed is emitted when wake_up_time is changed, effectively
 * creating a new timer
 * - on_minute is emitted every minute
 *
 */

//TODO: add custom notification message/presets
class SleepTimer
{

  public SleepTimer(DateTime wake_up_time)
  {
    this.wake_up_time = wake_up_time;
    _set_sleep_targets();
  }
  
  public void set_new_wake_up_time(DateTime new_wake_up_time)
  requires (new_wake_up_time.difference(new DateTime.now_local()) > 6300000 ) //90 mins + 15 mins
  {
    stop();
    this.wake_up_time = new_wake_up_time;
    _set_sleep_targets();
  }
  public void choose_target(int target_number)   //0,1,2
  {
    current_target = sleep_targets.index(target_number);
  }

  public void start()
  {
    if ((current_target != null) && !running)
      {
        //print("Timer started\n");
        running = true;
        Timeout.add_seconds(60,every_minute);
        started();
      }
  }

  public void stop()
  {
    running = false;
  }

  //TODO: Notify time left at 1/2, 1/4,1/8 timespan
  private bool every_minute()
  {
    //print("new minute\n");
    on_minute();
    //alarm();
    var now = new DateTime.now_local();
    if (current_target.difference(now) <= 0)
      {
        on_target();
        //alarm();
        current_target = get_next_sleep_target();
        sleep_targets.remove_index(0);
      }
    return running;
  }

  //TODO: Add some safety measures

  private void _set_sleep_targets()
  {
    var now = new DateTime.now_local();
    sleep_targets = new Array<DateTime> ();
    now = now.add_minutes(+15); // time to get to sleep
    //wake_up_time = wake_up_time.add_minutes(-15);
    var target = wake_up_time.add_minutes(-SLEEP_CYCLE_LENGTH);
    while (target.difference(now) > 0)
      {
        sleep_targets.prepend_val(target);
        target = target.add_minutes(-SLEEP_CYCLE_LENGTH);
      }

    //print("%d\n",sleep_targets.size);
  }

  public DateTime? get_next_sleep_target()
  {
    if (sleep_targets.length > 1)
      {
        return sleep_targets.index(1);
      }
    else return null;
  }

  public string time_left_to_string()
  {
    int minutes = minutes_left();
    int hours = minutes / 60;
    minutes = minutes - hours*60;
    string left = ngettext("%lld hour", "%lld hours",(ulong)hours).printf(hours) + " " +
                  ngettext("%lld minute", "%lld minutes",(ulong)hours).printf(minutes);
    return left;
  }
  public int minutes_left()
  {
    var now = new DateTime.now_local();
    int seconds_left = (int) ( current_target.to_unix() - now.to_unix() );
    int minutes = seconds_left/60;
    minutes += (seconds_left - minutes*60) >= 30 ? 1:0;
    return minutes;
  }
  public signal void on_minute();
  public signal void on_target();
  public signal void started();

  public unowned DateTime wake_up_time
  {
    get;
    private set;
  }
  public Array<DateTime> sleep_targets;

  public DateTime current_target
  {
    get;
    private set;
  }
  public bool running
  {
    get;
    private set;
  default=false;
  }
  private const int SLEEP_CYCLE_LENGTH = 90;

}
